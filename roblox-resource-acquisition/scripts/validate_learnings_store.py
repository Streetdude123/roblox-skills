#!/usr/bin/env python3
"""Validate external Roblox learnings-store entries.

This is a structural validator only. Passing does not establish that any
recorded observation is true or still current, and it never grants trust or
verification status to anything.

The script prefers PyYAML when available but includes a deliberately small
fallback parser for the flat schema shipped by this skill, so validation does
not require an extra package in ordinary environments.
"""
from __future__ import annotations

import argparse
import ipaddress
import json
import re
from datetime import date
from pathlib import Path
from typing import Any
from urllib.parse import parse_qsl, urlparse

try:  # Optional convenience, not a runtime requirement.
    import yaml  # type: ignore
except Exception:  # pragma: no cover - environment dependent
    yaml = None


if yaml is not None:
    class UniqueKeyLoader(yaml.SafeLoader):
        pass

    def _construct_unique_mapping(loader: Any, node: Any, deep: bool = False) -> dict[Any, Any]:
        mapping: dict[Any, Any] = {}
        for key_node, value_node in node.value:
            key = loader.construct_object(key_node, deep=deep)
            if key in mapping:
                raise yaml.constructor.ConstructorError(
                    "while constructing a mapping",
                    node.start_mark,
                    f"found duplicate key {key!r}",
                    key_node.start_mark,
                )
            mapping[key] = loader.construct_object(value_node, deep=deep)
        return mapping

    UniqueKeyLoader.add_constructor(
        yaml.resolver.BaseResolver.DEFAULT_MAPPING_TAG,
        _construct_unique_mapping,
    )
else:  # pragma: no cover - only used without PyYAML
    UniqueKeyLoader = None

ALLOWED_FIELDS = {
    "schema_version",
    "kind",
    "scope",
    "slug",
    "canonical_url",
    "package_id",
    "observed",
    "statement",
    "evidence",
    "version_context",
    "reconsider_when",
    "task_context",
    "related_entry",
}
REQUIRED_FIELDS = {
    "schema_version",
    "kind",
    "scope",
    "observed",
    "statement",
    "evidence",
}
STRING_FIELDS = ALLOWED_FIELDS - {"schema_version"}

# A learning must stay an observation. These field names indicate an attempt
# to smuggle trust/verification state into the store, which only the curated
# registry (trust) and executed proof (verification) are allowed to carry.
FORBIDDEN_STATE_FIELDS = {
    "trust",
    "trust_level",
    "trust_basis",
    "verification",
    "verification_status",
    "verified",
    "status",
    "resource_proof",
    "skill_validation",
}

KINDS = {
    "integration-gotcha",
    "failed-query",
    "version-drift",
    "environment-blocker",
    "rejection",
    "repair-outcome",
}
SCOPES = {"resource", "search", "environment"}

# Kind/scope compatibility. Resource-bound kinds must carry canonical
# identity; query observations must not, so learnings cannot silently attach
# to a resource by accident.
KIND_SCOPE_RULES: dict[str, set[str]] = {
    "integration-gotcha": {"resource"},
    "version-drift": {"resource"},
    "rejection": {"resource"},
    "repair-outcome": {"resource"},
    "failed-query": {"search"},
    "environment-blocker": {"resource", "environment"},
}

# Fields that must be non-empty for specific kinds. A rejection without a
# reopen condition becomes a permanent silent blacklist, which the store's
# contract forbids.
KIND_REQUIRED_FIELDS: dict[str, set[str]] = {
    "version-drift": {"version_context"},
    "rejection": {"version_context", "reconsider_when"},
}

# No LIST_FIELDS: every field in this schema is a top-level scalar. The
# fallback parser fails closed on indented list syntax as a result.
LIST_FIELDS: frozenset[str] = frozenset()

SLUG_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")

SENSITIVE_QUERY_RE = re.compile(
    r"(?:"
    r"(?:^|[_-])(?:access[_-]?key|api[_-]?key|auth(?:orization)?|credential|password|passwd|secret|signature|sig|token)(?:$|[_-])"
    r"|(?:api|access|auth|client|private|refresh|session|bearer)[_-]?(?:token|key|secret|credential)(?:$|[_-])"
    r"|secret[_-]?key(?:$|[_-])"
    r")",
    re.I,
)


class MiniYamlError(ValueError):
    pass


def strip_comment(line: str) -> str:
    """Strip # comments outside simple single/double quotes."""
    out: list[str] = []
    quote: str | None = None
    escaped = False
    for ch in line:
        if escaped:
            out.append(ch)
            escaped = False
            continue
        if ch == "\\" and quote == '"':
            out.append(ch)
            escaped = True
            continue
        if quote:
            out.append(ch)
            if ch == quote:
                quote = None
            continue
        if ch in {"'", '"'}:
            quote = ch
            out.append(ch)
            continue
        # In a YAML plain scalar, ``#`` starts a comment only when it is
        # separated from the value (or begins the line). Preserve embedded
        # fragments such as ``https://example.test/page#section`` so the
        # fallback parser cannot silently discard identity-relevant URL data.
        if ch == "#" and (not out or out[-1].isspace()):
            break
        out.append(ch)
    return "".join(out).rstrip()


def split_inline_list(raw: str) -> list[str]:
    """Split a simple YAML flow sequence without supporting nested structures."""
    items: list[str] = []
    current: list[str] = []
    quote: str | None = None
    escaped = False
    for ch in raw:
        if escaped:
            current.append(ch)
            escaped = False
            continue
        if ch == "\\" and quote == '"':
            current.append(ch)
            escaped = True
            continue
        if quote:
            current.append(ch)
            if ch == quote:
                quote = None
            continue
        if ch in {"'", '"'}:
            quote = ch
            current.append(ch)
            continue
        if ch == ",":
            item = "".join(current).strip()
            if not item:
                raise MiniYamlError("empty item in inline list")
            items.append(item)
            current = []
            continue
        if ch in "[]{}":
            raise MiniYamlError("nested inline collections are not supported")
        current.append(ch)
    if quote:
        raise MiniYamlError("unterminated quote in inline list")
    item = "".join(current).strip()
    if item:
        items.append(item)
    elif raw.strip():
        raise MiniYamlError("empty trailing item in inline list")
    return items


def parse_scalar(raw: str) -> Any:
    raw = raw.strip()
    if raw == "":
        return ""
    if raw == "[]":
        return []

    # Fail closed on collection/quote syntax that this fallback cannot parse.
    # A learning must never be consumed merely because malformed YAML happened
    # to look like a bare string in the dependency-free parser.
    if raw.startswith("[") or raw.endswith("]"):
        if not (raw.startswith("[") and raw.endswith("]")):
            raise MiniYamlError("unterminated inline list")
        inner = raw[1:-1].strip()
        if not inner:
            return []
        return [parse_scalar(item) for item in split_inline_list(inner)]
    if raw.startswith("{") or raw.endswith("}"):
        raise MiniYamlError("inline mappings are not supported by this schema")

    if raw.startswith('"'):
        if not raw.endswith('"') or len(raw) < 2:
            raise MiniYamlError("unterminated double-quoted string")
        try:
            return json.loads(raw)
        except json.JSONDecodeError as exc:
            raise MiniYamlError(f"invalid double-quoted string: {exc.msg}") from exc
    if raw.startswith("'"):
        if not raw.endswith("'") or len(raw) < 2:
            raise MiniYamlError("unterminated single-quoted string")
        # YAML single-quoted strings escape a quote by doubling it.
        return raw[1:-1].replace("''", "'")

    # In YAML, an unquoted colon followed by whitespace starts mapping syntax.
    # Nested mappings are outside this flat schema, so reject rather than
    # misclassifying them as valid string content.
    if re.search(r":\s", raw):
        raise MiniYamlError("nested mapping syntax is not supported by this schema")

    lowered = raw.lower()
    if lowered in {"true", "yes", "on"}:
        return True
    if lowered in {"false", "no", "off"}:
        return False
    if lowered in {"null", "~"}:
        return None
    if lowered in {".inf", "+.inf"}:
        return float("inf")
    if lowered == "-.inf":
        return float("-inf")
    if lowered == ".nan":
        return float("nan")
    if re.fullmatch(r"[-+]?0b[01_]+", raw, re.I):
        sign = -1 if raw.startswith("-") else 1
        digits = raw.lstrip("+-")[2:].replace("_", "")
        return sign * int(digits, 2)
    if re.fullmatch(r"[-+]?0x[0-9a-f_]+", raw, re.I):
        sign = -1 if raw.startswith("-") else 1
        digits = raw.lstrip("+-")[2:].replace("_", "")
        return sign * int(digits, 16)
    if re.fullmatch(r"[-+]?[0-9][0-9_]*", raw):
        return int(raw.replace("_", ""), 10)
    if re.fullmatch(r"[-+]?\d+(?::[0-5]?\d)+", raw):
        # PyYAML resolves sexagesimal integer syntax; only the resulting type
        # matters to this schema validator.
        return 0
    if re.fullmatch(r"[-+]?(?:\d[\d_]*\.[\d_]*|[\d_]*\.[\d_]+)(?:[eE][-+]?\d+)?", raw):
        return float(raw.replace("_", ""))
    if re.fullmatch(r"\d{4}-\d{2}-\d{2}", raw):
        try:
            return date.fromisoformat(raw)
        except ValueError:
            pass
    if re.match(r"^\d{4}-\d{2}-\d{2}(?:[Tt]|[ \t]+)\d{1,2}:\d{2}", raw):
        raise MiniYamlError("timestamp scalars are not supported; quote string values explicitly")
    # Bare strings are valid for this intentionally small schema.
    return raw


def parse_flat_yaml_fallback(text: str) -> dict[str, Any]:
    """Parse only the top-level scalar schema used by learning entries."""
    data: dict[str, Any] = {}
    current_list: str | None = None
    for lineno, raw_line in enumerate(text.splitlines(), 1):
        if not raw_line.strip() or raw_line.lstrip().startswith("#"):
            continue
        line = strip_comment(raw_line)
        if not line.strip():
            continue

        indent = len(line) - len(line.lstrip(" "))
        stripped = line.strip()
        if indent:
            if current_list is None or not stripped.startswith("-"):
                raise MiniYamlError(f"line {lineno}: nested mappings are not supported by this schema")
            item = stripped[1:].strip()
            if not item:
                raise MiniYamlError(f"line {lineno}: empty list item")
            data[current_list].append(parse_scalar(item))
            continue

        current_list = None
        if ":" not in stripped:
            raise MiniYamlError(f"line {lineno}: expected 'key: value'")
        key, raw_value = stripped.split(":", 1)
        key = key.strip()
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_-]*", key):
            raise MiniYamlError(f"line {lineno}: invalid key {key!r}")
        if key in data:
            raise MiniYamlError(f"line {lineno}: duplicate key {key!r}")
        value = parse_scalar(raw_value)
        data[key] = value
        if value == "" and key in LIST_FIELDS:
            data[key] = []
            current_list = key
    if isinstance(data.get("observed"), date):
        data["observed"] = data["observed"].isoformat()
    return data


def load_entry(path: Path) -> dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    if yaml is not None:
        try:
            loaded = yaml.load(text, Loader=UniqueKeyLoader)
        except Exception as exc:
            raise ValueError(f"invalid YAML: {exc}") from exc
        if loaded is None:
            return {}
        if not isinstance(loaded, dict):
            raise ValueError("top-level YAML value must be a mapping")
        # PyYAML resolves an unquoted ISO date to datetime.date. Accept that
        # natural YAML spelling and normalize it to the schema's string form.
        if isinstance(loaded.get("observed"), date):
            loaded["observed"] = loaded["observed"].isoformat()
        return loaded
    try:
        return parse_flat_yaml_fallback(text)
    except MiniYamlError as exc:
        raise ValueError(f"invalid supported YAML subset: {exc}") from exc


def validated_url_host(parsed) -> str | None:
    """Return a normalized hostname when URL authority syntax is valid."""
    try:
        host = parsed.hostname
        # Accessing .port validates its numeric/range syntax.
        _ = parsed.port
    except ValueError:
        return None
    if not host or re.search(r"[\s\x00-\x1f\x7f]", host) or "%" in host:
        return None
    host = host.rstrip(".")
    if not host:
        return None
    if ":" in host:
        try:
            ipaddress.ip_address(host)
        except ValueError:
            return None
        return host.lower()
    try:
        ascii_host = host.encode("idna").decode("ascii")
    except UnicodeError:
        return None
    if len(ascii_host) > 253:
        return None
    labels = ascii_host.split(".")
    if any(
        not label
        or len(label) > 63
        or label.startswith("-")
        or label.endswith("-")
        or not re.fullmatch(r"[A-Za-z0-9-]+", label)
        for label in labels
    ):
        return None
    return ascii_host.lower()


def validate_https_url(value: str, *, field: str) -> list[str]:
    errors: list[str] = []
    try:
        parsed = urlparse(value)
    except Exception:
        return [f"{field} is not a valid URL"]
    if parsed.scheme != "https" or not parsed.netloc:
        errors.append(f"{field} must be an absolute https:// URL")
    host = validated_url_host(parsed)
    if parsed.netloc and host is None:
        errors.append(f"{field} has an invalid URL host or port")
    if parsed.username or parsed.password:
        errors.append(f"{field} must not contain embedded credentials")
    for component_name, component in (("query", parsed.query), ("fragment", parsed.fragment)):
        for key, _ in parse_qsl(component, keep_blank_values=True):
            if SENSITIVE_QUERY_RE.search(key):
                errors.append(
                    f"{field} must not contain credential-like {component_name} parameter {key!r}"
                )
    return errors


def nonempty(data: dict[str, Any], field: str) -> bool:
    value = data.get(field)
    return isinstance(value, str) and bool(value.strip())


# Advisory only. Learnings are observations, and the consumption contract in
# references/learnings-store.md already requires directives inside a statement
# to be disregarded; this pattern merely surfaces entries that read as
# instructions so a human notices the side-channel attempt or rephrases the
# fact. Warnings never fail validation and never affect trust or verification.
# Anchored to statement-initial imperatives plus explicit policy-override
# phrases so factual uses of always/never ("Fire never clones payloads") do
# not warn.
DIRECTIVE_STATEMENT_RE = re.compile(
    r"(?:^\s*(?:always|never|ignore|skip|do not|don't|disable|bypass)\b"
    r"|\b(?:in|for)\s+(?:all\s+)?future\s+runs\b"
    r"|\bfrom\s+now\s+on\b"
    r"|\bignore\s+the\s+(?:repair\s+)?budget\b"
    r"|\b(?:skip|bypass|disable)\s+(?:runtime\s+|resource\s+)?verification\b)",
    re.I,
)


def entry_warnings(data: dict[str, Any]) -> list[str]:
    warnings: list[str] = []
    statement = data.get("statement")
    if isinstance(statement, str) and statement.strip():
        if DIRECTIVE_STATEMENT_RE.search(statement.strip()):
            warnings.append(
                "statement reads as an imperative directive; learnings are "
                "observations, so record the fact (what happened/holds), not an "
                "instruction (what to always/never do) — consumers must "
                "disregard directives per references/learnings-store.md"
            )
    return warnings


def validate_entry(path: Path, data: dict[str, Any]) -> list[str]:
    errors: list[str] = []

    forbidden = sorted(set(data) & FORBIDDEN_STATE_FIELDS)
    if forbidden:
        errors.append(
            "learning entries must not carry trust or verification state; "
            "remove field(s): " + ", ".join(forbidden)
        )
    unknown = sorted(set(data) - ALLOWED_FIELDS - FORBIDDEN_STATE_FIELDS)
    if unknown:
        errors.append("unknown field(s): " + ", ".join(unknown))
    missing = sorted(field for field in REQUIRED_FIELDS if field not in data)
    if missing:
        errors.append("missing required field(s): " + ", ".join(missing))

    if data.get("schema_version") != 1:
        errors.append("schema_version must be integer 1")

    for field in STRING_FIELDS:
        if field in data and not isinstance(data[field], str):
            errors.append(f"{field} must be a string")

    kind = data.get("kind")
    if isinstance(kind, str) and kind:
        if kind not in KINDS:
            errors.append("kind must be one of: " + ", ".join(sorted(KINDS)))
    elif isinstance(kind, str):
        errors.append("kind must not be empty")

    scope = data.get("scope")
    if isinstance(scope, str) and scope:
        if scope not in SCOPES:
            errors.append("scope must be one of: " + ", ".join(sorted(SCOPES)))
    elif isinstance(scope, str):
        errors.append("scope must not be empty")

    if isinstance(kind, str) and kind in KIND_SCOPE_RULES and isinstance(scope, str) and scope in SCOPES:
        allowed_scopes = KIND_SCOPE_RULES[kind]
        if scope not in allowed_scopes:
            errors.append(
                f"kind {kind!r} requires scope " + " or ".join(sorted(allowed_scopes))
            )

    slug = data.get("slug")
    canonical = data.get("canonical_url")
    package_id = data.get("package_id")
    if isinstance(scope, str) and scope == "resource":
        if not nonempty(data, "slug"):
            errors.append("resource-scoped entries require a non-empty slug")
        elif isinstance(slug, str) and not SLUG_RE.fullmatch(slug):
            errors.append("slug must be lowercase kebab-case (a-z, 0-9, hyphen)")
        if not nonempty(data, "canonical_url"):
            errors.append("resource-scoped entries require canonical_url; learnings bind to canonical identity, not display names")
        elif isinstance(canonical, str):
            errors.extend(validate_https_url(canonical.strip(), field="canonical_url"))
    elif isinstance(scope, str) and scope in SCOPES:
        for field in ("slug", "canonical_url", "package_id"):
            if nonempty(data, field):
                errors.append(f"{field} must be empty when scope is {scope!r}")

    if isinstance(package_id, str) and ("\n" in package_id or "\r" in package_id):
        errors.append("package_id must be a single-line exact identifier")

    observed = data.get("observed")
    if isinstance(observed, str):
        if not observed.strip():
            errors.append("observed must not be empty")
        elif observed == "YYYY-MM-DD":
            errors.append("observed still contains the template placeholder YYYY-MM-DD; set a real date")
        else:
            try:
                parsed_date = date.fromisoformat(observed)
                if parsed_date > date.today():
                    errors.append("observed cannot be in the future")
            except ValueError:
                errors.append("observed must be YYYY-MM-DD")

    for field in ("statement", "evidence"):
        if field in data and isinstance(data[field], str) and not data[field].strip():
            errors.append(f"{field} must not be empty")

    if isinstance(kind, str) and kind in KIND_REQUIRED_FIELDS:
        for field in sorted(KIND_REQUIRED_FIELDS[kind]):
            if not nonempty(data, field):
                errors.append(f"kind {kind!r} requires non-empty {field}")

    return errors


def collect_files(path: Path) -> list[Path]:
    if path.is_file():
        if path.suffix.lower() not in {".yaml", ".yml"}:
            raise ValueError(f"{path}: expected .yaml or .yml file")
        return [path]
    if path.is_dir():
        return sorted(
            p for p in path.iterdir()
            if p.is_file() and p.suffix.lower() in {".yaml", ".yml"} and not p.name.startswith(".")
        )
    raise ValueError(f"{path}: path does not exist")


def main() -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Validate learnings-store entry structure. Entries from all supplied "
            "stores merge; order carries no precedence."
        )
    )
    parser.add_argument(
        "store",
        nargs="+",
        type=Path,
        help="Learnings-store directory or entry file.",
    )
    args = parser.parse_args()

    overall_errors = 0
    overall_warnings = 0

    for store_path in args.store:
        try:
            files = collect_files(store_path)
        except ValueError as exc:
            print(f"ERROR: {exc}")
            overall_errors += 1
            continue

        if not files:
            print(f"NOTE: {store_path}: no .yaml/.yml entries found")
            continue

        for file_path in files:
            try:
                data = load_entry(file_path)
            except (OSError, UnicodeError, ValueError) as exc:
                print(f"ERROR: {file_path}: {exc}")
                overall_errors += 1
                continue

            errors = validate_entry(file_path, data)
            warnings = entry_warnings(data)
            if errors:
                for error in errors:
                    print(f"ERROR: {file_path}: {error}")
                overall_errors += len(errors)
            else:
                print(f"PASS: {file_path}")
            for warning in warnings:
                print(f"WARN: {file_path}: {warning}")
            overall_warnings += len(warnings)

    if overall_errors:
        print(f"FAIL: learnings-store validation found {overall_errors} error(s)")
        return 1

    print(
        "PASS: learnings-store structural checks passed\n"
        "NOTE: this does not establish that any observation is true or current, "
        "and it never grants trust or verification"
    )
    if overall_warnings:
        print(
            f"NOTE: {overall_warnings} advisory warning(s) above; warnings never "
            "fail validation and never affect trust or verification"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

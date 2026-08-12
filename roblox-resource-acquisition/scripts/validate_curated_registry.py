#!/usr/bin/env python3
"""Validate external curated Roblox resource registry entries.

This is a structural/identity validator only. Passing does not establish that a
resource is good, safe, maintained, compatible, or runtime-correct.

The script prefers PyYAML when available but includes a deliberately small
fallback parser for the flat schema shipped by this skill, so validation does
not require an extra package in ordinary environments.
"""
from __future__ import annotations

import argparse
import ipaddress
import json
import re
from collections import defaultdict
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
    "slug",
    "name",
    "capabilities",
    "use_when",
    "avoid_when",
    "canonical_url",
    "package_id",
    "install_hint",
    "devforum_url",
    "curation_reason",
    "last_reviewed",
    "notes",
}
REQUIRED_FIELDS = {
    "schema_version",
    "slug",
    "name",
    "capabilities",
    "use_when",
    "canonical_url",
    "curation_reason",
}
LIST_FIELDS = {"capabilities", "use_when", "avoid_when", "notes"}
STRING_FIELDS = {
    "slug",
    "name",
    "canonical_url",
    "package_id",
    "install_hint",
    "devforum_url",
    "curation_reason",
    "last_reviewed",
}
SLUG_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
DEVFORUM_TOPIC_PATH_RE = re.compile(r"/t/(?:[^/]+/)?\d+(?:/\d+)?/?")

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
        # fallback parser cannot silently discard security-relevant URL data.
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
    # A curated entry must never become trusted merely because malformed YAML
    # happened to look like a bare string in the dependency-free parser.
    if raw.startswith("[") or raw.endswith("]"):
        if not (raw.startswith("[") and raw.endswith("]")):
            raise MiniYamlError("unterminated inline list")
        inner = raw[1:-1].strip()
        if not inner:
            return []
        return [parse_scalar(item) for item in split_inline_list(inner)]
    if raw.startswith("{") or raw.endswith("}"):
        raise MiniYamlError("inline mappings are not supported by this schema")

    if raw.startswith('\"'):
        if not raw.endswith('\"') or len(raw) < 2:
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
    # misclassifying them as trusted string content.
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
    """Parse only the top-level scalar/list schema used by curated entries."""
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
    if isinstance(data.get("last_reviewed"), date):
        data["last_reviewed"] = data["last_reviewed"].isoformat()
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
        if isinstance(loaded.get("last_reviewed"), date):
            loaded["last_reviewed"] = loaded["last_reviewed"].isoformat()
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


def validate_https_url(value: str, *, field: str, expected_host: str | None = None) -> list[str]:
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
    if expected_host and host and host != expected_host:
        errors.append(f"{field} must use host {expected_host}")
    for component_name, component in (("query", parsed.query), ("fragment", parsed.fragment)):
        for key, _ in parse_qsl(component, keep_blank_values=True):
            if SENSITIVE_QUERY_RE.search(key):
                errors.append(
                    f"{field} must not contain credential-like {component_name} parameter {key!r}"
                )
    return errors


def validate_entry(path: Path, data: dict[str, Any]) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    notes: list[str] = []

    unknown = sorted(set(data) - ALLOWED_FIELDS)
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

    for field in LIST_FIELDS:
        value = data.get(field, [])
        if not isinstance(value, list):
            errors.append(f"{field} must be a list")
            continue
        bad = [item for item in value if not isinstance(item, str) or not item.strip()]
        if bad:
            errors.append(f"{field} must contain only non-empty strings")

    slug = data.get("slug")
    if isinstance(slug, str):
        if not slug:
            errors.append("slug must not be empty")
        elif not SLUG_RE.fullmatch(slug):
            errors.append("slug must be lowercase kebab-case (a-z, 0-9, hyphen)")

    name = data.get("name")
    if isinstance(name, str) and not name.strip():
        errors.append("name must not be empty")

    capabilities = data.get("capabilities")
    if isinstance(capabilities, list) and not capabilities:
        errors.append("capabilities must contain at least one item")

    use_when = data.get("use_when")
    if isinstance(use_when, list) and not use_when:
        errors.append("use_when must contain at least one item")

    reason = data.get("curation_reason")
    if isinstance(reason, str) and not reason.strip():
        errors.append("curation_reason must not be empty")

    canonical = data.get("canonical_url")
    if isinstance(canonical, str):
        if not canonical.strip():
            errors.append("canonical_url must not be empty")
        else:
            errors.extend(validate_https_url(canonical.strip(), field="canonical_url"))

    devforum = data.get("devforum_url")
    if isinstance(devforum, str) and devforum.strip():
        devforum_value = devforum.strip()
        errors.extend(validate_https_url(devforum_value, field="devforum_url", expected_host="devforum.roblox.com"))
        try:
            parsed_devforum = urlparse(devforum_value)
        except ValueError:
            parsed_devforum = None
        if parsed_devforum is not None and validated_url_host(parsed_devforum) == "devforum.roblox.com":
            if not DEVFORUM_TOPIC_PATH_RE.fullmatch(parsed_devforum.path):
                errors.append("devforum_url must identify a specific DevForum topic, not a category/home/search page")

    reviewed = data.get("last_reviewed")
    if isinstance(reviewed, str) and reviewed.strip():
        if reviewed == "YYYY-MM-DD":
            errors.append("last_reviewed still contains the template placeholder YYYY-MM-DD; set a real date or empty string")
        else:
            try:
                parsed_date = date.fromisoformat(reviewed)
                if parsed_date > date.today():
                    errors.append("last_reviewed cannot be in the future")
            except ValueError:
                errors.append("last_reviewed must be YYYY-MM-DD or empty")

    package_id = data.get("package_id")
    if isinstance(package_id, str) and ("\n" in package_id or "\r" in package_id):
        errors.append("package_id must be a single-line exact identifier")

    if path.stem != slug and isinstance(slug, str) and slug:
        notes.append(f"filename {path.name!r} differs from slug {slug!r}; slug remains authoritative")

    return errors, notes


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
        description="Validate curated Roblox resource registry structure and canonical identity."
    )
    parser.add_argument(
        "registry",
        nargs="+",
        type=Path,
        help="Registry directory or entry file. For multiple registries, pass highest precedence first.",
    )
    args = parser.parse_args()

    overall_errors = 0
    all_entries: list[tuple[int, Path, dict[str, Any]]] = []

    for registry_index, registry_path in enumerate(args.registry):
        try:
            files = collect_files(registry_path)
        except ValueError as exc:
            print(f"ERROR: {exc}")
            overall_errors += 1
            continue

        if not files:
            print(f"NOTE: {registry_path}: no .yaml/.yml entries found")
            continue

        results: list[dict[str, Any]] = []
        slug_to_results: dict[str, list[dict[str, Any]]] = defaultdict(list)

        for file_path in files:
            try:
                data = load_entry(file_path)
            except (OSError, UnicodeError, ValueError) as exc:
                results.append({"path": file_path, "data": {}, "errors": [str(exc)], "notes": []})
                continue

            errors, notes = validate_entry(file_path, data)
            result = {"path": file_path, "data": data, "errors": errors, "notes": notes}
            results.append(result)
            slug = data.get("slug")
            if isinstance(slug, str) and slug:
                slug_to_results[slug].append(result)

        # Same-registry duplicates are ambiguous. Mark every duplicate entry as
        # invalid so no arbitrary file appears to have earned trust.
        for slug, dupes in slug_to_results.items():
            if len(dupes) > 1:
                paths = ", ".join(str(item["path"]) for item in dupes)
                for item in dupes:
                    item["errors"].append(
                        f"duplicate slug {slug!r} in same registry; conflicting entries: {paths}"
                    )

        for result in results:
            file_path = result["path"]
            errors = result["errors"]
            notes = result["notes"]
            if errors:
                for error in errors:
                    print(f"ERROR: {file_path}: {error}")
                overall_errors += len(errors)
            else:
                print(f"PASS: {file_path}")
                all_entries.append((registry_index, file_path, result["data"]))
            for note in notes:
                print(f"NOTE: {file_path}: {note}")

    by_slug: dict[str, list[tuple[int, Path]]] = defaultdict(list)
    for registry_index, path, data in all_entries:
        slug = data.get("slug")
        if isinstance(slug, str) and slug:
            by_slug[slug].append((registry_index, path))

    for slug, occurrences in sorted(by_slug.items()):
        registry_ids = {idx for idx, _ in occurrences}
        if len(registry_ids) > 1:
            winner = min(occurrences, key=lambda pair: pair[0])
            overridden = [str(path) for idx, path in occurrences if (idx, path) != winner]
            print(
                f"NOTE: slug {slug!r} appears across registries; highest-precedence entry is {winner[1]}; "
                f"overrides: {', '.join(overridden)}"
            )

    if overall_errors:
        print(f"FAIL: curated registry validation found {overall_errors} error(s)")
        return 1

    print(
        "PASS: curated registry structural/identity checks passed\n"
        "NOTE: this does not establish quality, safety, maintenance, compatibility, or runtime correctness"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

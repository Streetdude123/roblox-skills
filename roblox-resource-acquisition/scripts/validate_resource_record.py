#!/usr/bin/env python3
"""Validate portable Roblox resource evidence records.

This is a structural and state-consistency validator. Passing does not establish
that the resource, source claims, or generated skill are actually correct.

PyYAML is used when available. A small dependency-free fallback parser supports
the schema emitted by templates/resource-record.yaml, including its nested maps
and string lists.
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

TOP_LEVEL_FIELDS = {
    "resource",
    "slug",
    "discovery_origin",
    "trust",
    "canonical_url",
    "package_id",
    "verification",
    "capability",
    "devforum_url",
    "selection_reason",
    "alternatives_considered",
    "resource_proof",
    "generated_skill",
    "skill_validation",
    "limitations",
    "blocked_use_or_version",
    "rejection_reason",
    "reconsider_when",
}
REQUIRED_TOP_LEVEL_FIELDS = TOP_LEVEL_FIELDS
NESTED_FIELDS = {
    "trust": {"level", "basis", "reason"},
    "verification": {"status", "validated_at", "version_or_commit"},
    "resource_proof": {"executed", "passed", "environment", "result", "unavailable_claims"},
    "skill_validation": {
        "structural_passed",
        "independent_behavioral_executed",
        "independent_behavioral_passed",
        "environment",
        "result",
    },
}
LIST_FIELDS = {
    "alternatives_considered",
    "limitations",
    "resource_proof.unavailable_claims",
}
BOOL_FIELDS = {
    "resource_proof.executed",
    "resource_proof.passed",
    "skill_validation.structural_passed",
    "skill_validation.independent_behavioral_executed",
    "skill_validation.independent_behavioral_passed",
}
STRING_FIELDS = {
    "resource",
    "slug",
    "discovery_origin",
    "canonical_url",
    "package_id",
    "capability",
    "devforum_url",
    "selection_reason",
    "generated_skill",
    "blocked_use_or_version",
    "rejection_reason",
    "reconsider_when",
    "trust.level",
    "trust.basis",
    "trust.reason",
    "verification.status",
    "verification.validated_at",
    "verification.version_or_commit",
    "resource_proof.environment",
    "resource_proof.result",
    "skill_validation.environment",
    "skill_validation.result",
}
ALLOWED_ORIGINS = {"curated", "project", "devforum", "other"}
ALLOWED_TRUST_LEVELS = {"trusted", "untrusted"}
ALLOWED_TRUST_BASES = {"", "curated", "verified-acquisition", "project", "explicit-user", "other"}
ALLOWED_VERIFICATION = {"unverified", "unavailable", "verified", "failed"}
SLUG_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
VOLATILE_VERSION_TOKEN_RE = re.compile(
    r"\b(?:latest|current|stable|head|main|master|trunk|nightly|rolling|dev|development)\b",
    re.I,
)

IMMUTABLE_VERSION_ID_RE = re.compile(
    r"(?:"
    r"\bv\d+(?:(?:[._-]\d+)+(?:[-+][0-9A-Za-z.-]+)?)?\b"
    r"|\b\d+(?:[._-]\d+)+(?:[-+][0-9A-Za-z.-]+)?\b"
    r"|\b[0-9a-f]{7,64}\b"
    r")",
    re.I,
)

EXPLICIT_IMMUTABLE_REF_RE = re.compile(
    r"\b(?:tag|release|version|commit|revision|rev|build|asset version)\b"
    r"\s*(?:[:=#@]|is\b)?\s*([A-Za-z0-9][A-Za-z0-9._/-]{0,127})\b",
    re.I,
)

SOURCE_STATE_DATE_RE = re.compile(r"\b\d{4}-\d{2}-\d{2}\b")

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
    if raw.startswith("[") or raw.endswith("]"):
        if not (raw.startswith("[") and raw.endswith("]")):
            raise MiniYamlError("unterminated inline list")
        inner = raw[1:-1].strip()
        if not inner:
            return []
        return [parse_scalar(item) for item in split_inline_list(inner)]
    if raw.startswith("{") or raw.endswith("}"):
        raise MiniYamlError("inline maps are not supported")
    if raw[0:1] in {"'", '"'} or raw[-1:] in {"'", '"'}:
        if len(raw) < 2 or raw[0] != raw[-1] or raw[0] not in {"'", '"'}:
            raise MiniYamlError("unterminated or mismatched quote")
        if raw[0] == '"':
            # JSON string escaping is a safe subset of YAML double-quoted
            # escaping and correctly handles forms such as \u0023. Reject
            # unsupported escapes rather than silently changing YAML meaning.
            try:
                return json.loads(raw)
            except json.JSONDecodeError as exc:
                raise MiniYamlError(f"invalid double-quoted string: {exc.msg}") from exc
        # YAML single-quoted strings escape a quote by doubling it.
        return raw[1:-1].replace("''", "'")
    # Reject mapping syntax that would not be a plain scalar in YAML.
    if re.search(r":\s", raw):
        raise MiniYamlError("nested mapping syntax is not supported")

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
    return raw


def load_fallback(path: Path) -> dict[str, Any]:
    """Parse the deliberately small resource-record schema without PyYAML."""
    root: dict[str, Any] = {}
    current_map: str | None = None
    current_list: tuple[dict[str, Any], str] | None = None

    for lineno, raw_line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = strip_comment(raw_line)
        if not line.strip():
            continue
        if "\t" in raw_line[: len(raw_line) - len(raw_line.lstrip())]:
            raise MiniYamlError(f"line {lineno}: tabs are not supported for indentation")
        indent = len(line) - len(line.lstrip(" "))
        content = line.strip()

        if indent == 0:
            current_map = None
            current_list = None
            if content.startswith("-"):
                raise MiniYamlError(f"line {lineno}: top-level sequence is not supported")
            if ":" not in content:
                raise MiniYamlError(f"line {lineno}: expected key: value")
            key, raw_value = content.split(":", 1)
            key = key.strip()
            if not key:
                raise MiniYamlError(f"line {lineno}: empty key")
            if key in root:
                raise MiniYamlError(f"line {lineno}: duplicate key {key!r}")
            raw_value = raw_value.strip()
            if raw_value == "":
                if key in NESTED_FIELDS:
                    root[key] = {}
                    current_map = key
                elif key in {"alternatives_considered", "limitations"}:
                    root[key] = []
                    current_list = (root, key)
                else:
                    root[key] = ""
            else:
                root[key] = parse_scalar(raw_value)
            continue

        if indent == 4:
            if current_list is None or not content.startswith("-"):
                raise MiniYamlError(
                    f"line {lineno}: four-space indentation is only supported for nested list items"
                )
            item = content[1:].strip()
            if not item:
                raise MiniYamlError(f"line {lineno}: empty list item")
            current_list[0][current_list[1]].append(parse_scalar(item))
            continue

        if indent != 2:
            raise MiniYamlError(f"line {lineno}: only two-space nested mappings and four-space nested list items are supported")

        if content.startswith("-"):
            if current_list is None:
                raise MiniYamlError(f"line {lineno}: list item appears outside a list field")
            item = content[1:].strip()
            if not item:
                raise MiniYamlError(f"line {lineno}: empty list item")
            current_list[0][current_list[1]].append(parse_scalar(item))
            continue

        if current_map is None:
            raise MiniYamlError(f"line {lineno}: nested mapping appears without a parent map")
        if ":" not in content:
            raise MiniYamlError(f"line {lineno}: expected nested key: value")
        key, raw_value = content.split(":", 1)
        key = key.strip()
        child = root[current_map]
        if not isinstance(child, dict):
            raise MiniYamlError(f"line {lineno}: invalid mapping parent {current_map!r}")
        if key in child:
            raise MiniYamlError(f"line {lineno}: duplicate key {current_map}.{key}")
        raw_value = raw_value.strip()
        if raw_value == "":
            if current_map == "resource_proof" and key == "unavailable_claims":
                child[key] = []
                current_list = (child, key)
            else:
                child[key] = ""
                current_list = None
        else:
            child[key] = parse_scalar(raw_value)
            current_list = None

    verification = root.get("verification")
    if isinstance(verification, dict) and isinstance(verification.get("validated_at"), date):
        verification["validated_at"] = verification["validated_at"].isoformat()
    return root


def load_record(path: Path) -> dict[str, Any]:
    if yaml is not None:
        try:
            loaded = yaml.load(path.read_text(encoding="utf-8"), Loader=UniqueKeyLoader)
        except Exception as exc:
            raise ValueError(f"invalid YAML: {exc}") from exc
        if not isinstance(loaded, dict):
            raise ValueError("record must be a YAML mapping")
        verification = loaded.get("verification")
        if isinstance(verification, dict) and isinstance(verification.get("validated_at"), date):
            verification["validated_at"] = verification["validated_at"].isoformat()
        return loaded
    try:
        return load_fallback(path)
    except MiniYamlError as exc:
        raise ValueError(f"invalid or unsupported YAML: {exc}") from exc


def dotted_get(data: dict[str, Any], dotted: str) -> Any:
    current: Any = data
    for part in dotted.split("."):
        if not isinstance(current, dict) or part not in current:
            return None
        current = current[part]
    return current


def nonempty_string(value: Any) -> bool:
    return isinstance(value, str) and bool(value.strip())


def validated_url_host(parsed: Any) -> str | None:
    """Return a normalized hostname when URL authority syntax is valid."""
    try:
        host = parsed.hostname
        _ = parsed.port  # validates numeric/range syntax
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
    if parsed.scheme.lower() != "https" or not parsed.netloc:
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
                errors.append(f"{field} must not contain credential-like {component_name} parameter {key!r}")
    return errors


def validate_date(value: str, *, field: str) -> list[str]:
    if value == "YYYY-MM-DD":
        return [f"{field} still contains the template placeholder YYYY-MM-DD"]
    try:
        parsed = date.fromisoformat(value)
    except ValueError:
        return [f"{field} must be a real ISO date in YYYY-MM-DD form"]
    if parsed > date.today():
        return [f"{field} cannot be in the future"]
    return []


def has_immutable_version_evidence(value: str) -> bool:
    """Accept an immutable-looking ID, named reference, or valid dated source state."""
    for raw_date in SOURCE_STATE_DATE_RE.findall(value):
        try:
            source_date = date.fromisoformat(raw_date)
        except ValueError:
            continue
        if source_date <= date.today():
            return True

    # Date-shaped tokens can resemble numeric release IDs. Mask them before
    # checking version identifiers so malformed/future dates cannot satisfy a
    # release-number branch by accident.
    without_dates = SOURCE_STATE_DATE_RE.sub(" ", value)
    if IMMUTABLE_VERSION_ID_RE.search(without_dates):
        return True

    explicit = EXPLICIT_IMMUTABLE_REF_RE.search(without_dates)
    if not explicit:
        return False
    identifier = explicit.group(1).strip().lower()
    return identifier not in {
        "latest", "current", "stable", "head", "main", "master", "trunk",
        "nightly", "rolling", "dev", "development", "unknown", "tbd", "none",
        "not", "unavailable", "unspecified", "n/a", "na", "not-available",
        "not_available", "not-applicable", "not_applicable",
    }


def validate_record(path: Path, data: dict[str, Any]) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    notes: list[str] = []

    unknown = sorted(set(data) - TOP_LEVEL_FIELDS)
    missing = sorted(REQUIRED_TOP_LEVEL_FIELDS - set(data))
    if unknown:
        errors.append(f"unknown top-level field(s): {', '.join(unknown)}")
    if missing:
        errors.append(f"missing required top-level field(s): {', '.join(missing)}")

    for parent, allowed in NESTED_FIELDS.items():
        value = data.get(parent)
        if not isinstance(value, dict):
            errors.append(f"{parent} must be a mapping")
            continue
        nested_unknown = sorted(set(value) - allowed)
        nested_missing = sorted(allowed - set(value))
        if nested_unknown:
            errors.append(f"unknown {parent} field(s): {', '.join(nested_unknown)}")
        if nested_missing:
            errors.append(f"missing required {parent} field(s): {', '.join(nested_missing)}")

    for field in STRING_FIELDS:
        value = dotted_get(data, field)
        if value is not None and not isinstance(value, str):
            errors.append(f"{field} must be a string")

    for field in LIST_FIELDS:
        value = dotted_get(data, field)
        if value is None:
            continue
        if not isinstance(value, list):
            errors.append(f"{field} must be a list")
            continue
        if any(not isinstance(item, str) or not item.strip() for item in value):
            errors.append(f"{field} must contain only non-empty strings")

    for field in BOOL_FIELDS:
        value = dotted_get(data, field)
        if value is not None and not isinstance(value, bool):
            errors.append(f"{field} must be true or false")

    resource = data.get("resource")
    if isinstance(resource, str) and not resource.strip():
        errors.append("resource must not be empty")

    slug = data.get("slug")
    if isinstance(slug, str) and slug.strip() and not SLUG_RE.fullmatch(slug.strip()):
        errors.append("slug must be lowercase kebab-case (a-z, 0-9, hyphen) when present")

    origin = data.get("discovery_origin")
    if isinstance(origin, str) and origin not in ALLOWED_ORIGINS:
        errors.append(f"discovery_origin must be one of: {', '.join(sorted(ALLOWED_ORIGINS))}")

    trust_level = dotted_get(data, "trust.level")
    trust_basis = dotted_get(data, "trust.basis")
    trust_reason = dotted_get(data, "trust.reason")
    if isinstance(trust_level, str) and trust_level not in ALLOWED_TRUST_LEVELS:
        errors.append("trust.level must be exactly trusted or untrusted")
    if isinstance(trust_basis, str) and trust_basis not in ALLOWED_TRUST_BASES:
        errors.append("trust.basis must be curated, verified-acquisition, project, explicit-user, other, or empty")
    if trust_level == "trusted":
        if not nonempty_string(trust_basis):
            errors.append("trusted records must name a trust.basis")
        if not nonempty_string(trust_reason):
            errors.append("trusted records must explain trust.reason")
    if trust_basis in {"curated", "verified-acquisition", "project", "explicit-user"} and trust_level != "trusted":
        errors.append(f"trust.basis {trust_basis!r} requires trust.level: trusted")
    if trust_basis == "curated" and origin != "curated":
        errors.append("trust.basis curated requires discovery_origin: curated")
    if trust_basis == "verified-acquisition" and origin == "curated":
        errors.append("verified-acquisition is for previously untrusted discovery, not curated-origin records")

    canonical = data.get("canonical_url")
    if isinstance(canonical, str) and canonical.strip():
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

    status = dotted_get(data, "verification.status")
    validated_at = dotted_get(data, "verification.validated_at")
    version = dotted_get(data, "verification.version_or_commit")
    if isinstance(status, str) and status not in ALLOWED_VERIFICATION:
        errors.append("verification.status must be unverified, unavailable, verified, or failed")
    if isinstance(validated_at, str) and validated_at.strip():
        errors.extend(validate_date(validated_at.strip(), field="verification.validated_at"))
    if status in {"verified", "unavailable", "failed"} and not nonempty_string(validated_at):
        errors.append(f"verification.status {status!r} requires verification.validated_at")
    if status == "verified" and not nonempty_string(version):
        errors.append("verified resource records must name verification.version_or_commit")
    if status == "verified" and isinstance(version, str) and version.strip() and not has_immutable_version_evidence(version):
        errors.append(
            "verified resource records require an immutable version/commit, an explicitly labeled named tag/release/build, or a valid dated source state"
        )
    if isinstance(version, str) and version.strip() and VOLATILE_VERSION_TOKEN_RE.search(version):
        if not has_immutable_version_evidence(version):
            errors.append("verification.version_or_commit must not rely only on a volatile pointer such as latest/current/main")

    proof_executed = dotted_get(data, "resource_proof.executed")
    proof_passed = dotted_get(data, "resource_proof.passed")
    proof_environment = dotted_get(data, "resource_proof.environment")
    proof_result = dotted_get(data, "resource_proof.result")
    unavailable_claims = dotted_get(data, "resource_proof.unavailable_claims")
    if proof_passed is True and proof_executed is not True:
        errors.append("resource_proof.passed cannot be true unless resource_proof.executed is true")
    if proof_executed is True:
        if not nonempty_string(proof_environment):
            errors.append("executed resource proof must record resource_proof.environment")
        if not nonempty_string(proof_result):
            errors.append("executed resource proof must record resource_proof.result")
    if status == "verified":
        if proof_executed is not True or proof_passed is not True:
            errors.append("verification.status verified requires executed and passing resource_proof")
        if isinstance(unavailable_claims, list) and unavailable_claims:
            errors.append("verification.status verified cannot have material resource_proof.unavailable_claims")
    if status == "unavailable":
        if not isinstance(unavailable_claims, list) or not unavailable_claims:
            errors.append("verification.status unavailable requires at least one resource_proof.unavailable_claims entry")
        if proof_passed is True:
            errors.append("verification.status unavailable cannot have resource_proof.passed: true")
    if status == "failed" and proof_passed is True:
        errors.append("verification.status failed cannot have resource_proof.passed: true")
    if proof_passed is True and status not in {"verified"}:
        errors.append("passing overall resource_proof requires verification.status: verified")

    structural = dotted_get(data, "skill_validation.structural_passed")
    independent_executed = dotted_get(data, "skill_validation.independent_behavioral_executed")
    independent_passed = dotted_get(data, "skill_validation.independent_behavioral_passed")
    skill_environment = dotted_get(data, "skill_validation.environment")
    skill_result = dotted_get(data, "skill_validation.result")
    if independent_passed is True and independent_executed is not True:
        errors.append("independent_behavioral_passed cannot be true unless independent_behavioral_executed is true")
    if independent_executed is True:
        if not nonempty_string(skill_environment):
            errors.append("executed independent behavioral validation must record skill_validation.environment")
        if not nonempty_string(skill_result):
            errors.append("executed independent behavioral validation must record skill_validation.result")

    generated_skill = data.get("generated_skill")
    if any(value is True for value in (structural, independent_executed, independent_passed)) and not nonempty_string(generated_skill):
        errors.append("skill validation evidence requires generated_skill to identify the generated skill")

    if trust_basis == "verified-acquisition":
        required_nonempty = {
            "canonical_url": canonical,
            "verification.validated_at": validated_at,
            "verification.version_or_commit": version,
            "generated_skill": generated_skill,
        }
        for field, value in required_nonempty.items():
            if not nonempty_string(value):
                errors.append(f"verified-acquisition requires {field}")
        if status != "verified":
            errors.append("verified-acquisition requires verification.status: verified")
        if proof_executed is not True or proof_passed is not True:
            errors.append("verified-acquisition requires executed and passing resource_proof")
        if structural is not True:
            errors.append("verified-acquisition requires skill_validation.structural_passed: true")
        if independent_executed is not True or independent_passed is not True:
            errors.append("verified-acquisition requires executed and passing independent behavioral skill validation")
        if isinstance(unavailable_claims, list) and unavailable_claims:
            errors.append("verified-acquisition cannot have material resource_proof.unavailable_claims")
        if isinstance(canonical, str) and not canonical.strip():
            errors.append("verified-acquisition requires canonical identity/provenance")

    if trust_basis == "curated":
        if not nonempty_string(slug):
            errors.append("curated records must carry the curated slug")
        if not nonempty_string(canonical):
            errors.append("curated records must carry canonical_url so trust cannot drift to a same-named resource")
        if status == "unverified":
            notes.append("curated + trusted + unverified is valid; curation establishes trust, not runtime verification")

    if status == "failed":
        if trust_basis == "curated" and not nonempty_string(data.get("blocked_use_or_version")):
            errors.append("failed curated records must identify blocked_use_or_version without revoking catalog trust")
        elif trust_level == "untrusted" and not nonempty_string(data.get("rejection_reason")):
            notes.append("failed untrusted record has no rejection_reason yet; acceptable during investigation, but record one before final rejection")

    return errors, notes


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Validate a portable Roblox resource evidence record for structural and trust/verification state consistency."
        )
    )
    parser.add_argument("resource_record", type=Path, help="resource-record YAML file")
    return parser.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    path = args.resource_record.resolve()
    if not path.is_file() or path.suffix.lower() not in {".yaml", ".yml"}:
        print(f"FAIL\n- expected an existing .yaml/.yml resource record: {path}")
        return 1
    try:
        data = load_record(path)
    except (OSError, UnicodeError, ValueError) as exc:
        print(f"FAIL\n- {exc}")
        return 1

    errors, notes = validate_record(path, data)
    if errors:
        print("FAIL")
        for error in errors:
            print(f"- {error}")
        for note in notes:
            print(f"NOTE: {note}")
        return 1

    print("PASS: resource-record structural/state checks passed")
    for note in notes:
        print(f"NOTE: {note}")
    print("NOTE: this does not prove source truth, resource behavior, or generated-skill behavior; it only checks that the recorded state is internally consistent")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

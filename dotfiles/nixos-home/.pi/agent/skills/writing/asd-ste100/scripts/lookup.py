#!/usr/bin/env python3

"""Search the bundled ASD-STE100 Issue 9 reference data."""

import argparse
import json
import re
from collections.abc import Iterable
from pathlib import Path
from typing import Any


DATA_DIR = Path(__file__).parents[1] / "references" / "data"
RULE_FIELDS = {
    "id": "id_",
    "ref": "ref",
    "section": "section",
    "category": "category",
    "name": "name",
    "summary": "summary",
    "content": "contents",
}
WORD_FIELDS = {
    "name": "name",
    "status": "status",
    "type": "type_",
    "category": "category",
    "meaning": "meanings",
    "alternative": "alternatives",
    "example": ("ste_example", "nonste_example"),
    "note": "note",
}


def positive_int(value: str) -> int:
    result = int(value)
    if result < 1:
        raise argparse.ArgumentTypeError("must be greater than zero")
    return result


def scalar_strings(value: Any) -> Iterable[str]:
    if isinstance(value, dict):
        for item in value.values():
            yield from scalar_strings(item)
    elif isinstance(value, list):
        for item in value:
            yield from scalar_strings(item)
    elif value is not None:
        yield str(value)


def selected_values(item: dict[str, Any], field: str, fields: dict[str, str | tuple[str, ...]]) -> Iterable[str]:
    if field == "all":
        return scalar_strings(item)

    keys = fields[field]
    if isinstance(keys, str):
        keys = (keys,)
    return scalar_strings([item.get(key) for key in keys])


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    with path.open(encoding="utf-8") as source:
        return [json.loads(line) for line in source if line.strip()]


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    subparsers = parser.add_subparsers(dest="kind", required=True)

    rule = subparsers.add_parser("rule", help="search rules, recommendations, and information")
    rule.add_argument("query", help="case-insensitive regular expression, or literal text with --exact")
    rule.add_argument("--field", choices=[*RULE_FIELDS, "all"], default="all")
    rule.add_argument("--exact", action="store_true", help="match a complete field value instead of a regex")
    rule.add_argument("--limit", type=positive_int, default=20)

    word = subparsers.add_parser("word", help="search core or technical vocabulary")
    word.add_argument("query", help="case-insensitive regular expression, or literal text with --exact")
    word.add_argument("--source", choices=["core", "technical", "all"], default="all")
    word.add_argument("--field", choices=[*WORD_FIELDS, "all"], default="all")
    word.add_argument("--exact", action="store_true", help="match a complete field value instead of a regex")
    word.add_argument("--limit", type=positive_int, default=20)

    return parser


def main() -> None:
    parser = build_parser()
    args = parser.parse_args()

    if args.exact:
        expected = args.query.casefold()

        def matches(values: Iterable[str]) -> bool:
            return any(value.casefold() == expected for value in values)

    else:
        try:
            expression = re.compile(args.query, re.IGNORECASE)
        except re.error as error:
            parser.error(f"invalid regular expression: {error}")

        def matches(values: Iterable[str]) -> bool:
            return any(expression.search(value) for value in values)

    if args.kind == "rule":
        with (DATA_DIR / "rules.json").open(encoding="utf-8") as source:
            items = json.load(source)
        fields = RULE_FIELDS
    else:
        items = []
        if args.source in ("core", "all"):
            items.extend(load_jsonl(DATA_DIR / "core-vocabulary.jsonl"))
        if args.source in ("technical", "all"):
            items.extend(load_jsonl(DATA_DIR / "technical-words.jsonl"))
        fields = WORD_FIELDS

    results = [item for item in items if matches(selected_values(item, args.field, fields))]
    returned = results[: args.limit]
    print(
        json.dumps(
            {
                "query": args.query,
                "kind": args.kind,
                "field": args.field,
                "exact": args.exact,
                "match_count": len(results),
                "returned_count": len(returned),
                "truncated": len(returned) < len(results),
                "results": returned,
            },
            indent=2,
        )
    )


if __name__ == "__main__":
    main()

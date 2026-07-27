---
name: asd-ste100
description: Applies and reviews ASD-STE100 Simplified Technical English Issue 9. Use when writing, rewriting, or checking technical documentation against STE, or when looking up an STE rule, approved or rejected word, approved meaning, part of speech, alternative, technical noun, or technical verb.
license: See references/SOURCES.md
compatibility: Requires Python 3.11 or later for the lookup script.
---

# ASD-STE100 Issue 9

Use the bundled reference data through targeted lookups. Do not load the complete vocabulary or rules into context.

## Scope

- Treat the data as an unofficial Issue 9 reference, not an ASD certification service.
- Say "no findings" or "consistent with the checked rules." Do not claim that text is certified or fully compliant.
- Distinguish mandatory `rule` entries from `recommendation` and `information` entries.
- Preserve product identifiers, command names, code, literals, measurements, and approved company terminology.
- Ask for the applicable company or subject-field glossary when technical terminology controls the result.

## Lookup

Resolve paths relative to this `SKILL.md`. Set `skill_dir` to this skill directory, then run:

```bash
python3 "$skill_dir/scripts/lookup.py" rule 'R5.1' --field id --exact
python3 "$skill_dir/scripts/lookup.py" rule 'hyphen|dash' --field all
python3 "$skill_dir/scripts/lookup.py" word 'test' --source core --field name --exact
python3 "$skill_dir/scripts/lookup.py" word 'acceptable' --source core --field name --exact
python3 "$skill_dir/scripts/lookup.py" word 'access ladder' --source technical --field name --exact
```

The script prints JSON with the total match count, truncation state, and matching source records. Queries are case-insensitive regular expressions unless `--exact` is present. Use `--limit N` for more than 20 results.

Lookup fields:

- Rules: `id`, `ref`, `section`, `category`, `name`, `summary`, `content`, `all`.
- Words: `name`, `status`, `type`, `category`, `meaning`, `alternative`, `example`, `note`, `all`.
- Word sources: `core`, `technical`, `all`.

For a word decision, first use an exact `name` lookup. A spelling can have both approved and rejected records for different parts of speech. Then inspect meanings, forms, alternatives, examples, and notes in the returned records. Use broad regex searches only for discovery.

## Writing and review workflow

1. Classify each passage as procedural, descriptive, or safety-related writing.
2. Identify candidate dictionary words and domain terms.
3. Look up important, unusual, ambiguous, or changed words by exact name.
4. Verify each approved word's part of speech, meaning, spelling, and permitted form.
5. Treat an unknown word as permissible only when it qualifies as a technical noun or technical verb and the applicable organization or subject field approves it. Do not treat the bundled technical examples as universal approval.
6. Apply the writing-type rules and retrieve the full source record for every cited rule.
7. Rewrite with one term for one concept. Do not introduce synonyms for style.
8. Recheck the final text. Report findings with the exact rule ID, location, reason, and proposed replacement.

## Minimum checks

Always check these unless the task has a narrower scope:

- Approved word, part of speech, meaning, and form: R1.1-R1.4.
- Consistent approved technical terminology: R1.5-R1.13.
- American English spelling unless another directive applies: R1.14.
- Multi-word noun length and introduction: R2.1-R2.2.
- Simple verb forms and active voice: R3.1-R3.7.
- Clear sentence structure, no omitted words, and no contractions: R4.1-R4.5.
- Procedural sentences: maximum 20 words, normally one imperative instruction: R5.1-R5.5.
- Descriptive sentences: maximum 25 words; one topic per paragraph; maximum six sentences per paragraph: R6.1-R6.6.
- Safety instruction structure and consequence: R7.1-R7.3.
- Punctuation and STE word-count rules, including no semicolons: R8.1-R8.7.
- Correct constructions, no phrasal verbs, and consistent style: R9.1-R9.4.

Do not count words with a generic tokenizer when a punctuation or parenthetical case invokes R8.4-R8.7. Look up and apply the applicable rule.

## Review output

Use this compact structure:

```markdown
## Findings

- `location` - R5.1: 24-word procedural sentence; maximum 20. Suggested text: "..."
- `location` - R1.2: `test` is used as a verb; it is approved only as a noun. Suggested text: "Do the test..."

## Notes

- GR-7 recommendation: ...
- Organization glossary decision required: ...
```

If there are no findings, state which rule groups and vocabulary were checked. State any excluded content or missing organization glossary.

## Data cautions

- `references/data/rules.json` is a JSON array despite its upstream `.jsonl` name.
- The upstream rules data contains `Rnnn.0`, an obvious placeholder. Ignore it.
- See [references/SOURCES.md](references/SOURCES.md) for provenance, pinned commits, hashes, and licenses.

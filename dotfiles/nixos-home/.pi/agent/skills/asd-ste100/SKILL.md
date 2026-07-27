---
name: asd-ste100
description: Writes and examines technical text with ASD-STE100 Issue 9. Use for STE writing, text changes, rule queries, and word queries.
license: See references/SOURCES.md
compatibility: Python 3.11 minimum for the query script.
---

# ASD-STE100 Issue 9

Use targeted queries. Read only the necessary bundled rules and vocabulary.

## Limits

- The data is an unofficial Issue 9 reference.
- The output does not give ASD certification or proof of full compliance.
- Use "no findings" or "consistent with the checked rules."
- Do not mix `rule`, `recommendation`, and `information` entries.
- Do not change product identifiers, commands, code, literals, measurements, or approved company terms.
- Use the applicable company or subject-field glossary for technical terms.

## Query data

Set `skill_dir` to this skill directory. Then use:

```bash
python3 "$skill_dir/scripts/lookup.py" rule 'R5.1' --field id --exact
python3 "$skill_dir/scripts/lookup.py" rule 'hyphen|dash' --field all
python3 "$skill_dir/scripts/lookup.py" word 'acceptable' --source core --field name --exact
python3 "$skill_dir/scripts/lookup.py" word 'access ladder' --source technical --field name --exact
```

The script gives JSON with records, result count, and truncation data.

Queries are case-insensitive regular expressions unless you use `--exact`. Use `--limit N` for more than 20 results.

- Rule fields: `id`, `ref`, `section`, `category`, `name`, `summary`, `content`, `all`.
- Word fields: `name`, `status`, `type`, `category`, `meaning`, `alternative`, `example`, `note`, `all`.
- Word sources: `core`, `technical`, `all`.

For a word decision, first use `--exact` with `name`. One spelling can have records for different parts of speech.

Examine all records found. Examine meanings, forms, alternatives, examples, and notes. Use broad queries only to find entries.

## Workflow

1. Select procedural, descriptive, or safety-related rules for the text.
2. Find important, unusual, ambiguous, or changed words and technical terms.
3. Use `--exact` with `name` for each selected word.
4. Make sure that each word has the permitted meaning, spelling, part of speech, and form.
5. Use an unknown word only as a technical noun or technical verb with glossary approval.
6. Do not use the bundled technical examples as universal approval.
7. Use the rules for the selected writing type.
8. Read the full source record before you give a rule ID.
9. Use one term for one concept. Do not use synonyms only for style.
10. Examine the text after changes. Give the rule ID, location, cause, and replacement for each finding.

## Minimum checks

Use all groups unless the task has a smaller scope:

- R1.1-R1.14: approved words, technical terms, forms, and American English spelling.
- R2.1-R2.2: multi-word nouns.
- R3.1-R3.7: verb forms and active voice.
- R4.1-R4.5: clear sentence structure, all necessary words, and no contractions.
- R5.1-R5.5: procedural writing and the 20-word limit.
- R6.1-R6.6: descriptive writing, the 25-word limit, paragraph topics, and paragraph length.
- R7.1-R7.3: safety instructions and consequences.
- R8.1-R8.7: punctuation and word count, with no semicolons.
- R9.1-R9.4: correct constructions, no phrasal verbs, and one style.

Do not use a generic tokenizer for cases in R8.4-R8.7. Use the applicable word-count rule.

## Output

```markdown
## Findings

- `location` - R5.1: 24-word procedural sentence; maximum 20. Replacement: "..."
- `location` - R1.2: `test` is a verb here; only the noun is approved. Replacement: "Do the test..."

## Notes

- GR-7 recommendation: ...
- Organization glossary decision required: ...
```

If there are no findings, give the checked rule groups and the vocabulary in queries.

Give excluded content and each necessary glossary decision.

## Data notes

- `references/data/rules.json` is a JSON array despite its upstream `.jsonl` name.
- Ignore the upstream `Rnnn.0` placeholder.
- `references/SOURCES.md` contains provenance, pinned commits, hashes, and licenses.

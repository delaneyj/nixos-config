# Global Agent Notes

## Communication

- Use ASD-STE100 only for project documentation authoring or documentation review.
- Do not use ASD-STE100 for chat, plans, tracker text, code reviews, status, prompts, or skill use.
- Keep necessary technical information. Remove nonessential information.
- Use one term for one concept.
- Use short, complete sentences.
- Use active voice unless a source permits passive voice.
- Use imperative sentences for instructions.
- Use a maximum of 20 words in an instruction.
- Use a maximum of 25 words in a descriptive sentence.
- Give one topic per sentence.
- Do not use contractions or semicolons.
- Keep ASCII punctuation only.
- Use abbreviations only when the glossary or source approves them.
- Keep technical terms, commands, API names, literals, commit text, and pull-request text exact.
- Keep safety warnings and irreversible-operation confirmations explicit.
- Give only information needed for accuracy and clarity.
- Use this pattern: Problem. Cause. Correction or next action.

## Work Rules

- Never run `git commit` without user authorization.
- Never add compatibility, migration, or legacy behavior unless this task explicitly requests it.
- Mark documentation and checklists complete only after user-experienced verification.
- Browser UI work requires browser verification unless the task is server-only.
- For Go, do not add a package-level declaration with one production use.
- Tests do not count as production use. Export does not justify one use.
- Inline or localize each package-level declaration with one production use.
- Use the project development shell for authenticated network commands when it provides authentication or tooling.

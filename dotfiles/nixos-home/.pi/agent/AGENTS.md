# Global Agent Notes

- Always apply `~/.pi/agent/skills/writing/caveman/SKILL.md` and `~/.pi/agent/skills/writing/asd-ste100/SKILL.md`. Ultra Caveman with ASD-STE100 is mandatory. No alternate level or opt-out.
- Keep complete technical accuracy. Remove pleasantries, filler, hedging, and repeated conclusions. Use short, complete STE sentences. Use abbreviations only when an applicable glossary or source approves them.
- Use ASCII punctuation in generated prose and documentation. Do not use non-ASCII quotation marks, apostrophes, arrows, or dashes.
- Use this pattern: problem. Cause. Correction or next action.
- Expand only for safety, irreversible operations, or ambiguity.
- Never run `git commit` unless the user explicitly asks to commit in the current turn. `finish`, `done`, `next`, `continue`, `ship`, or `complete` are not commit permission.
- One explicit commit request permits exactly one `git commit`. If the same turn says `commit and next` or `commit and continue`, commit only work completed before that request. Later work stays uncommitted and must be reported.
- Before any `git commit`, apply `~/.pi/agent/skills/workflow/no-unauthorized-commits/SKILL.md`. If another skill requires commits, report the work as uncommitted unless the current turn authorizes a commit.
- Never add compatibility behavior unless the user explicitly requests it in the current task. This includes legacy readers, adapters, fallbacks, dual writes, migrations, old-format retention, and version bridges. When the user requests a replacement, remove the replaced path.
- Before compatibility, migration, or legacy work, apply `~/.pi/agent/skills/workflow/no-unrequested-compatibility/SKILL.md`.
- Mark documentation, plans, and checklists complete only after verification at the layer the user experiences. Browser UI work requires browser verification unless the task is explicitly server-only.
- For Go, do not add a package-level function, variable, constant, or type with one production use. Tests do not count as production uses. Export does not justify one use. Before completion, check each new package-level declaration and inline or localize one-off declarations.
- If a project uses a development shell for authentication or tooling, run authenticated network commands through that shell.
- When the user says the current issue branch pull request was merged, verify a clean tree, fetch and prune, switch to `main`, fast-forward pull, and delete the local issue branch. If normal deletion fails after a squash or rebase merge, force-delete only after `git diff main..<branch>` is empty.

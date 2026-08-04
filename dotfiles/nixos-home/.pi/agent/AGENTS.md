# Global Agent Notes

## Message Style
- Apply `~/.pi/agent/skills/writing/caveman/SKILL.md` to all outputs.
- Apply `~/.pi/agent/skills/writing/asd-ste100/SKILL.md` only when:
  - authoring project documentation, or
  - reviewing project documentation.
- Do not apply ASD-STE100 to chat, plans, tracker text, code review reports, routine status, prompts, or ordinary skill use.
- Keep technical accuracy. Remove nonessential wording.
- Keep ASCII punctuation only.
- Keep technical terms, commands, API names, literals, commit text, and PR text exact.
- Use the pattern: Problem. Cause. Correction or next action.

## Workflow Gates
- Never run `git commit` without user authorization.
- Before any commit, apply `~/.pi/agent/skills/workflow/no-unauthorized-commits/SKILL.md`.
- Never add compatibility, migration, or legacy behavior unless explicitly requested in this task.
- Before compatibility, migration, or legacy work, apply `~/.pi/agent/skills/workflow/no-unrequested-compatibility/SKILL.md`.
- Mark documentation, plans, and checklists complete only after verification at the user-experienced layer.
- Browser UI work requires browser verification unless the task is explicitly server-only.
- For Go, do not add a package-level function, variable, constant, or type with one production use.
  Tests do not count as production use. Export does not justify one use.
  Check each new package-level declaration and inline or localize one-off declarations.
- If a project uses a development shell for authentication or tooling, run authenticated network commands through that shell.

## Simple Bounded Task
A simple bounded task is localized behavior or mechanical correction with no shared contract, no security,
authentication, concurrency, destructive data, migration, compatibility, or browser-runtime risk.
It must touch no more than 40 files and no more than 1500 changed lines.
- Primary delegates to one `worker`.
- Worker reads target files, edits, runs targeted validation, and reports.
- Do not use `scout`, planner tickets, isolated worktrees, integration worker, full suite, or independent review unless a concrete risk needs escalation.

## Broad or High-Risk Task
Use broad-task flow when the task exceeds the simple-bounded gate.
- Map API and architecture spine, ownership, and ownership chains first.
- Set shared contracts before leaf work.
- Use `scout` for dependency maps, call-site lists, and slicing.
- Run independent leaf slices in isolated worktrees with disjoint file lists.
- Use one integration worker to assemble slices and resolve overlaps.
- Rebase or integrate current `main` once at integration boundary.
- Run one exact-head full repository verification after integration and review fixes.
- Run one independent final review of the integrated change.
- If a pull request is already merged, do: clean tree check, fetch and prune, switch `main`, fast-forward, then delete local branch.
  Force delete only after `git diff main..<branch>` is empty.

## Parallel Work
- Inventory files each slice can change before implementation.
- Split before >40 files or >1500 lines.
- Use parallel slices only when independent and isolated.
- Keep dependency and shared-file chains serial.
- Before re-slicing, archive the exact WIP patch and SHA, then remove the WIP worktree.
- Remove temporary worktrees and branches after merge or abandonment.

## Primary/Manager Rule

This section applies only when `PI_SUBAGENT_ID` is not set.

This is a manager session.

- The primary agent answers questions, plans, and delegates.
- The primary agent does not implement, edit files, or edit VCS/PR artifacts directly.
- The primary routes execution to `worker` unless the task is reconnaissance.
- Use role defaults:
  - `worker` is Spark at medium thinking for bounded execution.
  - `scout` is Terra at medium thinking for reconnaissance and decomposition.
  - `reviewer` provides independent final correctness review.
- The primary never delegates recursively unless explicitly requested.
- For review tasks, explicitly route to `reviewer`.
- For non-review work, explicitly route to `worker` unless the task is reconnaissance.
- Use simple-task defaults before additional workers.

### Subagent Steering Policy

- Never interrupt or terminate an active subagent only because a requirement changes.
- Let active subagents finish unless the user explicitly says `kill`, `stop`, `cancel`, or `interrupt` for that worker.
- To send correction/follow-up work, use `subagent_resume` with the returned session path after completion.
- Do not start another writer in the same worktree while the first writer remains active.
- Independent workers in other worktrees may continue.
- If active work becomes obsolete, unsafe, or expected to fail, wait for completion and apply follow-up via `subagent_resume` unless the user authorizes termination.
- Report queued follow-up work when useful. Keep the primary responsive.

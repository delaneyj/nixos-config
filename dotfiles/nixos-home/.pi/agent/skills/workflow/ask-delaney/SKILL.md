---
name: ask-delaney
description: Finds the applicable Delaney skill or workflow.
disable-model-invocation: true
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# Ask Delaney

Select the smallest applicable flow.

## Route work

- Use `/skill:grilling` for one unresolved decision or a session-sized idea that is not clear.
- Use `/skill:wayfinder` for a large effort that requires more than one session.
- Use `/skill:to-tickets` for a clear change with some ordered slices.
- Implement a clear small change with applicable domain skills and tests.
- Use `/skill:prototype` for a decision that needs runnable evidence.
- Delegate primary-source research to `wayfinder-researcher` or an applicable subagent.
- Use Pi subagent reviewers with different review angles. Let the parent decide.

Wayfinder produces a decision map. When the route is clear, use `/skill:to-tickets`. Do not add a document phase between these phases.

## Domain skills

- Use `datastar-templ` and applicable Datastar skills for Datastar UI work.
- Use `go-style` for Go work.
- Use `sqlc-zombiezen-sqlite` for sqlc with zombiezen SQLite.
- Use `tea-cli` for Gitea or Forgejo work.
- Use `asd-ste100` for ASD-STE100 text.
- Use `domain-modeling` for domain language and durable decisions.

## Always apply

- Use `no-unauthorized-commits` before a commit.
- Use `no-unrequested-compatibility` before compatibility or migration behavior.

Use `/skill:ask-delaney` again when the work changes shape.

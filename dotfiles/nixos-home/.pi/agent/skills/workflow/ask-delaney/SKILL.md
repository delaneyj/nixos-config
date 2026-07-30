---
name: ask-delaney
description: Finds the applicable Delaney skill or work flow.
disable-model-invocation: true
license: MIT; see ../../references/mattpocock-skills/LICENSE
---

# Ask Delaney

Choose the smallest flow that fits.

## Route work

- One unresolved decision or a session-sized unclear idea: `/skill:grilling`.
- A large effort whose route cannot fit in one session: `/skill:wayfinder`.
- A clear change that needs several ordered slices: `/skill:to-tickets`.
- A clear small change: implement directly with the applicable domain skills and tests.
- A decision that needs runnable evidence: `/skill:prototype`.
- External facts: delegate focused primary-source research with `wayfinder-researcher` or the applicable subagent.
- Fresh review: use Pi subagent reviewers with separate review angles, then let the parent decide.

Wayfinder produces a decision map. When the route is clear, use `/skill:to-tickets`; do not add an intermediate document phase.

## Domain skills

- Datastar UI: `datastar-templ` and its applicable Datastar skills.
- Go: `go-style`.
- sqlc with zombiezen SQLite: `sqlc-zombiezen-sqlite`.
- Gitea or Forgejo: `tea-cli`.
- ASD-STE100 text: `asd-ste100`.
- Domain language and durable decisions: `domain-modeling`.

## Always apply

- `no-unauthorized-commits` before a commit.
- `no-unrequested-compatibility` before compatibility or migration behavior.

Use `/skill:ask-delaney` again when the work changes shape.

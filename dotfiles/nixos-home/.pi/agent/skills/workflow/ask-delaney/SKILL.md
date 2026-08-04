---
name: ask-delaney
description: Finds the applicable Delaney skill or workflow.
disable-model-invocation: true
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# Ask Delaney

Pick the smallest applicable flow.

## Scope guard
- If the user did not request tracker, issue, PR, release, or repository work, go directly to implementation.
- `tea-cli` rules apply only when tracker/repo work is explicitly requested.

## Simple bounded task
A simple bounded task is local, mechanical, clear behavior correction with no shared contract and no high-risk work.
Target: <=40 files and <=1500 changed lines.
If simple and bounded, route directly to implementation.

## Route map
- `/skill:grilling` for one unresolved decision.
- `/skill:wayfinder` for multi-session planning.
- `/skill:to-tickets` for ordered slices.
- `/skill:prototype` for evidence-needed decisions.
- `/skill:reviewer` for broad/high-risk final review or explicit review request.
- Re-run `/skill:ask-delaney` if scope changes.

## Domain add-ons
- Use `datastar-templ` + applicable Datastar skills for Datastar UI.
- Use `go-style` for Go.
- Use `sqlc-zombiezen-sqlite` for zombiezen sqlite sqlc.
- Use `tea-cli` for Gitea/Forgejo work.
- Use `domain-modeling` for durable terminology.
- Use `asd-ste100` only for project documentation work.

## Required gates
Always apply:
- `no-unauthorized-commits` before any commit.
- `no-unrequested-compatibility` before compatibility, migration, or legacy behavior.
- explicit user approval before tracker writes.

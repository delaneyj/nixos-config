---
name: to-tickets
description: Publishes clear work as small vertical implementation tickets with blocking edges. Use after Wayfinder or when a multi-step change is already understood.
disable-model-invocation: true
license: MIT; see ../../references/mattpocock-skills/LICENSE
---

# To Tickets

Turn an approved direction or a completed Wayfinder map into implementation tickets. Do not add an interview or a separate design-document phase.

## Tracker

Inspect `git remote -v`.

- GitHub: read [../references/trackers/GITHUB.md](../references/trackers/GITHUB.md).
- Gitea or Forgejo: apply `tea-cli`, then read [../references/trackers/GITEA.md](../references/trackers/GITEA.md).
- Any other tracker: stop and ask where tickets must go.

## Process

1. Read the full source conversation, map, decision tickets, and linked research.
2. Read the relevant code, tests, domain glossary, and ADRs.
3. Draft tracer-bullet tickets. Each ticket delivers one complete, verifiable behavior through all applicable layers.
4. Give each ticket only the blocking edges that prevent it from starting.
5. Keep each ticket within one focused agent session.
6. Present the numbered draft with title, blockers, delivered behavior, and acceptance criteria.
7. Ask the user to approve the draft before tracker writes.
8. Publish approved tickets in blocker-first order and add native blocking relationships when the tracker supports them.
9. Read the published tickets and report their names and URLs.

Use one ticket for a mechanical repository-wide change only when no smaller change can keep validation green.

Do not add compatibility stages unless the user requested compatibility in the current task.

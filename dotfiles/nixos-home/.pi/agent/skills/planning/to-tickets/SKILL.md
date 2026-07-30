---
name: to-tickets
description: Publishes clear work as small vertical implementation tickets with blocking edges. Use after Wayfinder or when a multi-step change is understood.
disable-model-invocation: true
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# To Tickets

Turn an approved direction or completed Wayfinder map into implementation tickets. Do not add an interview or separate design-document phase.

## Tracker

Inspect `git remote -v`.

- GitHub: read [../references/trackers/GITHUB.md](../references/trackers/GITHUB.md).
- Gitea or Forgejo: apply `tea-cli`. Then read [../references/trackers/GITEA.md](../references/trackers/GITEA.md).
- Any other tracker: stop. Ask where tickets must go.

## Process

1. Read the full source conversation, map, decision tickets, and linked research.
2. Read applicable code, tests, domain glossary, and ADRs.
3. Draft tracer-bullet tickets. Each ticket delivers one verifiable behavior through all applicable layers.
4. Give each ticket only blocking edges that prevent its start.
5. Keep each ticket within one focused agent session.
6. Present the numbered draft with title, blockers, delivered behavior, and acceptance criteria.
7. Ask the user to approve the draft before tracker writes.
8. Publish approved tickets in blocker-first order. Add native blocking relationships when the tracker supports them.
9. Read published tickets. Report their names and URLs.

Use one ticket for a mechanical repository-wide change only when no smaller change can keep validation green.

Do not add compatibility stages unless the user requests compatibility in the current task.

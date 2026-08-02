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
3. Map the API and architecture spine. Map file and package ownership before ticket decomposition.
4. Draft dependency-spine tickets before independent leaf tickets.
5. Draft bounded leaf tickets. Each ticket delivers one verifiable behavior through all applicable layers.
6. Give each ticket only blocking edges that prevent its start.
7. Mark shared contracts and shared-file ownership. Do not allow leaf tickets to invent these contracts.
8. Keep each ticket within one focused agent session.
9. Present the numbered draft with title, blockers, delivered behavior, and acceptance criteria.
10. Ask the user to approve the draft before tracker writes.
11. Publish approved tickets in blocker-first order. Add native blocking relationships when the tracker supports them.
12. Read published tickets. Report their names and URLs.

Use one ticket for a mechanical repository-wide change only when no smaller change can keep validation green. Finish a ticket that unlocks many dependents before dependent tickets start.

Do not add compatibility stages unless the user requests compatibility in the current task.

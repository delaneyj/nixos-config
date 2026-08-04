---
name: wayfinder
description: Maps an effort that one session cannot resolve into decision tickets. Resolves frontier decisions until implementation can start in one or more tickets.
disable-model-invocation: true
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# Wayfinder

Use Wayfinder only when one session cannot route the full work.
Use `/skill:to-tickets` for approved multi-step work.
Use direct implementation for clear bounded tasks.

## Tracker

Inspect `git remote -v` before writes.

- GitHub: read [../references/trackers/GITHUB.md](../references/trackers/GITHUB.md).
- Gitea or Forgejo: apply `tea-cli`. Then read [../references/trackers/GITEA.md](../references/trackers/GITEA.md).
- Any other tracker: stop. Ask where the map must exist.

Use linked titles in user-facing text.

## Map

The map is one issue labeled `wayfinder:map`.
It is an index; each decision is one child ticket.

```markdown
## Destination

<One or two lines that state what must be clear when mapping ends.>

## Notes

<Domain, necessary skills, and standing constraints.>

## Decisions so far

- <linked closed ticket title> - <one-line result>

## Not yet clear

<In-scope questions that are not clear.>

## Out of scope

<Work that does not belong to this effort.>
```

## Decision tickets

```markdown
## Question

<The decision or investigation this ticket resolves.>
```

Ticket labels identify method:

- `wayfinder:research`: external evidence with `wayfinder-researcher`.
- `wayfinder:prototype`: visible or runnable proof via `prototype`.
- `wayfinder:grilling`: one-question user decisions via `grilling` and `domain-modeling`.
- `wayfinder:task`: prerequisite work that exposes facts for a decision.

## Chart a map

1. If destination is unclear, run `grilling` and `domain-modeling`.
2. Add clearly defined questions as tickets with blockers and fog labels.
3. Keep only defined questions as tickets; leave fog questions un-ticketed.
4. Stop map creation when one session can contain all remaining work.
5. Draft map, child tickets, links, and blockers.
6. Show draft and ask approval before tracker writes.
7. Create map first, then tickets.
8. Run unblocked research tickets in parallel `wayfinder-researcher` calls.
9. Post each result, close ticket, update `Decisions so far`.
10. Add new questions when answers reveal them.

Charting does not create implementation tickets.

## Work through a map

1. Read only the map.
2. Select the named ticket or first frontier.
3. Assign the ticket.
4. Resolve one ticket with its labeled method.
5. Post the answer, close the ticket, and update `Decisions so far`.
6. Add new tickets for newly clear questions and set blockers.
7. Continue until user input is required or the frontier is empty.

When fog is empty and frontier is empty, recommend `/skill:to-tickets`.
Do not start implementation from the map.

Do not treat a closed ticket as complete while another frontier ticket remains.

Grilling applies only when user decision is required.
Prototype applies only when evidence is required.
Domain modeling applies only for real terminology conflicts.

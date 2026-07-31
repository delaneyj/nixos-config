---
name: wayfinder
description: Maps an effort that one session cannot resolve into decision tickets. Resolves frontier decisions continuously until user input is required or implementation tickets are possible.
disable-model-invocation: true
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# Wayfinder

Use Wayfinder only when one session cannot show the route to the destination. Use `/skill:to-tickets` or direct implementation for a clear change.

Wayfinder creates decision tickets, not implementation tickets. Complete the map when no decision remains before implementation tickets.

## Tracker

Inspect `git remote -v` before writes.

- GitHub: read [../references/trackers/GITHUB.md](../references/trackers/GITHUB.md).
- Gitea or Forgejo: apply `tea-cli`. Then read [../references/trackers/GITEA.md](../references/trackers/GITEA.md).
- Any other tracker: stop. Ask where the map must exist.

Use linked titles for each map and ticket in user-facing text. Do not use a bare issue number as a name.

## Map

The map is one issue with label `wayfinder:map`. It is an index. Each decision is in one child ticket.

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

<Work that the destination does not include.>
```

`Not yet clear` is fog, not a ticket backlog. Create a ticket when the question is clearly defined. Keep it in fog when a prerequisite decision can change it.

## Decision tickets

Each ticket contains one question. Each ticket fits one 100K-token agent session.

```markdown
## Question

<The decision or investigation this ticket resolves.>
```

Ticket labels identify the method:

- `wayfinder:research`: primary-source investigation by `wayfinder-researcher`.
- `wayfinder:prototype`: runnable or visible evidence through `prototype`.
- `wayfinder:grilling`: one-question-at-a-time user work through `grilling` and `domain-modeling`.
- `wayfinder:task`: prerequisite work that exposes facts for a subsequent decision.

An assignee claims a ticket. The frontier contains open, unassigned tickets with no open blocker.

## Chart a map

Use this mode when the user gives a large effort that is not clear.

1. Apply `grilling` and `domain-modeling` to name the destination. The destination sets scope.
2. Grill breadth-first across the effort. Identify clearly defined first questions, blocking edges, and remaining fog.
3. Stop when no fog remains and one session can contain all work. Recommend direct implementation or `/skill:to-tickets`.
4. Draft the map, decision tickets, labels, child links, and blocking edges.
5. Show the full draft. Ask for approval before tracker writes.
6. Create labels, the map, and all clearly defined tickets. Create tickets before relationships.
7. Run all unblocked research tickets in one parallel `subagent` call. Use `wayfinder-researcher`, new context, different questions, and read-only project scope.
8. Post each research result as its ticket answer. Close the ticket. Add its linked title and one-line result to `Decisions so far`.
9. Add questions that research clearly defined. Update fog.
10. After research resolution, claim the first frontier ticket. Continue until user input is required, no frontier remains, or the user stops work.

Charting resolves no grilling, prototype, or task ticket.

## Work through a map

Use this mode when the user gives a map URL or number.

1. Read only the map. Do not read all tickets.
2. Select the named ticket. If the user names no ticket, select the first frontier ticket.
3. Assign the ticket before work.
4. Read related decisions only when necessary.
5. Resolve one ticket with its labeled method. Only research tickets can run in parallel.
6. Post the answer. Close the ticket. Add its linked title and one-line result to `Decisions so far`.
7. Create tickets for questions that became clear. Add blocking edges. Remove these questions from fog.
8. Close a ticket that is not part of the destination. Add its linked title and reason to `Out of scope`.
9. After each resolved ticket, read tracker state and claim the next frontier ticket.
10. Continue until user input is required, no frontier remains, or the user stops work.

Do not report a resolved ticket as a stopping point when another frontier ticket is available.

When frontier and fog are empty, the route is clear. Recommend `/skill:to-tickets` with the map and closed decision tickets as its source. Do not start implementation from the map.

Other sessions can resolve different frontier tickets. Read tracker state again before each write.

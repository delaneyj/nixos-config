---
name: wayfinder
description: Maps an effort that is too large or unclear for one session into decision tickets, then resolves one frontier decision per session until implementation can be ticketed.
disable-model-invocation: true
license: MIT; see ../../references/mattpocock-skills/LICENSE
---

# Wayfinder

Use Wayfinder only when the route to the destination is not visible in one session. A well-understood change uses `/skill:to-tickets` or direct implementation.

Wayfinder creates decisions, not implementation. The map is complete when no decision remains between the current state and implementation tickets.

## Tracker

Inspect `git remote -v` before writes.

- GitHub: read [../references/trackers/GITHUB.md](../references/trackers/GITHUB.md).
- Gitea or Forgejo: apply `tea-cli`, then read [../references/trackers/GITEA.md](../references/trackers/GITEA.md).
- Any other tracker: stop and ask where the map must live.

Refer to every map and ticket by its linked title in user-facing text. Do not use a bare issue number as its name.

## Map

The map is one issue labeled `wayfinder:map`. It is an index. Each decision lives in one child ticket.

```markdown
## Destination

<One or two lines that state what must be clear when mapping ends.>

## Notes

<Domain, required skills, and standing constraints.>

## Decisions so far

- <linked closed ticket title> - <one-line result>

## Not yet clear

<In-scope questions that cannot yet be stated precisely.>

## Out of scope

<Work beyond this destination.>
```

`Not yet clear` is fog, not a ticket backlog. Create a ticket when the question is precise. Keep it in the fog when an earlier decision can still change the question.

## Decision tickets

Each ticket contains one question and fits one 100K-token agent session.

```markdown
## Question

<The decision or investigation this ticket resolves.>
```

Ticket labels identify the method:

- `wayfinder:research`: primary-source investigation by `wayfinder-researcher`.
- `wayfinder:prototype`: runnable or visible evidence through `prototype`.
- `wayfinder:grilling`: one-question-at-a-time work with the user through `grilling` and `domain-modeling`.
- `wayfinder:task`: prerequisite work that exposes facts needed for a later decision.

A ticket is claimed by its assignee. The frontier is the set of open, unassigned tickets with no open blocker.

## Chart a map

Use this mode when the user gives a large, unclear effort.

1. Apply `grilling` and `domain-modeling` to name the destination. The destination sets the scope.
2. Grill breadth-first across the effort. Identify precise first questions, blocking edges, and remaining fog.
3. If no fog remains and all work fits one session, stop. Recommend direct implementation or `/skill:to-tickets`.
4. Draft the map, decision tickets, labels, child links, and blocking edges.
5. Show the complete draft and ask for approval before tracker writes.
6. Create labels, the map, and all currently precise tickets. Create tickets before wiring relationships.
7. Run all unblocked research tickets in one parallel `subagent` call. Use agent `wayfinder-researcher`, fresh context, distinct questions, and read-only project scope.
8. Post each research result as its ticket answer, close the ticket, and append the linked ticket title with a one-line result to `Decisions so far`.
9. Add questions that the research made precise and update the fog.
10. Stop after charting and research resolution. Report the frontier by linked title.

Charting resolves no grilling, prototype, or task ticket.

## Work through a map

Use this mode when the user gives a map URL or number.

1. Read the map only. Do not load every ticket.
2. Select the named ticket, or the first frontier ticket when none is named.
3. Assign the ticket before work.
4. Read related decisions only when needed.
5. Resolve one ticket with its labeled method. Research tickets are the only tickets that can run in parallel.
6. Post the answer, close the ticket, and append the linked ticket title with a one-line result to `Decisions so far`.
7. Create newly precise tickets, wire blocking edges, and remove their questions from the fog.
8. Close a ticket that is beyond the destination and add the linked ticket title with its reason to `Out of scope`.
9. Stop after one non-research ticket.

When the frontier and fog are empty, the route is clear. Recommend `/skill:to-tickets` with the map and closed decision tickets as its source. Do not start implementation from the map itself.

Other sessions can work different frontier tickets. Read tracker state again before each write.

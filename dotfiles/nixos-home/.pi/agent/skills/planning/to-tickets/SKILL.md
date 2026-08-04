---
name: to-tickets
description: Publish clear work as small vertical implementation tickets with blocking edges. Use after Wayfinder or for approved multi-step work.
disable-model-invocation: true
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# To Tickets

Use this for approved multi-step work. Use one worker directly for one clear bounded task.

## Tracker

Inspect `git remote -v`.

- GitHub: read [../references/trackers/GITHUB.md](../references/trackers/GITHUB.md).
- Gitea or Forgejo: apply `tea-cli`. Then read [../references/trackers/GITEA.md](../references/trackers/GITEA.md).
- Any other tracker: stop and ask where tickets go.

## Process

1. Read the full source conversation, map, decision tickets, and linked research.
2. Read applicable code, tests, glossary, and ADRs.
3. Map API and ownership before ticket boundaries.
4. Draft dependency-spine tickets before leaf tickets.
5. Each leaf ticket delivers one behavior and one acceptance target.
6. Add only blockers that prevent start.
7. Keep shared contracts and ownership explicit.
8. Ask user approval before any tracker write.
9. Publish tickets in blocker-first order with native blocks where supported.
10. Read published tickets and report names and URLs.

Do not add compatibility stages unless user asks for compatibility in this task.

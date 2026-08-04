---
name: prototype
description: Builds a throwaway artifact to answer one design question. Use when a decision needs runnable logic, visible UI evidence, or Wayfinder creates a prototype ticket.
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# Prototype

Use for one decision that needs evidence.

Select one branch:

- Data flow, state, transitions: read [LOGIC.md](LOGIC.md).
- Visual or interaction: read [UI.md](UI.md).

## Shared rules

1. State the question before coding.
2. Put the prototype near the relevant code. Mark it `prototype`.
3. Give one command or URL to run it.
4. Keep state in memory unless persistence is the question.
5. Show applicable state after each action.
6. Skip production polish and abstractions.
7. Capture the answer when user decides.
8. Leave capture, branch, and commit actions to explicit user authorization.
9. Prototype code cannot be promoted to production. Keep it throwaway.

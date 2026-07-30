---
name: prototype
description: Builds a throwaway artifact to answer one design question. Use when a decision requires runnable logic or visible UI evidence, or Wayfinder creates a prototype ticket.
license: MIT. See ../../references/mattpocock-skills/LICENSE
---

# Prototype

A prototype answers one question with throwaway code.

Select one branch:

- Business logic, state transitions, or data shape: read [LOGIC.md](LOGIC.md).
- Visual structure or interaction design: read [UI.md](UI.md).

## Shared rules

1. State the question before you change code.
2. Put the prototype near the applicable code. Mark it `prototype`.
3. Give one command or URL to run it.
4. Keep state in memory unless persistence is the question.
5. Show applicable state data after each action or variant change.
6. Skip production polish and abstractions.
7. Record the answer when the user makes a decision.
8. Leave capture, branch, and commit actions for explicit user authorization.

The validated decision can enter production work. Prototype code cannot enter production work.

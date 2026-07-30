---
name: prototype
description: Builds a throwaway artifact to answer one design question. Use when a decision needs runnable logic or visible UI evidence, or when Wayfinder creates a prototype ticket.
license: MIT; see ../../references/mattpocock-skills/LICENSE
---

# Prototype

A prototype answers one question with throwaway code.

Choose one branch:

- Business logic, state transitions, or data shape: read [LOGIC.md](LOGIC.md).
- Visual structure or interaction design: read [UI.md](UI.md).

## Shared rules

1. State the question before code changes.
2. Put the prototype near the applicable code and mark it `prototype`.
3. Give one command or URL that runs it.
4. Keep state in memory unless persistence is the question.
5. Show the relevant state after each action or variant change.
6. Skip production polish and abstractions.
7. Record the answer when the user reaches a decision.
8. Leave capture, branch, and commit actions for explicit user authorization.

The validated decision can enter production work. Prototype code does not.

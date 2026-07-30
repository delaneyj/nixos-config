# Logic prototype

Build a small interactive terminal program for a question about business logic, state transitions, or data shape.

## Process

1. Put the exact question in a README or top-of-file comment.
2. Use the project's language and task runner.
3. Put the decision logic behind a small pure interface, such as a reducer, state machine, or small function set.
4. Keep terminal I/O outside the decision logic.
5. Render the complete current state and available actions on one screen.
6. Read one action, apply it, and render the full state again.
7. Give the user one run command.
8. After the user decides, record the answer and remove the throwaway shell from production work.

Do not add persistence, generalized behavior, or production error handling unless it is part of the question. Do not add tests to the prototype. Production code derived from the decision uses the normal test workflow.

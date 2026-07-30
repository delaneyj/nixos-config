# Logic prototype

Build a small interactive terminal program for a business-logic question, state transition, or data shape.

## Process

1. Put the exact question in a README or top-of-file comment.
2. Use the project language and task runner.
3. Put decision logic behind a small pure interface, such as a reducer, state machine, or small set of functions.
4. Do not put terminal I/O in decision logic.
5. Render all current state data and available actions on one screen.
6. Read one action. Apply it. Render all state data again.
7. Give the user one command to run the prototype.
8. After the user decides, record the answer. Remove the throwaway shell from production work.

Do not add persistence, generalized behavior, or production error handling unless the question requires it. Do not add tests to the prototype. Use the usual test workflow for production code from the decision.

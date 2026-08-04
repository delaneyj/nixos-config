---
name: plan
description: >
  Planning workflow. For broad, unclear, high-risk, or decision-heavy requests, it runs optional reconnaissance, then planner-led design.
  Use direct implementation for clear simple tasks.
  Requires the subagents extension running inside herdr.
---

# Plan

A planning workflow. Clear simple bounded tasks should skip planning and go straight to one worker.

**Announce at start:** "Let me take a quick look, then I'll decide whether we need a scout before planning."

Only the manager delegates agents. Do not delegate recursively.

---

## Phase 1: Quick Assessment (~30s)

Run enough commands to frame the request:

```bash
ls -la
find . -type f -name "*.ts" | head -20  # or relevant extension
cat package.json 2>/dev/null | head -30
```

If the request is already clear and bounded, go to Phase 4.

---

## Phase 2: Optional Scout

Run a scout only when facts are missing, scope is broad, or risk is high.

- For codebase context.

```typescript
subagent({
  name: "Scout",
  agent: "scout",
  task: `Analyze the area: [user request]. Map files, modules, and patterns relevant to [feature area].

Save findings to: .pi/plans/YYYY-MM-DD-<name>/scout-context.md`,
});
```

Wait for completion, then read the context file with `read`.

---

## Phase 3: Spawn Planner Agent

Use when the request is not ready for execution yet.

```typescript
subagent({
  name: "Planner",
  agent: "planner",
  interactive: true,
  task: `Plan: [what the user wants to build]

Scout context:
[paste scout findings if available]

Save the final plan to: .pi/plans/YYYY-MM-DD-<name>/plan.md
Create todos tagged with: <name>`,
});
```

If the planner hits a factual gap, the manager can run another scout. Do not delegate recursively.

---

## Phase 4: Review Plan & Todos

Read the plan.

Ask one short question:
> "Here is the plan and blockers. Approve this plan and any blockers before execution?"

If no plan is needed, proceed directly to implementation with worker.

---

## Phase 5: Execute Todos

Before execution, make an exact inventory of files for each todo.

- Split work before implementation when it changes more than 40 files or 1,500 lines.
- Run dependency and shared-file work serially.
- Run independent work in parallel only if owned-file lists are disjoint and worktrees are isolated.

```typescript
subagent({
  name: "Worker",
  agent: "worker",
  cwd: "[unique prepared isolated worktree for TODO-xxxx]",
  task: "Implement TODO-xxxx. Owned files: [exact list]. Plan: [plan path]\n\nScout context: [paste scout summary]",
});
```

`/plan` does not grant commit permission.
Follow commit authorization rules for any commit.

---

## Phase 6: Optional Review

For complex work, route to reviewer after execution:

```typescript
subagent({
  name: "Reviewer",
  agent: "reviewer",
  interactive: false,
  task: "Review the recent changes. Plan: [plan path]",
});
```

Triage findings by priority; P0/P1 require fixes before reporting done.

---

## Artifact Paths

For a planning run, pick a short `<name>` and use `.pi/plans/YYYY-MM-DD-<name>/`:

- `.pi/plans/YYYY-MM-DD-<name>/scout-context.md`
- `.pi/plans/YYYY-MM-DD-<name>/plan.md`
- `.pi/plans/YYYY-MM-DD-<name>/review.md` (optional)

---

## Completion Checklist

1. Scout ran when scope needed reconnaissance.
2. Scout context passed to planner when used.
3. Each todo has a clear file inventory.
4. Disjoint ownership for parallel work, when applicable.
5. Dependency-heavy tasks ran serially.
6. All worker todos closed.
7. Reviewer run for complex work, when needed.
8. Reviewer findings triaged by priority.
9. Commit authorization exists for any commit.

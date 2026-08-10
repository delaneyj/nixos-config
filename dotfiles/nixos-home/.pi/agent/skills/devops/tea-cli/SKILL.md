---
name: tea-cli
description: Defines Gitea and Forgejo tea CLI use. Use for issues, pull requests, releases, repositories, notifications, and authenticated API calls.
---

# Tea CLI

Use `tea` for explicit Gitea/Forgejo tracker and repository work.

## Scope guard
Only run this workflow when the user explicitly requests tracker, issue, PR, release, or repository work.
Use this workflow only for Gitea and Forgejo projects.
For GitHub, use GitHub CLI draft PRs with normal titles. Never add a `WIP: ` prefix on GitHub.
For normal code tasks, skip issue creation, PR work, worktrees, and review ceremonies.

## Setup and auth
- Use `tea` from PATH.
- Use the Nix shell when project auth requires it:

```bash
nix develop --command tea --version
nix develop --command tea <args...>
```

- Auth is stored at `$XDG_CONFIG_HOME/tea`.
- Never ask for or print a token.
- If auth is missing, ask for:

```bash
tea login add
```

- Use noninteractive flags when possible.

## Safety gates
Get current-turn approval before any write action, unless issue-work or PR-work authorization is active:
- A direct request to work, continue, or finish a specific open issue or PR starts an active progress session.
- The session covers logical commits, normal pushes, PR progress text, and WIP title lifecycle.
- It does not cover merge, close, delete, force-push, draft-state changes, releases, webhooks, or admin actions.
- Get explicit current-turn approval for excluded actions.

Use JSON output for inspection and audit.

A PR request for uncommitted code on the base branch authorizes the complete publication workflow. Create the issue, issue branch, commit, push, and PR.

Never run `git commit` without `no-unauthorized-commits`.

## Dependency tracking
Use native Gitea issue dependencies as the blocking authority.
Do not add or require a `blocked` label.
IssueHound and Gitea dependency APIs read native links, not labels.
Treat an issue as blocked only when at least one native dependency is open.
A closed dependency preserves history but does not block work.
Use these endpoints to inspect both directions:

```bash
tea api '/repos/{owner}/{repo}/issues/<number>/dependencies'
tea api '/repos/{owner}/{repo}/issues/<number>/blocks'
```

`tea` does not synchronize labels when dependency states change.
For repository-wide audits, query the Gitea issues API and exclude entries with a non-null `pull_request` field.
Compare native links with explicit dependency statements in issue bodies.
Do not infer dependencies from a label.

## Issue branch gate
1. Read target issue first:

```bash
tea issue <number> --comments --output json
```

2. Require `state == "open"` before branch work.
3. Do not start branch work from closed or replaced issues.
4. For replacement issues:
   - create replacement only with approval,
   - read replacement issue,
   - use replacement issue number for branch.

## Branching
- Base branch labels on the issue with:
  `<number>-<two-to-five-word-lowercase-hyphen-slug>`.
- Verify branch starts with the issue number before edits.
- Check existing branches before create/switch.

```bash
git branch --all --list '*<number>*'
git remote -v
git branch --show-current
```

Create branch from fresh main:

```bash
git switch main
git pull --ff-only
git switch -c <number>-<short-label>
```

## PR preflight and publish

When uncommitted code is on the base branch:

1. Inspect the code.
2. Create the required issue.
3. Read the issue and verify that it is open.
4. Create the issue branch without changing the code.
5. Commit and push the requested code.
6. Create the PR.

Before PR creation:

```bash
git status --short
git branch --show-current
git remote -v
git log --oneline --decorate main..HEAD
```

- Do not create PR from `main`.
- Push branch before PR creation:

```bash
git push -u origin HEAD
```

Create a WIP PR immediately after issue branch creation.
Use one `WIP: ` prefix.
Convert the issue scope into an unchecked PR task checklist before implementation.
Use `Tests: pending` until validation gives exact commands.
Use the PR checklist as the progress record while WIP is present.
Try no-diff PR creation first when supported by the tracker.
For issue-work only, if the tracker rejects no-diff PRs, create one empty commit named `chore: start issue N` and push it to open the PR.
For explicit PR-only requests, keep explicit approval.

If there is no base commit, stop and request base-initialization authorization.

## WIP title and reviewer
`WIP: ` means that the agent is still making progress.
A leading `WIP: ` blocks merge in Gitea and Forgejo.
Remove the prefix before handoff so that the tracker can permit merge.
Prefix removal does not authorize merge.
Keep commits logically small and bounded while this prefix is present.
Prefer one checklist task or one tightly coupled task slice per commit.
Push each completed logical commit.
Update the PR checklist after each push.

```bash
tea pr create --base main --head <branch> --title "WIP: <title>" --description "..."
```

Before PR revision:
- Read the title with `tea pr <number> --output json`.
- Add one non-duplicated prefix when active agent work lacks it.

```bash
tea pr edit <number> --title "WIP: <title>"
```

At handoff:
1. Complete implementation and required checks.
2. Complete user-layer verification when required.
3. Complete independent review and corrections.
4. Push all logical commits.
5. Update the PR body and checklist.
6. Remove only the leading `WIP: ` without waiting for another request.
7. Read the PR back and report that it is ready for human review.

Do not change the separate PR draft state without explicit authorization.

Assign the issue creator as reviewer:

```bash
tea issue <number> --output json
tea pr edit <pr-number> --add-reviewers <issue-creator>
```

If reviewer assignment fails, report the failure.

## PR body format
Use a short title and ordered body:

- `Why:` root cause, user effect, and fix rationale.
- `What changed:` result themes.
- `Progress:` an issue-derived Markdown task checklist.
- `Tests:` exact commands.
- Include `Closes #<number>` when applicable.
- Start every planned task unchecked before implementation.
- Check a task only after its verified commit is in the remote PR.
- After each push, update tasks completed by that commit.
- Add newly discovered work as unchecked tasks before starting it.
- Keep unfinished and blocked work unchecked.
- Use `Tests: pending` until implementation validation finishes.
- Replace `Tests: pending` with exact commands after validation.

Use a temp file for multiline description.

## Read-first verification
After write operations:

```bash
tea issue <number> --output json
tea pr <number> --output json
tea release list --output json
```

## Output style and API fallback
Use JSON/list defaults and `--fields` for short tables.
Use `tea api` only when subcommand lacks required options.

```bash
tea api '/repos/{owner}/{repo}/issues?state=open'
tea api -X PATCH '/repos/{owner}/{repo}/issues/123' -F state=closed
```

## Parallel draft confirmation
For real open-issue parallel draft PR workflows only:

1. keep each draft branch in an isolated worktree.
2. confirm in dependency order, oldest first when independent.
3. switch the primary folder to selected branch for confirmation.
4. if earlier draft merged, rebase selected branch on current `main`.
5. confirmation must include exact steps and expected UI/CLI result, and report full error output on failure.
6. PR draft state is handled separately from WIP naming and changes only when explicitly authorized.
7. a request to confirm/rebase/check does not authorize commit, push, force-push, PR edit, ready-state change, or merge.

## Post-merge cleanup
After user says PR merged:

1. `tea pr <number> --output json` and require `hasMerged: true`.
2. save branch name.
3. switch to PR base.
4. `git fetch --all --prune` and fast-forward base.
5. `git branch -d <branch>`.
6. report current branch and tree status.

Do not delete remote branches without explicit approval.

## Core command examples

```bash
# Issues
tea issue list --state open --output json
tea issue <number> --comments
tea issue create --title "..." --description "..."
tea issue close <number>

# Pull requests
tea pr list --state open --output json
tea pr <number> --comments
tea pr create --base main --head <branch> --title "WIP: <title>" --description "..."
tea pr review <number>
tea pr merge <number>

# Releases
tea release list --output json
tea release create --tag <tag> --title "..." --note "..."
tea release delete <tag>
```

After tracker write: read back and return affected issue/PR/release URL or index.

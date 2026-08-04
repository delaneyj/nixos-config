---
name: tea-cli
description: Defines Gitea and Forgejo tea CLI use. Use for issues, pull requests, releases, repositories, notifications, and authenticated API calls.
---

# Tea CLI

Use `tea` for explicit Gitea/Forgejo tracker and repository work.

## Scope guard
Only run this workflow when the user explicitly requests tracker, issue, PR, release, or repository work.
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
Get current-turn approval before any write action:
- create/edit/close/merge an issue, PR, release, label, milestone, webhook, or repository
- PR merge/close
- delete release or repository
- admin actions

Use JSON output for inspection and audit.

Never run `git commit` without `no-unauthorized-commits`.

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

Create PR only with explicit approval.

## WIP title and reviewer
Agent PRs need one `WIP: ` prefix:

```bash
tea pr create --base main --head <branch> --title "WIP: <title>" --description "..."
```

Before PR revision:
- read title via `tea pr <number> --output json`.
- if missing prefix, run one non-duplicated edit:

```bash
tea pr edit <number> --title "WIP: <title>"
```

Remove the prefix only after implementation, tests, and independent review are complete.

Assign the issue creator as reviewer:

```bash
tea issue <number> --output json
tea pr edit <pr-number> --add-reviewers <issue-creator>
```

If reviewer assignment fails, report the failure.

## PR body format
Use short title and ordered body:

- `Why:` root cause, user effect, fix rationale.
- `What changed:` result themes.
- `Tests:` commands.
- include `Closes #<number>` when applicable.

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
5. confirmation must include exact steps, expected UI/CLI result, and end with `confirmed` or request full error output.
6. PR stays draft until user confirms.
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

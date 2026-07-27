---
name: tea-cli
description: Defines use of the Gitea and Forgejo tea CLI. Use for issues, pull requests, releases, repositories, notifications, and authenticated API calls.
---

# Tea CLI

Use `tea` for Gitea and Forgejo operations.

## Setup

Use `tea` from `PATH`. In a Nix project, use the development shell when necessary:

```bash
nix develop --command tea --version
nix develop --command tea <args...>
```

`tea` stores authentication in `$XDG_CONFIG_HOME/tea`.

Do not request or print a token. If authentication is missing, tell the user to run:

```bash
tea login add
```

## Safety

Read operations are safe. Get explicit current-turn approval before these operations:

- Create or edit an issue, PR, release, label, milestone, webhook, or repository.
- Merge or close a PR.
- Close an issue.
- Delete a release or repository.
- Run an administration command.

Before `git commit`, use `no-unauthorized-commits`. A tea workflow does not authorize a commit.

Before PR creation, examine status, branch, remotes, commits, and publication state.

Use noninteractive flags. Stop for user input when required data is unclear.

## Issue branch gate

Do not create or switch to an issue branch until you read an open issue.

Read the issue and comments first:

```bash
tea issue <number> --comments --output json
```

Require `state == "open"` before branch work.

For a replacement issue:

1. Create the replacement only with current-turn approval.
2. Read the replacement issue.
3. Create or rename the branch with the replacement issue number.

Do not start new work from a closed or replaced issue. Existing-work cleanup is the only exception.

## Repository context

Use the development shell for authenticated git network commands when the project requires it.

Do not retry plain `git pull` or `git push` after a credential-helper failure.

Before repository operations, run:

```bash
git remote -v
git branch --show-current
tea repo --output json
```

If repository detection is ambiguous, use one selector:

```bash
tea <cmd> --repo owner/repo
tea <cmd> --remote origin
tea <cmd> --login <name>
```

## Output

Use JSON for parsed output:

```bash
tea issue list --output json --limit 50
tea pr list --output json --state all --limit 50
tea release list --output json
```

Use `--fields` for small tables:

```bash
tea pr list --fields index,title,state,author,updated,ci
tea issue list --fields index,title,state,labels,updated
```

Quote API endpoints that contain `?` or `&`.

## Issue workflow

1. Find or create the applicable open issue.
2. Do not invent an issue number.
3. Read the issue and comments as JSON.
4. Make a short branch label from the issue title.
5. Use lowercase words separated by hyphens.
6. Use two to five useful words and include the issue number.
7. Use `<number>-<short-label>` by default.
8. Find local and remote branches before branch creation.

```bash
git branch --all --list '*<number>*'
git branch --all --list '*<short-label>*'
```

If a branch exists, switch to it:

```bash
git switch <branch>
git switch --track origin/<branch>
```

If none exists, update the target base and create the branch:

```bash
git switch main
git pull --ff-only
git switch -c <number>-<short-label>
```

Use authenticated development-shell git commands when required.

After the switch, make sure the branch starts with the open issue number.

Do not edit files on a branch that fails this check. Do not commit without new current-turn authorization.

## PR workflow

Before PR creation, run:

```bash
git status --short
git branch --show-current
git remote -v
git log --oneline --decorate main..HEAD
```

- Stop if the branch is `main`.
- Get the issue number from the branch name first.
- Examine the log for all intended commits.
- Report uncommitted or unpublished work.
- Push the branch before PR creation.

```bash
git push -u origin HEAD
```

Create the PR only with explicit current-turn approval.

PR text rules:

- Use a short title that describes the result.
- Put `Why:` before `What changed:`.
- In `Why:`, give the cause, user effect, and reason for the correction.
- In `What changed:`, give commit themes and the result.
- Do not include process logs, large test output, or speculative work.
- Add `Closes #<number>` when applicable.
- Assign the issue creator as reviewer.
- Read the issue `user` field to get that reviewer.
- Pass newline characters. Do not pass literal `\n` text.

Use a temporary file for a multiline body:

```bash
tmp=$(mktemp)
cat > "$tmp" <<'EOF'
Closes #<number>

Why:
- Root cause and user effect.
- Reason for this correction.

What changed:
- Final result.

Tests: <command>
EOF
tea pr create --base main --head <branch> --title "..." --description "$(cat "$tmp")"
tea pr edit <pr-number> --add-reviewers <issue-creator>
```

Reviewer assignment can fail when the issue creator is the PR author. Report that result.

## Post-merge cleanup

When the user says a PR was merged:

1. Run `tea pr <number> --output json`.
2. Require `hasMerged: true`.
3. Save the current branch name.
4. Switch to the PR base when currently on the PR branch.
5. Fetch, prune, and fast-forward the base through the authenticated shell.
6. Delete the local PR branch with `git branch -d <branch>`.
7. Report the current branch and tree status.

Do not delete a remote branch without explicit approval.

## Commands

```bash
# Identity
tea login list
tea login default
tea whoami

# Issues
tea issue list --state open --output json
tea issue <number> --comments
tea issue create --title "..." --description "..."
tea issue edit <number> --title "..." --description "..."
tea issue close <number>

# Pull requests
tea pr list --state open --output json
tea pr <number> --comments
tea pr checkout <number>
tea pr create --base main --head <branch> --title "..." --description "..."
tea pr review <number>
tea pr approve <number>
tea pr reject <number> --description "..."
tea pr merge <number>

# Comments and releases
tea comment <issue-or-pr-number> --description "..."
tea release list --output json
tea release create --tag <tag> --title "..." --note "..."
tea release edit <tag> --title "..."
tea release delete <tag>
```

Follow the safety and PR workflows before write commands.

## API fallback

Use `tea api` when no subcommand has the necessary option:

```bash
tea api '/repos/{owner}/{repo}/issues?state=open'
tea api -X PATCH '/repos/{owner}/{repo}/issues/123' -F state=closed
tea api -X POST '/repos/{owner}/{repo}/issues' -f title='Title' -f body='Body'
tea api -X POST '/repos/{owner}/{repo}/issues' -d @issue.json
```

Use `-F` for typed JSON. Use `-f` for strings. Use `-d @file` for raw JSON.

## Verification

After a write operation, read the changed object:

```bash
tea issue <number> --output json
tea pr <number> --output json
tea release list --output json
```

Give the affected URL or index and the command result.

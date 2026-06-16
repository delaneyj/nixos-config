---
name: tea-cli
description: Use the Gitea/Forgejo tea CLI. Use when listing, reading, creating, editing, reviewing, or linking Gitea issues, pull requests, releases, repos, notifications, or authenticated Gitea API calls.
---

# Tea CLI

Use `tea` for Gitea/Forgejo operations from the terminal.

## Availability

- Prefer `tea` when available in `PATH`.
- In Nix projects, if `tea` is not in `PATH`, use:
  ```bash
  nix develop --command tea --version
  nix develop --command tea <args...>
  ```
- `tea` stores auth in `$XDG_CONFIG_HOME/tea`.
- Never request or print tokens. If auth is missing, ask the user to run:
  ```bash
  tea login add
  ```

## Safety rules

- Read/list/show operations are safe.
- Do not run destructive or publishing operations without explicit current-turn user approval:
  - `tea pr merge`, `tea pr close`, `tea issue close`, `tea release delete`, `tea repo delete`, `tea admin ...`
  - creating/editing issues, PRs, releases, labels, milestones, webhooks, repos
- Do not commit as part of a `tea` workflow unless the current user turn explicitly authorizes `git commit`; apply `no-unauthorized-commits` first.
- Before opening a PR, verify git status/branch/remotes and tell the user if work is uncommitted or unpublished.
- Issue-gated branch rule: never create or switch to an issue branch for new work until the matching open issue exists and has been read with `tea issue <number> --comments --output json`. If the user asks to replace/supersede an issue, create/read the replacement issue first, then create/rename/switch the branch to the replacement issue number. Do not branch from a closed/superseded issue except for cleanup of already-existing work, and report that cleanup explicitly.
- Prefer non-interactive flags over prompts. If a command would prompt for unclear data, stop and ask.

## Repo context

If the repo uses a dev shell for `tea`/credential helpers, run authenticated git network commands through it too. In Nix projects prefer `nix develop --command git fetch|pull|push ...`; do not retry plain `git pull`/`git push` after a credential-helper failure.

`tea` infers the Gitea login/repo from the current git remote. Before acting on a repo:

```bash
git remote -v
git branch --show-current
tea repo --output json
```

If repo detection is ambiguous, pass one of:

```bash
tea <cmd> --repo owner/repo
tea <cmd> --remote origin
tea <cmd> --login <name>
```

## Output handling

- Prefer machine-readable output when parsing:
  ```bash
  tea issue list --output json --limit 50
  tea pr list --output json --state all --limit 50
  tea release list --output json
  ```
- Use `--fields` to reduce table output:
  ```bash
  tea pr list --fields index,title,state,author,updated,ci
  tea issue list --fields index,title,state,labels,updated
  ```
- Quote endpoints containing `?` or `&`.

## Issue work workflow

When asked to work on a Gitea issue:

0. Confirm there is a matching open issue before touching git branches:
   - If the user names an issue number, read it first and require `state == "open"` before creating/switching branches.
   - If the user describes work but no issue exists, do not invent a branch number. Ask to create an issue or, when the current turn explicitly approves issue creation, create the issue and read it back before branching.
   - If replacing/superseding another issue, create/read the replacement issue before renaming/switching the branch; branch name must use the replacement issue number.
1. Read the issue first:
   ```bash
   tea issue <number> --comments --output json
   ```
2. Derive a terse branch label from the issue title:
   - lowercase
   - words only, hyphen-separated
   - remove filler words
   - keep it short, usually 2-5 words
   - include the issue number
   - preferred shape: `<number>-<terse-label>`
   - example: `42-query-inspect-switch`
3. Find an existing local or remote branch for the issue before creating one:
   ```bash
   git branch --all --list '*<number>*'
   git branch --all --list '*<terse-label>*'
   ```
4. Switch to the existing branch if found:
   ```bash
   git switch <branch>
   ```
   If only a remote branch exists:
   ```bash
   git switch --track origin/<branch>
   ```
5. If no branch exists, create it from the target base, usually up-to-date `main`. Only do this after step 0/1 confirmed the issue is open:
   ```bash
   git switch main
   git pull --ff-only
   git switch -c <number>-<terse-label>
   ```
6. After branch creation/switch, verify the branch name starts with the open issue number. If not, stop and fix it before editing files.
7. Work normally. Do not commit unless the current user turn explicitly asks for `git commit`.

When asked to create a PR for the current branch/issue:

1. Verify state:
   ```bash
   git status --short
   git branch --show-current
   git remote -v
   git log --oneline --decorate main..HEAD
   ```
2. If current branch is `main`, stop and error out. Do not create a PR from `main`.
3. Identify the issue number from the branch name first, then commits/issue context if needed.
4. Ensure the branch is pushed:
   ```bash
   git push -u origin HEAD
   ```
5. Create terse PR details as a synopsis of commits and final results:
   - title: imperative/summary title, include issue number only if useful
   - body: short bullets; summarize commit themes and actual final result
   - avoid long process logs, test dumps, or speculative future work
   - include closes/fixes reference when intended, e.g. `Closes #<number>`
   - assign the linked issue creator as reviewer when creating the PR; get creator from `tea issue <number> --output json` field `user`
   - for multi-line bodies, pass real newline characters; never pass literal `\n` escape sequences in quoted shell arguments
   - safest pattern: write the body to a temp file/heredoc, then pass `--description "$(cat "$tmp")"`
6. Create the PR only with explicit current-turn approval:
   ```bash
   tmp=$(mktemp)
   cat > "$tmp" <<'EOF'
   Closes #<number>

   - Summary bullet
   - Summary bullet

   Tests: <command>
   EOF
   tea pr create --base main --head <branch> --title "..." --description "$(cat "$tmp")"
   tea pr edit <pr-number> --add-reviewers <issue-creator>
   ```
   If the issue creator is also the PR author, reviewer assignment can fail; report that outcome.

## Post-merge cleanup

When the user says a PR is merged or asks to verify merge:

1. Verify with `tea pr <number> --output json` and require `hasMerged: true`.
2. Capture current branch. If it is the PR head branch, switch to the PR base branch.
3. Update the base branch with authenticated/dev-shell git, e.g. `nix develop --command git fetch origin main --prune` and `nix develop --command git pull --ff-only`.
4. Delete the local PR branch after switching away: `git branch -d <branch>`.
5. Report final branch and clean/dirty status. Do not delete remote branches unless explicitly asked.

## Common commands

### Identity and setup

```bash
tea login list
tea login default
tea whoami
```

### Issues

```bash
tea issue list --state open --output json
tea issue <number> --comments
tea issue create --title "..." --description "..."
tea issue edit <number> --title "..." --description "..."
tea issue close <number>
```

### Pull requests

```bash
tea pr list --state open --output json
tea pr <number> --comments
tea pr checkout <number>
tea pr create --base main --head <branch> --title "..." --description "..."
tea pr review <number>
tea pr approve <number>
tea pr reject <number> --description "..."
tea pr merge <number>
```

Before `tea pr create`, follow the issue PR workflow above. Always error out if the current branch is `main`. Ensure the branch is pushed; `tea` assumes local git state is already published.

### Comments

```bash
tea comment <issue-or-pr-number> --description "..."
```

### Releases

```bash
tea release list --output json
tea release create --tag <tag> --title "..." --note "..."
tea release edit <tag> --title "..."
tea release delete <tag>
```

### Authenticated API fallback

Use `tea api` when a `tea` subcommand lacks an option:

```bash
tea api '/repos/{owner}/{repo}/issues?state=open'
tea api -X PATCH '/repos/{owner}/{repo}/issues/123' -F state=closed
tea api -X POST '/repos/{owner}/{repo}/issues' -f title='Title' -f body='Body'
tea api -X POST '/repos/{owner}/{repo}/issues' -d @issue.json
```

Use `-F` for typed JSON values (`true`, `123`, `null`, arrays/objects), `-f` for strings, and `-d @file` for raw JSON.

## Verification

After any write operation:

```bash
tea issue <number> --output json
tea pr <number> --output json
tea release list --output json
```

Report the affected URL/index and the command-level outcome.

# GitHub tracker operations

Use `gh` inside the repository. Resolve the repository once:

```bash
repo=$(gh repo view --json nameWithOwner --jq .nameWithOwner)
```

## Labels

Create or update the required labels before the first map:

```bash
gh label create 'wayfinder:map' --color 5319E7 --description 'Wayfinder decision map' --force
gh label create 'wayfinder:research' --color 0E8A16 --description 'Wayfinder research decision' --force
gh label create 'wayfinder:prototype' --color FBCA04 --description 'Wayfinder prototype decision' --force
gh label create 'wayfinder:grilling' --color D4C5F9 --description 'Wayfinder human decision' --force
gh label create 'wayfinder:task' --color BFD4F2 --description 'Wayfinder prerequisite task' --force
```

## Maps and tickets

Create issues with a temporary body file:

```bash
gh issue create --title "$title" --body-file "$body_file" --label 'wayfinder:map'
gh issue create --title "$title" --body-file "$body_file" --label "wayfinder:$type"
```

Link a ticket as a sub-issue. GitHub requires the ticket database ID, not its issue number:

```bash
child_id=$(gh api "repos/$repo/issues/$child_number" --jq .id)
gh api --method POST "repos/$repo/issues/$map_number/sub_issues" -F "sub_issue_id=$child_id"
```

Add a blocking edge to the blocked ticket:

```bash
blocker_id=$(gh api "repos/$repo/issues/$blocker_number" --jq .id)
gh api --method POST "repos/$repo/issues/$blocked_number/dependencies/blocked_by" -F "issue_id=$blocker_id"
```

Sources:

- https://docs.github.com/en/rest/issues/sub-issues#add-sub-issue
- https://docs.github.com/en/rest/issues/issue-dependencies#add-a-dependency-an-issue-is-blocked-by

## Frontier and claim

Read the map and its children:

```bash
gh issue view "$map_number" --comments --json number,title,body,state,url
gh api "repos/$repo/issues/$map_number/sub_issues?per_page=100"
```

For each open child, read assignees and `issue_dependencies_summary.blocked_by`. The frontier contains open children with no assignee and no open blocker.

Claim before work:

```bash
gh issue edit "$ticket_number" --add-assignee '@me'
```

## Resolve

```bash
gh issue comment "$ticket_number" --body-file "$answer_file"
gh issue close "$ticket_number"
gh issue edit "$map_number" --body-file "$updated_map_file"
```

Read each changed issue after the write.

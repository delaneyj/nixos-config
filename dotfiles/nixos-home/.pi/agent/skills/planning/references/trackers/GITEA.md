# Gitea and Forgejo tracker operations

Apply the `tea-cli` skill. Use `tea` inside the repository. Use JSON output for reads.

## Representation

Gitea and Forgejo maps use ordinary issues:

- Map label: `wayfinder:map`
- Ticket labels: `wayfinder:research`, `wayfinder:prototype`, `wayfinder:grilling`, or `wayfinder:task`
- Ticket body starts with `Part of #<map-number>`.
- Use `Blocked by: #<number>, #<number>` for blocking.

This body format is the primary tracker representation.

## Create and read

```bash
tea issue create --title "$title" --description "$(cat "$body_file")" --labels 'wayfinder:map'
tea issue create --title "$title" --description "$(cat "$body_file")" --labels "wayfinder:$type"
tea issue "$number" --comments --output json
tea issue list --state open --output json --limit 100
```

Create missing labels with the repository API before the first map. List labels first. Do not create duplicates.

## Frontier and claim

Select open tickets for the map. Exclude tickets with an assignee or an unresolved issue in `Blocked by`.

Claim tickets before work:

```bash
user=$(tea whoami)
tea issue edit "$ticket_number" --add-assignees "$user"
```

## Resolve

```bash
tea comment "$ticket_number" "$(cat "$answer_file")"
tea issue close "$ticket_number"
tea issue edit "$map_number" --description "$(cat "$updated_map_file")"
```

Read each changed issue after the write.

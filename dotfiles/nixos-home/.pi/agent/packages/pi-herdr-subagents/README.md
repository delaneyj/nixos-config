# pi-herdr-subagents local fork

This package is based on `pi-herdr-subagents` 0.1.5.

Local changes:

- Support Pi subagents only.
- Terminate a subagent by closing its Herdr pane and stopping its watcher.
- Report `error` and `length` stop reasons to the parent session.

Run these checks after each change:

```bash
npm test
npm run lint
```

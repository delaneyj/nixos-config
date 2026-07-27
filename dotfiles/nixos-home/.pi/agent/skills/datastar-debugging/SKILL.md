---
name: datastar-debugging
description: Finds Datastar browser and runtime faults. Use for datastar-dev, Rocket, StellarUI, bindings, styles, hot reload, regressions, and user-run servers.
---

# Datastar Debugging

Use this workflow for Datastar, Rocket, StellarUI, browser bindings, and visual faults.

## Hard limits

- Do not build, test, start, stop, or run the Datastar app.
- The user operates the development server with hot reload.
- Do not use `task`, `go test`, `go run`, `pnpm`, browser launchers, or server commands.
- Only an explicit user instruction can override these limits.
- Edit source and add logs. Get browser or server output from the user.
- Keep debug logs until the user confirms the correction.

## Loop

1. Examine source with `read`, `rg`, and `git diff`.
2. Add focused `console.log` or `console.warn` calls near the suspected path.
3. Give the user one specified interaction and the necessary log names.
4. Use the returned logs as source data.
5. Add more logs or make one small correction.
6. After the behavior works, log computed styles for the applicable elements.
7. Remove logs only after explicit user confirmation.

## Logs

Use structured logs with stable prefixes:

```js
console.log('[rocket-light-dom-binding]', {
  el,
  attrName,
  before,
  after,
  signalPathBase,
  scopeSignalKeys,
})
```

Copy event values immediately:

```js
const value = evt.currentTarget?.value
console.log('[color-mode input]', { value })
```

Copy event values before an asynchronous callback.

For visual checks:

```js
const styles = getComputedStyle(el)
console.log('[visual-check]', {
  display: styles.display,
  color: styles.color,
  backgroundColor: styles.backgroundColor,
  width: styles.width,
  height: styles.height,
})
```

## Known checks

- `Undefined Rocket action: onClick` usually means the action has no registration.
- Examine the lifecycle hook before the handler body.
- Current Rocket uses `onFirstRender`. Some older StellarUI bundles use `onFirstUpdate`.
- For color mode faults, log `$colorMode`, `$systemDark`, the root class, and the system media query.
- Do not use only `stellar-button-color-mode.value` for system preference changes.

## Verification

Verification depends on user hot reload, interaction, logs, and browser confirmation.

Do not replace this workflow with agent-run tests or builds.

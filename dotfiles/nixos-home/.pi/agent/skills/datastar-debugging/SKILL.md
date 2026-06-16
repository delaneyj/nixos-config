---
name: datastar-debugging
description: Debugs Datastar/datastar-dev browser/runtime behavior. Use when working in datastar-dev, Rocket/StellarUI, browser bindings, computed styles, hot reload, regressions, or any Datastar issue where the user is running the dev server.
---

# Datastar Debugging

Use this before debugging Datastar, Rocket, StellarUI, browser bindings, visual behavior, or computed styles.

## Non-negotiables

- Do **not** run/build/test/start/kill the Datastar app yourself.
- The user runs Datastar in the background with hot reload on changes.
- Do **not** use `task`, `go test`, `go run`, `pnpm`, browser launchers, or server commands for debugging unless the user explicitly overrides this skill.
- Debug by editing source and adding logs; ask the user to paste browser/server output.
- Do **not** remove debug logs until the user confirms the issue is fixed.

## Debug loop

1. Inspect source only: `read`, `rg`, `git diff` are OK.
2. Add focused `console.log` / `console.warn` instrumentation near the suspected runtime path.
3. Tell the user exactly what interaction to perform and what logs to paste.
4. Use pasted logs as the source of truth.
5. Iterate with more logs or a small code fix.
6. After visual behavior works, add logs around computed styles for the elements in question.
7. Remove logs only after explicit user confirmation.

## Logging style

Prefer structured logs with stable prefixes:

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

For events, copy values synchronously; do not rely on event objects later:

```js
const value = evt.currentTarget?.value
console.log('[color-mode input]', { value })
```

For visual issues, log computed styles after the user says behavior is visually close/working:

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

## Known Datastar/Rocket checks

- `Undefined Rocket action: onClick` (or any component action) usually means the action was never registered. Check the component lifecycle hook name before debugging the handler body. Current Rocket uses `onFirstRender`; older/generated StellarUI bundles may still contain `onFirstUpdate`.
- For color mode/system theme bugs, prefer root-level diagnostics: `$colorMode`, `$systemDark` from `data-match-media:system-dark`, `document.documentElement.className`, and `matchMedia('(prefers-color-scheme: dark)').matches`. Do not rely only on `stellar-button-color-mode.value` for OS/browser preference changes.

## Verification

Verification is user-mediated:

- user hot reloads/runs interaction
- user pastes browser console/server logs
- user confirms visual/runtime result

Do not substitute agent-run tests/builds for this workflow.

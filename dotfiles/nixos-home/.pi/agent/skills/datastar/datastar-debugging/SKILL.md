---
name: datastar-debugging
description: Finds Datastar browser and runtime faults. Use for datastar-dev, Rocket, StellarUI, bindings, styles, hot reload, regressions, and user-run servers.
---

# Datastar Debugging

Use this workflow for Datastar, Rocket, StellarUI, bindings, and visual faults.

## Hard limits
- Do not build, test, start, stop, or run the app.
- User runs the dev server and hot reload.
- Do not use `task`, `go test`, `go run`, `pnpm`, or browser launchers.
- Only explicit user instruction can override.
- Edit source and add logs.
- Keep logs until user confirms fix.

## Loop
1. Read source with `read`, `rg`, `git diff`.
2. Add focused `console.log`/`console.warn` near suspected path.
3. Give user one exact interaction and needed log labels.
4. Gather logs from user.
5. Apply one small correction.
6. If behavior works, log computed styles for affected nodes.
7. Remove logs only after user confirmation.

## Log templates

```js
console.log('[rocket-light-dom-binding]', {
	el,
	attrName,
	before,
	after,
	signalPathBase,
	scopeSignalKeys,
})

const value = evt.currentTarget?.value
console.log('[color-mode input]', { value })

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
- `Undefined Rocket action: onClick` => check action registration and lifecycle hook.
- New and legacy bindings differ: check `onFirstRender` vs old `onFirstUpdate` usage.
- Color mode: log `$colorMode`, `$systemDark`, root class, media query.
- Stellar editor: capture host reference before first action.
- Repeat every suspicious action twice.
- If root class stable but host changes, inspect parent morphs before CSS edits.
- On patchable parents of editor, set `data-ignore-morph` in first response.
- Update value/language/diagnostics/results by signals or properties.
- Avoid local `--code-*` theme overrides until editor host is stable.
- Do not rely only on `stellar-button-color-mode.value` for system preference.

## Verification
- Use user hot reload + interaction log cycle + browser confirmation.
- Never replace with agent-run tests or builds in this workflow.

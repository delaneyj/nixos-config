---
name: datastar-css
description: Defines CSS style for Datastar and templ UIs. Use for CSS in Datastar server-rendered interfaces.
---

# Datastar CSS

Use semantic HTML, CSS state, and coarse morphing. Prefer CSS over JavaScript.

## HTML and behavior
- Prefer semantic elements and explicit labels/names.
- Use `fieldset` and `legend` where useful.
- Style `data-class:*`, `aria-*`, and `hidden` states.
- Do not use `<form>` in Datastar app pages.
- Use signal-bound controls and explicit Datastar actions.

## Design tokens
- Use CSS variables for all reusable values: colors, spacing, sizing, radii, shadows, durations, z-index, layers.
- Check `stellar.css` and `stellarui.css` before adding tokens.
- Reuse existing Stellar variables first.
- Only define a new variable at the smallest shared owner.
- Literal colors/sizes may repeat only for one-time use, `0`, percentages, intrinsic keywords, unitless multipliers.
- Use existing border-width variable for one-pixel lines.
- Keep query scope local to the component and document need.

## Structure and selectors
- Prefer modern CSS nesting.
- Use semantic selectors inside feature root before adding classes.
- Add classes only for ownership boundaries or custom elements.
- Keep selectors low-specificity; use `:where()` when needed.
- Use grid/flex, `minmax()`, logical properties, and fluid sizing.
- Action bars should wrap with explicit gaps.
- Avoid inline styles except for dynamic values.

## Datastar/state handling
- Toggle meaningful classes via `data-class:*` (`loading`, `open`, etc.).
- Use CSS transitions that survive patched/reordered DOM.
- Use `data-ignore-morph` only for client-owned regions.

## Code editor hard gate
Before editor color edits:
- Keep `.cm-content` transparent when `drawSelection` is active.
- Use native `::selection` when inversion is required.
- Use `var(--code-editor-fg)` for selection background.
- Use `var(--code-editor-bg)` for selected text color.
- Keep read-only editors focusable/selectable.
- Compare host reference and root dark class before changing editor background.

## Do not
- Replace semantic structure with nonsemantic wrappers.
- Build deep class chains when scoped nested selectors are clear.
- Use viewport-only layouts without narrow-screen support.
- Use JS for CSS/Datastar behavior.
- Keep repeated design literals.

## Verification
1. Remove unnecessary flat selectors.
2. Remove all repeated design literals.
3. Confirm token reuse before adding scoped tokens.
4. Verify generated markup stays semantic and accessible.
5. Run project templ checks/tests for Go-templ changes.

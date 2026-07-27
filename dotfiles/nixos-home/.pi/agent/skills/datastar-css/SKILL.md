---
name: datastar-css
description: Defines CSS style for Datastar/templ UIs. Use for CSS in Datastar server-rendered interfaces.
---

# Datastar CSS

Use semantic HTML, CSS state, and coarse morphing. Do not use JavaScript when CSS can do the work.

## HTML

- Select semantic elements before classes.
- Give inputs labels. Give buttons names for accessibility.
- Use fieldsets and legends when applicable.
- Style `data-class:*`, `aria-*`, and `hidden` states.
- Do not use `<form>` in Datastar app pages.
- Use signal-bound design-system controls and explicit Datastar actions.

## Design tokens

All project design values must use CSS custom properties.

- Do not add literal colors, spacing, sizes, radii, shadows, durations, layers, or layout measures with two or more uses.
- Examine `stellar.css` and `stellarui.css` first.
- Use the Stellar variable with the applicable meaning.
- If none exists, define one variable at the narrowest shared owner.
- Do not repeat fallback literals at use sites.
- Literal `0`, percentages, intrinsic keywords, and unitless multipliers are permitted.
- Use an existing border-width variable for a one-pixel line.
- Use intrinsic grid or flex layouts before width breakpoints.
- If a query is necessary, scope it to its component and document the cause.

## Structure

- Use modern CSS nesting for project CSS.
- Use semantic selectors nested in layout roots before new classes.
- Add a class only for an ownership boundary or custom element.
- Scope styles to the feature root.
- Use low-specificity selectors and `:where()` when useful.
- Use grid, flex, `minmax()`, logical properties, and fluid sizes.
- Let action bars wrap with explicit tokenized gaps.
- Use inline styles only for dynamic values or established small exceptions.

## Code editors

- Keep `.cm-content` transparent when CodeMirror `drawSelection` is active.
- A content background with a color hides the selection layer.
- Use native `::selection` when selected text must invert colors.
- Use `var(--code-editor-fg)` for the selection background.
- Use `var(--code-editor-bg)` for the selection text.
- Keep read-only editors focusable and selectable.
- Correct selection behavior before you change the editor background.

## Datastar states

- Toggle meaningful classes such as `loading` and `open` with `data-class:*`.
- Use CSS for visibility and animation.
- Make transitions safe for patched or reordered elements.
- Use `data-ignore-morph` only for DOM that server rendering does not own.

## Do not use

- Nonsemantic element groups when semantic HTML is applicable.
- Deep class hierarchies when scoped nested selectors are clear.
- Client JavaScript for CSS or Datastar behavior.
- Viewport-only layouts that fail on narrow screens.
- Hard-coded project design values.

## Verification

1. Examine changed CSS for flat selectors that are not necessary.
2. Examine each added value and remove design literals.
3. Use existing tokens before you add a scoped token.
4. Make sure generated markup is semantic.
5. Examine labels, names, keyboard use, and ARIA.
6. For Go/templ projects, run `templ generate` and the usual tests or build.

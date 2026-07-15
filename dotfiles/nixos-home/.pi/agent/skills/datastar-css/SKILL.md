---
name: datastar-css
description: CSS style for Datastar/templ UIs. Use when writing or changing CSS for Datastar-first server-rendered interfaces.
---

# Datastar CSS

CSS should support semantic HTML and coarse morphing. Keep styling declarative; avoid JS-driven layout/state when CSS can do it.

## HTML first

- Choose semantic elements before classes.
- Preserve accessible names: labels for inputs, button text/aria-labels, fieldsets/legends where useful.
- Style states with attributes/classes that Datastar toggles (`data-class:*`, `aria-*`, `hidden`) rather than custom JS.
- Prefer project design-system controls for app UI forms/filters (for example StellarUI `stellar-text-field`, `stellar-select`, `stellar-button`) instead of raw inputs, while preserving native form submission/progressive enhancement semantics.

## Design tokens are mandatory

- Always use CSS custom properties for design values. Do not write literal colors, spacing, font sizes, control sizes, radii, shadows, animation durations, z-index layers, or reusable layout measures in project CSS.
- Search `stellar.css` and `stellarui.css` first. Reuse the closest existing Stellar variable whenever its semantics match.
- If no suitable Stellar variable exists, add a clearly named variable at the narrowest shared owner (`stellarui.css` for reusable UI-system values, the app root for app-wide values, or the feature root for feature-only values), then consume that variable. Do not repeat the fallback literal at call sites.
- Literal `0`, percentages, intrinsic keywords, and unitless multipliers are allowed. A one-pixel hairline must use the existing border-width variable rather than literal `1px` when one exists.
- CSS query thresholds cannot currently use custom properties. Avoid width breakpoints through intrinsic flex/grid layout first. If a media/container query is truly necessary, scope it to the owning component and document why the structural mode change cannot be intrinsic.
- Before reporting CSS work complete, audit every added declaration for literals and replace design literals with existing or newly defined variables.

## Modern CSS

Use modern CSS nesting by default for project-authored CSS. Flat repeated selectors are a smell unless the file is generated, vendored, or a tiny reset.

```css
.feature {
  display: grid;
  gap: var(--space-4);

  & header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  & button[aria-pressed="true"] {
    font-weight: 700;
  }

  @media (width >= 48rem) {
    grid-template-columns: 1fr auto;
  }
}
```

## Structure

- Project app CSS (for example `stardust.css`) must prefer semantic element selectors nested under layout roots (`header`, `main`, `aside`, `footer`, `nav`, `section`, `article`) before adding more classes.
- Keep component/layout class names only for real ownership boundaries or custom elements; do not add class wrappers when semantic elements already identify the structure.
- Scope styles by feature root class/ID to avoid global leakage.
- Prefer low-specificity selectors; use `:where()` for grouping when helpful.
- Use design tokens/custom properties (`--space-*`, `--color-*`) instead of magic values.
- When a project uses Stellar CSS, copy/use its baseline stylesheet and derive app CSS from Stellar variables. Hard-coded design values are not permitted.
- Keep layout resilient: grid/flex, `minmax()`, logical properties, fluid sizes.
- For filter/action bars, prefer flex with `flex-wrap`, explicit `gap`, and tokenized spacing so controls wrap cleanly on narrow screens.
- Avoid inline styles except examples, dynamic values, or tiny one-offs already common in the target codebase.

## Code editor styling

For StellarUI/CodeMirror editors:

- CodeMirror `drawSelection` paints selection as a background layer behind `.cm-content`; any opaque `.cm-content` background hides it. Keep `.cm-content` transparent if using drawn selections.
- If selected text must invert foreground/background, prefer native selection over CodeMirror `drawSelection`: use `::selection { background: var(--code-editor-fg); color: var(--code-editor-bg); }` and keep the editor focusable/selectable.
- Do not chase selection contrast by changing the whole editor background. Fix the selection path first: content transparency, read-only focusability, then selection foreground/background.

## Datastar interaction states

- Use `data-class:loading`, `data-class:open`, etc. to toggle meaningful classes.
- Use CSS for visibility/animation; Datastar only flips state.
- Respect morphing: transitions should tolerate elements being patched/reordered.
- Use `data-ignore-morph` only for DOM that CSS/JS owns outside server rendering.

## Avoid

- Div soup when semantic HTML fits.
- Deep BEM/class hierarchies when scoped nested selectors are clearer.
- Client JS for hover/focus/disclosure behavior CSS or Datastar attributes can express.
- Hard-coded viewport-only layouts; support narrow screens by default.

## Verification

Before finishing CSS changes:

1. Scan touched CSS for unnecessary flat selectors and class-only structure; convert to nested semantic selectors where practical.
2. Audit added CSS values. Reuse variables from `stellar.css` or `stellarui.css`; add a scoped variable only when no matching token exists. Leave no hard-coded design literals.
3. Check generated markup remains semantic and accessible.
4. For Go/templ projects, run `templ generate` plus normal tests/build.

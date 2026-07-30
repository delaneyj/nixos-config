# UI prototype

Build three structurally different UI variants when the question is visual structure or interaction design.

## Placement

Prefer an existing page with its real data, navigation, and density. Use a new prototype route only when no applicable page exists.

## Process

1. State the question, route, and number of variants.
2. Keep the project's component and style system.
3. Make variants differ in layout, information hierarchy, and primary action.
4. Select variants with a shareable `?variant=` query value.
5. Add a fixed development-only switcher with previous, label, and next controls.
6. Support left and right arrow keys except while an editable control has focus.
7. Give the user the URL and variant keys.
8. Record the selected direction and reason.
9. Remove losing variants and the switcher from production work.

Keep prototypes read-only or connect mutations to stubs. Rewrite the selected direction under normal production and test rules.

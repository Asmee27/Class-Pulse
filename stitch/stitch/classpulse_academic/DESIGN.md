```markdown
# Design System Strategy: The Academic Halo

## 1. Overview & Creative North Star
The "Academic Halo" is the creative north star for this design system. We are moving away from the rigid, boxed-in nature of traditional Learning Management Systems (LMS) and toward an interface that feels like an open, breathing conversation. 

The system treats information as "floating insights." Instead of trapping classroom data in heavy grids, we utilize **intentional asymmetry** and **tonal layering** to guide the eye. By breaking the standard "template" look with generous white space and overlapping elements, we create a professional yet approachable atmosphere that reduces student anxiety and heightens educator focus. This is "Soft Minimalism"—where every pixel serves a pedagogical purpose through quiet authority.

---

## 2. Colors & Surface Logic
Our palette is rooted in a deep, authoritative `primary` (#253153) balanced by an ethereal `surface` (#f7f9ff). 

### The "No-Line" Rule
To maintain a high-end editorial feel, **1px solid borders are prohibited for sectioning.** Boundaries must be defined through background color shifts. For example, a `surface-container-low` section should sit directly on a `surface` background to define its territory. 

### Surface Hierarchy & Nesting
Treat the UI as a series of physical layers. Use the surface-container tiers to create "nested" depth:
- **Base Layer:** `surface` (#f7f9ff) for the main app background.
- **Content Blocks:** `surface-container-lowest` (#ffffff) for primary cards.
- **In-Card Elements:** `surface-container-high` (#e5e8ef) for secondary details inside a card.

### The Glass & Gradient Rule
Floating elements (like real-time feedback modals) should utilize **Glassmorphism**. Apply `surface-container-lowest` at 80% opacity with a `20px` backdrop-blur. 
- **Signature Texture:** Use a subtle linear gradient for Hero CTAs, transitioning from `primary` (#253153) to `primary-container` (#3c486b) at a 135-degree angle. This adds "soul" to the primary actions, preventing them from feeling like flat, disconnected blocks.

---

## 3. Typography: The Editorial Voice
We use **Plus Jakarta Sans** exclusively. Its modern rounded terminals bridge the gap between "Professional" and "Friendly."

- **Display (display-lg to display-sm):** Use for high-impact classroom stats (e.g., "85% Got It"). These should be `primary` color with tight letter-spacing (-0.02em) to feel like an editorial headline.
- **Headlines (headline-lg to headline-sm):** Use `on-surface` (#181c21). These are the anchors of your pages.
- **Body (body-lg to body-md):** Use `on-surface-variant` (#45464e) for long-form text to reduce eye strain.
- **Labels (label-md to label-sm):** Always in `secondary` (#5a5e6e) and often Uppercase with +0.05em tracking for a "meta-data" feel.

---

## 4. Elevation & Depth
In this system, depth is a function of light and shadow, not lines.

- **The Layering Principle:** Rather than shadows, stack tiers. A `surface-container-lowest` card placed on a `surface-container-low` section creates a natural "lift."
- **Ambient Shadows:** When a card must float (e.g., a "Lost" alert), use a shadow with a `24px` blur and `4%` opacity. The shadow color must be a tinted version of `on-surface` (#181c21), never pure black.
- **The "Ghost Border" Fallback:** If accessibility demands a container edge, use `outline-variant` (#c6c6cf) at **15% opacity**. It should be felt, not seen.
- **Roundedness:** Use `xl` (1.5rem) for main containers and `md` (0.75rem) for internal components like buttons or inputs.

---

## 5. Components

### Buttons
- **Primary:** Gradient fill (`primary` to `primary-container`), white text, `full` roundedness. 
- **Secondary:** `secondary-container` background with `on-secondary-container` text. No border.
- **Tertiary:** No background. `primary` text. Use for low-priority "Cancel" or "Back" actions.

### Feedback Chips (Status)
Instead of harsh status colors, use "Soft Accents":
- **Success/Got It:** `tertiary-fixed` (#d2e6ef) background with `on-tertiary-fixed-variant` (#374951) text.
- **Warning/Sort Of:** Soft orange (#FFF3E0) background.
- **Critical/Lost:** `error-container` (#ffdad6) background.
*All chips use `full` roundedness and `label-md` typography.*

### Cards & Feedback Lists
**Strict Rule: Forbid divider lines.** 
To separate feedback entries, use a vertical spacing of `spacing-4` (1rem) and subtle background toggles between `surface-container-low` and `surface-container-lowest`.

### The "Pulse" Input
A custom text field for students. The input should have no visible border, only a `surface-container-highest` bottom-heavy shadow that "glows" into a `primary` tint when focused.

---

## 6. Do's and Don'ts

### Do:
- **Do** use `spacing-12` and `spacing-16` for section margins to create an "Editorial" feel.
- **Do** overlap elements. Let a feedback chip sit 25% outside the top edge of a card to break the grid.
- **Do** use `surface-tint` for subtle iconography to maintain tonal harmony.

### Don't:
- **Don't** use 100% black text. Always use `on-surface` (#181c21).
- **Don't** use a shadow and a border at the same time. Choose one (preferably the shadow).
- **Don't** use "Standard Blue" for links. Use the `primary` navy to maintain the "Academic Halo" authority.
- **Don't** crowd the screen. If a classroom is "Lost," the UI should reflect that with more breathing room, not more icons.
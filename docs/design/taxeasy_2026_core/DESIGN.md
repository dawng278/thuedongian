---
name: TaxEasy 2026 Core
colors:
  surface: '#f8f9ff'
  surface-dim: '#cbdbf5'
  surface-bright: '#f8f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#eff4ff'
  surface-container: '#e5eeff'
  surface-container-high: '#dce9ff'
  surface-container-highest: '#d3e4fe'
  on-surface: '#0b1c30'
  on-surface-variant: '#434655'
  inverse-surface: '#213145'
  inverse-on-surface: '#eaf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#00668a'
  on-secondary: '#ffffff'
  secondary-container: '#40c2fd'
  on-secondary-container: '#004d6a'
  tertiary: '#4d556b'
  on-tertiary: '#ffffff'
  tertiary-container: '#656d84'
  on-tertiary-container: '#eef0ff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#c4e7ff'
  secondary-fixed-dim: '#7bd0ff'
  on-secondary-fixed: '#001e2c'
  on-secondary-fixed-variant: '#004c69'
  tertiary-fixed: '#dae2fd'
  tertiary-fixed-dim: '#bec6e0'
  on-tertiary-fixed: '#131b2e'
  on-tertiary-fixed-variant: '#3f465c'
  background: '#f8f9ff'
  on-background: '#0b1c30'
  surface-variant: '#d3e4fe'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  data-tabular:
    fontFamily: Roboto Flex
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  base: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 48px
---

## Brand & Style
The design system is built on the pillars of **precision, speed, and institutional trust.** It targets a user base of individuals and small business owners who require clarity amidst the complexity of tax compliance.

The visual style is **Corporate Modern with a "White-First" philosophy.** It prioritizes high-key interfaces to minimize cognitive load, using generous white space to separate data-dense sections. To maintain an approachable yet professional tone, the system utilizes subtle depth through tonal layering and a refined blue-spectrum palette, ensuring the application feels like a reliable financial tool rather than a complex bureaucratic hurdle.

## Colors
The palette is led by **Trust Blue (#2563EB)**, a color chosen for its association with stability and institutional authority.

- **Primary & Secondary:** Used for action-oriented elements and brand highlights. The secondary blue provides a softer counterpoint for informational accents.
- **Surface Strategy:** We employ a dual-surface approach. Pure white (#FFFFFF) is reserved for interactive containers, forms, and data lists to maximize legibility. A subtle blue-tinted neutral (#F8FAFC) is used for global page backgrounds to provide a soft "nesting" effect for white cards.
- **Brand Gradient:** A high-energy gradient is reserved for "Hero Moments"—specifically for authentication screens, high-level financial metric summaries, and final submission calls-to-action.

## Typography
Typography is the cornerstone of this design system's utility. We use **Inter** for all UI copy due to its exceptional legibility and neutral tone.

For all currency, percentages, and numerical tables, **Roboto Flex** is mandated with **Tabular Numerals** enabled. This ensures that columns of financial data align perfectly, allowing users to scan and compare values without visual "wobble." Headlines use tight letter spacing and heavier weights to command attention, while body text maintains a generous line height to prevent eye fatigue during long form-filling sessions.

## Layout & Spacing
The system operates on an **8pt Grid System**. All margins, paddings, and height increments must be multiples of 8.

- **Desktop:** A 12-column fixed-width grid (max-width 1280px) is preferred for dashboards to maintain focus. Gutters are fixed at 24px.
- **Mobile:** A fluid 4-column layout with 16px side margins.
- **Consistency:** Horizontal spacing between form labels and inputs should strictly follow the `md` (16px) unit, while vertical spacing between distinct form sections uses `xl` (32px) to create clear thematic grouping.

## Elevation & Depth
Depth is communicated through **Tonal Layers** and extremely soft **Ambient Shadows**.

1.  **Level 0 (Base):** The #F8FAFC canvas.
2.  **Level 1 (Cards):** Pure #FFFFFF surfaces with a subtle 1px border (#E2E8F0) or a very soft shadow (0px 4px 12px rgba(0, 0, 0, 0.05)). This is the primary container for all user data.
3.  **Level 2 (Modals/Popovers):** Higher contrast shadows (0px 12px 24px rgba(0, 0, 0, 0.1)) to signify temporary interruption or contextual action.

We avoid heavy drop shadows in favor of "ghost borders"—low-opacity outlines that define shapes without adding visual weight.

## Shapes
The shape language is varied to create a clear hierarchy of containment:

- **Cards & Primary Containers:** Use `rounded-md` (16px) to strike a balance between friendly and professional.
- **Interactive Toggles & Inputs:** Use `rounded-lg` (20px) to make touch targets feel distinct and modern.
- **Sheets & Bottom Drawers:** Use `rounded-xl` (28px) on top corners to emphasize their role as high-level navigational or entry components.
- **Buttons:** Small and medium buttons follow the `rounded-lg` rule to match inputs.

## Components
- **Buttons:** Primary buttons use the Trust Blue fill with white text. Secondary buttons use a white fill with a 1px #E2E8F0 border.
- **Inputs:** All text inputs must feature a 16px corner radius. Focus states are indicated by a 2px Trust Blue border and a soft blue outer glow.
- **Data Cards:** These are the "atoms" of the dashboard. They must have a white background, 16px border radius, and use Roboto Flex for all numerical values.
- **Gradients:** Apply the Brand Blue Gradient to the "Submit Return" button and the "Total Refund" metric card to signify importance.
- **Imagery:** Use high-quality, bright photography showing diverse retail and small business environments on onboarding screens to ground the technical product in real-world context.
- **Progress Steppers:** Use a linear, simplified stepper at the top of forms to reduce "form anxiety" by showing a clear path to completion.
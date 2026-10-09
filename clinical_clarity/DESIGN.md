---
name: Clinical Clarity
colors:
  surface: '#faf8ff'
  surface-dim: '#d2d9f4'
  surface-bright: '#faf8ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f3ff'
  surface-container: '#eaedff'
  surface-container-high: '#e2e7ff'
  surface-container-highest: '#dae2fd'
  on-surface: '#131b2e'
  on-surface-variant: '#434652'
  inverse-surface: '#283044'
  inverse-on-surface: '#eef0ff'
  outline: '#737783'
  outline-variant: '#c3c6d4'
  surface-tint: '#2b5bb5'
  primary: '#003178'
  on-primary: '#ffffff'
  primary-container: '#0d47a1'
  on-primary-container: '#a1bbff'
  inverse-primary: '#b0c6ff'
  secondary: '#00677d'
  on-secondary: '#ffffff'
  secondary-container: '#50d9fe'
  on-secondary-container: '#005c70'
  tertiary: '#003d28'
  on-tertiary: '#ffffff'
  tertiary-container: '#00573a'
  on-tertiary-container: '#40d399'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d9e2ff'
  primary-fixed-dim: '#b0c6ff'
  on-primary-fixed: '#001945'
  on-primary-fixed-variant: '#00429c'
  secondary-fixed: '#b3ebff'
  secondary-fixed-dim: '#4cd6fb'
  on-secondary-fixed: '#001f27'
  on-secondary-fixed-variant: '#004e5f'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#faf8ff'
  on-background: '#131b2e'
  surface-variant: '#dae2fd'
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.015em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 28px
    letterSpacing: -0.01em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
    letterSpacing: -0.005em
  title-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '600'
    lineHeight: 22px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 20px
    letterSpacing: 0.01em
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.04em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 1rem
  space-lg: 1.5rem
  space-xl: 2rem
---

## Brand & Style

This design system establishes an empathetic, clinically precise, and uncompromisingly trustworthy mobile interface for personal health records. The target audience encompasses patients, caregivers, and medical practitioners navigating high-density health logs, lab diagnostics, surgical timelines, and medication regimens. 

The emotional signature is reassuring, calm, and immaculate—balancing clinical authority with approachable warmth. The design style synthesizes modern technical clarity with tactile depth:
- **Clean Clinical Surfaces:** Grounded in pure whites, whisper-slate canvases, and luminous cyan tints that replace harsh medical steriles with breathing room.
- **Micro-tactile Feedback:** Subtle, tinted depth cues that signal reliability and interactive stability without decorative distraction.
- **Absolute Legibility:** Prioritizing scanning efficiency, rapid triage of critical alerts, and effortless chronological navigation during high-stress medical appointments.

## Colors

The palette leverages a carefully balanced medical chromatic structure designed to communicate clinical confidence and reduce visual fatigue.

### Core Roles
- **Primary (`#0D47A1` / Deep Clinical Navy):** Anchors high-priority actions, active state navigation, structural headers, and primary interaction triggers. Conveys established medical governance.
- **Secondary (`#00B4D8` / Luminous Cyan-Teal):** Used for interactive data metrics, progress indicators, timelines, and dynamic visual anchors. Infuses technological precision.
- **Tertiary (`#10B981` / Vitality Emerald):** Validated outcomes, stable lab ranges, active prescriptions, and positive diagnostic statuses.
- **Neutral (`#0F172A` / Slate Abyss):** The primary typographic ink, structured downward into secondary text (`#334155`), tertiary captions (`#64748B`), subtle hairline borders (`#E2E8F0`), and resting ground canvases (`#F8FAFC`).

### Functional Alert Tones
- **Critical / Urgent Alert (`#EF4444`):** Out-of-bounds lab markers, allergy flags, emergency contacts, and vital contraindications. Paired with 8% alpha tint backgrounds (`#FEF2F2`).
- **Attention / Pending (`#F59E0B`):** Upcoming appointments, medication re-orders, and pending clinical reviews. Paired with tinted backgrounds (`#FFFBEB`).
- **Info Accent (`#E0F2FE`):** Soft cyan surface tint utilized behind informational badges, active card highlights, and grouped medical event summaries.

## Typography

Typography relies uniformly on **Plus Jakarta Sans** to unify contemporary warmth with structured medical clarity. The tall x-height, clear apertures, and distinct numeral forms safeguard readability for lab readings, dosages, and biometric values.

### Typographic Hierarchy Rules
- **Numerical Biometrics:** Dosage and lab metrics render in bold weight (`title-md` or `headline-md`) using tabular figures (`tnum`) where available to facilitate rapid column alignment.
- **Section Headers:** Utilize `headline-sm` with tight negative tracking (`-0.005em`) to balance authority without crowding subsequent card structures.
- **Metadata & Badges:** Use `label-sm` in uppercase with subtle letter-spacing (`0.04em`) for category anchors (e.g., `CARDIOLOGY`, `VACCINATION`, `ALLERGY`).
- **Body & Clinical Descriptions:** Constrained to `body-md` and `body-lg` with a minimum line height multiplier of 1.4x to prevent visual confusion when scanning complex treatment summaries.

## Layout & Spacing

The layout operates on an uncompromising 4px/8px incremental rhythm configured for touch ergonomics, one-handed mobile reach, and accessibility.

### Structural Canvas
- **Screen Margins:** Fixed at `1.25rem` (20px) on standard mobile devices, ensuring sufficient clearance from hardware edges while maximizing usable data area.
- **Column Grids:** Single-column layout on mobile devices under 600px width; 2-column contextual split on tablets (600px–1024px) separating the patient timeline from detailed record drill-downs.
- **Touch Target Integrity:** Every interactive module strictly enforces a minimum touch target bounding box of 48x48px, even when internal visual indicators (e.g., icons, chips) appear smaller.
- **Vertical Rhythm:**
  - `space-xs` (4px): Micro-spacing between paired label and value items.
  - `space-sm` (8px): Gap between chips, list metadata, and icon-to-label offsets.
  - `space-md` (16px): Standard internal card padding and stack gap between related modules.
  - `space-lg` (24px): Boundary gap separating disparate clinical record groups (e.g., separating "Active Conditions" from "Recent Lab Results").
  - `space-xl` (32px): Structural spacing below top navigation bars and persistent action docks.

## Elevation & Depth

Visual hierarchy uses diffused, ambient-tinted shadows paired with crisp border delineations. Instead of generic grey dropshadows, shadows are tinted with the deep slate neutral (`#0F172A`) at low opacity to maintain an ultra-clean, clinical aesthetic.

### Depth Levels
- **Level 0 (Flat Ground):** `#F8FAFC`. The foundational canvas for screens and full-width tab backgrounds. Zero shadow.
- **Level 1 (Card & Module Surface):** `#FFFFFF`. The primary surface for health record cards, timeline entries, and input fields. Features a crisp 1px stroke in `#E2E8F0` coupled with an ambient shadow: `0px 2px 8px -2px rgba(15, 23, 42, 0.04), 0px 1px 3px 0px rgba(15, 23, 42, 0.02)`.
- **Level 2 (Active & Expandable Panels):** Elevated cards on tap, popover menus, floating action buttons, and segmented pickers. Shadow: `0px 8px 16px -4px rgba(15, 23, 42, 0.08), 0px 4px 6px -2px rgba(15, 23, 42, 0.03)`.
- **Level 3 (Modals & Emergency Sheets):** Bottom sheets, dosage interaction sheets, and critical medical confirmations. Shadow: `0px 20px 24px -4px rgba(15, 23, 42, 0.12), 0px 8px 8px -4px rgba(15, 23, 42, 0.04)`.
- **Level 4 (Sticky Safety Navigation):** Bottom navigation bars and top biometric headers incorporate a subtle backdrop blur (`backdrop-filter: blur(12px)`) with a semi-opaque background (`rgba(255, 255, 255, 0.92)`) bounded by a 1px border (`#E2E8F0`) at the bottom or top boundary.

## Shapes

The interface embraces a human-centric, organic softness using consistent, nested radii. Geometry remains disciplined to keep complex diagnostic data structured and scannable.

### Radius Assignments
- **Small Radii (8px / `0.5rem`):** Badges, category chips, status tags, toggle switches, and internal form controls.
- **Medium Radii (16px / `1rem`):** Primary action buttons, list group containers, secondary medical record modules, and floating metric pills.
- **Large Radii (20px–24px / `1.25rem–1.5rem`):** Key health metric cards (e.g., Blood Pressure card, Timeline container cards), bottom sheets, and full-screen overlay dialogs.
- **Full Radius (9999px / Pill):** Filter pills, avatar placeholders, audio playback notes, and quick-dial emergency actions.

## Components

### Buttons
- **Primary Action Button:** High-contrast solid fill using `#0D47A1` with crisp `#FFFFFF` text. Minimum height: 52px (yielding a generous mobile touch target). Corner radius: 16px. Internal padding: 16px horizontal. Hover/Pressed state transitions to `#0A387E` with slight physical scale reduction (`0.98`).
- **Secondary Action Button:** Surface tint `#E0F2FE` with `#0D47A1` text and an optional icon. Height: 48px.
- **Emergency Button:** High-visibility `#EF4444` fill with white text, applied strictly for critical incidents, allergy warnings, or SOS triggers.

### Cards
- **Medical Record Card:** Pure white background (`#FFFFFF`), 16px to 24px corner radius, wrapped in a 1px stroke of `#E2E8F0`. Padding strictly set to 16px. Contains a prominent title (`title-md`), metadata row (`body-sm` in `#64748B`), and a designated status badge anchored to the top-right.
- **Vitals Metric Card:** Structured with a prominent colored accent indicator (e.g., `#00B4D8` for oxygen saturation, `#EF4444` for heart rate) integrated as a 4px vertical bar on the leading edge or as an icon background tile.

### Chips & Filter Pills
- **Filter Chips:** Height of 36px, fully rounded (pill shape). Inactive: `#FFFFFF` fill, 1px `#E2E8F0` border, `#334155` text. Active: `#0D47A1` fill, `#FFFFFF` text, zero border.
- **Diagnostic Badges:** Height of 24px, 6px corner radius, padding 2px 8px. Background colors are strictly rendered at 10%–15% opacity of their respective semantic meaning (e.g., Red for abnormal, Green for normal, Blue for informational) with 100% opacity typography.

### Input Fields
- Enclosed input containers with a fixed height of 52px.
- Background: `#FFFFFF`. Border: 1.5px solid `#E2E8F0`. Focused state shifts border to `#00B4D8` with a 3px soft outer ring (`rgba(0, 180, 216, 0.15)`).
- Floating label structure adhering to `label-md` to preserve context while entering sensitive medical records.

### Lists & Timeline Components
- **Chronological Timeline Item:** Vertical 2px line rendered in `#E2E8F0` connecting record events. The event indicator is an elevated 12px circular node with a 3px ring matching the medical category color.
- **Grouped Record Lists:** Nested within a single 16px rounded surface with zero margins between items; separated internally by hairline dividers (`#F1F5F9`) indented 16px from the leading icon.

### Checkboxes & Radios
- Size: 24x24px with a centered 48x48px invisible tap target area.
- Unchecked: 2px border `#94A3B8`, rounded 6px for checkboxes and circle for radios.
- Checked: Solid fill `#0D47A1` with a clean white tick or inner pip.
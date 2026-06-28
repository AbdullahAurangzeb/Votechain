# VoteChain Design System

**Secure, Institutional UI Language**

A secure, institutional design language for the VoteChain ecosystem, bridging high-trust government fintech with modern blockchain infrastructure.

This document is the single source of truth for visual design across the **Flutter mobile app** and **React admin dashboard**. All UI implementation must match Google Stitch exports and the tokens defined here.

**Design source:** Google Stitch — project `6109903895886936453`  
**Screen exports:** `design/stitch-screens/`  
**Related docs:** [`PROJECT.md`](./PROJECT.md) · [`ARCHITECTURE.md`](./ARCHITECTURE.md)

---

## Table of Contents

1. [Brand Identity](#01-brand-identity)
2. [Color Palette](#02-color-palette-dark-mode-primary)
3. [Typography](#03-typography)
4. [Component Rules](#04-component-rules)
5. [Visual Language](#05-visual-language)
6. [Platform Implementation](#06-platform-implementation)
7. [Design Rules for Developers](#07-design-rules-for-developers)

---

## 01. Brand Identity

### Logo

The **Shield-Ballot-Check** mark is the primary VoteChain brand identifier.

| Element | Meaning |
|---------|---------|
| **Shield** | Security and protection of voter identity |
| **Ballot** | Democracy and the act of voting |
| **Checkmark** | Verification, audit, and trust |

**Asset location:** `design/logo/`

### Core Aesthetic

- **Minimal** — no decorative clutter; every element serves a function
- **High-fidelity** — crisp typography, precise spacing, polished surfaces
- **Authoritative** — institutional tone suitable for government and university elections

VoteChain UI must feel **trustworthy, modern, and secure** — not playful or consumer-casual.

---

## 02. Color Palette (Dark Mode Primary)

Dark mode is the **primary and default** theme for VoteChain. Light mode is out of scope unless explicitly requested.

### Core Tokens

| Token | Hex | Usage |
|-------|-----|-------|
| **Background** | `#080E1D` | App scaffold, full-screen backgrounds (Deepest Navy) |
| **Surface** | `#0D1322` | Base surface, app bars, bottom sheets |
| **Surface Bright** | `#191F2F` | Elevated cards, list tiles, modals |
| **Primary** | `#16A34A` | Primary actions, success states, active nav (Emerald Green) |
| **Secondary** | `#2563EB` | Functional actions, links, info states (Royal Blue) |
| **Accent** | `#7C3AED` | Blockchain status, transaction badges, Web3 indicators (Purple) |
| **Text Primary** | `#FFFFFF` | Headlines, body emphasis, button labels |
| **Text Secondary** | `#94A3B8` | Supporting text, captions, placeholders (Slate Grey) |
| **Border** | `rgba(255, 255, 255, 0.1)` | Dividers, card outlines, input borders |

### Semantic Color Usage

| Context | Color | Example |
|---------|-------|---------|
| Vote / Confirm / Success | Primary `#16A34A` | "Cast Vote", verification passed |
| Info / Links / Secondary CTA | Secondary `#2563EB` | "View Receipt", election details |
| Blockchain / Tx Hash / On-chain | Accent `#7C3AED` | Transaction badge, block explorer link |
| Error / Destructive | `#DC2626` | Validation errors, failed verification |
| Warning / Pending | `#F59E0B` | Pending approval, election upcoming |
| Disabled | `#475569` at 50% opacity | Inactive buttons, locked elections |

### Color Rules

- **Never hardcode hex values in widgets or components** — reference theme tokens only.
- Primary green is reserved for ** affirmative actions** (vote, confirm, verify) — do not overuse on decorative elements.
- Purple accent is reserved for **blockchain-specific UI** — receipts, tx status, chain indicators.
- Maintain sufficient contrast: primary text on background must meet WCAG AA (4.5:1 minimum).

---

## 03. Typography

### Font Families

| Role | Font | Weights | Usage |
|------|------|---------|-------|
| **Headings** | **Poppins** | Semi-bold (600), Bold (700) | Screen titles, section headers, brand presence |
| **Body & Data** | **Inter** | Regular (400), Medium (500) | Lists, tables, instructions, form labels, data values |

**Flutter package:** `google_fonts`  
**React:** Import via Google Fonts CDN or `@fontsource/poppins` / `@fontsource/inter`

### Type Scale

| Style | Size / Line Height | Weight | Font | Usage |
|-------|-------------------|--------|------|-------|
| **Display** | 32px / 40px | Bold (700) | Poppins | Splash, onboarding hero, election result totals |
| **Headline** | 24px / 32px | Semi-bold (600) | Poppins | Screen headers, modal titles |
| **Title** | 18px / 24px | Medium (500) | Poppins | Card titles, candidate names, section labels |
| **Body** | 14px / 20px | Regular (400) | Inter | Paragraphs, descriptions, list items |
| **Label** | 12px / 16px | Medium (500) | Inter | Status badges, timestamps, metadata — **all-caps for status labels** |

### Typography Rules

- Screen headers always use **Poppins Headline** — never Inter for primary titles.
- Data-dense screens (election lists, vote history, admin tables) use **Inter Body**.
- Status labels (e.g., `ACTIVE`, `PENDING`, `CLOSED`) use **Label** style in all-caps with letter-spacing `0.5px`.
- Do not mix more than two font families on a single screen.
- No inline font size overrides — use theme text styles exclusively.

---

## 04. Component Rules

### Buttons

| Variant | Style | Usage |
|---------|-------|-------|
| **Primary** | Solid Emerald Green (`#16A34A`), 14px radius, bold white text | Main action per screen (Vote, Verify, Continue) |
| **Secondary** | Outlined Slate Grey or tinted Blue/Green surface | Cancel, back, alternative actions |
| **Destructive** | Solid red (`#DC2626`), 14px radius | Irreversible actions (rare — confirm dialogs only) |
| **Ghost / Text** | No fill, Primary or Secondary text color | Tertiary actions, inline links |

**Layout rules:**

- **Mobile:** Full-width primary buttons for main screen actions.
- **Desktop (Admin):** Hug-contents for filter/toolbar buttons; full-width only in forms/modals.
- Minimum touch target: **48dp** height on mobile.
- Disabled state: 50% opacity, no interaction.

### Cards

| Property | Value |
|----------|-------|
| Background | Surface Bright `#191F2F` |
| Border radius | **16px** |
| Border | 1px `rgba(255, 255, 255, 0.1)` |
| Internal padding | **16px–20px** |
| Elevation | Flat — border over shadow |

**Card types:**

- **Election Card** — title, date range, status badge, candidate count
- **Candidate Card** — photo, name, party, manifesto excerpt
- **Vote Receipt Card** — tx hash (Accent purple), timestamp, election name
- **Stat Card (Admin)** — metric value (Display), label (Label), trend indicator

### Inputs

| Property | Value |
|----------|-------|
| Background | Surface `#0D1322` |
| Border radius | **12px** |
| Font | Inter Regular 14px |
| Border | 1px `rgba(255, 255, 255, 0.1)` — Primary green on focus |
| Icons | Material Symbols Rounded, left-aligned, `#94A3B8` |

**Input types:** Text, password, search, CNIC formatted, date picker trigger.

**Validation:** Error state — red border `#DC2626` + error message in Label style below field.

### Navigation

#### Mobile (Flutter)

- **Bottom Navigation Bar** with icon + label.
- **Active state:** Emerald Green icon and label with subtle emerald glow.
- **Inactive state:** Text Secondary `#94A3B8`.
- Maximum **5 tabs** — Home, Elections, Vote, Notifications, Profile.

#### Desktop (React Admin)

- **Persistent sidebar** with icon + label.
- **Active item:** High-contrast Emerald Green left border + bright surface highlight.
- **Collapsed mode:** Icons only with tooltips.
- Top bar: organization name, admin avatar, notification bell.

### Status Badges

| Status | Background | Text |
|--------|------------|------|
| Active | `#16A34A` at 15% opacity | `#16A34A` |
| Pending | `#F59E0B` at 15% opacity | `#F59E0B` |
| Closed | `#94A3B8` at 15% opacity | `#94A3B8` |
| On-chain | `#7C3AED` at 15% opacity | `#7C3AED` |
| Failed | `#DC2626` at 15% opacity | `#DC2626` |

Badge style: Label (12px, medium, all-caps), 8px horizontal padding, 4px vertical padding, 8px radius.

---

## 05. Visual Language

### Elevation

VoteChain uses **flat surfaces with subtle borders** — not heavy drop shadows.

- Prefer 1px border (`rgba(255, 255, 255, 0.1)`) over `box-shadow`.
- Modals and bottom sheets may use a soft shadow: `0 8px 32px rgba(0, 0, 0, 0.4)`.
- Material 3 elevation levels 0–2 only — never elevation 4+.

### Spacing

Base unit: **4px / 8px grid**.

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Icon-to-text gap, tight inline spacing |
| `sm` | 8px | List item internal padding, badge padding |
| `md` | 16px | Standard card padding, form field gap |
| `lg` | 24px | Section margins, screen horizontal padding |
| `xl` | 32px | Screen top/bottom safe area padding |
| `2xl` | 48px | Hero section spacing, empty state vertical gap |

Standard screen horizontal margin: **16px (mobile)**, **24px (tablet/desktop admin)**.

### Icons

- **Library:** Material Symbols Rounded
- **Stroke weight:** 2px (optical weight via filled/rounded variant)
- **Default size:** 24dp (mobile), 20px (admin dense tables)
- **Color:** Text Secondary default; Primary green for active/affirmative; Accent purple for blockchain

**Asset location:** `design/icons/`

### Illustrations

- **Style:** Premium, minimal isometric vectors
- **Background:** Transparent
- **Accent:** Subtle neon glows in Emerald Green and Royal Blue
- **Usage:** Onboarding, empty states, verification success, blockchain confirmation

**Asset location:** `design/illustrations/`

### Empty States

Centered layout:

1. Isometric illustration (128dp height)
2. Headline title (Poppins Title 18px)
3. Supportive description (Inter Body 14px, Text Secondary)
4. Optional primary CTA button

### Loading States

- **Skeleton pulses** on Surface Bright `#191F2F` base
- Animated shimmer: `#191F2F` → `#0D1322` → `#191F2F`
- Match target component border radius (12px inputs, 16px cards)
- Never use spinners alone on full screens — pair with skeleton layout

---

## 06. Platform Implementation

### Flutter (`mobile/lib/theme/`)

| Design Token | Flutter Mapping |
|--------------|-----------------|
| Color tokens | `ColorScheme` + custom `AppColors` extension |
| Typography scale | `TextTheme` with `GoogleFonts.poppins()` / `GoogleFonts.inter()` |
| Spacing | `AppSpacing` constants class |
| Border radius | `AppRadius` constants class |
| Components | Reusable widgets in `mobile/lib/widgets/` |

Theme file structure:

```text
mobile/lib/theme/
├── app_colors.dart
├── app_spacing.dart
├── app_radius.dart
├── app_typography.dart
└── app_theme.dart          # Material 3 ThemeData assembly
```

### React Admin (`admin/src/theme/`)

| Design Token | React Mapping |
|--------------|---------------|
| Color tokens | CSS custom properties or MUI `createTheme()` palette |
| Typography | Theme typography with Poppins + Inter imports |
| Spacing | Theme spacing scale (multiples of 4/8) |
| Components | Shared components in `admin/src/components/` |

Both platforms must render visually equivalent screens for shared concepts (election cards, status badges, vote receipts).

---

## 07. Design Rules for Developers

### Mandatory

1. **Match Google Stitch exports exactly** — reference `design/stitch-screens/` before implementing any screen.
2. Add a file-level comment on every screen: `// Stitch: <screen_filename>.png`
3. Use theme tokens only — **no hardcoded colors, fonts, or spacing**.
4. Extract repeated patterns into reusable components after the second use.
5. Implement in priority order: **Layout → Spacing → Typography → Colors → Icons → Animations → Business Logic**.

### Prohibited

- Redesigning screens unless explicitly requested
- Introducing light mode without approval
- Using non-approved fonts or icon libraries
- Heavy drop shadows or Material 2 components
- Inline style overrides that bypass the theme system

### Stitch Screen Reference

When implementing a screen, locate its Stitch export:

```text
design/stitch-screens/<screen_name>.png
```

Stitch project reference for design updates:

```text
web application/stitch/projects/6109903895886936453/screens/
```

### Cross-Platform Consistency Checklist

- [ ] Colors match token table (no hex drift)
- [ ] Poppins for headings, Inter for body
- [ ] Card radius 16px, input radius 12px, button radius 14px
- [ ] Status badges use all-caps Label style
- [ ] Primary green reserved for main actions
- [ ] Purple accent used only for blockchain elements
- [ ] Empty and loading states follow VoteChain Design System patterns
- [ ] Mobile bottom nav / admin sidebar active states use Emerald Green

---

## Design Token Quick Reference

```text
┌─────────────────────────────────────────────────────┐
│  VOTECHAIN DESIGN SYSTEM — TOKEN SUMMARY            │
├─────────────────────────────────────────────────────┤
│  Background     #080E1D    Surface        #0D1322   │
│  Surface Bright #191F2F    Primary        #16A34A   │
│  Secondary      #2563EB    Accent         #7C3AED   │
│  Text Primary   #FFFFFF    Text Secondary #94A3B8   │
│  Border         rgba(255,255,255,0.1)               │
├─────────────────────────────────────────────────────┤
│  Font Headings  Poppins    Font Body      Inter     │
│  Radius Card    16px       Radius Input   12px      │
│  Radius Button  14px       Grid Base      4px/8px   │
└─────────────────────────────────────────────────────┘
```

---

*VoteChain Design System — v1.0*  
*Source: Google Stitch · Material 3 · Dark Mode Primary*

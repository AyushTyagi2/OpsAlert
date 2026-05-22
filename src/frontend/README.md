# OpsPulse — Frontend Architecture & UI Engineering Audit

> **Audited by:** Staff Frontend Engineer / SaaS UI Architect
> **Project:** Ops Alerting & Incident Management Platform (OpsPulse)
> **Stack:** React · TypeScript · TailwindCSS · Framer Motion · React Router · Recharts · shadcn/ui · CRA
> **Scope:** Full production-grade frontend audit across architecture, UI/UX, performance, TypeScript quality, design system, and enterprise realism

---

## Table of Contents

1. [Overall Frontend Maturity Assessment](#1-overall-frontend-maturity-assessment)
2. [Architecture Audit](#2-architecture-audit)
3. [UI/UX Audit](#3-uiux-audit)
4. [Performance Audit](#4-performance-audit)
5. [Production-Readiness Assessment](#5-production-readiness-assessment)
6. [Technical Debt Risks](#6-technical-debt-risks)
7. [Top 10 Improvements to Prioritize](#7-top-10-improvements-to-prioritize)
8. [Long-Term Frontend Architecture Recommendations](#8-long-term-frontend-architecture-recommendations)
9. [Recruiter-Impact Assessment](#9-recruiter-impact-assessment)
10. [Final Realism Score](#10-final-realism-score)

---

## 1. Overall Frontend Maturity Assessment

**Rating: 5.5 / 10 — "Promising Prototype with Structural Debt"**

OpsPulse shows genuine visual ambition and a credible aesthetic direction. The `Analytics` page in particular demonstrates that the author can build dense, data-rich interfaces that feel closer to a real SRE tool than most portfolio projects. However, the codebase has a hard split between the high-polish `Analytics.tsx` (which is well-structured, self-contained, and visually impressive) and the rest of the application, which reads as an unfinished scaffold with placeholder pages, empty type files, hardcoded mock data living inside components, and zero real state management.

The project is not production-grade today. It is a strong foundation that will become a genuinely impressive portfolio piece with 3–4 weeks of focused architectural cleanup. The gap is not in visual skill — it's in engineering discipline.

---

## 2. Architecture Audit

### Folder Structure

```
src/
├── alerts/          # Single file, no types
├── analytics/       # Analytics.tsx — monolithic 800+ line file
├── api/             # axiosClient.ts (good), stubs that export nothing
├── auth/            # Login/Register pages exist, empty useAuth.ts
├── components/      # Flat component dump, no sub-organization
├── hooks/           # useIncidents.ts, usePolling.ts — both export {}
├── incidents/       # IncidentDashboard, IncidentDetail, IncidentTimeline — all stubs or partial
├── store/           # authStore.ts, incidentStore.ts — both export {}
├── styles/          # 5 separate CSS files with unclear ownership
├── types/           # alert.ts, incident.ts, user.ts — ALL export {} (empty)
├── ui/              # shadcn components (correct placement)
└── utils/           # constants.ts, formatDate.ts, severityColors.ts — all export {}
```

**What is production-grade:**
- The domain-based folder split (`incidents/`, `analytics/`, `alerts/`) is the right instinct and maps well to feature-based architecture.
- `api/axiosClient.ts` with a Bearer token interceptor is a correct, real-world pattern.
- `ui/` separation of shadcn primitives from application components is correct.
- `ErrorBoundary.tsx` exists — that's a meaningful signal.

**What is weak:**
- `types/alert.ts`, `types/incident.ts`, `types/user.ts` are completely empty (`export {}`). This is the single most damaging thing in the codebase. The entire TypeScript value proposition collapses without shared types.
- `store/authStore.ts` and `store/incidentStore.ts` are empty. The state management layer is imaginary.
- `hooks/useIncidents.ts` and `hooks/usePolling.ts` are empty. The data layer is imaginary.
- `utils/constants.ts`, `utils/formatDate.ts`, `utils/severityColors.ts` are all empty.
- All mock data lives directly inside components (`App.tsx`, `IncidentDashboard.tsx`, `Analytics.tsx`). There is no data layer.

**What will become technical debt:**
- `Analytics.tsx` is ~800 lines in a single file. Every sub-component (`MetricCard`, `Panel`, `SlaGauge`, `Sparkline`, `ResponderRow`, etc.) is defined locally. As soon as you need to reuse any of these, you'll have a naming collision with the global `MetricCard` in `components/MetricCard.tsx`.
- There are **two `MetricCard` components** in the project with different props interfaces — one in `components/MetricCard.tsx` (Framer Motion 3D hover card) and one inside `Analytics.tsx` (trend/sparkline card). This will cause confusion.
- The `App.tsx` routing file also contains the `Dashboard` component inline. This mixes concerns and makes the router impossible to lazy-load.
- `styles/` has 5 CSS files (`globals.css`, `index.css`, `tailwind.css`, `theme.css`, `fonts.css`) plus `App.css`, `index.css`, and `default_shadcn_theme.css` at the root level — 8 CSS entry points with unknown cascade ordering.

**What should be refactored early:**
1. Fill the type files immediately — `Incident`, `Alert`, `User` domain types are foundational.
2. Extract the `Dashboard` component from `App.tsx` into `dashboard/Dashboard.tsx`.
3. Break `Analytics.tsx` into `analytics/components/` sub-components.
4. Implement either Zustand or TanStack Query — even with mock adapters for now.
5. Consolidate CSS to a single `globals.css` entry point.

### Routing Structure

The router is functional but has two problems:

1. **No lazy loading.** All routes are eagerly imported. In a real SRE tool used 24/7 in high-stress incidents, initial bundle size matters.
2. **`PlaceholderPage` with a construction emoji** (`🚧`) is present in production routes. This is the most immediately noticeable "student project" signal in the entire codebase. `/monitoring`, `/alerts`, `/on-call`, and `/settings` all show this. Five of seven routes are dead ends.

### State Management

There is no functioning state management. `authStore.ts` and `incidentStore.ts` are empty files. This means:
- No auth state is persisted or shared
- No incident data is globally accessible
- Every component that needs data would have to re-fetch or re-declare it
- The `PrivateRoute` component exists but cannot function without a working auth store

### API Layer

`axiosClient.ts` is correct — it's a proper Axios instance with a request interceptor. But the five API files (`alertApi.ts`, `analyticsApi.ts`, `authApi.ts`, `incidentApi.ts`) likely contain only stubs (pattern matches the hook files). The client exists; the API methods do not.

---

## 3. UI/UX Audit

### What Feels Realistic

**The Analytics page** is genuinely impressive and would hold up in a real product review. Specific elements that work well:
- MTTA/MTTR dual-line chart with dashed vs solid distinction is a real SRE pattern
- Alert Noise Analysis (noisy vs suppressed vs actionable) is a real observability concept — this shows domain knowledge
- Responder Load with burnout risk signal is thoughtful and realistic
- SLA Gauge circular indicators are visually clear and contextually appropriate
- Flapping services table is a real operational concept most portfolio projects would never include
- The "Slowest Resolution Pipelines" panel with SLA breach markers is enterprise-grade thinking

**The Dashboard (`App.tsx`) header section** — the gradient text, glassmorphism cards, and ambient glow aesthetic is consistent and professional-feeling for a dark ops tool.

**`LiveAlertTicker`** — the animating feed is a credible real-time UI pattern. The implementation (interval cycling through static alerts) is obviously fake, but the pattern itself is correct.

**`ServiceHealthGrid`** — the status badge with uptime + latency data per service is the right information hierarchy for an ops tool.

### What Feels Fake / Toy-Like

**The five placeholder pages** are the most damaging UX issue. A recruiter or SRE engineer clicking "Alerts" and seeing a 🚧 emoji immediately re-categorizes this from "platform" to "wireframe." This single issue has the highest ROI to fix.

**`IncidentDashboard.tsx`** is a regression from the main dashboard. It drops the glassmorphism design language entirely, uses plain `bg-slate-900 border border-slate-800` styling, has no animations, no filtering, no sorting, no pagination, and the incident rows have no click target. Compared to the main dashboard and analytics page, this page looks like it was built by a different person. The severity badges are hardcoded `bg-red-500` with no severity-conditional logic. This is the second most damaging page.

**The `"View all"` button** in the main dashboard's Recent Incidents section is a plain `<button>` with no `onClick` handler. Clicking it does nothing.

**`MetricCard` trend logic is inverted for some metrics.** "Active Incidents" trending down is good, but the component colors all `trend="down"` in red. There's no `badTrendUp` prop on the main dashboard `MetricCard` (only on the analytics one), so incident count going down shows as a red badge, which is incorrect.

**The `LiveAlertTicker` always shows "Just now"** regardless of which alert is displayed. This is a minor but noticeable credibility break.

**`ActivityChart`** has no X-axis labels, no tooltip, no legend, and the Y-axis is hidden. The chart shows values from 45–95 with no unit. What is being measured? Events per second? CPU? Request count? An unlabeled chart in an ops dashboard is a UI failure.

**Typography hierarchy is inconsistent.** The main dashboard uses `<h1>`, `<h2>`, `<h3>` without explicit size classes (relying on Tailwind's base reset, which strips heading styles). The analytics page uses inline font-size styles. Neither approach is correct — there's no typography scale in use.

### Operational Readiness UX Issues

- No keyboard navigation support for incident rows
- No filter/sort controls on any incident list
- No time range selector on the main dashboard (analytics has one; dashboard doesn't)
- No drill-down from metric cards (clicking "7 Active Incidents" should navigate somewhere)
- No acknowledge/resolve action on any incident card
- No on-call schedule view
- No notification preferences
- No search functionality
- The sidebar status indicator ("All Systems Operational") is hardcoded — it will never show a degraded state

### Sidebar / Navigation UX

The sidebar is the best-executed component in the codebase:
- `layoutId="activeTab"` spring animation is smooth and professional
- The active glow pulse animation is a nice touch without being distracting
- `NavLink` with `end` on the root route is correct

One issue: the sidebar has no collapse state. On a real 13" laptop used in a high-stress incident, the fixed 256px sidebar eating 20% of horizontal space becomes a problem.

### Accessibility

- No `aria-label` on any icon buttons
- No `role` attributes on interactive elements that aren't native buttons/links
- Color is the only indicator for severity (no icons on the `IncidentDashboard` severity badges)
- No focus ring styles visible (likely overridden by Tailwind reset)
- No skip navigation link
- Framer Motion animations have no `prefers-reduced-motion` check

---

## 4. Performance Audit

### Rendering Concerns

**`Analytics.tsx` is a 800+ line monolithic component.** It re-renders entirely on every `tick` state change (every 3 seconds). Every chart, every table row, every panel re-renders even though only 4 numeric values change. This is a significant unnecessary re-render problem at scale.

**Multiple `useEffect` + `setInterval` patterns across components** (`LiveAlertTicker`, `Analytics`) with no coordination. On the main dashboard, both components run independent intervals simultaneously.

**Framer Motion usage concerns:**
- `MetricCard` uses `useMotionValue` + `useTransform` for 3D tilt on every card. With 6 metric cards on the main dashboard, that's 12 motion values created on mount. On a dashboard refreshed every 30s by SREs watching 20 browser tabs, this adds up.
- The sidebar's active item has **three separate animated `motion.div` layers** per nav item (active background, hover background, glow pulse). Seven nav items = 21 animated elements just for navigation. The `animate` prop with `boxShadow` array on the active item (`duration: 2, repeat: Infinity`) runs a continuous CSS animation on every page load.
- `layoutId` animations are correct and efficient — this is well-used.

**`ActivityChart` has `animationDuration={1000}` on the Area component.** On every re-render, the chart re-animates from scratch.

### Memoization Opportunities

- `MetricCard` should be `React.memo` — its props are all primitives and it receives no callbacks
- All static data arrays in `Analytics.tsx` (incidentTrendData, mttrData, etc.) are declared at module scope, which is correct — they won't trigger re-renders
- `ResponderRow`, `ServiceTableRow`, `Panel`, `SlaGauge` in Analytics should be extracted to their own files and wrapped in `React.memo`
- The `navItems` array in `Sidebar.tsx` is declared at module scope (correct)

### Virtualization Candidates

- The service reliability table (8 rows today) needs virtualization at 50+ services
- The incident list on `IncidentDashboard` needs virtualization at 100+ incidents
- The responder table needs virtualization at 20+ engineers

### Chart Rendering

- All Recharts charts use `ResponsiveContainer` which is correct
- Custom `ChartTooltip` in Analytics is a good pattern — avoids Recharts' default tooltip re-render behavior
- No chart is memoized — consider `React.memo` wrappers for chart-only components

### CRA Limitations

CRA (Create React App) has been deprecated and unmaintained since 2022. It bundles with Webpack 4, has no built-in code splitting by route, slow HMR, and no tree-shaking optimizations available in Vite/Turbopack. For a tool used in production incident response, bundle size and hot-reload speed in development matter.

---

## 5. Production-Readiness Assessment

| Concern | Status |
|---|---|
| Authentication flow | ❌ Store is empty; LoginPage/RegisterPage exist but non-functional |
| Protected routes | ⚠️ `PrivateRoute` component exists but auth state is absent |
| API integration | ⚠️ `axiosClient` is correct; all API methods are likely stubs |
| Error handling | ⚠️ `ErrorBoundary` exists; no error states in individual components |
| Loading states | ❌ No loading skeletons anywhere; `LoadingSpinner` exists but is unused in routes |
| Empty states | ❌ No empty states on any list |
| Responsive design | ⚠️ Grid breakpoints exist on the main dashboard; Analytics page has no responsive layout |
| Real-time data | ❌ All data is hardcoded static mock |
| TypeScript coverage | ❌ Domain types are empty; no type safety on the most critical data |
| Testing | ❌ `setupTests.ts` is boilerplate only; no tests exist |
| Environment config | ⚠️ `.env` file exists; `REACT_APP_API_URL` is configured |
| Accessibility | ❌ No aria attributes, no focus management, no reduced-motion support |

---

## 6. Technical Debt Risks

### Critical (Address Before Any New Features)

**Empty type files.** The `types/` directory is the single greatest risk. Every future component will define its own inline interface, creating a divergent type ecosystem that's impossible to refactor. An `Incident` type defined in `IncidentDashboard.tsx`, a different one in `IncidentCard.tsx`, and a third in `Analytics.tsx` is exactly what happens when shared types don't exist. It's already happening — `IncidentCard` has severity as `"critical" | "warning" | "resolved"` while `IncidentDashboard` uses `"CRITICAL" | "HIGH" | "MEDIUM"` as strings. This inconsistency will produce runtime errors when you connect real data.

**Empty state management files.** Building more features on top of an absent state layer will mean rewriting all data flow twice.

**Two `MetricCard` components with the same name.** The analytics-local `MetricCard` and `components/MetricCard` will collide the moment any refactoring occurs. One needs to be renamed or merged.

### High

**`Analytics.tsx` monolith.** This file will become unmaintainable past 1000 lines. The component boundaries are already drawn internally — they just need to be externalized.

**Inline mock data in `App.tsx` and `IncidentDashboard.tsx`.** `mockIncidents` array living in `App.tsx` means the dashboard cannot be tested or developed independently.

**CSS file proliferation.** Eight CSS entry points with unknown cascade ordering create specificity bugs that are painful to debug under pressure.

**`PlaceholderPage` in production routes.** Five routes going nowhere is not a "to-do" — it's a product liability.

### Medium

**No error boundaries per route.** A single `ErrorBoundary` at the app level means one bad API call can crash the entire platform.

**`setInterval` in `LiveAlertTicker` with no websocket upgrade path.** Polling every 4s for alert display is fine for a prototype. Connecting real data will require replacing this entirely with a WebSocket or SSE pattern.

**`reportWebVitals.ts`** is CRA boilerplate that is almost certainly unused.

---

## 7. Top 10 Improvements to Prioritize

### 1. Fill the Type Files (1 day)

Define `Incident`, `Alert`, `User`, `Service`, `OnCallSchedule` types in their respective files. Add `severity` as a proper union type with consistent casing across the entire app. This is the highest-leverage change in the codebase.

```typescript
// types/incident.ts
export type IncidentSeverity = 'critical' | 'high' | 'medium' | 'low';
export type IncidentStatus = 'triggered' | 'acknowledged' | 'investigating' | 'resolved';

export interface Incident {
  id: string;
  title: string;
  severity: IncidentSeverity;
  status: IncidentStatus;
  service: string;
  createdAt: string;
  assignee?: string;
  impact?: string;
}
```

### 2. Implement State Management (2 days)

Add Zustand (or TanStack Query for server state). Implement `incidentStore` with at minimum: `incidents[]`, `activeIncident`, `fetchIncidents()`, `acknowledgeIncident()`. Even wired to mock data, this unlocks cross-component state sharing.

### 3. Build the Alerts Page (2–3 days)

Replace the `PlaceholderPage` at `/alerts` with a real `AlertsTable` component. This is where `AlertsTable.tsx` presumably belongs (it's in the directory but wasn't in the zip). A filterable, sortable table of alerts with severity badges, acknowledgement actions, and source labels would immediately elevate the perceived completeness of the platform.

### 4. Rebuild `IncidentDashboard.tsx` (1–2 days)

This page needs to match the design language of the main dashboard and analytics page. Add severity-conditional styling, click-through to `IncidentDetail`, a status filter row (All / Triggered / Acknowledged / Resolved), and proper empty/loading states.

### 5. Extract `Analytics.tsx` into Sub-Components (1 day)

Split into: `analytics/components/MetricCards.tsx`, `IncidentTrendChart.tsx`, `MttrChart.tsx`, `AlertNoiseChart.tsx`, `SloGauges.tsx`, `ServiceReliabilityTable.tsx`, `ResponderWorkload.tsx`, `OperationalIntelligence.tsx`. The main `Analytics.tsx` becomes a layout compositor only.

### 6. Add Lazy Loading to Routes (2 hours)

```tsx
const Analytics = React.lazy(() => import('./analytics/Analytics'));
const IncidentDashboard = React.lazy(() => import('./incidents/IncidentDashboard'));
```

Wrap in `<Suspense fallback={<LoadingSpinner />}>`. Use the existing `LoadingSpinner` component that's already built but never used.

### 7. Migrate from CRA to Vite (2–4 hours)

```bash
npm create vite@latest -- --template react-ts
```

Vite provides: ~10x faster HMR, native ESM, smaller production bundles, built-in code splitting. CRA is deprecated and will eventually block package upgrades.

### 8. Add `prefers-reduced-motion` Support (2 hours)

```tsx
const prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

// In Framer Motion components:
transition={{ duration: prefersReducedMotion ? 0 : 0.5 }}
```

This is both an accessibility requirement and a performance improvement on low-end machines used in war rooms.

### 9. Consolidate CSS (2 hours)

Delete `App.css`, `styles/index.css`, `styles/tailwind.css`. Merge everything into `styles/globals.css`. Add a CSS variable token sheet for the color palette currently hardcoded as hex strings across both Tailwind classes and inline styles.

### 10. Add Route-Level Error Boundaries (1 hour)

Wrap each `<Route>` element in a dedicated `ErrorBoundary`. A crash in Analytics should not take down Incidents. This is table stakes for any ops tool where availability of the tool itself is critical.

---

## 8. Long-Term Frontend Architecture Recommendations

### Feature-Based Module Architecture

Move from the current loose domain folders to a strict feature module pattern:

```
src/
├── features/
│   ├── dashboard/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── store/
│   │   └── index.tsx
│   ├── incidents/
│   │   ├── components/
│   │   │   ├── IncidentList.tsx
│   │   │   ├── IncidentCard.tsx
│   │   │   ├── IncidentDetail.tsx
│   │   │   ├── IncidentTimeline.tsx
│   │   │   └── IncidentStatusBadge.tsx
│   │   ├── hooks/
│   │   │   ├── useIncidents.ts
│   │   │   └── useIncidentDetail.ts
│   │   ├── store/
│   │   │   └── incidentStore.ts
│   │   └── index.tsx
│   ├── alerts/
│   ├── analytics/
│   ├── on-call/
│   └── settings/
├── shared/
│   ├── components/    # MetricCard, Sidebar, ErrorBoundary, LoadingSpinner
│   ├── hooks/         # usePolling, useWebSocket
│   ├── types/         # All domain types
│   ├── api/           # axiosClient + typed API methods
│   └── utils/
└── app/
    ├── App.tsx        # Layout only
    ├── Router.tsx     # Route definitions only
    └── providers/     # Auth, Theme, QueryClient providers
```

### Server State Management

For a real ops platform, TanStack Query (React Query) is the correct choice over Zustand for server data:
- Built-in polling with `refetchInterval`
- Stale-while-revalidate for dashboard freshness
- Optimistic updates for acknowledge/resolve actions
- Background refetching when the tab regains focus (critical for ops tools)

Zustand remains appropriate for UI state (sidebar collapse, active filters, modal state).

### Real-Time Data Layer

The current polling architecture (`usePolling`) is acceptable for a 30s refresh dashboard. For true real-time incident feeds, the architecture should support:

```
WebSocket (preferred) → SSE (fallback) → Polling (degraded)
```

This is a real pattern used by PagerDuty and Opsgenie. Implementing even a mock WebSocket adapter that can be swapped for a real one demonstrates this thinking.

### Design Token System

Formalize the color and spacing tokens that are currently implicit:

```css
/* tokens.css */
--color-critical: #ef4444;
--color-critical-bg: rgba(239, 68, 68, 0.1);
--color-critical-border: rgba(239, 68, 68, 0.3);
--color-high: #f97316;
--color-warning: #eab308;
--color-resolved: #22c55e;
--color-surface-primary: rgba(15, 23, 42, 0.72);
--color-surface-elevated: rgba(30, 41, 59, 0.88);
```

This prevents the current situation where `#ef4444` for critical is hardcoded in at least 6 different places across the codebase.

### Testing Strategy

For an ops tool, the highest-value tests are:
- Unit tests on severity color logic and date formatting utilities
- Integration tests on the incident store (acknowledge, resolve, escalate flows)
- E2E tests on the incident acknowledgement workflow (Playwright)
- Visual regression tests on the Analytics page (Chromatic/Percy)

---

## 9. Recruiter-Impact Assessment

### What Works in Your Favor

**The visual quality of the Dashboard and Analytics pages is competitive.** The glassmorphism aesthetic, the Framer Motion spring animations, the Recharts integration with custom tooltips, and the operational vocabulary (MTTA, MTTR, alert noise ratio, SLO compliance, burnout risk) all signal genuine effort and domain research. A recruiter scrolling through a Loom recording of these two pages would be impressed.

**The Analytics page alone demonstrates:** Recharts mastery, custom SVG sparklines, responsive grid layouts, real-time simulated data, proper dark theme design, and knowledge of SRE concepts. That's a strong signal.

**The Framer Motion usage** — particularly `layoutId` for the sidebar active indicator — shows awareness of advanced animation patterns beyond basic CSS transitions.

### What Will Hurt You

**An SRE or platform engineer reviewing this codebase** (not just watching a demo) will immediately open `types/incident.ts` and find `export {}`. This will read as "the author knows they need types but didn't write them." It undermines the TypeScript claim on the resume more than not using TypeScript at all.

**Five placeholder pages with emoji** is the most visually obvious incompleteness signal. Clicking "On-Call" during an interview demo and seeing a construction site is a hard stop.

**The IncidentDashboard being visually inconsistent** with the rest of the app suggests the author ran out of time or motivation. In a production context, visual consistency is a proxy for engineering discipline.

**The empty hooks and stores** — a technical reviewer will `grep` for `useState` and `useEffect` patterns, look at the store files, and conclude the app has no real data layer.

### What Would Immediately Impress a Backend or SRE Recruiter

- A working incident acknowledge/resolve flow (even against mock data)
- Keyboard shortcuts (`j`/`k` to navigate incidents, `a` to acknowledge) — PagerDuty does this
- A real-time WebSocket mock showing live alert ingestion
- An on-call schedule view (even static)
- Runbook links on incident detail pages
- A working search across incidents
- An audit log / timeline on incident detail (`IncidentTimeline.tsx` exists but is empty)

---

## 10. Final Realism Score

**6.5 / 10**

### Score Breakdown

| Dimension | Score | Notes |
|---|---|---|
| Visual Design Quality | 8/10 | Dashboard and Analytics are genuinely strong |
| Architectural Discipline | 4/10 | Empty types, hooks, stores undercut the structure |
| Feature Completeness | 3/10 | 5 of 7 routes are placeholders |
| TypeScript Quality | 3/10 | Domain types are entirely absent |
| Operational Realism | 7/10 | Vocabulary and data models are authentic |
| Performance Awareness | 5/10 | CRA, no memoization, infinite Framer Motion loops |
| Code Consistency | 5/10 | Analytics page vs IncidentDashboard are from different universes |
| Enterprise Credibility | 6/10 | Looks real at demo speed; breaks under inspection |

### Final Verdict

This project sits exactly at the boundary between "portfolio demo" and "believable internal tool." The visual craft is real. The SRE domain knowledge is real. The engineering infrastructure is a convincing skeleton that hasn't been filled in.

The path from 6.5 to 8.5 is not more features — it's filling in what's already declared. Write the types. Implement the stores. Build the incident detail and timeline that already have files. Turn the placeholder routes into real pages. That work is less glamorous than building a new chart but it's the work that separates a demo from a product.

> "The difference between a senior engineer's portfolio and a junior engineer's portfolio isn't what they built. It's what they finished."

---

*Audit completed. All findings are based on static analysis of the source files provided. No runtime or network behavior was evaluated.*
import { useState, useEffect, FC, ReactNode } from "react";
import {
  AreaChart, Area, LineChart, Line, BarChart, Bar,
  XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, TooltipProps,
} from "recharts";

// ─── TYPES ────────────────────────────────────────────────────────────────────

interface IncidentPoint {
  time: string;
  critical: number;
  high: number;
  medium: number;
  low: number;
}

interface MttrPoint { day: string; mtta: number; mttr: number; }
interface AlertNoisePoint { service: string; noisy: number; actionable: number; suppressed: number; }
interface Responder { name: string; incidents: number; p1: number; avgMttr: number; oncall: number; }
interface ServiceRow { service: string; uptime: number; p50: number; p99: number; incidents: number; }
interface SeverityItem { name: string; value: number; color: string; }
interface AlertSource { name: string; value: number; color: string; }
interface FlappingService { name: string; flaps: number; since: string; status: "critical" | "high" | "medium" | "low"; }
interface EscalatedTeam { team: string; escalations: number; avgDelay: string; }
interface Pipeline { pipeline: string; p95: string; sla: string; breach: boolean; }

// ─── DATA ─────────────────────────────────────────────────────────────────────

const incidentTrendData: IncidentPoint[] = [
  { time: "00:00", critical: 3, high: 7, medium: 12, low: 5 },
  { time: "02:00", critical: 1, high: 5, medium: 9, low: 4 },
  { time: "04:00", critical: 0, high: 3, medium: 6, low: 2 },
  { time: "06:00", critical: 2, high: 6, medium: 10, low: 6 },
  { time: "08:00", critical: 5, high: 11, medium: 18, low: 9 },
  { time: "10:00", critical: 8, high: 14, medium: 22, low: 11 },
  { time: "12:00", critical: 6, high: 10, medium: 19, low: 8 },
  { time: "14:00", critical: 9, high: 16, medium: 25, low: 13 },
  { time: "16:00", critical: 11, high: 18, medium: 28, low: 15 },
  { time: "18:00", critical: 7, high: 12, medium: 20, low: 10 },
  { time: "20:00", critical: 4, high: 9, medium: 15, low: 7 },
  { time: "22:00", critical: 6, high: 11, medium: 17, low: 9 },
];

const mttrData: MttrPoint[] = [
  { day: "Mon", mtta: 4.2, mttr: 28.5 },
  { day: "Tue", mtta: 3.8, mttr: 24.1 },
  { day: "Wed", mtta: 5.1, mttr: 31.7 },
  { day: "Thu", mtta: 3.2, mttr: 22.4 },
  { day: "Fri", mtta: 6.8, mttr: 41.2 },
  { day: "Sat", mtta: 2.9, mttr: 19.8 },
  { day: "Sun", mtta: 4.5, mttr: 26.3 },
];

const alertNoiseData: AlertNoisePoint[] = [
  { service: "payment-svc", noisy: 142, actionable: 38, suppressed: 67 },
  { service: "auth-gateway", noisy: 98, actionable: 51, suppressed: 29 },
  { service: "data-pipeline", noisy: 187, actionable: 22, suppressed: 103 },
  { service: "api-gateway", noisy: 76, actionable: 63, suppressed: 18 },
  { service: "cache-layer", noisy: 214, actionable: 15, suppressed: 142 },
  { service: "notification", noisy: 55, actionable: 47, suppressed: 12 },
];

const responderData: Responder[] = [
  { name: "alex.kim", incidents: 34, p1: 8, avgMttr: 22.4, oncall: 168 },
  { name: "sarah.chen", incidents: 28, p1: 5, avgMttr: 31.2, oncall: 144 },
  { name: "raj.patel", incidents: 41, p1: 12, avgMttr: 18.7, oncall: 192 },
  { name: "maya.jones", incidents: 19, p1: 3, avgMttr: 44.1, oncall: 96 },
  { name: "tom.wilson", incidents: 37, p1: 9, avgMttr: 27.8, oncall: 168 },
  { name: "lisa.zhang", incidents: 22, p1: 6, avgMttr: 35.6, oncall: 120 },
];

const serviceReliabilityData: ServiceRow[] = [
  { service: "api-gateway", uptime: 99.97, p50: 45, p99: 312, incidents: 2 },
  { service: "auth-service", uptime: 99.91, p50: 82, p99: 687, incidents: 7 },
  { service: "payment-svc", uptime: 99.72, p50: 124, p99: 1240, incidents: 18 },
  { service: "data-pipeline", uptime: 98.94, p50: 890, p99: 8400, incidents: 43 },
  { service: "cache-layer", uptime: 99.99, p50: 2, p99: 18, incidents: 1 },
  { service: "notification", uptime: 99.84, p50: 310, p99: 2100, incidents: 11 },
  { service: "search-svc", uptime: 99.45, p50: 420, p99: 3800, incidents: 29 },
  { service: "ml-inference", uptime: 97.82, p50: 1200, p99: 12000, incidents: 87 },
];

const severityDist: SeverityItem[] = [
  { name: "P1 Critical", value: 47, color: "#ef4444" },
  { name: "P2 High", value: 128, color: "#f97316" },
  { name: "P3 Medium", value: 243, color: "#eab308" },
  { name: "P4 Low", value: 312, color: "#3b82f6" },
];

const alertSources: AlertSource[] = [
  { name: "Prometheus", value: 38, color: "#e85d04" },
  { name: "Datadog", value: 27, color: "#818cf8" },
  { name: "CloudWatch", value: 19, color: "#f59e0b" },
  { name: "PagerDuty", value: 9, color: "#06d6a0" },
  { name: "Custom", value: 7, color: "#38bdf8" },
];

const flappingServices: FlappingService[] = [
  { name: "data-pipeline", flaps: 142, since: "2h ago", status: "critical" },
  { name: "ml-inference", flaps: 98, since: "4h ago", status: "high" },
  { name: "search-svc", flaps: 67, since: "1h ago", status: "high" },
  { name: "notification", flaps: 43, since: "6h ago", status: "medium" },
  { name: "cache-layer", flaps: 31, since: "8h ago", status: "low" },
];

const escalatedTeams: EscalatedTeam[] = [
  { team: "Platform SRE", escalations: 47, avgDelay: "8.2m" },
  { team: "Backend Eng", escalations: 38, avgDelay: "12.4m" },
  { team: "Data Eng", escalations: 31, avgDelay: "6.8m" },
  { team: "Security", escalations: 19, avgDelay: "4.1m" },
  { team: "ML Ops", escalations: 14, avgDelay: "18.7m" },
];

const slowestPipelines: Pipeline[] = [
  { pipeline: "Payment → Finance", p95: "4h 12m", sla: "2h", breach: true },
  { pipeline: "Infra → Network", p95: "2h 48m", sla: "2h", breach: true },
  { pipeline: "App → Platform", p95: "1h 33m", sla: "2h", breach: false },
  { pipeline: "Data → Analytics", p95: "1h 07m", sla: "1h", breach: true },
  { pipeline: "Security → CISO", p95: "45m", sla: "1h", breach: false },
];

const sparkDefault = [3, 7, 5, 9, 4, 8, 6, 11, 8, 14, 10, 12];
const sparkMttr    = [31, 28, 33, 24, 41, 20, 26, 29, 22, 35, 27, 28];
const sparkNoise   = [68, 72, 65, 78, 81, 74, 70, 85, 77, 82, 69, 74];
const sparkSla     = [99.1, 99.3, 99.0, 98.8, 99.2, 99.4, 99.6, 99.5, 99.7, 99.8, 99.6, 99.7];

// ─── SPARKLINE ────────────────────────────────────────────────────────────────

interface SparklineProps { data: number[]; color?: string; danger?: boolean; }

const Sparkline: FC<SparklineProps> = ({ data, color = "#38bdf8", danger = false }) => {
  const c = danger ? "#f87171" : color;
  const max = Math.max(...data);
  const min = Math.min(...data);
  const range = max - min || 1;
  const W = 80, H = 28;
  const points = data.map((v, i) => ({
    x: (i / (data.length - 1)) * W,
    y: H - ((v - min) / range) * H,
  }));
  const polyline = points.map(p => `${p.x},${p.y}`).join(" ");
  const area = `M0,${H} ${points.map(p => `L${p.x},${p.y}`).join(" ")} L${W},${H} Z`;
  const gradId = `sg${c.replace("#", "")}`;
  return (
    <svg width={W} height={H} style={{ overflow: "visible", flexShrink: 0 }}>
      <defs>
        <linearGradient id={gradId} x1="0" y1="0" x2="0" y2="1">
          <stop offset="0%" stopColor={c} stopOpacity="0.35" />
          <stop offset="100%" stopColor={c} stopOpacity="0" />
        </linearGradient>
      </defs>
      <path d={area} fill={`url(#${gradId})`} />
      <polyline points={polyline} fill="none" stroke={c} strokeWidth="1.5" strokeLinejoin="round" />
    </svg>
  );
};

// ─── PULSE DOT ────────────────────────────────────────────────────────────────

const PulseDot: FC<{ color?: string }> = ({ color = "#38bdf8" }) => (
  <span style={{ position: "relative", display: "inline-flex", alignItems: "center", justifyContent: "center", width: 10, height: 10, flexShrink: 0 }}>
    <span style={{ position: "absolute", width: 10, height: 10, borderRadius: "50%", background: color, opacity: 0.4, animation: "pulse-ring 2s ease-out infinite" }} />
    <span style={{ width: 6, height: 6, borderRadius: "50%", background: color, display: "block", flexShrink: 0 }} />
  </span>
);

// ─── STATUS BADGE ─────────────────────────────────────────────────────────────

const statusMap: Record<string, { bg: string; color: string }> = {
  critical: { bg: "rgba(239,68,68,0.15)",  color: "#f87171" },
  high:     { bg: "rgba(249,115,22,0.15)", color: "#fb923c" },
  medium:   { bg: "rgba(234,179,8,0.15)",  color: "#fbbf24" },
  low:      { bg: "rgba(59,130,246,0.15)", color: "#60a5fa" },
};

const StatusBadge: FC<{ status: string }> = ({ status }) => {
  const s = statusMap[status] ?? statusMap.low;
  return (
    <span style={{ background: s.bg, color: s.color, fontSize: 10, fontWeight: 700, padding: "2px 6px", borderRadius: 3, letterSpacing: "0.05em", whiteSpace: "nowrap" }}>
      {status.toUpperCase()}
    </span>
  );
};

// ─── UPTIME BADGE ─────────────────────────────────────────────────────────────

const UptimeBadge: FC<{ value: number }> = ({ value }) => {
  const color = value >= 99.9 ? "#22c55e" : value >= 99 ? "#eab308" : "#ef4444";
  const bg    = value >= 99.9 ? "rgba(34,197,94,0.12)" : value >= 99 ? "rgba(234,179,8,0.12)" : "rgba(239,68,68,0.12)";
  return (
    <span style={{ background: bg, color, fontSize: 11, fontWeight: 600, padding: "2px 7px", borderRadius: 4, fontFamily: "monospace", whiteSpace: "nowrap" }}>
      {value.toFixed(2)}%
    </span>
  );
};

// ─── CUSTOM TOOLTIP ───────────────────────────────────────────────────────────

interface ChartTooltipPayload { name?: string; value?: number | string; color?: string; }

interface ChartTooltipProps extends TooltipProps<number, string> {
  payload?: ChartTooltipPayload[];
  label?: string | number;
}

const ChartTooltip: FC<ChartTooltipProps> = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;
  return (
    <div style={{ background: "rgba(2,8,23,0.97)", border: "1px solid rgba(56,189,248,0.2)", borderRadius: 8, padding: "10px 14px", fontSize: 12 }}>
      <p style={{ color: "#94a3b8", marginBottom: 6, fontWeight: 600, margin: "0 0 6px" }}>{label}</p>
      {payload.map((p, i) => (
        <p key={i} style={{ color: p.color ?? "#e2e8f0", margin: "3px 0" }}>
          {p.name}: <strong style={{ color: "#e2e8f0" }}>{typeof p.value === "number" ? p.value.toFixed(1) : p.value}</strong>
        </p>
      ))}
    </div>
  );
};

// ─── PANEL ────────────────────────────────────────────────────────────────────

interface PanelProps { title?: string; subtitle?: string; accent?: boolean; noPad?: boolean; children: ReactNode; }

const Panel: FC<PanelProps> = ({ title, subtitle, accent = false, noPad = false, children }) => (
  <div style={{
    background: "rgba(15,23,42,0.72)",
    border: accent ? "1px solid rgba(56,189,248,0.22)" : "1px solid rgba(30,41,59,0.9)",
    borderRadius: 12, backdropFilter: "blur(14px)", overflow: "hidden",
  }}>
    {(title || subtitle) && (
      <div style={{ padding: "13px 20px", borderBottom: "1px solid rgba(30,41,59,0.8)", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <div>
          <h3 style={{ fontSize: 13, fontWeight: 700, color: "#e2e8f0", margin: 0, letterSpacing: "0.03em" }}>{title}</h3>
          {subtitle && <p style={{ fontSize: 11, color: "#475569", margin: "2px 0 0", fontWeight: 500 }}>{subtitle}</p>}
        </div>
        <span style={{ width: 6, height: 6, borderRadius: "50%", background: accent ? "#38bdf8" : "#1e293b", display: "block", flexShrink: 0 }} />
      </div>
    )}
    <div style={noPad ? {} : { padding: "16px 20px" }}>{children}</div>
  </div>
);

// ─── SECTION LABEL ────────────────────────────────────────────────────────────

const SectionLabel: FC<{ label: string }> = ({ label }) => (
  <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 14 }}>
    <div style={{ width: 3, height: 16, background: "linear-gradient(180deg,#38bdf8,#6366f1)", borderRadius: 2, flexShrink: 0 }} />
    <span style={{ fontSize: 11, fontWeight: 700, color: "#64748b", letterSpacing: "0.12em", textTransform: "uppercase" }}>{label}</span>
  </div>
);

// ─── METRIC CARD ──────────────────────────────────────────────────────────────

interface MetricCardProps {
  title: string; value: string | number; unit?: string;
  trend: "up" | "down"; trendVal: string;
  sparkData?: number[]; color?: string; badTrendUp?: boolean;
}

const MetricCard: FC<MetricCardProps> = ({ title, value, unit, trend, trendVal, sparkData, color = "#38bdf8", badTrendUp = false }) => {
  const [hovered, setHovered] = useState(false);
  const trendUp = trend === "up";
  const trendColor = badTrendUp ? (trendUp ? "#f87171" : "#4ade80") : (trendUp ? "#4ade80" : "#f87171");

  return (
    <div
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        background: hovered ? "rgba(30,41,59,0.88)" : "rgba(15,23,42,0.72)",
        border: `1px solid ${hovered ? "rgba(56,189,248,0.28)" : "rgba(56,189,248,0.1)"}`,
        borderRadius: 12, padding: "18px 20px",
        transition: "all 0.22s ease",
        transform: hovered ? "translateY(-2px) scale(1.012)" : "none",
        boxShadow: hovered ? "0 8px 32px rgba(56,189,248,0.07)" : "none",
        backdropFilter: "blur(14px)", cursor: "default", position: "relative", overflow: "hidden",
      }}
    >
      {hovered && <div style={{ position: "absolute", inset: 0, pointerEvents: "none", background: "radial-gradient(circle at 50% -20%, rgba(56,189,248,0.05) 0%, transparent 65%)" }} />}
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 10 }}>
        <span style={{ fontSize: 10, color: "#475569", fontWeight: 700, letterSpacing: "0.1em", textTransform: "uppercase" }}>{title}</span>
        <PulseDot color={color} />
      </div>
      <div style={{ display: "flex", alignItems: "baseline", gap: 4, marginBottom: 14 }}>
        <span style={{ fontSize: 30, fontWeight: 700, color: "#f1f5f9", fontFamily: "monospace", lineHeight: 1 }}>{value}</span>
        {unit && <span style={{ fontSize: 12, color: "#475569", fontWeight: 500 }}>{unit}</span>}
      </div>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 5 }}>
          <span style={{ fontSize: 12, color: trendColor, fontWeight: 700 }}>{trendUp ? "▲" : "▼"} {trendVal}</span>
          <span style={{ fontSize: 10, color: "#334155" }}>vs prev</span>
        </div>
        <Sparkline data={sparkData ?? sparkDefault} color={color} danger={badTrendUp && trendUp} />
      </div>
    </div>
  );
};

// ─── RESPONDER ROW ────────────────────────────────────────────────────────────

interface ResponderRowProps extends Responder { maxIncidents: number; }

const ResponderRow: FC<ResponderRowProps> = ({ name, incidents, p1, avgMttr, oncall, maxIncidents }) => {
  const pct = (incidents / maxIncidents) * 100;
  const burnout = oncall > 160;
  const initials = name.split(".").map(p => p[0].toUpperCase()).join("");
  const hue = (name.charCodeAt(0) * 47 + name.charCodeAt(name.length - 1) * 13) % 360;
  return (
    <div style={{ marginBottom: 14 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 5, flexWrap: "wrap", gap: 4 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          <div style={{ width: 26, height: 26, borderRadius: "50%", background: `hsl(${hue},55%,30%)`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 9, fontWeight: 800, color: "#e2e8f0", flexShrink: 0 }}>{initials}</div>
          <span style={{ fontSize: 12, color: "#cbd5e1", fontFamily: "monospace" }}>{name}</span>
          {burnout && <span style={{ fontSize: 9, fontWeight: 700, background: "rgba(239,68,68,0.15)", color: "#f87171", padding: "1px 5px", borderRadius: 3, letterSpacing: "0.05em" }}>BURNOUT RISK</span>}
        </div>
        <div style={{ display: "flex", gap: 14, fontSize: 11 }}>
          <span style={{ color: "#475569" }}>P1: <strong style={{ color: "#f87171" }}>{p1}</strong></span>
          <span style={{ color: "#475569" }}>MTTR: <strong style={{ color: "#94a3b8" }}>{avgMttr}m</strong></span>
          <span style={{ color: "#475569" }}>On-call: <strong style={{ color: burnout ? "#f87171" : "#94a3b8" }}>{oncall}h</strong></span>
        </div>
      </div>
      <div style={{ height: 4, background: "rgba(15,23,42,0.8)", borderRadius: 2, overflow: "hidden" }}>
        <div style={{ height: "100%", width: `${pct}%`, background: burnout ? "linear-gradient(90deg,#ef4444,#f97316)" : "linear-gradient(90deg,#3b82f6,#38bdf8)", borderRadius: 2, transition: "width 1.2s ease" }} />
      </div>
      <span style={{ fontSize: 10, color: "#334155", marginTop: 3, display: "block" }}>{incidents} total incidents</span>
    </div>
  );
};

// ─── SERVICE ROW ──────────────────────────────────────────────────────────────

const ServiceTableRow: FC<ServiceRow> = ({ service, uptime, p50, p99, incidents }) => {
  const barColor = uptime >= 99.9 ? "#22c55e" : uptime >= 99 ? "#eab308" : "#ef4444";
  return (
    <div style={{ display: "grid", gridTemplateColumns: "160px 1fr 90px 70px 80px 58px", alignItems: "center", gap: 12, padding: "9px 0", borderBottom: "1px solid rgba(30,41,59,0.5)" }}>
      <span style={{ fontSize: 12, color: "#94a3b8", fontFamily: "monospace", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{service}</span>
      <div style={{ height: 4, background: "rgba(15,23,42,0.8)", borderRadius: 2 }}>
        <div style={{ height: "100%", width: `${Math.min(uptime, 100)}%`, minWidth: "2%", background: barColor, borderRadius: 2 }} />
      </div>
      <UptimeBadge value={uptime} />
      <span style={{ fontSize: 11, color: "#475569", textAlign: "right", fontFamily: "monospace" }}>{p50}ms</span>
      <span style={{ fontSize: 11, color: "#475569", textAlign: "right", fontFamily: "monospace" }}>{p99 >= 1000 ? `${(p99 / 1000).toFixed(1)}s` : `${p99}ms`}</span>
      <span style={{ fontSize: 11, color: incidents > 20 ? "#f87171" : "#475569", textAlign: "right", fontWeight: incidents > 20 ? 700 : 400, fontFamily: "monospace" }}>{incidents}</span>
    </div>
  );
};

// ─── SLA GAUGE ────────────────────────────────────────────────────────────────

const SlaGauge: FC<{ value: number; label: string; target: number }> = ({ value, label, target }) => {
  const ok = value >= target;
  const color = ok ? "#22c55e" : value >= target - 0.5 ? "#eab308" : "#ef4444";
  const radius = 36, stroke = 6;
  const circ = 2 * Math.PI * radius;
  const dash = (value / 100) * circ;
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
      <div style={{ position: "relative", width: 88, height: 88 }}>
        <svg width={88} height={88} style={{ transform: "rotate(-90deg)" }}>
          <circle cx={44} cy={44} r={radius} fill="none" stroke="rgba(30,41,59,0.8)" strokeWidth={stroke} />
          <circle cx={44} cy={44} r={radius} fill="none" stroke={color} strokeWidth={stroke} strokeLinecap="round"
            strokeDasharray={circ} strokeDashoffset={circ - dash} style={{ transition: "stroke-dashoffset 1.2s ease" }} />
        </svg>
        <div style={{ position: "absolute", inset: 0, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center" }}>
          <span style={{ fontSize: 13, fontWeight: 700, color, fontFamily: "monospace", lineHeight: 1 }}>{value.toFixed(1)}%</span>
        </div>
      </div>
      <span style={{ fontSize: 11, color: "#64748b", textAlign: "center", fontWeight: 600 }}>{label}</span>
      <span style={{ fontSize: 10, color: ok ? "#4ade80" : "#f87171", fontWeight: 700 }}>{ok ? `▲ ${(value - target).toFixed(2)}% above SLO` : `▼ SLO breach`}</span>
    </div>
  );
};

// ─── MAIN PAGE ────────────────────────────────────────────────────────────────

const OperationalAnalytics: FC = () => {
  const [timeframe, setTimeframe] = useState("24h");
  const [env, setEnv] = useState("production");
  const [tick, setTick] = useState(0);

  useEffect(() => {
    const t = setInterval(() => setTick(x => x + 1), 3000);
    return () => clearInterval(t);
  }, []);

  // Simulated live metric drift
  const liveMtta = (4.2 + Math.sin(tick * 0.31) * 0.18).toFixed(1);
  const liveMttr = (28.5 + Math.sin(tick * 0.19) * 1.2).toFixed(1);
  const liveTotal = 730 + Math.floor(Math.sin(tick * 0.07) * 3);
  const liveCritical = 47 + Math.floor(Math.sin(tick * 0.13) * 2);

  const selectStyle: React.CSSProperties = {
    background: "rgba(15,23,42,0.85)", border: "1px solid rgba(56,189,248,0.2)",
    borderRadius: 7, color: "#94a3b8", fontSize: 12, padding: "6px 10px",
    cursor: "pointer", outline: "none", fontFamily: "inherit",
  };

  const btnStyle: React.CSSProperties = {
    background: "rgba(56,189,248,0.1)", border: "1px solid rgba(56,189,248,0.25)",
    borderRadius: 7, color: "#38bdf8", fontSize: 12, padding: "6px 14px",
    cursor: "pointer", fontWeight: 600, letterSpacing: "0.03em", fontFamily: "inherit",
  };

  return (
    <div style={{
      minHeight: "100vh",
      background: "linear-gradient(135deg,#020817 0%,#0a1628 55%,#060d1f 100%)",
      color: "#e2e8f0", fontFamily: "'Inter','SF Pro Text',system-ui,sans-serif",
      fontSize: 14, lineHeight: 1.5,
    }}>
      <style>{`
        @keyframes pulse-ring {
          0%   { transform: scale(1); opacity: 0.5; }
          100% { transform: scale(2.6); opacity: 0; }
        }
        @keyframes drift {
          0%,100% { opacity: 0.3; transform: scaleX(1); }
          50%      { opacity: 0.55; transform: scaleX(1.01); }
        }
        ::-webkit-scrollbar { width: 5px; }
        ::-webkit-scrollbar-track { background: rgba(15,23,42,0.5); }
        ::-webkit-scrollbar-thumb { background: rgba(56,189,248,0.18); border-radius: 3px; }
      `}</style>

      {/* Grid overlay */}
      <div style={{
        position: "fixed", inset: 0, pointerEvents: "none", zIndex: 0,
        backgroundImage: "linear-gradient(rgba(56,189,248,0.025) 1px,transparent 1px),linear-gradient(90deg,rgba(56,189,248,0.025) 1px,transparent 1px)",
        backgroundSize: "48px 48px",
      }} />
      {/* Ambient glow */}
      <div style={{ position: "fixed", top: -200, left: "30%", width: 600, height: 400, background: "radial-gradient(ellipse,rgba(56,189,248,0.04) 0%,transparent 70%)", pointerEvents: "none", zIndex: 0 }} />

      <div style={{ position: "relative", zIndex: 1, maxWidth: 1440, margin: "0 auto", padding: "0 28px 64px" }}>

        {/* ── TOP HEADER ── */}
        <div style={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          padding: "20px 0 24px", borderBottom: "1px solid rgba(30,41,59,0.7)",
          marginBottom: 28, flexWrap: "wrap", gap: 14,
        }}>
          <div style={{ display: "flex", flexDirection: "column", gap: 4 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
              <h1 style={{ fontSize: 22, fontWeight: 800, color: "#f1f5f9", margin: 0, letterSpacing: "-0.02em" }}>
                Operational Analytics
              </h1>
              <div style={{ display: "flex", alignItems: "center", gap: 6, background: "rgba(34,197,94,0.1)", border: "1px solid rgba(34,197,94,0.2)", borderRadius: 20, padding: "3px 10px" }}>
                <PulseDot color="#22c55e" />
                <span style={{ fontSize: 11, color: "#4ade80", fontWeight: 700, letterSpacing: "0.06em" }}>LIVE</span>
              </div>
            </div>
            <p style={{ fontSize: 12, color: "#475569", margin: 0 }}>SRE intelligence · incident reliability · service observability</p>
          </div>
          <div style={{ display: "flex", alignItems: "center", gap: 10, flexWrap: "wrap" }}>
            <select value={timeframe} onChange={e => setTimeframe(e.target.value)} style={selectStyle}>
              <option value="1h">Last 1h</option>
              <option value="6h">Last 6h</option>
              <option value="24h">Last 24h</option>
              <option value="7d">Last 7d</option>
              <option value="30d">Last 30d</option>
            </select>
            <select value={env} onChange={e => setEnv(e.target.value)} style={selectStyle}>
              <option value="production">Production</option>
              <option value="staging">Staging</option>
              <option value="all">All Environments</option>
            </select>
            <button style={btnStyle}>⬇ Export Report</button>
          </div>
        </div>

        {/* ── METRIC CARDS ── */}
        <div style={{ marginBottom: 36 }}>
          <SectionLabel label="Key Operational Metrics" />
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(210px,1fr))", gap: 14 }}>
            <MetricCard title="MTTA" value={liveMtta} unit="min" trend="down" trendVal="0.6m" sparkData={sparkDefault} color="#38bdf8" />
            <MetricCard title="MTTR" value={liveMttr} unit="min" trend="down" trendVal="3.2m" sparkData={sparkMttr} color="#818cf8" />
            <MetricCard title="Total Incidents" value={liveTotal} trend="up" trendVal="4.8%" sparkData={[68,72,65,78,81,74,70,85,77,82,69,74]} color="#f97316" badTrendUp />
            <MetricCard title="Critical (P1)" value={liveCritical} trend="down" trendVal="12%" sparkData={[8,11,7,14,9,12,8,10,6,9,7,8]} color="#f87171" badTrendUp />
            <MetricCard title="Alert Noise Ratio" value="67.3" unit="%" trend="down" trendVal="2.1%" sparkData={sparkNoise} color="#fbbf24" badTrendUp />
            <MetricCard title="SLA Compliance" value="99.7" unit="%" trend="up" trendVal="0.3%" sparkData={sparkSla} color="#4ade80" />
          </div>
        </div>

        {/* ── CHARTS ROW 1 ── */}
        <div style={{ marginBottom: 28 }}>
          <SectionLabel label="Incident Intelligence" />
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 18 }}>

            {/* Incident Trend */}
            <Panel title="Incident Volume by Severity" subtitle="24h rolling window · stacked area" accent>
              <ResponsiveContainer width="100%" height={220}>
                <AreaChart data={incidentTrendData} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                  <defs>
                    {(["critical","high","medium","low"] as const).map((k, i) => {
                      const colors = { critical: "#ef4444", high: "#f97316", medium: "#eab308", low: "#3b82f6" };
                      return (
                        <linearGradient key={k} id={`grad-${k}`} x1="0" y1="0" x2="0" y2="1">
                          <stop offset="0%" stopColor={colors[k]} stopOpacity="0.5" />
                          <stop offset="100%" stopColor={colors[k]} stopOpacity="0.05" />
                        </linearGradient>
                      );
                    })}
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(30,41,59,0.6)" />
                  <XAxis dataKey="time" tick={{ fill: "#475569", fontSize: 10 }} axisLine={false} tickLine={false} />
                  <YAxis tick={{ fill: "#475569", fontSize: 10 }} axisLine={false} tickLine={false} />
                  <Tooltip content={<ChartTooltip />} />
                  <Area type="monotone" dataKey="critical" stackId="1" stroke="#ef4444" fill="url(#grad-critical)" strokeWidth={1.5} name="Critical" />
                  <Area type="monotone" dataKey="high"     stackId="1" stroke="#f97316" fill="url(#grad-high)"     strokeWidth={1.5} name="High" />
                  <Area type="monotone" dataKey="medium"   stackId="1" stroke="#eab308" fill="url(#grad-medium)"   strokeWidth={1.5} name="Medium" />
                  <Area type="monotone" dataKey="low"      stackId="1" stroke="#3b82f6" fill="url(#grad-low)"      strokeWidth={1.5} name="Low" />
                </AreaChart>
              </ResponsiveContainer>
              <div style={{ display: "flex", gap: 16, marginTop: 8, flexWrap: "wrap" }}>
                {[["Critical","#ef4444"],["High","#f97316"],["Medium","#eab308"],["Low","#3b82f6"]].map(([l,c]) => (
                  <span key={l} style={{ display: "flex", alignItems: "center", gap: 5, fontSize: 11, color: "#475569" }}>
                    <span style={{ width: 8, height: 8, borderRadius: 2, background: c as string, flexShrink: 0 }} />{l}
                  </span>
                ))}
              </div>
            </Panel>

            {/* MTTR / MTTA */}
            <Panel title="MTTR vs MTTA Performance" subtitle="Acknowledgement vs resolution efficiency · 7d">
              <ResponsiveContainer width="100%" height={220}>
                <LineChart data={mttrData} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(30,41,59,0.6)" />
                  <XAxis dataKey="day" tick={{ fill: "#475569", fontSize: 10 }} axisLine={false} tickLine={false} />
                  <YAxis tick={{ fill: "#475569", fontSize: 10 }} axisLine={false} tickLine={false} />
                  <Tooltip content={<ChartTooltip />} />
                  <Line type="monotone" dataKey="mttr" stroke="#818cf8" strokeWidth={2} dot={{ fill: "#818cf8", r: 3 }} name="MTTR (min)" />
                  <Line type="monotone" dataKey="mtta" stroke="#38bdf8" strokeWidth={2} dot={{ fill: "#38bdf8", r: 3 }} name="MTTA (min)" strokeDasharray="4 2" />
                </LineChart>
              </ResponsiveContainer>
              <div style={{ display: "flex", gap: 16, marginTop: 8 }}>
                <span style={{ display: "flex", alignItems: "center", gap: 5, fontSize: 11, color: "#475569" }}>
                  <span style={{ width: 20, height: 2, background: "#818cf8", display: "inline-block", flexShrink: 0 }} />MTTR
                </span>
                <span style={{ display: "flex", alignItems: "center", gap: 5, fontSize: 11, color: "#475569" }}>
                  <span style={{ width: 20, height: 2, background: "#38bdf8", display: "inline-block", flexShrink: 0, borderTop: "2px dashed #38bdf8" }} />MTTA
                </span>
              </div>
            </Panel>
          </div>
        </div>

        {/* ── CHARTS ROW 2 ── */}
        <div style={{ marginBottom: 28 }}>
          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 18 }}>

            {/* Alert Noise */}
            <Panel title="Alert Noise Analysis" subtitle="Noisy vs actionable vs suppressed alerts per service">
              <ResponsiveContainer width="100%" height={220}>
                <BarChart data={alertNoiseData} layout="vertical" margin={{ top: 0, right: 4, left: 60, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(30,41,59,0.6)" horizontal={false} />
                  <XAxis type="number" tick={{ fill: "#475569", fontSize: 10 }} axisLine={false} tickLine={false} />
                  <YAxis dataKey="service" type="category" tick={{ fill: "#64748b", fontSize: 10, fontFamily: "monospace" }} axisLine={false} tickLine={false} width={70} />
                  <Tooltip content={<ChartTooltip />} />
                  <Bar dataKey="noisy"      fill="#f97316" stackId="a" name="Noisy"       radius={[0,0,0,0]} />
                  <Bar dataKey="suppressed" fill="#475569" stackId="a" name="Suppressed"  radius={[0,0,0,0]} />
                  <Bar dataKey="actionable" fill="#22c55e" stackId="a" name="Actionable"  radius={[0,3,3,0]} />
                </BarChart>
              </ResponsiveContainer>
              <div style={{ display: "flex", gap: 14, marginTop: 8, flexWrap: "wrap" }}>
                {[["Noisy","#f97316"],["Suppressed","#475569"],["Actionable","#22c55e"]].map(([l,c]) => (
                  <span key={l} style={{ display: "flex", alignItems: "center", gap: 5, fontSize: 11, color: "#475569" }}>
                    <span style={{ width: 8, height: 8, borderRadius: 2, background: c as string, flexShrink: 0 }} />{l}
                  </span>
                ))}
              </div>
            </Panel>

            {/* Severity + Sources donut side-by-side */}
            <Panel title="Severity Distribution & Alert Sources" subtitle="Incident breakdown by priority · alert origin">
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 }}>
                <div>
                  <p style={{ fontSize: 11, color: "#475569", margin: "0 0 8px", fontWeight: 600, textAlign: "center" }}>Severity</p>
                  <ResponsiveContainer width="100%" height={160}>
                    <PieChart>
                      <Pie data={severityDist} cx="50%" cy="50%" innerRadius={42} outerRadius={68} paddingAngle={3} dataKey="value">
                        {severityDist.map((entry, i) => <Cell key={i} fill={entry.color} stroke="transparent" />)}
                      </Pie>
                      <Tooltip content={<ChartTooltip />} />
                    </PieChart>
                  </ResponsiveContainer>
                  <div style={{ display: "flex", flexDirection: "column", gap: 3, marginTop: 4 }}>
                    {severityDist.map(s => (
                      <div key={s.name} style={{ display: "flex", justifyContent: "space-between", fontSize: 10 }}>
                        <span style={{ display: "flex", alignItems: "center", gap: 4, color: "#64748b" }}>
                          <span style={{ width: 7, height: 7, borderRadius: 2, background: s.color, flexShrink: 0 }} />{s.name}
                        </span>
                        <strong style={{ color: s.color }}>{s.value}</strong>
                      </div>
                    ))}
                  </div>
                </div>
                <div>
                  <p style={{ fontSize: 11, color: "#475569", margin: "0 0 8px", fontWeight: 600, textAlign: "center" }}>Alert Sources</p>
                  <ResponsiveContainer width="100%" height={160}>
                    <PieChart>
                      <Pie data={alertSources} cx="50%" cy="50%" innerRadius={42} outerRadius={68} paddingAngle={3} dataKey="value">
                        {alertSources.map((entry, i) => <Cell key={i} fill={entry.color} stroke="transparent" />)}
                      </Pie>
                      <Tooltip content={<ChartTooltip />} />
                    </PieChart>
                  </ResponsiveContainer>
                  <div style={{ display: "flex", flexDirection: "column", gap: 3, marginTop: 4 }}>
                    {alertSources.map(s => (
                      <div key={s.name} style={{ display: "flex", justifyContent: "space-between", fontSize: 10 }}>
                        <span style={{ display: "flex", alignItems: "center", gap: 4, color: "#64748b" }}>
                          <span style={{ width: 7, height: 7, borderRadius: 2, background: s.color, flexShrink: 0 }} />{s.name}
                        </span>
                        <strong style={{ color: "#94a3b8" }}>{s.value}%</strong>
                      </div>
                    ))}
                  </div>
                </div>
              </div>
            </Panel>
          </div>
        </div>

        {/* ── SERVICE RELIABILITY ── */}
        <div style={{ marginBottom: 28 }}>
          <SectionLabel label="Service Reliability" />
          <Panel title="Service Health & Uptime Matrix" subtitle="Uptime · P50 latency · P99 latency · incident count" accent>
            <div style={{ padding: "0 4px" }}>
              <div style={{ display: "grid", gridTemplateColumns: "160px 1fr 90px 70px 80px 58px", gap: 12, padding: "0 0 8px", borderBottom: "1px solid rgba(30,41,59,0.7)", marginBottom: 4 }}>
                {["Service","Uptime Bar","SLO %","P50","P99","Inc."].map(h => (
                  <span key={h} style={{ fontSize: 10, color: "#334155", fontWeight: 700, letterSpacing: "0.08em", textTransform: "uppercase", textAlign: h === "P50" || h === "P99" || h === "Inc." ? "right" : "left" }}>{h}</span>
                ))}
              </div>
              {serviceReliabilityData.map(s => <ServiceTableRow key={s.service} {...s} />)}
            </div>
          </Panel>
        </div>

        {/* ── SLA GAUGES ── */}
        <div style={{ marginBottom: 28 }}>
          <SectionLabel label="SLA / SLO Compliance" />
          <Panel title="SLO Tracking Dashboard" subtitle="Real-time SLO compliance across critical service tiers">
            <div style={{ display: "flex", justifyContent: "space-around", flexWrap: "wrap", gap: 20, padding: "8px 0" }}>
              <SlaGauge value={99.97} label="API Gateway" target={99.9} />
              <SlaGauge value={99.72} label="Payment SVC" target={99.95} />
              <SlaGauge value={99.91} label="Auth Service" target={99.9} />
              <SlaGauge value={98.94} label="Data Pipeline" target={99.5} />
              <SlaGauge value={99.45} label="Search SVC" target={99.5} />
              <SlaGauge value={97.82} label="ML Inference" target={99.0} />
            </div>
          </Panel>
        </div>

        {/* ── RESPONDER ANALYTICS ── */}
        <div style={{ marginBottom: 28 }}>
          <SectionLabel label="Responder Load & Burnout Risk" />
          <Panel title="On-call Engineer Workload Distribution" subtitle="Incident ownership · P1 exposure · burnout risk signals">
            {(() => {
              const max = Math.max(...responderData.map(r => r.incidents));
              return responderData.map(r => <ResponderRow key={r.name} {...r} maxIncidents={max} />);
            })()}
          </Panel>
        </div>

        {/* ── INTEL PANELS ROW ── */}
        <div style={{ marginBottom: 28 }}>
          <SectionLabel label="Operational Intelligence" />
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(300px,1fr))", gap: 18 }}>

            {/* Top Flapping */}
            <Panel title="Top Flapping Services" subtitle="State oscillation · last window">
              {flappingServices.map((s, i) => (
                <div key={s.name} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "9px 0", borderBottom: i < flappingServices.length - 1 ? "1px solid rgba(30,41,59,0.5)" : "none" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                    <span style={{ fontSize: 10, color: "#334155", fontWeight: 700, width: 14, textAlign: "right", fontFamily: "monospace" }}>#{i + 1}</span>
                    <span style={{ fontSize: 12, color: "#94a3b8", fontFamily: "monospace" }}>{s.name}</span>
                  </div>
                  <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                    <span style={{ fontSize: 12, fontWeight: 700, color: "#f1f5f9", fontFamily: "monospace" }}>{s.flaps}x</span>
                    <span style={{ fontSize: 10, color: "#475569" }}>{s.since}</span>
                    <StatusBadge status={s.status} />
                  </div>
                </div>
              ))}
            </Panel>

            {/* Most Escalated */}
            <Panel title="Most Escalated Teams" subtitle="Escalation frequency · avg response delay">
              {escalatedTeams.map((t, i) => {
                const maxE = escalatedTeams[0].escalations;
                return (
                  <div key={t.team} style={{ marginBottom: i < escalatedTeams.length - 1 ? 12 : 0 }}>
                    <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 4 }}>
                      <span style={{ fontSize: 12, color: "#94a3b8" }}>{t.team}</span>
                      <div style={{ display: "flex", gap: 12, fontSize: 11 }}>
                        <span style={{ color: "#f87171", fontWeight: 700, fontFamily: "monospace" }}>{t.escalations}</span>
                        <span style={{ color: "#475569" }}>delay: <strong style={{ color: "#94a3b8" }}>{t.avgDelay}</strong></span>
                      </div>
                    </div>
                    <div style={{ height: 3, background: "rgba(15,23,42,0.8)", borderRadius: 2 }}>
                      <div style={{ height: "100%", width: `${(t.escalations / maxE) * 100}%`, background: "linear-gradient(90deg,#f87171,#f97316)", borderRadius: 2 }} />
                    </div>
                  </div>
                );
              })}
            </Panel>

            {/* Slowest Pipelines */}
            <Panel title="Slowest Resolution Pipelines" subtitle="P95 resolution time vs SLA target">
              {slowestPipelines.map((p, i) => (
                <div key={p.pipeline} style={{ display: "flex", justifyContent: "space-between", alignItems: "center", padding: "9px 0", borderBottom: i < slowestPipelines.length - 1 ? "1px solid rgba(30,41,59,0.5)" : "none", gap: 8 }}>
                  <span style={{ fontSize: 12, color: "#94a3b8", flex: 1, fontFamily: "monospace", overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>{p.pipeline}</span>
                  <div style={{ display: "flex", alignItems: "center", gap: 10, flexShrink: 0 }}>
                    <span style={{ fontSize: 12, fontWeight: 700, color: p.breach ? "#f87171" : "#4ade80", fontFamily: "monospace" }}>{p.p95}</span>
                    <span style={{ fontSize: 10, color: "#475569" }}>SLA: {p.sla}</span>
                    {p.breach && <span style={{ fontSize: 9, fontWeight: 700, background: "rgba(239,68,68,0.15)", color: "#f87171", padding: "1px 5px", borderRadius: 3 }}>BREACH</span>}
                  </div>
                </div>
              ))}
            </Panel>
          </div>
        </div>

        {/* ── FOOTER ── */}
        <div style={{ borderTop: "1px solid rgba(30,41,59,0.5)", paddingTop: 16, display: "flex", justifyContent: "space-between", alignItems: "center", flexWrap: "wrap", gap: 8 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
            <PulseDot color="#22c55e" />
            <span style={{ fontSize: 11, color: "#334155" }}>Data streams live · refreshes every 30s · {env} environment</span>
          </div>
          <span style={{ fontSize: 11, color: "#1e293b" }}>OpsAlert Platform · Analytics Engine v4.2.1</span>
        </div>

      </div>
    </div>
  );
};

export default OperationalAnalytics;
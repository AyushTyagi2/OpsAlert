import { Routes, Route } from "react-router-dom";
import { Sidebar } from "./components/Sidebar";
import { MetricCard } from "./components/MetricCard";
import { IncidentCard } from "./components/IncidentCard";
import { LiveAlertTicker } from "./components/LiveAlertTicker";
import { ServiceHealthGrid } from "./components/ServiceHealthGrid";
import { ActivityChart } from "./components/ActivityChart";
import IncidentDashboard from "./incidents/IncidentDashboard";
import { MonitoringPage } from "./monitoring/page";
import {
  Activity,
  AlertTriangle,
  CheckCircle,
  Clock,
  TrendingUp,
  Users
} from "lucide-react";
import OperationalAnalytics from "./analytics/Analytics";
const mockIncidents = [
  {
    id: "1",
    title: "API Gateway timeout spike",
    severity: "critical" as const,
    service: "api-gateway-03",
    time: "2m ago",
    impact: "High request latency",
  },
  {
    id: "2",
    title: "Database connection pool saturation",
    severity: "warning" as const,
    service: "postgres-primary",
    time: "15m ago",
    impact: "Reduced throughput",
  },
  {
    id: "3",
    title: "SSL certificate renewal completed",
    severity: "resolved" as const,
    service: "load-balancer",
    time: "1h ago",
    impact: "No impact",
  },
  {
    id: "4",
    title: "Memory usage threshold exceeded",
    severity: "warning" as const,
    service: "worker-node-07",
    time: "2h ago",
    impact: "Moderate resource constraint",
  },
];

function Dashboard() {
  return (
    <div className="p-8 max-w-[1600px] mx-auto">
      {/* Header */}
      <div className="mb-8">
        <h1 className="mb-2 bg-gradient-to-br from-white via-slate-200 to-slate-400 bg-clip-text text-transparent">
          Incident Command Center
        </h1>
        <p className="text-slate-400">
          Real-time operational monitoring and incident response
        </p>
      </div>

      {/* Live alert ticker */}
      <div className="mb-8">
        <LiveAlertTicker />
      </div>

      {/* Metrics grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-6 mb-8">
        <MetricCard
          title="Active Incidents"
          value="7"
          change="-2 from yesterday"
          trend="down"
          icon={<AlertTriangle className="w-5 h-5 text-red-400" />}
          delay={0}
        />
        <MetricCard
          title="Response Time"
          value="2.4m"
          change="+0.3m avg"
          trend="up"
          icon={<Clock className="w-5 h-5 text-amber-400" />}
          delay={0.1}
        />
        <MetricCard
          title="Resolved Today"
          value="34"
          change="+12% increase"
          trend="up"
          icon={<CheckCircle className="w-5 h-5 text-emerald-400" />}
          delay={0.2}
        />
        <MetricCard
          title="On-Call Engineers"
          value="12"
          change="Active now"
          trend="up"
          icon={<Users className="w-5 h-5 text-blue-400" />}
          delay={0.3}
        />
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
        <div className="lg:col-span-2">
          <ActivityChart />
        </div>
        <div className="flex flex-col gap-6">
          <MetricCard
            title="System Load"
            value="67%"
            change="+5% from avg"
            trend="up"
            icon={<Activity className="w-5 h-5 text-cyan-400" />}
            delay={0.4}
          />
          <MetricCard
            title="Uptime"
            value="99.97%"
            change="30d avg"
            trend="up"
            icon={<TrendingUp className="w-5 h-5 text-emerald-400" />}
            delay={0.5}
          />
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2 space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-slate-200">Recent Incidents</h2>
            <button className="text-sm text-blue-400 hover:text-blue-300 transition-colors">
              View all
            </button>
          </div>
          <div className="space-y-3">
            {mockIncidents.map((incident, index) => (
              <IncidentCard
                key={incident.id}
                {...incident}
                delay={0.6 + index * 0.1}
              />
            ))}
          </div>
        </div>
        <div className="space-y-6">
          <h2 className="text-slate-200">Service Health</h2>
          <ServiceHealthGrid />
        </div>
      </div>
    </div>
  );
}

// Placeholder pages for unbuilt routes
function PlaceholderPage({ title }: { title: string }) {
  return (
    <div className="p-8 flex flex-col items-center justify-center h-full text-center">
      <div className="text-6xl mb-4">🚧</div>
      <h2 className="text-slate-200 text-2xl mb-2">{title}</h2>
      <p className="text-slate-400">This page is under construction.</p>
    </div>
  );
}

export default function App() {
  return (
    <div className="size-full flex bg-slate-950 text-slate-100 overflow-hidden relative">
      {/* Ambient background effects */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-0 w-[800px] h-[800px] bg-gradient-radial from-blue-500/10 via-transparent to-transparent blur-3xl" />
        <div className="absolute bottom-0 right-0 w-[600px] h-[600px] bg-gradient-radial from-cyan-500/10 via-transparent to-transparent blur-3xl" />
        <div
          className="absolute inset-0 opacity-[0.02]"
          style={{
            backgroundImage: `
              linear-gradient(rgba(148, 163, 184, 0.5) 1px, transparent 1px),
              linear-gradient(90deg, rgba(148, 163, 184, 0.5) 1px, transparent 1px)
            `,
            backgroundSize: "50px 50px",
          }}
        />
      </div>
<div className="flex h-screen w-screen overflow-hidden bg-[#020817] text-white">
  <Sidebar />

  <main className="flex-1 overflow-y-auto">
    <div className="p-8">
      <Routes>
          <Route path="/" element={<Dashboard />} />
          <Route path="/incidents" element={<IncidentDashboard />} />
          <Route path="/monitoring" element={<MonitoringPage />} />
          <Route path="/alerts" element={<PlaceholderPage title="Alerts" />} />
          <Route path="/analytics" element={<OperationalAnalytics />} />
          <Route path="/on-call" element={<PlaceholderPage title="On-Call" />} />
          <Route path="/settings" element={<PlaceholderPage title="Settings" />} />
        </Routes>
      </div>
  </main>
</div>

</div>
  );
}
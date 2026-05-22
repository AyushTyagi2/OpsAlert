import { MonitoringHeader } from "./components/MonitoringHeader";
import { SystemHealthCards } from "./components/Systemhealthcards";
import { ServicesStatusTable } from "./components/ServiceStatusTable";
import { LiveAlertFeed } from "./components/LiveAlertFeed";
import { MonitoringCharts } from "./components/MonitoringCharts";
import { MonitoringEventList } from "./components/MonitoringEventList";

export function MonitoringPage() {
  return (
    <div className="min-h-screen bg-[#080c14] text-slate-100">
      {/* Subtle grid texture */}
      <div
        className="fixed inset-0 pointer-events-none opacity-[0.03]"
        style={{ backgroundImage: "linear-gradient(#334155 1px, transparent 1px), linear-gradient(90deg, #334155 1px, transparent 1px)", backgroundSize: "40px 40px" }}
      />

      <div className="relative z-10 max-w-[1600px] mx-auto px-4 sm:px-6 py-6 space-y-5">
        <MonitoringHeader lastRefresh="12:04:15 UTC" />
        <SystemHealthCards />

        {/* Main grid: table + alert feed */}
        <div className="grid grid-cols-1 xl:grid-cols-[1fr_360px] gap-4">
          <ServicesStatusTable />
          <LiveAlertFeed />
        </div>

        <MonitoringCharts />

        {/* Bottom grid: events */}
        <div className="grid grid-cols-1 xl:grid-cols-2 gap-4">
          <MonitoringEventList />
          <div className="rounded-xl border border-slate-800 bg-slate-900/50 p-4 flex flex-col justify-between">
            <div className="flex items-center gap-2 mb-4">
              <div className="w-1 h-4 bg-rose-500 rounded-full" />
              <h2 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">Active Incidents</h2>
            </div>
            {[
              { id: "INC-204", title: "notification-svc complete outage", sev: "P1", age: "22m", assignee: "kartik.m" },
              { id: "INC-203", title: "auth-gateway token validation failures", sev: "P2", age: "1h 4m", assignee: "priya.s" },
            ].map((inc) => (
              <div key={inc.id} className="flex items-center justify-between p-3 rounded-lg bg-slate-800/50 border border-slate-700/50 mb-2 hover:border-slate-600 transition-colors">
                <div className="flex items-center gap-3">
                  <span className={`text-[10px] font-mono font-bold px-2 py-0.5 rounded border ${inc.sev === "P1" ? "text-red-400 border-red-500/30 bg-red-500/10" : "text-amber-400 border-amber-500/30 bg-amber-500/10"}`}>{inc.sev}</span>
                  <div>
                    <div className="text-xs font-mono text-slate-200">{inc.id}</div>
                    <div className="text-[10px] font-mono text-slate-500">{inc.title}</div>
                  </div>
                </div>
                <div className="text-right">
                  <div className="text-[10px] font-mono text-slate-500">{inc.age}</div>
                  <div className="text-[10px] font-mono text-slate-600">@{inc.assignee}</div>
                </div>
              </div>
            ))}
            <div className="mt-auto pt-3 text-center">
              <button className="text-xs font-mono text-slate-500 hover:text-slate-300 transition-colors">
                View Incident Timeline →
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
import { Shield, RefreshCw, Wifi } from "lucide-react";

interface MonitoringHeaderProps {
  lastRefresh: string;
}

export function MonitoringHeader({ lastRefresh }: MonitoringHeaderProps) {
  return (
    <div className="flex items-start justify-between pb-4 border-b border-slate-800">
      <div className="flex items-center gap-4">
        <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-cyan-500/20 to-blue-600/20 border border-cyan-500/30 flex items-center justify-center">
          <Shield className="w-5 h-5 text-cyan-400" />
        </div>
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-xl font-bold text-slate-100 tracking-tight font-mono">
              OPS MONITOR
            </h1>
            <span className="text-xs font-mono px-2 py-0.5 rounded bg-slate-800 text-slate-400 border border-slate-700">
              PRODUCTION
            </span>
          </div>
          <p className="text-xs text-slate-500 mt-0.5 font-mono">
            Alerting & Incident Management · us-east-1 cluster
          </p>
        </div>
      </div>

      <div className="flex items-center gap-4">
        <div className="flex items-center gap-2 text-xs font-mono">
          <div className="w-1.5 h-1.5 rounded-full bg-orange-400 animate-pulse" />
          <span className="text-orange-400 font-semibold">DEGRADED</span>
        </div>
        <div className="h-4 w-px bg-slate-700" />
        <div className="flex items-center gap-2 text-xs text-slate-500 font-mono">
          <Wifi className="w-3.5 h-3.5 text-slate-600" />
          <span>Live</span>
          <RefreshCw className="w-3 h-3 text-slate-600" />
          <span>{lastRefresh}</span>
        </div>
        <button className="text-xs font-mono px-3 py-1.5 rounded bg-slate-800 hover:bg-slate-700 border border-slate-700 hover:border-cyan-500/50 text-slate-300 transition-all duration-200">
          + New Alert Rule
        </button>
      </div>
    </div>
  );
}
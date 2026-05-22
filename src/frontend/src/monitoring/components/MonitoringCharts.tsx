import { LatencyChart } from "./LatencyChart";
import { ErrorRateChart } from "./ErrorRateChart";
import { IncidentDistributionChart } from "./IncidentDistributionChart";

export function MonitoringCharts() {
  return (
    <div>
      <div className="flex items-center gap-2 mb-3">
        <div className="w-1 h-4 bg-violet-500 rounded-full" />
        <h2 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">
          Performance Metrics
        </h2>
      </div>
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-3">
        <LatencyChart />
        <ErrorRateChart />
        <IncidentDistributionChart />
      </div>
    </div>
  );
}
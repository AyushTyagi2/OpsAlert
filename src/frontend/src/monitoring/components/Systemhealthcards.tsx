import { HealthMetricCard } from "./HealthMetricCard";
import { mockHealthMetrics } from "./MockData";

export function SystemHealthCards() {
  return (
    <div>
      <div className="flex items-center gap-2 mb-3">
        <div className="w-1 h-4 bg-cyan-500 rounded-full" />
        <h2 className="text-xs font-mono font-semibold text-slate-400 uppercase tracking-widest">
          System Overview
        </h2>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-3">
        {mockHealthMetrics.map((metric) => (
          <HealthMetricCard key={metric.id} metric={metric} />
        ))}
      </div>
    </div>
  );
}
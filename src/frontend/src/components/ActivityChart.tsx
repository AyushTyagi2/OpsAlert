import { motion } from "framer-motion";
import { AreaChart, Area, ResponsiveContainer, YAxis } from "recharts";

const data = [
  { value: 45 },
  { value: 52 },
  { value: 48 },
  { value: 61 },
  { value: 58 },
  { value: 72 },
  { value: 68 },
  { value: 75 },
  { value: 71 },
  { value: 82 },
  { value: 78 },
  { value: 85 },
  { value: 89 },
  { value: 92 },
  { value: 88 },
  { value: 95 },
  { value: 91 },
  { value: 87 },
  { value: 83 },
  { value: 79 },
  { value: 76 },
  { value: 72 },
  { value: 69 },
  { value: 65 },
];

export function ActivityChart() {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay: 0.2 }}
      className="relative bg-slate-800/40 backdrop-blur-xl border border-slate-700/50 rounded-xl p-6 overflow-hidden group"
    >
      {/* Ambient glow */}
      <div className="absolute inset-0 bg-gradient-to-br from-blue-500/5 via-transparent to-cyan-500/5 pointer-events-none" />

      <div className="relative z-10">
        <div className="flex items-start justify-between mb-6">
          <div>
            <h3 className="text-slate-200 mb-1">System Activity</h3>
            <p className="text-sm text-slate-400">Last 24 hours</p>
          </div>
          <div className="text-right">
            <div className="text-2xl text-slate-100 mb-1">2.4M</div>
            <div className="text-sm text-emerald-400">+12.5%</div>
          </div>
        </div>

        <div className="relative h-32">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={data}>
              <defs>
                <linearGradient id="chartGradient" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="rgb(59, 130, 246)" stopOpacity={0.4} />
                  <stop offset="100%" stopColor="rgb(59, 130, 246)" stopOpacity={0} />
                </linearGradient>
              </defs>
              <YAxis hide domain={[0, 100]} />
              <Area
                type="monotone"
                dataKey="value"
                stroke="rgb(96, 165, 250)"
                strokeWidth={2}
                fill="url(#chartGradient)"
                animationDuration={1000}
              />
            </AreaChart>
          </ResponsiveContainer>

          {/* Animated data point */}
          <motion.div
            className="absolute top-0 right-8 w-2 h-2 bg-blue-400 rounded-full"
            animate={{
              scale: [1, 1.5, 1],
              opacity: [1, 0.5, 1],
            }}
            transition={{ duration: 2, repeat: Infinity }}
          />
        </div>

        {/* Grid overlay */}
        <div className="absolute inset-x-0 bottom-0 h-32 pointer-events-none">
          <div className="w-full h-full" style={{
            backgroundImage: "linear-gradient(rgba(148, 163, 184, 0.05) 1px, transparent 1px)",
            backgroundSize: "100% 16px",
          }} />
        </div>
      </div>

      {/* Hover glow */}
      <motion.div
        className="absolute inset-0 opacity-0 group-hover:opacity-100 pointer-events-none"
        transition={{ duration: 0.3 }}
        style={{
          background: "radial-gradient(circle at 50% 50%, rgba(59, 130, 246, 0.1), transparent 70%)",
        }}
      />
    </motion.div>
  );
}

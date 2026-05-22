import { motion } from "framer-motion";
import { AlertCircle, AlertTriangle, CheckCircle, Clock } from "lucide-react";

interface IncidentCardProps {
  id: string;
  title: string;
  severity: "critical" | "warning" | "resolved";
  service: string;
  time: string;
  impact: string;
  delay?: number;
}

const severityConfig = {
  critical: {
    icon: AlertCircle,
    color: "text-red-400",
    bg: "bg-red-500/10",
    border: "border-red-500/30",
    glow: "rgba(239, 68, 68, 0.3)",
    pulse: true,
  },
  warning: {
    icon: AlertTriangle,
    color: "text-amber-400",
    bg: "bg-amber-500/10",
    border: "border-amber-500/30",
    glow: "rgba(251, 191, 36, 0.3)",
    pulse: false,
  },
  resolved: {
    icon: CheckCircle,
    color: "text-emerald-400",
    bg: "bg-emerald-500/10",
    border: "border-emerald-500/30",
    glow: "rgba(52, 211, 153, 0.3)",
    pulse: false,
  },
};

export function IncidentCard({ id, title, severity, service, time, impact, delay = 0 }: IncidentCardProps) {
  const config = severityConfig[severity];
  const Icon = config.icon;

  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 0.4, delay }}
      whileHover={{
        scale: 1.01,
        x: 4,
        boxShadow: `0 0 30px ${config.glow}`,
      }}
      className={`relative bg-slate-800/60 backdrop-blur-lg border ${config.border} rounded-lg p-4 cursor-pointer overflow-hidden group`}
    >
      {/* Animated pulse for critical */}
      {config.pulse && (
        <motion.div
          className="absolute inset-0 bg-red-500/5 rounded-lg"
          animate={{ opacity: [0.5, 0.8, 0.5] }}
          transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
        />
      )}

      {/* Hover glow */}
      <motion.div
        className="absolute inset-0 opacity-0 group-hover:opacity-100 pointer-events-none"
        initial={{ opacity: 0 }}
        whileHover={{ opacity: 1 }}
        transition={{ duration: 0.3 }}
        style={{
          background: `linear-gradient(135deg, ${config.glow} 0%, transparent 50%)`,
        }}
      />

      <div className="relative z-10 flex items-start gap-4">
        <motion.div
          className={`p-2 ${config.bg} rounded-lg`}
          whileHover={{ scale: 1.1, rotate: 5 }}
          transition={{ type: "spring", stiffness: 400, damping: 10 }}
        >
          <Icon className={`w-5 h-5 ${config.color}`} />
        </motion.div>

        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-4 mb-2">
            <h3 className="text-slate-100 truncate">{title}</h3>
            <span className={`px-2 py-0.5 ${config.bg} ${config.color} rounded text-xs whitespace-nowrap uppercase tracking-wider`}>
              {severity}
            </span>
          </div>

          <div className="flex items-center gap-4 text-sm text-slate-400">
            <span className="flex items-center gap-1">
              <Clock className="w-3.5 h-3.5" />
              {time}
            </span>
            <span>Service: {service}</span>
            <span className="truncate">{impact}</span>
          </div>
        </div>
      </div>

      {/* Bottom gradient */}
      <div className="absolute bottom-0 left-0 right-0 h-px bg-gradient-to-r from-transparent via-slate-600 to-transparent opacity-50" />
    </motion.div>
  );
}

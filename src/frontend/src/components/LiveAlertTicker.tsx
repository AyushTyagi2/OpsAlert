import { motion, AnimatePresence } from "framer-motion";
import { useState, useEffect } from "react";
import { AlertCircle, TrendingUp, Zap } from "lucide-react";

const alerts = [
  { icon: AlertCircle, text: "High CPU usage detected on api-gateway-03", color: "text-amber-400" },
  { icon: Zap, text: "Response time spike: +125ms average", color: "text-blue-400" },
  { icon: TrendingUp, text: "Traffic surge: 2.4k req/s (+45%)", color: "text-cyan-400" },
  { icon: AlertCircle, text: "Database connection pool saturation at 89%", color: "text-orange-400" },
];

export function LiveAlertTicker() {
  const [currentIndex, setCurrentIndex] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentIndex((prev) => (prev + 1) % alerts.length);
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  const currentAlert = alerts[currentIndex];
  const Icon = currentAlert.icon;

  return (
    <motion.div
      initial={{ opacity: 0, y: -20 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-slate-800/40 backdrop-blur-xl border border-slate-700/50 rounded-lg px-6 py-3 flex items-center gap-3 overflow-hidden"
    >
      <motion.div
        className="w-2 h-2 bg-blue-400 rounded-full"
        animate={{ scale: [1, 1.2, 1], opacity: [1, 0.7, 1] }}
        transition={{ duration: 1.5, repeat: Infinity }}
      />

      <span className="text-xs text-slate-400 uppercase tracking-wider">Live Feed</span>

      <div className="flex-1 relative h-6">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentIndex}
            initial={{ y: 20, opacity: 0 }}
            animate={{ y: 0, opacity: 1 }}
            exit={{ y: -20, opacity: 0 }}
            transition={{ duration: 0.3 }}
            className="absolute inset-0 flex items-center gap-2"
          >
            <Icon className={`w-4 h-4 ${currentAlert.color}`} />
            <span className="text-sm text-slate-300">{currentAlert.text}</span>
          </motion.div>
        </AnimatePresence>
      </div>

      <div className="text-xs text-slate-500">Just now</div>
    </motion.div>
  );
}

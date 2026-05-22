import { motion, useMotionValue, useTransform } from "framer-motion";
import { useRef } from "react";

interface MetricCardProps {
  title: string;
  value: string;
  change: string;
  trend: "up" | "down";
  icon: React.ReactNode;
  delay?: number;
}

export function MetricCard({ title, value, change, trend, icon, delay = 0 }: MetricCardProps) {
  const ref = useRef<HTMLDivElement>(null);
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  const rotateX = useTransform(mouseY, [-100, 100], [5, -5]);
  const rotateY = useTransform(mouseX, [-100, 100], [-5, 5]);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!ref.current) return;
    const rect = ref.current.getBoundingClientRect();
    const centerX = rect.left + rect.width / 2;
    const centerY = rect.top + rect.height / 2;
    mouseX.set(e.clientX - centerX);
    mouseY.set(e.clientY - centerY);
  };

  const handleMouseLeave = () => {
    mouseX.set(0);
    mouseY.set(0);
  };

  return (
    <motion.div
      ref={ref}
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.5, delay }}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
      style={{
        rotateX,
        rotateY,
        transformStyle: "preserve-3d",
      }}
      whileHover={{ scale: 1.02, z: 50 }}
      className="relative bg-gradient-to-br from-slate-800/80 to-slate-900/80 backdrop-blur-xl border border-slate-700/50 rounded-xl p-6 cursor-pointer overflow-hidden"
    >
      {/* Cursor glow effect */}
      <motion.div
        className="absolute inset-0 opacity-0 group-hover:opacity-100 pointer-events-none"
        style={{
          background: `radial-gradient(600px circle at ${mouseX}px ${mouseY}px, rgba(96, 165, 250, 0.1), transparent 40%)`,
        }}
      />

      {/* Glass reflection */}
      <div className="absolute inset-0 bg-gradient-to-br from-white/5 to-transparent pointer-events-none" />

      <div className="relative z-10">
        <div className="flex items-start justify-between mb-4">
          <div className="p-2 bg-slate-700/50 rounded-lg backdrop-blur-sm">
            {icon}
          </div>
          <div className={`text-sm px-2 py-1 rounded ${
            trend === "up" ? "bg-emerald-500/20 text-emerald-400" : "bg-red-500/20 text-red-400"
          }`}>
            {change}
          </div>
        </div>

        <div className="text-3xl mb-1 bg-gradient-to-br from-white to-slate-300 bg-clip-text text-transparent">
          {value}
        </div>
        <div className="text-slate-400 text-sm">{title}</div>
      </div>

      {/* Hover shadow */}
      <motion.div
        className="absolute inset-0 rounded-xl opacity-0"
        whileHover={{ opacity: 1 }}
        transition={{ duration: 0.3 }}
        style={{
          boxShadow: "0 0 40px rgba(96, 165, 250, 0.3)",
        }}
      />
    </motion.div>
  );
}

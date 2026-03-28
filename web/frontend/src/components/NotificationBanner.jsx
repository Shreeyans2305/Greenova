import { AlertTriangle, CheckCircle, X } from "lucide-react";
import { useState } from "react";

export default function NotificationBanner({ type = "warning", message, dismissible = true }) {
  const [visible, setVisible] = useState(true);

  if (!visible) return null;

  const styles = {
    warning: {
      bg: "bg-warn-500/10 border-warn-500/30",
      icon: <AlertTriangle className="w-5 h-5 text-warn-400 shrink-0" />,
      text: "text-warn-400",
    },
    success: {
      bg: "bg-accent-emerald/10 border-accent-emerald/30",
      icon: <CheckCircle className="w-5 h-5 text-accent-emerald shrink-0" />,
      text: "text-accent-emerald",
    },
  };

  const s = styles[type] || styles.warning;

  return (
    <div className={`flex items-center gap-3 px-4 py-3 rounded-xl border ${s.bg} animate-fade-in-up`}>
      {s.icon}
      <p className={`text-sm flex-1 ${s.text}`}>{message}</p>
      {dismissible && (
        <button onClick={() => setVisible(false)} className="text-text-muted hover:text-text-main transition-colors">
          <X className="w-4 h-4" />
        </button>
      )}
    </div>
  );
}

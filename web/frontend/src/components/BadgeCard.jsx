export default function BadgeCard({ badge }) {
  const { name, icon, description, earned, earnedDate } = badge;

  return (
    <div
      className={`glass-card p-5 text-center transition-all duration-300 group ${
        earned
          ? "hover:border-primary-500/40 animate-pulse-glow"
          : "opacity-40 grayscale hover:opacity-60"
      }`}
    >
      <div
        className={`text-4xl mb-3 transition-transform duration-300 ${
          earned ? "group-hover:scale-110" : ""
        }`}
      >
        {icon}
      </div>
      <h4 className="text-sm font-semibold text-surface-100 mb-1">{name}</h4>
      <p className="text-xs text-surface-200/50 mb-2 leading-relaxed">{description}</p>
      {earned ? (
        <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-primary-500/15 text-primary-300 border border-primary-500/20">
          Earned {earnedDate}
        </span>
      ) : (
        <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-surface-700/30 text-surface-200/40 border border-surface-700/30">
          Locked
        </span>
      )}
    </div>
  );
}

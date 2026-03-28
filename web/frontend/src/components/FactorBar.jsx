export default function FactorBar({ factor, compact = false }) {
  const { name, score1, score2, winner } = factor;
  const maxScore = 10;
  const barWidth = 100 / maxScore;

  const getBarColor = (score, isWinner) => {
    if (isWinner === "tie") return "bg-accent-cyan";
    if (isWinner === "product1") {
      return score === score1 ? "bg-accent-emerald" : "bg-text-muted/30";
    }
    return score === score2 ? "bg-accent-emerald" : "bg-text-muted/30";
  };

  const p1Wins = winner === "product1";
  const p2Wins = winner === "product2";
  const isTie = winner === "tie" || (!winner);

  const barHeight = compact ? "h-6" : "h-8";

  return (
    <div className={`${compact ? "py-2" : "py-3"} border-b border-text-muted/10 last:border-b-0`}>
      <div className="flex items-center justify-between mb-2">
        <span className="text-sm font-medium text-text-main">{name}</span>
        {!compact && (
          <span className={`text-xs px-2 py-0.5 rounded-full ${
            isTie 
              ? "bg-accent-cyan/20 text-accent-cyan" 
              : p1Wins 
                ? "bg-accent-emerald/20 text-accent-emerald" 
                : "bg-accent-emerald/20 text-accent-emerald"
          }`}>
            {isTie ? "Tie" : winner === "product1" ? "P1 Wins" : "P2 Wins"}
          </span>
        )}
      </div>
      
      <div className={`flex gap-4 ${compact ? "items-center" : "items-center"}`}>
        {/* Product 1 Bar */}
        <div className="flex-1">
          <div className={`${barHeight} bg-surface-bg/40 rounded-lg overflow-hidden relative`}>
            <div 
              className={`h-full rounded-lg transition-all duration-500 ${getBarColor(score1, p1Wins)}`}
              style={{ width: `${Math.min(score1 * barWidth, 100)}%` }}
            />
            {!compact && (
              <span className="absolute right-2 top-1/2 -translate-y-1/2 text-xs font-medium text-text-main/80">
                {score1.toFixed(1)}
              </span>
            )}
          </div>
        </div>

        {/* Divider */}
        <div className="w-px h-6 bg-text-muted/20" />

        {/* Product 2 Bar */}
        <div className="flex-1">
          <div className={`${barHeight} bg-surface-bg/40 rounded-lg overflow-hidden relative`}>
            <div 
              className={`h-full rounded-lg transition-all duration-500 ${getBarColor(score2, p2Wins)}`}
              style={{ width: `${Math.min(score2 * barWidth, 100)}%` }}
            />
            {!compact && (
              <span className="absolute right-2 top-1/2 -translate-y-1/2 text-xs font-medium text-text-main/80">
                {score2.toFixed(1)}
              </span>
            )}
          </div>
        </div>
      </div>

      {compact && (
        <div className="flex justify-between mt-1 text-xs text-text-muted">
          <span>{score1.toFixed(1)}</span>
          <span>{score2.toFixed(1)}</span>
        </div>
      )}
    </div>
  );
}

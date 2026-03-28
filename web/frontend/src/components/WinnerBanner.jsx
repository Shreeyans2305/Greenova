import { Trophy, Scale, ArrowLeftRight } from "lucide-react";

export default function WinnerBanner({ winner, winnerName, summary }) {
  const isTie = winner === "tie" || !winner;
  
  return (
    <div className={`glass-card p-6 text-center ${
      isTie 
        ? "border-accent-cyan/30 bg-gradient-to-br from-surface-bg/90 to-accent-cyan/5" 
        : "border-accent-emerald/30 bg-gradient-to-br from-surface-bg/90 to-accent-emerald/5"
    }`}>
      <div className={`inline-flex items-center justify-center w-16 h-16 rounded-full mb-4 ${
        isTie ? "bg-accent-cyan/20" : "bg-accent-emerald/20"
      }`}>
        {isTie ? (
          <Scale className="w-8 h-8 text-accent-cyan" />
        ) : (
          <Trophy className="w-8 h-8 text-accent-emerald" />
        )}
      </div>
      
      <h2 className={`text-2xl font-bold mb-2 ${
        isTie ? "text-accent-cyan" : "text-accent-emerald"
      }`}>
        {isTie ? "It's a Tie!" : `${winnerName} Wins!`}
      </h2>
      
      <p className="text-text-muted max-w-lg mx-auto">
        {summary || "Comparison completed successfully."}
      </p>
    </div>
  );
}

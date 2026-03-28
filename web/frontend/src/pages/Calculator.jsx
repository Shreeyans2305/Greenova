import { useState } from "react";
import {
  ChevronRight,
  ChevronLeft,
  Calculator as CalcIcon,
  Leaf,
  Car,
  Home,
  Utensils,
  ShoppingBag,
  Recycle,
  Plane,
  SkipForward,
  RotateCcw,
  Loader2,
} from "lucide-react";
import { calculatorQuestions as questions, BASE_IMPACT } from "../data/calculatorData";
import useAIText from "../hooks/useAIText";
import useCalculatorInsights from "../hooks/useCalculatorInsights";
import NotificationBanner from "../components/NotificationBanner";

const ICONS = [Leaf, Car, Home, Utensils, ShoppingBag, Recycle, Plane];

export default function Calculator() {
  const [step, setStep] = useState(0);
  const [answers, setAnswers] = useState({});
  const [showResult, setShowResult] = useState(false);
  const [skipped, setSkipped] = useState(false);

  const t = useAIText("calculator");
  const { insights, isLoading: insightsLoading, fetchInsights, reset: resetInsights } = useCalculatorInsights();

  const currentQ = questions[step];
  const Icon = ICONS[step] || Leaf;
  const progress = ((step + 1) / questions.length) * 100;

  const calculateCO2 = () => {
    let total = BASE_IMPACT;
    questions.forEach((q, i) => {
      const val = answers[i] ?? q.options[0].value;
      total += val;
    });
    return Math.round(total * 100) / 100;
  };

  const handleSelect = async (value) => {
    const updated = { ...answers, [step]: value };
    setAnswers(updated);

    if (step < questions.length - 1) {
      setStep(step + 1);
    } else {
      setShowResult(true);
      let total = BASE_IMPACT;
      questions.forEach((q, i) => {
        const val = updated[i] ?? q.options[0].value;
        total += val;
      });
      total = Math.round(total * 100) / 100;
      await fetchInsights(updated, total);
    }
  };

  const handleSkip = () => {
    setSkipped(true);
    setShowResult(true);
  };

  const handleRecalculate = () => {
    setStep(0);
    setAnswers({});
    setShowResult(false);
    setSkipped(false);
    resetInsights();
  };

  const totalCO2 = calculateCO2();

  // Determine badge and color (fallback or from AI)
  let badge, badgeColor;
  if (insights) {
    badge = insights.badge;
    badgeColor = insights.badge_color;
  } else {
    if (totalCO2 < 6) {
      badge = "Eco Champion 🌿";
      badgeColor = "green";
    } else if (totalCO2 < 10) {
      badge = "Conscious Citizen 🌎";
      badgeColor = "yellow";
    } else {
      badge = "Needs Improvement 🏭";
      badgeColor = "red";
    }
  }

  const badgeStyles = {
    green: "bg-accent-emerald/15 text-accent-emerald border-accent-emerald/20",
    yellow: "bg-warn-500/15 text-warn-400 border-warn-500/20",
    red: "bg-danger-500/15 text-danger-400 border-danger-500/20",
  };

  // Result view
  if (showResult) {
    return (
      <main className="max-w-2xl mx-auto px-4 pt-24 pb-16 animate-fade-in-up">
        <div className="glass-card p-8 text-center space-y-6">
          <CalcIcon className="w-12 h-12 text-accent-emerald mx-auto" />
          <h1 className="text-3xl font-bold text-text-main">
            {t("result_title", "Your Carbon Footprint")}
          </h1>

          {skipped ? (
            <div className="space-y-4">
              <p className="text-text-muted">
                {t("skip_message", "You skipped the calculator. We couldn't calculate your accurate footprint.")}
              </p>
              <button
                onClick={handleRecalculate}
                className="flex items-center gap-2 mx-auto px-6 py-3 bg-accent-emerald text-page-bg rounded-xl text-sm font-medium hover:bg-accent-emerald-dark transition-all"
              >
                <RotateCcw className="w-4 h-4" />
                {t("recalculate", "Recalculate")}
              </button>
            </div>
          ) : (
            <div className="space-y-6">
              {/* CO2 Display */}
              <div className="relative">
                <div className="text-6xl font-bold text-text-main">{totalCO2}</div>
                <div className="text-sm text-text-muted mt-1">{t("co2_unit", "Tons of CO2 per year")}</div>
              </div>

              {/* Badge */}
              <span
                className={`inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-medium border ${badgeStyles[badgeColor] || badgeStyles.yellow}`}
              >
                {badge}
              </span>

              {/* AI Insights */}
              {insightsLoading && (
                <div className="flex items-center justify-center gap-2 text-text-muted text-sm">
                  <Loader2 className="w-4 h-4 animate-spin" />
                  {t("calculating", "Calculating your impact...")}
                </div>
              )}

              {insights && (
                <div className="space-y-4 text-left">
                  {/* Comparison */}
                  {insights.comparison && (
                    <NotificationBanner
                      type={totalCO2 < 4.5 ? "success" : "warning"}
                      message={insights.comparison}
                    />
                  )}

                  {/* Insights */}
                  {insights.insights?.length > 0 && (
                    <div className="glass-card-light p-4 space-y-2">
                      <h3 className="text-sm font-semibold text-text-main flex items-center gap-2">
                        <Leaf className="w-4 h-4 text-accent-emerald" />
                        Insights
                      </h3>
                      <ul className="space-y-1.5">
                        {insights.insights.map((insight, i) => (
                          <li key={i} className="text-sm text-text-muted flex items-start gap-2">
                            <span className="text-accent-emerald mt-0.5">•</span>
                            {insight}
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Tips */}
                  {insights.tips?.length > 0 && (
                    <div className="glass-card-light p-4 space-y-2">
                      <h3 className="text-sm font-semibold text-text-main flex items-center gap-2">
                        <Recycle className="w-4 h-4 text-accent-cyan" />
                        Tips to Reduce
                      </h3>
                      <ul className="space-y-1.5">
                        {insights.tips.map((tip, i) => (
                          <li key={i} className="text-sm text-text-muted flex items-start gap-2">
                            <span className="text-accent-cyan mt-0.5">•</span>
                            {tip}
                          </li>
                        ))}
                      </ul>
                    </div>
                  )}
                </div>
              )}

              {/* Recalculate */}
              <button
                onClick={handleRecalculate}
                className="flex items-center gap-2 mx-auto px-6 py-3 bg-surface-bg text-text-muted rounded-xl text-sm font-medium border border-card-bg hover:border-accent-emerald/30 hover:text-accent-emerald transition-all"
              >
                <RotateCcw className="w-4 h-4" />
                {t("recalculate", "Recalculate")}
              </button>
            </div>
          )}
        </div>
      </main>
    );
  }

  // Question view
  return (
    <main className="max-w-2xl mx-auto px-4 pt-24 pb-16 animate-fade-in-up">
      <div className="space-y-8">
        {/* Progress */}
        <div className="space-y-2">
          <div className="flex items-center justify-between text-xs text-text-muted">
            <span>{t("question_of", "Question {current} of {total}").replace("{current}", step + 1).replace("{total}", questions.length)}</span>
            <span>{Math.round(progress)}%</span>
          </div>
          <div className="h-1.5 bg-surface-bg border border-card-bg rounded-full overflow-hidden">
            <div
              className="h-full bg-linear-to-r from-accent-emerald to-accent-cyan rounded-full transition-all duration-500"
              style={{ width: `${progress}%` }}
            />
          </div>
        </div>

        {/* Question Card */}
        <div className="glass-card p-8 text-center space-y-6">
          <Icon className="w-12 h-12 text-accent-emerald mx-auto" />
          <h2 className="text-2xl font-bold text-text-main">{currentQ.question}</h2>

          <div className="grid gap-3">
            {currentQ.options.map((opt, idx) => (
              <button
                key={idx}
                onClick={() => handleSelect(opt.value)}
                className="glass-card-light p-4 text-left hover:border-accent-emerald/40 hover:bg-accent-emerald/5 transition-all duration-300 group"
              >
                <div className="flex items-center justify-between">
                  <span className="text-sm text-text-main group-hover:text-accent-emerald transition-colors">
                    {opt.label}
                  </span>
                  <ChevronRight className="w-4 h-4 text-text-muted group-hover:text-accent-emerald group-hover:translate-x-1 transition-all" />
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Nav */}
        <div className="flex items-center justify-between">
          <button
            onClick={() => step > 0 && setStep(step - 1)}
            disabled={step === 0}
            className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm text-text-muted hover:text-text-main disabled:opacity-30 disabled:cursor-not-allowed transition-all"
          >
            <ChevronLeft className="w-4 h-4" />
            Back
          </button>

          <div className="flex items-center gap-3">
            <button
              onClick={() => handleSelect(currentQ.options[0].value)}
              className="text-xs text-text-muted hover:text-text-main transition-all"
            >
              {t("skip_question", "Skip this question")}
            </button>
            <button
              onClick={handleSkip}
              className="flex items-center gap-2 px-4 py-2 rounded-xl text-sm text-text-muted border border-surface-bg hover:text-warn-400 hover:border-warn-500/30 transition-all"
            >
              <SkipForward className="w-4 h-4" />
              {t("skip_calculator", "Skip Calculator")}
            </button>
          </div>
        </div>
      </div>
    </main>
  );
}

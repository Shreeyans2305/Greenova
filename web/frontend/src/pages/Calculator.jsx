import { useState } from "react";
import { MoveRight, Loader2, Sparkles, UserX, RefreshCw } from "lucide-react";
import { calculatorQuestions, BASE_IMPACT } from "../data/calculatorData";

export default function Calculator() {
  const [currentStep, setCurrentStep] = currentStepInit();
  const [answers, setAnswers] = useState({});
  const [isCalculated, setIsCalculated] = useState(false);
  const [isCalculating, setIsCalculating] = useState(false);
  const [skipMode, setSkipMode] = useState(false);

  function currentStepInit() {
    return useState(0);
  }

  const handleSelectOption = (value) => {
    setAnswers({ ...answers, [currentStep]: value });
    nextStep();
  };

  const nextStep = () => {
    if (currentStep < calculatorQuestions.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      calculateResult();
    }
  };

  const skipQuestion = () => {
    // Skipping assumes average or missing value (0 for math ease, though 
    // real models might assume average). We'll assume median impacts later.
    setAnswers({ ...answers, [currentStep]: null });
    nextStep();
  };

  const skipCalculator = () => {
    setSkipMode(true);
    calculateResult();
  };

  const calculateResult = () => {
    setIsCalculating(true);
    setTimeout(() => {
      setIsCalculated(true);
      setIsCalculating(false);
    }, 1200); // simulate calculation time
  };

  const restart = () => {
    setCurrentStep(0);
    setAnswers({});
    setIsCalculated(false);
    setSkipMode(false);
  };

  const calculateFinalScore = () => {
    let total = BASE_IMPACT;
    Object.values(answers).forEach((val) => {
      // If skipped, we might assign a default median (e.g., 1.5).
      total += val !== null ? val : 1.5; 
    });
    return total.toFixed(1);
  };

  // Result View
  if (isCalculated) {
    const finalScore = calculateFinalScore();
    let badge = "";
    let color = "";

    if (skipMode) {
      badge = "Unknown Impact";
      color = "text-surface-300";
    } else if (finalScore < 6) {
      badge = "Eco Champion 🌿";
      color = "text-accent-400";
    } else if (finalScore < 10) {
      badge = "Conscious Citizen 🌎";
      color = "text-primary-400";
    } else {
      badge = "Needs Improvement 🏭";
      color = "text-danger-400";
    }

    return (
      <div className="min-h-screen pt-24 px-4 sm:px-6 lg:px-8 pb-12 flex flex-col items-center">
        <div className="max-w-md w-full glass-card p-8 text-center animate-fade-in-up">
          <div className="inline-flex items-center justify-center p-4 rounded-full bg-primary-500/10 mb-6">
            <Sparkles className="w-8 h-8 text-primary-400" />
          </div>
          
          <h2 className="text-2xl font-bold text-surface-100 mb-2">Your Carbon Footprint</h2>
          
          {skipMode ? (
            <div className="py-8">
               <UserX className="w-12 h-12 text-surface-200/50 mx-auto mb-4" />
               <p className="text-surface-200/70">You skipped the calculator. We couldn't calculate your accurate footprint.</p>
            </div>
          ) : (
            <>
              <div className="py-6">
                <p className="text-5xl font-black bg-linear-to-r from-primary-400 to-accent-400 bg-clip-text text-transparent">
                  {finalScore}
                </p>
                <p className="text-sm text-surface-200/60 mt-2">Tons of CO2 per year</p>
              </div>
              <div className="py-3 px-4 rounded-xl bg-surface-800/50 border border-surface-700/50 mb-8 inline-block">
                <span className={`font-semibold ${color}`}>{badge}</span>
              </div>
            </>
          )}

          <button
            onClick={restart}
            className="w-full flex items-center justify-center gap-2 py-3 px-4 rounded-xl bg-surface-700 hover:bg-surface-600 border border-surface-600/50 text-surface-100 transition-all font-medium"
          >
            <RefreshCw className="w-4 h-4" />
            Recalculate
          </button>
        </div>
      </div>
    );
  }

  // Loading View
  if (isCalculating) {
    return (
      <div className="min-h-screen pt-32 px-4 flex justify-center">
        <div className="text-center animate-pulse">
          <Loader2 className="w-10 h-10 text-primary-400 animate-spin mx-auto mb-4" />
          <h2 className="text-xl font-medium text-surface-100">Calculating your impact...</h2>
          <p className="text-surface-200/50 mt-2"> crunching the numbers </p>
        </div>
      </div>
    );
  }

  // Questionnaire View
  const question = calculatorQuestions[currentStep];
  const progressPercent = ((currentStep + 1) / calculatorQuestions.length) * 100;

  return (
    <div className="min-h-screen pt-24 pb-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-2xl mx-auto">
        
        {/* Progress header & Skip all */}
        <div className="flex items-center justify-between mb-8">
          <div className="w-full max-w-xs">
            <div className="flex justify-between text-xs text-surface-200/60 mb-2 font-medium tracking-wide">
              <span>Question {currentStep + 1} of {calculatorQuestions.length}</span>
              <span>{Math.round(progressPercent)}%</span>
            </div>
            <div className="h-1.5 w-full bg-surface-800 rounded-full overflow-hidden">
              <div 
                className="h-full bg-linear-to-r from-primary-500 to-accent-500 transition-all duration-500 ease-out"
                style={{ width: `${progressPercent}%` }}
              />
            </div>
          </div>
          <button 
            onClick={skipCalculator}
            className="text-sm font-medium text-surface-200/50 hover:text-surface-100 transition-colors"
          >
            Skip Calculator
          </button>
        </div>

        {/* Question Card */}
        <div className="glass-card p-6 sm:p-10 animate-fade-in-up" key={currentStep}>
          <h2 className="text-2xl sm:text-3xl font-bold text-surface-100 mb-8 text-center">
            {question.title}
          </h2>

          <div className="grid gap-4 sm:grid-cols-2">
            {question.options.map((option, idx) => (
              <button
                key={idx}
                onClick={() => handleSelectOption(option.value)}
                className="flex items-center gap-4 p-4 rounded-2xl bg-surface-800/40 border border-surface-700/50 hover:bg-surface-700/60 hover:border-primary-500/40 transition-all duration-300 group text-left"
              >
                <span className="text-3xl group-hover:scale-110 transition-transform duration-300">
                  {option.icon}
                </span>
                <span className="font-medium text-surface-100 group-hover:text-primary-300 transition-colors">
                  {option.label}
                </span>
              </button>
            ))}
          </div>

          <div className="mt-8 flex justify-center">
            <button
              onClick={skipQuestion}
              className="group inline-flex items-center gap-2 px-6 py-2.5 rounded-full border border-surface-700 hover:border-surface-600 hover:bg-surface-800 text-surface-200/70 hover:text-surface-100 transition-all text-sm font-medium"
            >
              Skip this question
              <MoveRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
            </button>
          </div>
        </div>

      </div>
    </div>
  );
}

const OLLAMA_ENDPOINT = "http://127.0.0.1:11434/api/generate";
const MODEL_NAME = "gemma3:latest";

async function runTest() {
  const products = [
    { id: 1, title: "EcoFriendly Water Bottle", brand: "EcoBrand", price: "$15.00", category: "amazon" },
    { id: 2, title: "Plastic Toys Generic", brand: "Generic Factory", price: "$5.00", category: "amazon" },
    { id: 3, title: "Organic Cotton T-Shirt", brand: "GreenThreads", price: "$25.00", category: "amazon" }
  ];

  const prompt = [
    "You are a sustainability analyst.",
    "Return strict JSON which MUST be an array of objects.",
    "Each object must have this exact shape:",
    '{"id": number, "score": number, "grade": "A|B|C|D|E", "summary": string, "positive_impacts": string[], "negative_impacts": string[], "how_it_affects_environment": string, "confidence": number, "recommendations": string[]}',
    "Score rules: 0 worst, 100 best.",
    "Grade mapping: A=80-100, B=65-79, C=50-64, D=35-49, E=0-34.",
    "Be concise, practical, and avoid markdown. ONLY RETURN JSON.",
    "Products to score:",
    JSON.stringify(products)
  ].join("\n");

  console.log("Sending prompt to Ollama...");
  try {
    const response = await fetch(OLLAMA_ENDPOINT, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model: MODEL_NAME,
        prompt: prompt,
        stream: false,
        options: {
          temperature: 0.2,
          num_predict: 8192
        }
      })
    });

    console.log("Status:", response.status);
    if (!response.ok) {
        console.error("Error response:", await response.text());
        return;
    }

    const data = await response.json();
    console.log("RAW RESPONSE:");
    console.log(data.response);
    
    console.log("Attempting to parse...");
    try {
      const parsed = parseModelBatchResponse(data.response);
      console.log("Parsed successfully! Length:", parsed.length);
    } catch (e) {
      console.error("Parse failed:", e);
    }
  } catch (err) {
    console.error("Fetch failed:", err);
  }
}

function safeNumber(value, min, max, fallback) {
  const n = Number(value);
  if (Number.isNaN(n)) return fallback;
  return Math.min(max, Math.max(min, n));
}

function normalizeGrade(score, grade) {
  if (typeof grade === "string" && /^[ABCDE]$/i.test(grade.trim())) {
    return grade.trim().toUpperCase();
  }
  if (score >= 80) return "A";
  if (score >= 65) return "B";
  if (score >= 50) return "C";
  if (score >= 35) return "D";
  return "E";
}

function asStringArray(value) {
  if (!Array.isArray(value)) return [];
  return value.map((item) => String(item || "").trim()).filter(Boolean).slice(0, 6);
}

function extractJson(text) {
  try {
    return JSON.parse(text);
  } catch (error) {
    const start = text.indexOf("[");
    const end = text.lastIndexOf("]");
    if (start === -1 || end === -1 || end <= start) {
      const startObj = text.indexOf("{");
      const endObj = text.lastIndexOf("}");
      if (startObj !== -1 && endObj !== -1 && endObj > startObj) {
         const obj = JSON.parse(text.slice(startObj, endObj + 1));
         return [obj];
      }
      throw error;
    }
    return JSON.parse(text.slice(start, end + 1));
  }
}

function parseModelBatchResponse(rawText) {
  let parsedArray = extractJson(rawText);
  if (!Array.isArray(parsedArray)) {
     if (typeof parsedArray === 'object' && parsedArray.id !== undefined) {
         parsedArray = [parsedArray];
     } else {
         throw new Error("Model did not return a JSON array");
     }
  }
  
  return parsedArray.map(parsed => {
    const score = Math.round(safeNumber(parsed.score, 0, 100, 50));
    return {
      id: parsed.id,
      score,
      grade: normalizeGrade(score, parsed.grade),
      summary: String(parsed.summary || "No summary available."),
      positiveImpacts: asStringArray(parsed.positive_impacts),
      negativeImpacts: asStringArray(parsed.negative_impacts),
      environmentImpact: String(
        parsed.how_it_affects_environment || "Impact details are unavailable."
      ),
      confidence: Math.round(safeNumber(parsed.confidence, 0, 100, 60)),
      recommendations: asStringArray(parsed.recommendations),
      generatedAt: new Date().toISOString()
    };
  });
}

runTest();

const BADGE_CLASS = "greennova-score-badge";
const PANEL_ID = "greennova-report-panel";
const PROCESSED_ATTR = "data-greennova-processed";
const DEFAULT_ALLOWLIST = ["amazon", "flipkart", "greenmart"];
const RETRY_ATTR = "data-greennova-retry-count";
const MAX_RETRY_PER_CARD = 2;
const MAX_CONCURRENT_SCORE_REQUESTS = 1;

const inFlightKeys = new Set();
const stateByProductKey = new Map();
let allowlist = [...DEFAULT_ALLOWLIST];
let panel;
let scoringSuspendedUntil = 0;
let suspensionCode = "";
let extensionContextValid = true;
let statusPill;
let activeScoreRequests = 0;
const scoreRequestQueue = [];

function host() {
  return window.location.hostname.toLowerCase();
}

function detectDomainKey() {
  const h = host();
  console.log("[GreenNova] hostname:", h);
  if (h.includes("amazon.")) return "amazon";
  if (h.includes("flipkart.com")) return "flipkart";
  if (h.includes("localhost") || h.includes("127.0.0.1")) return "greenmart";
  return null;
}

function getSelectorsForDomain(domainKey) {
  if (domainKey === "amazon") {
    return {
      card: "div[data-component-type='s-search-result'], div.s-result-item[data-asin]",
      title: "h2 a span, h2 span, a.a-link-normal .a-text-normal",
      price: ".a-price .a-offscreen",
      brand: ".a-size-base-plus.a-color-base, h2 .a-size-base.a-color-base",
      description: ".a-size-base-plus + .a-size-base, .a-row.a-size-base.a-color-secondary",
      category: ""
    };
  }

  if (domainKey === "flipkart") {
    return {
      // Keep multiple selectors to survive frequent class-name changes.
      card: "div.bLCLBY, div.tUxRFH, div._1AtVbE, div[data-id]",
      // Product title link has class atJtCj; also try a[title] as fallback
      title: ".atJtCj, a[title], .KzDlHZ, .s1Q9rs, .IRpwTa",
      // Price: hZ3P6w is the actual price element
      price: ".hZ3P6w, .Nx9bqj, ._30jeq3",
      // Brand name: Fo1I0b is the brand div
      brand: ".Fo1I0b, .syl9yP, ._2WkVRV",
      description: ".WKTcLC, .yKfJKb, ._1xgFaf",
      category: ""
    };
  }

  if (domainKey === "greenmart") {
    return {
      card: ".gm-product-card",
      title: ".gm-product-title",
      price: ".gm-price",
      brand: ".gm-brand",
      description: ".gm-description",
      category: ".gm-category"
    };
  }

  return null;
}

function normalizeText(value) {
  return (value || "").replace(/\s+/g, " ").trim();
}

function firstText(card, selector) {
  if (!selector) return "";
  const el = card.querySelector(selector);
  return el ? normalizeText(el.textContent) : "";
}

function productKey(product) {
  return [product.title, product.brand, product.price, product.category]
    .map((x) => normalizeText(x).toLowerCase())
    .join("|");
}

function extractProduct(card, selectors, domainKey) {
  let title = firstText(card, selectors.title);
  const price = firstText(card, selectors.price);
  const brand = firstText(card, selectors.brand);
  const description = firstText(card, selectors.description);
  const categoryText = firstText(card, selectors.category);
  console.log("[GreenNova] extractProduct:", {
    title,
    price,
    brand,
    description,
    categoryText,
    domainKey
  });

  if (!title) {
    // Fallbacks for cards where title structure varies by layout.
    title =
      firstText(card, "h2 span") ||
      firstText(card, "h2 a") ||
      firstText(card, "a[aria-label]") ||
      firstText(card, "img[alt]");
  }

  if (!title) {
    // Skip silently: broad card selectors may include wrappers or promo containers.
    return null;
  }

  return {
    title,
    price,
    brand,
    description,
    category: categoryText || domainKey,
    url: window.location.href
  };
}

function badgeColor(grade) {
  if (grade === "A") return "#177245";
  if (grade === "B") return "#2a8f54";
  if (grade === "C") return "#c18a1f";
  if (grade === "D") return "#c16024";
  return "#ac2f2f";
}

function createBadge(report, onClick) {
  const button = document.createElement("button");
  button.type = "button";
  button.className = BADGE_CLASS;
  button.style.borderColor = badgeColor(report.grade);
  button.innerHTML = `
    <span class="greennova-score-value">${report.score}</span>
    <span class="greennova-score-grade">${report.grade}</span>
  `;
  button.title = "Open GreenNova sustainability report";
  button.addEventListener("click", onClick);
  return button;
}

function createPendingBadge() {
  const button = document.createElement("button");
  button.type = "button";
  button.className = `${BADGE_CLASS} greennova-pending-badge`;
  button.innerHTML = `
    <span class="greennova-score-value">...</span>
    <span class="greennova-score-grade">AI</span>
  `;
  button.title = "GreenNova is analyzing this product";
  return button;
}

function createErrorBadge(onClick) {
  const button = document.createElement("button");
  button.type = "button";
  button.className = `${BADGE_CLASS} greennova-error-badge`;
  button.innerHTML = `
    <span class="greennova-score-value">AI</span>
    <span class="greennova-score-grade">ERR</span>
  `;
  button.title = "GreenNova local AI is unavailable. Click for details.";
  button.addEventListener("click", onClick);
  return button;
}

function ensureStatusPill() {
  if (statusPill && document.body.contains(statusPill)) {
    return statusPill;
  }

  statusPill = document.createElement("div");
  statusPill.className = "greennova-status-pill";
  statusPill.textContent = "GreenNova: checking local AI...";
  document.body.appendChild(statusPill);
  return statusPill;
}

function setStatusPill(message, offline = false) {
  const pill = ensureStatusPill();
  pill.textContent = message;
  pill.classList.toggle("greennova-status-pill-offline", Boolean(offline));
}

function ensurePanel() {
  if (panel && document.body.contains(panel)) {
    return panel;
  }

  panel = document.createElement("aside");
  panel.id = PANEL_ID;
  panel.innerHTML = `
    <div class="greennova-panel-header">
      <strong>GreenNova Report</strong>
      <button type="button" class="greennova-close">Close</button>
    </div>
    <div class="greennova-panel-content"></div>
  `;

  panel.querySelector(".greennova-close").addEventListener("click", () => {
    panel.classList.remove("open");
  });

  document.body.appendChild(panel);
  return panel;
}

function renderList(items) {
  if (!items || !items.length) {
    return "<li>No data</li>";
  }
  return items.map((item) => `<li>${escapeHtml(item)}</li>`).join("");
}

function escapeHtml(text) {
  return String(text || "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function openReport(product, report) {
  const p = ensurePanel();
  const content = p.querySelector(".greennova-panel-content");

  content.innerHTML = `
    <section>
      <h3>${escapeHtml(product.title)}</h3>
      <p><strong>Score:</strong> ${report.score}/100 (${report.grade})</p>
      <p><strong>Confidence:</strong> ${report.confidence}%</p>
      <p>${escapeHtml(report.summary)}</p>
    </section>
    <section>
      <h4>How It Affects The Environment</h4>
      <p>${escapeHtml(report.environmentImpact)}</p>
    </section>
    <section>
      <h4>Positive Impacts</h4>
      <ul>${renderList(report.positiveImpacts)}</ul>
    </section>
    <section>
      <h4>Negative Impacts</h4>
      <ul>${renderList(report.negativeImpacts)}</ul>
    </section>
    <section>
      <h4>Recommendations</h4>
      <ul>${renderList(report.recommendations)}</ul>
    </section>
  `;

  p.classList.add("open");
}

function sendMessage(message) {
  return new Promise((resolve) => {
    if (!extensionContextValid) {
      resolve({ ok: false, code: "CONTEXT_INVALIDATED" });
      return;
    }

    try {
      chrome.runtime.sendMessage(message, (response) => {
        if (chrome.runtime.lastError) {
          const msg = String(chrome.runtime.lastError.message || "");
          if (msg.includes("Extension context invalidated")) {
            extensionContextValid = false;
            resolve({ ok: false, code: "CONTEXT_INVALIDATED" });
            return;
          }

          resolve({ ok: false, code: "RUNTIME_MESSAGE_FAILED", message: msg });
          return;
        }
        resolve(response || { ok: false });
      });
    } catch (err) {
      const msg = String(err && err.message ? err.message : "");
      if (msg.includes("Extension context invalidated")) {
        extensionContextValid = false;
        resolve({ ok: false, code: "CONTEXT_INVALIDATED" });
        return;
      }

      resolve({ ok: false, code: "RUNTIME_MESSAGE_FAILED", message: msg });
    }
  });
}

function enqueueScoreRequest(task) {
  return new Promise((resolve) => {
    scoreRequestQueue.push({ task, resolve });
    drainScoreQueue();
  });
}

function drainScoreQueue() {
  while (activeScoreRequests < MAX_CONCURRENT_SCORE_REQUESTS && scoreRequestQueue.length) {
    const job = scoreRequestQueue.shift();
    activeScoreRequests += 1;

    Promise.resolve()
      .then(() => job.task())
      .then((result) => job.resolve(result))
      .catch((err) => {
        job.resolve({
          ok: false,
          code: "SCORE_RUNTIME_ERROR",
          message: String(err && err.message ? err.message : "Queue runtime error")
        });
      })
      .finally(() => {
        activeScoreRequests -= 1;
        drainScoreQueue();
      });
  }
}

async function loadSettings() {
  const response = await sendMessage({ type: "GREENNOVA_GET_SETTINGS" });
  if (response.code === "CONTEXT_INVALIDATED") {
    return;
  }

  if (response.ok && response.settings && Array.isArray(response.settings.domainAllowlist)) {
    // If settings were saved as an empty list, keep safe defaults enabled.
    const saved = response.settings.domainAllowlist.filter(Boolean);
    allowlist = saved.length ? saved : [...DEFAULT_ALLOWLIST];
  }
}

function domainEnabled(domainKey) {
  if (domainKey === "greenmart") {
    return true;
  }
  return allowlist.includes(domainKey);
}

async function scoreCard(card, product) {
  if (!extensionContextValid || Date.now() < scoringSuspendedUntil) {
    return false;
  }

  const key = productKey(product);

  if (stateByProductKey.has(key)) {
    const existing = stateByProductKey.get(key);
    const badge = createBadge(existing, () => openReport(product, existing));
    mountBadge(card, badge);
    return true;
  }

  if (inFlightKeys.has(key)) {
    return false;
  }

  inFlightKeys.add(key);

  if (!card.querySelector(`.${BADGE_CLASS}`)) {
    mountBadge(card, createPendingBadge());
  }

  try {
    console.log("[GreenNova] Sending score request for:", product.title);
    const response = await enqueueScoreRequest(() =>
      sendMessage({
        type: "GREENNOVA_SCORE_PRODUCT",
        payload: product
      })
    );

    console.log("[GreenNova] Response received:", response);

    if (!response.ok || !response.report) {
      if (response.code === "CONTEXT_INVALIDATED") {
        extensionContextValid = false;
        return false;
      }

      const errMessage = response.message || "Local Ollama is unavailable.";
      const errorReport = {
        score: "AI unavailable",
        grade: "-",
        confidence: 0,
        summary: errMessage,
        environmentImpact:
          "GreenNova could not generate AI analysis from local Ollama. Start Ollama and ensure model gemma3:12b is installed.",
        positiveImpacts: [],
        negativeImpacts: ["No AI report generated"],
        recommendations: [
          "Run: ollama serve",
          "Run: ollama pull gemma3:12b",
          "Reload extension and refresh this page"
        ]
      };
      mountBadge(card, createErrorBadge(() => openReport(product, errorReport)));
      setStatusPill("GreenNova AI offline", true);

      if (response.code === "OLLAMA_FORBIDDEN") {
        // Avoid flooding logs and repeated failing requests while origin is blocked.
        scoringSuspendedUntil = Date.now() + 90 * 1000;
        if (suspensionCode !== response.code) {
          suspensionCode = response.code;
          console.warn(
            "[GreenNova] Ollama rejected extension origin (403). Configure OLLAMA_ORIGINS and restart Ollama."
          );
        }
      }

      return true;
    }

    console.log("[GreenNova] Mounting badge for:", product.title, "score:", response.report.score);
    stateByProductKey.set(key, response.report);
    const badge = createBadge(response.report, () => openReport(product, response.report));
    mountBadge(card, badge);
    setStatusPill("GreenNova AI online", false);
    return true;
  } finally {
    inFlightKeys.delete(key);
  }
}

function retryObserveCard(card, observer) {
  const current = Number(card.getAttribute(RETRY_ATTR) || "0");
  if (current >= MAX_RETRY_PER_CARD) {
    return;
  }

  card.setAttribute(RETRY_ATTR, String(current + 1));
  card.removeAttribute(PROCESSED_ATTR);

  setTimeout(() => {
    if (document.contains(card) && !card.querySelector(`.${BADGE_CLASS}`)) {
      observer.observe(card);
    }
  }, 1200);
}

function mountBadge(card, badge) {
  const existing = card.querySelector(`.${BADGE_CLASS}`);
  if (existing) {
    existing.replaceWith(badge);
    return;
  }

  const imageContainer = card.querySelector(".gm-product-image-container");
  if (imageContainer) {
    const wrapper = document.createElement("div");
    wrapper.className = "greennova-score-wrap greennova-score-overlay";
    wrapper.appendChild(badge);
    imageContainer.appendChild(wrapper);
    return;
  }

  const target = card.querySelector("h2, .atJtCj, .KzDlHZ, .s1Q9rs") || card;
  const wrapper = document.createElement("div");
  wrapper.className = "greennova-score-wrap";
  wrapper.appendChild(badge);

  if (target === card) {
    card.appendChild(wrapper);
    return;
  }

  if (target.parentElement) {
    target.parentElement.insertAdjacentElement("afterend", wrapper);
  } else {
    card.appendChild(wrapper);
  }
}

function buildObserver(selectors, domainKey) {
  const observer = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) {
          continue;
        }
        const card = entry.target;
        observer.unobserve(card);

        if (card.getAttribute(PROCESSED_ATTR) === "1") {
          continue;
        }
        card.setAttribute(PROCESSED_ATTR, "1");

        const product = extractProduct(card, selectors, domainKey);
        if (!product) {
          continue;
        }

        scoreCard(card, product).then((ok) => {
          if (!ok) {
            retryObserveCard(card, observer);
          }
        });
      }
    },
    {
      root: null,
      threshold: 0.35
    }
  );

  return observer;
}

function looksLikeProductCard(card, selectors) {
  const hasTitle = Boolean(firstText(card, selectors.title));
  const hasPrice = Boolean(firstText(card, selectors.price));

  // Many layouts include wrapper containers; require at least one product signal.
  if (hasTitle || hasPrice) {
    return true;
  }

  // Extra fallback signals used across Amazon/Flipkart variants.
  const fallbackTitle =
    firstText(card, "h2 span") ||
    firstText(card, "a[title]") ||
    firstText(card, "img[alt]");
  return Boolean(fallbackTitle);
}

function watchCards(selectors, domainKey) {
  const observer = buildObserver(selectors, domainKey);

  const scan = () => {
    const cards = document.querySelectorAll(selectors.card);
    console.log(`[GreenNova] scan() — found ${cards.length} cards with selector:`, selectors.card);
    cards.forEach((card) => {
      if (!looksLikeProductCard(card, selectors)) {
        return;
      }

      if (!card.querySelector(`.${BADGE_CLASS}`)) {
        observer.observe(card);
      }
    });
  };

  scan();

  const mutationObserver = new MutationObserver(() => {
    scan();
  });

  mutationObserver.observe(document.body, {
    childList: true,
    subtree: true
  });
}

async function init() {
  console.log("[GreenNova] init() called");
  const domainKey = detectDomainKey();
  if (!domainKey) {
    console.log("[GreenNova] Domain not supported, exiting.");
    return;
  }
  console.log("[GreenNova] Domain detected:", domainKey);

  await loadSettings();
  console.log("[GreenNova] Allowlist:", allowlist, "| Enabled:", domainEnabled(domainKey));

  if (!domainEnabled(domainKey)) {
    console.warn("[GreenNova] Domain is disabled in settings.");
    return;
  }

  if (domainKey === "greenmart") {
    ensureStatusPill();
    const health = await sendMessage({ type: "GREENNOVA_HEALTHCHECK" });
    if (health && health.ok && health.healthy) {
      setStatusPill("GreenNova AI online", false);
    } else {
      setStatusPill("GreenNova AI offline", true);
    }
  }

  const selectors = getSelectorsForDomain(domainKey);
  if (!selectors) {
    console.error("[GreenNova] No selectors for domain:", domainKey);
    return;
  }

  console.log("[GreenNova] Using selectors:", selectors);
  watchCards(selectors, domainKey);
}

init();

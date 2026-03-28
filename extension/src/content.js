const BADGE_CLASS = "greennova-score-badge";
const PANEL_ID = "greennova-report-panel";
const PROCESSED_ATTR = "data-greennova-processed";
const DEFAULT_ALLOWLIST = ["amazon", "flipkart"];

let allowlist = [...DEFAULT_ALLOWLIST];
let panel;
let extensionContextValid = true;
const stateByProductKey = new Map();
let currentDomainKey = null;
let currentSelectors = null;

function host() {
  return window.location.hostname.toLowerCase();
}

function detectDomainKey() {
  const h = host();
  if (h.includes("amazon.")) return "amazon";
  if (h.includes("flipkart.com")) return "flipkart";
  return null;
}

function getSelectorsForDomain(domainKey) {
  if (domainKey === "amazon") {
    return {
      card: "div[data-component-type='s-search-result'], div.s-result-item[data-asin]",
      title: "h2 a span, h2 span, a.a-link-normal .a-text-normal",
      price: ".a-price .a-offscreen",
      brand: ".a-size-base-plus.a-color-base, h2 .a-size-base.a-color-base"
    };
  }

  if (domainKey === "flipkart") {
    return {
      card: "div.bLCLBY, div.tUxRFH, div._1AtVbE, div[data-id]",
      title: ".atJtCj, a[title], .KzDlHZ, .s1Q9rs, .IRpwTa",
      price: ".hZ3P6w, .Nx9bqj, ._30jeq3",
      brand: ".Fo1I0b, .syl9yP, ._2WkVRV"
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

  if (!title) {
    title =
      firstText(card, "h2 span") ||
      firstText(card, "h2 a") ||
      firstText(card, "a[aria-label]") ||
      firstText(card, "img[alt]");
  }

  if (!title) {
    return null;
  }

  let url = window.location.href;
  const linkEl = card.querySelector("a.a-link-normal, a.atJtCj, a");
  if (linkEl && linkEl.href) {
    url = linkEl.href;
  }

  return {
    title,
    price,
    brand,
    category: domainKey,
    url
  };
}

function looksLikeProductCard(card, selectors) {
  const hasTitle = Boolean(firstText(card, selectors.title));
  const hasPrice = Boolean(firstText(card, selectors.price));

  if (hasTitle || hasPrice) {
    return true;
  }

  const fallbackTitle =
    firstText(card, "h2 span") ||
    firstText(card, "a[title]") ||
    firstText(card, "img[alt]");
  return Boolean(fallbackTitle);
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

function createErrorBadge() {
  const div = document.createElement("div");
  div.className = BADGE_CLASS;
  div.style.background = "linear-gradient(135deg, rgba(255, 245, 245, 0.9) 0%, rgba(255, 230, 230, 0.8) 100%)";
  div.style.borderColor = "rgba(220, 53, 69, 0.3)";
  div.style.color = "#a72834";
  div.style.cursor = "default";
  div.title = "Local AI could not generate score";
  div.innerHTML = `<span class="greennova-score-value">ERR</span>`;
  return div;
}

function createLoadingBadge() {
  const div = document.createElement("div");
  div.className = `${BADGE_CLASS} greennova-loading`;
  div.title = "AI is currently analyzing this product...";
  div.innerHTML = `
    <span class="greennova-score-value">...</span>
    <span class="greennova-score-grade">AI</span>
  `;
  return div;
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

function renderReportContent(container, product, report) {
  let headerHtml = `<h3>${escapeHtml(product.title)}</h3>`;
  if (report.isDeep) {
    headerHtml += `<div style="margin-bottom: 12px;"><span style="background: linear-gradient(135deg, rgba(42,143,84,0.1), rgba(42,143,84,0.05)); color: #177245; padding: 4px 8px; border-radius: 6px; font-size: 11px; font-weight: 700; border: 1px solid rgba(42,143,84,0.2); backdrop-filter: blur(4px);">✨ DEEP ANALYSIS</span></div>`;
  }
  
  container.innerHTML = `
    <section style="background: linear-gradient(135deg, #f0fff4 0%, #e6ffed 100%); border: 1px solid rgba(42, 143, 84, 0.2);">
      ${headerHtml}
      <div style="display: flex; gap: 16px; margin-top: 8px;">
        <div>
          <span style="font-size: 11px; color: #4a5568; text-transform: uppercase; font-weight: 600; letter-spacing: 0.5px;">Score</span>
          <div style="font-size: 24px; font-weight: 700; color: #1a202c;">${report.score}<span style="font-size: 14px; color: #718096; font-weight: 500;">/100</span></div>
        </div>
        <div>
          <span style="font-size: 11px; color: #4a5568; text-transform: uppercase; font-weight: 600; letter-spacing: 0.5px;">Grade</span>
          <div style="font-size: 16px; font-weight: 700; color: #2a8f54; margin-top: 4px; display: inline-block; padding: 2px 8px; border-radius: 4px; background: rgba(255,255,255,0.8); border: 1px solid rgba(42,143,84,0.2);">${report.grade}</div>
        </div>
      </div>
      <p style="margin-top: 12px; color: #2d3748; font-weight: 500;">${escapeHtml(report.summary)}</p>
    </section>
    <section>
      <h4>How It Affects The Environment</h4>
      <p>${escapeHtml(report.environmentImpact)}</p>
    </section>
    <section>
      <h4>Positive Impacts</h4>
      <ul style="color: #2a8f54;">${renderList(report.positiveImpacts)}</ul>
    </section>
    <section>
      <h4>Negative Impacts</h4>
      <ul style="color: #c53030;">${renderList(report.negativeImpacts)}</ul>
    </section>
    <section>
      <h4>Recommendations</h4>
      <ul style="color: #2b6cb0;">${renderList(report.recommendations)}</ul>
    </section>
  `;
}

async function fetchProductDetails(url) {
  try {
    const response = await fetch(url);
    const html = await response.text();
    const doc = new DOMParser().parseFromString(html, "text/html");
    
    const bullets = doc.querySelector('#feature-bullets') || doc.querySelector('#productDescription');
    const details = doc.querySelector('#detailBullets_feature_div') || doc.querySelector('#prodDetails');
    const category = doc.querySelector('#wayfinding-breadcrumbs_container');
    const fkBullets = doc.querySelector('.x-dws') || doc.querySelector('.yN+eE');

    const textData = [
       bullets ? bullets.textContent : "",
       details ? details.textContent : "",
       category ? category.textContent : "",
       fkBullets ? fkBullets.textContent : ""
    ].join(" ").replace(/\s+/g, " ").trim();
    
    return textData.substring(0, 5000); 
  } catch(e) {
    console.warn("[GreenNova] Failed to parse target product URL:", e);
    return "";
  }
}

async function openReport(product, report) {
  const p = ensurePanel();
  const content = p.querySelector(".greennova-panel-content");

  // Initial shallow render
  renderReportContent(content, product, report);
  p.classList.add("open");

  if (!report.isDeep) {
    const loadingDiv = document.createElement("div");
    loadingDiv.className = "greennova-deep-loading";
    loadingDiv.style.textAlign = "center";
    loadingDiv.style.marginTop = "24px";
    loadingDiv.style.padding = "24px 16px";
    loadingDiv.style.borderTop = "1px solid rgba(0,0,0,0.05)";
    loadingDiv.style.background = "linear-gradient(to bottom, transparent, rgba(255,255,255,0.5))";
    loadingDiv.style.borderRadius = "0 0 12px 12px";
    loadingDiv.innerHTML = `
      <div class="greennova-spinner" style="width: 24px; height: 24px; border-width: 3px; border-color: rgba(42, 143, 84, 0.2); border-top-color: #2a8f54; border-radius: 50%; animation: greennova-spin 1s linear infinite; margin: 0 auto 12px;"></div>
      <p style="color: #4a5568; font-size: 12px; font-weight: 500; margin: 0; animation: greennova-pulse 1.5s infinite;">Fetching deep sustainability insights...</p>
      <style>@keyframes greennova-spin { to { transform: rotate(360deg); } }</style>
    `;
    content.appendChild(loadingDiv);

    console.log("[GreenNova] Fetching deep product analysis for URL:", product.url);
    const detailsText = await fetchProductDetails(product.url);
    
    const response = await sendMessage({
      type: "GREENNOVA_DEEP_SCORE",
      payload: { product, detailsText }
    });

    if (loadingDiv.parentNode) {
      loadingDiv.remove();
    }

    if (response.ok && response.report) {
       console.log("[GreenNova] Received deep analysis!", response.report);
       response.report.isDeep = true;
       // We DO NOT sync this heavy result back to the badge list to avoid overriding chunks with slow single calls
       // Instead, replace the sidebar view immediately
       renderReportContent(content, product, response.report);
    } else {
       const errP = document.createElement("p");
       errP.style.color = "#ac2f2f";
       errP.style.fontSize = "12px";
       errP.style.textAlign = "center";
       errP.textContent = "Could not fetch deep analysis details.";
       content.appendChild(errP);
    }
  }
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

function mountBadge(card, badge) {
  const existing = card.querySelector(`.${BADGE_CLASS}`);
  if (existing) {
    existing.replaceWith(badge);
    return;
  }

  const target = card.querySelector("h2, .atJtCj, .KzDlHZ, .s1Q9rs") || card;
  const wrapper = document.createElement("div");
  wrapper.className = "greennova-score-wrap";
  wrapper.appendChild(badge);

  if (target.parentElement && target.tagName !== "DIV") {
    target.parentElement.insertAdjacentElement("afterend", wrapper);
  } else {
    card.appendChild(wrapper);
  }
}

async function handleBatchActivate() {
  if (!currentDomainKey || !currentSelectors) {
    console.warn("[GreenNova] Cannot activate batch, domain unsupported.");
    return;
  }

  const cards = document.querySelectorAll(currentSelectors.card);
  const productsPayload = [];
  const cardMap = new Map();

  let idCounter = 1;

  for (const card of cards) {
    if (!looksLikeProductCard(card, currentSelectors)) {
      continue;
    }

    const product = extractProduct(card, currentSelectors, currentDomainKey);
    if (!product) {
      continue;
    }

    const entryId = idCounter++;
    product.id = entryId;
    
    cardMap.set(entryId, { card, product });
    productsPayload.push(product);

    // Mount loading placeholder immediately
    mountBadge(card, createLoadingBadge());
  }

  if (productsPayload.length === 0) {
    console.log("[GreenNova] No products found on this page.");
    return;
  }

  console.log(`[GreenNova] Found ${productsPayload.length} product cards. Processing in batches...`);

  const CHUNK_SIZE = 10;
  for (let i = 0; i < productsPayload.length; i += CHUNK_SIZE) {
    const chunk = productsPayload.slice(i, i + CHUNK_SIZE);
    console.log(`[GreenNova] Processing chunk ${Math.floor(i / CHUNK_SIZE) + 1} of ${Math.ceil(productsPayload.length / CHUNK_SIZE)} (${chunk.length} items)...`);

    const response = await sendMessage({
      type: "GREENNOVA_BATCH_SCORE",
      payload: chunk
    });

    if (response.code === "CONTEXT_INVALIDATED") {
       console.error("[GreenNova] Extension context invalidated.");
       break;
    }

    if (!response.ok || !response.reports) {
      console.error(`[GreenNova] Chunk ${Math.floor(i / CHUNK_SIZE) + 1} failed:`, response.message);
      for (const p of chunk) {
         const mapping = cardMap.get(p.id);
         if (mapping) {
           mountBadge(mapping.card, createErrorBadge());
         }
      }
      continue; 
    }

    const reports = response.reports;
    for (const report of reports) {
      if (!report || !report.id) continue;
      
      const mapping = cardMap.get(report.id);
      if (mapping) {
        stateByProductKey.set(productKey(mapping.product), report);
        const badge = createBadge(report, () => openReport(mapping.product, report));
        mountBadge(mapping.card, badge);
      }
    }
  }

  console.log("[GreenNova] AI Batch processing complete!");
}

async function loadSettings() {
  const response = await sendMessage({ type: "GREENNOVA_GET_SETTINGS" });
  if (response.code === "CONTEXT_INVALIDATED") {
    return;
  }

  if (response.ok && response.settings && Array.isArray(response.settings.domainAllowlist)) {
    const saved = response.settings.domainAllowlist.filter(Boolean);
    allowlist = saved.length ? saved : [...DEFAULT_ALLOWLIST];
  }
}

function domainEnabled(domainKey) {
  return allowlist.includes(domainKey);
}

chrome.runtime.onMessage.addListener((msg, sender, sendResponse) => {
  if (msg.type === "GREENNOVA_ACTIVATE_BATCH_SCORE") {
    console.log("[GreenNova] Received activate batch message.");
    handleBatchActivate();
    sendResponse({ ok: true });
  }
});

async function init() {
  console.log("[GreenNova] init() called");
  currentDomainKey = detectDomainKey();
  if (!currentDomainKey) {
    console.log("[GreenNova] Domain not supported, exiting.");
    return;
  }

  await loadSettings();
  if (!domainEnabled(currentDomainKey)) {
    console.warn("[GreenNova] Domain is disabled in settings.");
    return;
  }

  currentSelectors = getSelectorsForDomain(currentDomainKey);
  if (!currentSelectors) {
    console.error("[GreenNova] No selectors for domain:", currentDomainKey);
    return;
  }

  console.log("[GreenNova] Content script loaded. Awaiting action click.");
}

init();

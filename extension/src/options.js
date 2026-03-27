const statusEl = document.getElementById("status");
const saveBtn = document.getElementById("saveBtn");
const amazonCheckbox = document.getElementById("amazon");
const flipkartCheckbox = document.getElementById("flipkart");
const customDomainsInput = document.getElementById("customDomains");

function setStatus(message, isError = false) {
  statusEl.textContent = message;
  statusEl.style.color = isError ? "#a32626" : "#22573a";
}

function sendMessage(message) {
  return new Promise((resolve) => {
    chrome.runtime.sendMessage(message, (response) => {
      resolve(response || { ok: false });
    });
  });
}

async function load() {
  const response = await sendMessage({ type: "GREENNOVA_GET_SETTINGS" });
  if (!response.ok) {
    setStatus("Could not load settings.", true);
    return;
  }

  const settings = response.settings || {};
  const allowlist = settings.domainAllowlist || [];
  amazonCheckbox.checked = allowlist.includes("amazon");
  flipkartCheckbox.checked = allowlist.includes("flipkart");
  customDomainsInput.value = (settings.customDomainHints || []).join(", ");
}

async function save() {
  const domainAllowlist = [];
  if (amazonCheckbox.checked) domainAllowlist.push("amazon");
  if (flipkartCheckbox.checked) domainAllowlist.push("flipkart");

  const customDomainHints = customDomainsInput.value
    .split(",")
    .map((x) => x.trim().toLowerCase())
    .filter(Boolean);

  const response = await sendMessage({
    type: "GREENNOVA_SET_SETTINGS",
    payload: {
      domainAllowlist,
      customDomainHints
    }
  });

  if (!response.ok) {
    setStatus("Could not save settings.", true);
    return;
  }

  setStatus("Settings saved.");
}

saveBtn.addEventListener("click", save);
load();

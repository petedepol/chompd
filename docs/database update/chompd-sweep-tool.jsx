import { useState, useEffect, useCallback, useRef } from "react";

// ━━━ CONSTANTS ━━━
const PHASES = [
  { id: "pricing", label: "Pricing", icon: "💰", desc: "Verify tier prices across currencies" },
  { id: "cancel_guides", label: "Cancel Guides", icon: "🚪", desc: "Verify cancel steps & deeplinks" },
  { id: "refund", label: "Refund Templates", icon: "💸", desc: "Check refund policy & contacts" },
  { id: "dark_patterns", label: "Dark Patterns", icon: "🕳️", desc: "Scan for deceptive practices" },
  { id: "alternatives", label: "Alternatives", icon: "🔄", desc: "Update competitor suggestions" },
  { id: "community", label: "Community Tips", icon: "👥", desc: "Moderate pending user tips" },
];

const C = {
  bg: "#0a0a0f",
  surface: "#12121a",
  card: "#1a1a26",
  cardHover: "#22222e",
  border: "#2a2a3a",
  borderLight: "#3a3a4e",
  text: "#e8e8f0",
  textDim: "#8888a0",
  textMuted: "#55556a",
  accent: "#ff6b35",     // Chompd piranha orange
  accentDim: "#ff6b3540",
  green: "#34d399",
  greenDim: "#34d39930",
  red: "#f87171",
  redDim: "#f8717130",
  blue: "#60a5fa",
  blueDim: "#60a5fa30",
  yellow: "#fbbf24",
  yellowDim: "#fbbf2430",
  purple: "#a78bfa",
};

// ━━━ SWEEP PROMPT BUILDER ━━━
function buildSweepPrompt(service, phases, date) {
  const phaseInstructions = [];
  if (phases.includes("pricing")) {
    phaseInstructions.push(`PRICING: Search for current ${service.name} subscription pricing. Check each tier (${(service.tiers || []).map(t => t.tier_name).join(", ") || "all tiers"}). Find prices in GBP, USD, EUR, PLN. Report exact prices. Check trial days and whether trial requires payment.`);
  }
  if (phases.includes("cancel_guides")) {
    phaseInstructions.push(`CANCEL GUIDES: Search "how to cancel ${service.name} ${new Date().getFullYear()}". Get step-by-step instructions for iOS, Android, and Web. Find cancel URLs. Rate cancel difficulty 1-10.`);
  }
  if (phases.includes("refund")) {
    phaseInstructions.push(`REFUND: Search "${service.name} refund policy ${new Date().getFullYear()}". Find refund window (days), contact email, support URL, and estimated success rate.`);
  }
  if (phases.includes("dark_patterns")) {
    phaseInstructions.push(`DARK PATTERNS: Search "${service.name} dark pattern" and "${service.name} hard to cancel". Flag deceptive practices. Classify severity: mild/moderate/severe.`);
  }
  if (phases.includes("alternatives")) {
    phaseInstructions.push(`ALTERNATIVES: Search "best alternatives to ${service.name} ${new Date().getFullYear()}". List top 3 with reason and price comparison.`);
  }

  return `You are updating the Chompd subscription database. Today is ${date}.

Service: ${service.name} (${service.category})
Slug: ${service.slug}
Current data: ${JSON.stringify(service, null, 2)}

CHECK THESE PHASES:
${phaseInstructions.map((p, i) => `${i + 1}. ${p}`).join("\n")}

Use web search to verify each phase thoroughly.

Respond ONLY with valid JSON (no markdown, no backticks, no preamble):
{
  "pricing": {
    "changes": [{"tier": "tier_name", "field": "monthly_gbp", "old": 0.00, "new": 0.00}],
    "trial_changes": {"trial_days": null, "trial_requires_payment": null}
  },
  "cancel_guides": {
    "platforms": {
      "ios": {"steps": ["step 1", "step 2"], "cancel_deeplink": null, "warning": null, "pro_tip": null},
      "android": null,
      "web": null
    },
    "cancel_difficulty": 5
  },
  "refund": {
    "refund_window_days": null,
    "contact_email": null,
    "contact_url": null,
    "success_rate_pct": null,
    "process_notes": null
  },
  "dark_patterns": [
    {"type": "pattern_type", "severity": "mild", "title": "short title", "description": "details"}
  ],
  "alternatives": [
    {"name": "Service Name", "reason": "why it's good", "price_comparison": "£X/mo cheaper"}
  ],
  "notes": "anything else notable"
}

Only include phases you were asked to check. Set others to null.`;
}

// ━━━ SONNET API CALL ━━━
async function runSweep(service, phases) {
  const date = new Date().toLocaleDateString("en-GB", { day: "numeric", month: "long", year: "numeric" });
  const prompt = buildSweepPrompt(service, phases, date);

  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      model: "claude-sonnet-4-5-20250929",
      max_tokens: 4096,
      tools: [{ type: "web_search_20250305", name: "web_search" }],
      messages: [{ role: "user", content: prompt }],
    }),
  });

  const data = await response.json();
  const textBlocks = (data.content || []).filter(b => b.type === "text").map(b => b.text);
  const fullText = textBlocks.join("\n");
  const cleaned = fullText.replace(/```json|```/g, "").trim();

  try {
    return { success: true, data: JSON.parse(cleaned), raw: fullText };
  } catch {
    return { success: false, data: null, raw: fullText, error: "Failed to parse JSON response" };
  }
}

// ━━━ SUPABASE HELPERS ━━━
async function fetchServices(url, key) {
  const res = await fetch(`${url}/rest/v1/services?select=*,service_tiers(*)&order=name`, {
    headers: { apikey: key, Authorization: `Bearer ${key}` },
  });
  if (!res.ok) throw new Error(`Supabase error: ${res.status}`);
  return res.json();
}

async function supabaseUpdate(url, key, table, id, data) {
  const res = await fetch(`${url}/rest/v1/${table}?id=eq.${id}`, {
    method: "PATCH",
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
      Prefer: "return=minimal",
    },
    body: JSON.stringify({ ...data, verified_at: new Date().toISOString(), updated_at: new Date().toISOString() }),
  });
  if (!res.ok) throw new Error(`Update failed: ${res.status}`);
}

async function supabaseInsert(url, key, table, data) {
  const res = await fetch(`${url}/rest/v1/${table}`, {
    method: "POST",
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
      Prefer: "return=representation",
    },
    body: JSON.stringify(data),
  });
  if (!res.ok) throw new Error(`Insert failed: ${res.status}`);
  return res.json();
}

// ━━━ COMPONENTS ━━━

function ConfigPanel({ config, setConfig, onConnect, connected, serviceCount }) {
  return (
    <div style={{ background: C.card, borderRadius: 12, border: `1px solid ${C.border}`, padding: 20, marginBottom: 16 }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 16 }}>
        <span style={{ fontSize: 20 }}>🔧</span>
        <span style={{ fontSize: 14, fontWeight: 700, color: C.text, letterSpacing: "0.05em" }}>SUPABASE CONFIG</span>
        {connected && (
          <span style={{ fontSize: 11, padding: "3px 10px", borderRadius: 100, background: C.greenDim, color: C.green, fontWeight: 600 }}>
            Connected — {serviceCount} services
          </span>
        )}
      </div>
      <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
        <input
          placeholder="Supabase URL"
          value={config.url}
          onChange={e => setConfig(c => ({ ...c, url: e.target.value }))}
          style={inputStyle}
        />
        <input
          placeholder="Service Role Key"
          type="password"
          value={config.key}
          onChange={e => setConfig(c => ({ ...c, key: e.target.value }))}
          style={{ ...inputStyle, flex: 2 }}
        />
        <button onClick={onConnect} style={btnStyle(C.accent, !config.url || !config.key)}>
          {connected ? "Reconnect" : "Connect"}
        </button>
      </div>
    </div>
  );
}

function ServiceSelector({ services, selected, setSelected, search, setSearch }) {
  const filtered = services.filter(s =>
    s.name.toLowerCase().includes(search.toLowerCase()) ||
    s.category.toLowerCase().includes(search.toLowerCase())
  );
  const allSelected = filtered.length > 0 && filtered.every(s => selected.includes(s.id));

  return (
    <div style={{ background: C.card, borderRadius: 12, border: `1px solid ${C.border}`, padding: 20, marginBottom: 16 }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <span style={{ fontSize: 20 }}>🎯</span>
          <span style={{ fontSize: 14, fontWeight: 700, color: C.text, letterSpacing: "0.05em" }}>SERVICES</span>
          <span style={{ fontSize: 11, color: C.textDim }}>{selected.length} selected</span>
        </div>
        <button
          onClick={() => {
            if (allSelected) setSelected(sel => sel.filter(id => !filtered.find(s => s.id === id)));
            else setSelected(sel => [...new Set([...sel, ...filtered.map(s => s.id)])]);
          }}
          style={{ ...tagBtn, background: allSelected ? C.accentDim : `${C.textMuted}30`, color: allSelected ? C.accent : C.textDim }}
        >
          {allSelected ? "Deselect All" : "Select All"}
        </button>
      </div>
      <input
        placeholder="Search services..."
        value={search}
        onChange={e => setSearch(e.target.value)}
        style={{ ...inputStyle, width: "100%", marginBottom: 12 }}
      />
      <div style={{ display: "flex", flexWrap: "wrap", gap: 6, maxHeight: 200, overflowY: "auto" }}>
        {filtered.map(s => {
          const active = selected.includes(s.id);
          return (
            <button
              key={s.id}
              onClick={() => setSelected(sel => active ? sel.filter(id => id !== s.id) : [...sel, s.id])}
              style={{
                padding: "6px 12px",
                borderRadius: 8,
                border: `1px solid ${active ? C.accent : C.border}`,
                background: active ? C.accentDim : "transparent",
                color: active ? C.accent : C.textDim,
                cursor: "pointer",
                fontSize: 12,
                fontWeight: active ? 600 : 400,
                fontFamily: "'JetBrains Mono', monospace",
                transition: "all 0.15s",
              }}
            >
              <span style={{ display: "inline-block", width: 18, height: 18, borderRadius: 4, background: s.brand_color || C.textMuted, marginRight: 6, verticalAlign: "middle", textAlign: "center", lineHeight: "18px", fontSize: 9, color: "#fff", fontWeight: 700 }}>
                {(s.icon_letter || s.name[0]).slice(0, 2)}
              </span>
              {s.name}
              <span style={{ fontSize: 9, color: C.textMuted, marginLeft: 6 }}>{s.category}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}

function PhaseSelector({ selectedPhases, setSelectedPhases }) {
  const allSelected = selectedPhases.length === PHASES.length;
  return (
    <div style={{ background: C.card, borderRadius: 12, border: `1px solid ${C.border}`, padding: 20, marginBottom: 16 }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between", marginBottom: 12 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <span style={{ fontSize: 20 }}>⚡</span>
          <span style={{ fontSize: 14, fontWeight: 700, color: C.text, letterSpacing: "0.05em" }}>PHASES</span>
        </div>
        <button
          onClick={() => setSelectedPhases(allSelected ? [] : PHASES.map(p => p.id))}
          style={{ ...tagBtn, background: allSelected ? C.accentDim : `${C.textMuted}30`, color: allSelected ? C.accent : C.textDim }}
        >
          {allSelected ? "None" : "All Phases"}
        </button>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))", gap: 8 }}>
        {PHASES.map(p => {
          const active = selectedPhases.includes(p.id);
          return (
            <button
              key={p.id}
              onClick={() => setSelectedPhases(sel => active ? sel.filter(x => x !== p.id) : [...sel, p.id])}
              style={{
                display: "flex", alignItems: "center", gap: 8, padding: "10px 14px",
                borderRadius: 8, border: `1px solid ${active ? C.accent : C.border}`,
                background: active ? C.accentDim : "transparent",
                cursor: "pointer", textAlign: "left", transition: "all 0.15s",
              }}
            >
              <span style={{ fontSize: 16 }}>{p.icon}</span>
              <div>
                <div style={{ fontSize: 12, fontWeight: 600, color: active ? C.accent : C.text }}>{p.label}</div>
                <div style={{ fontSize: 10, color: C.textMuted }}>{p.desc}</div>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
}

function ResultCard({ result, onApprove, onReject }) {
  const [expanded, setExpanded] = useState(false);
  const { service, status, data, error, raw, approved } = result;

  const statusConfig = {
    unchanged: { icon: "✅", label: "No changes", color: C.green, bg: C.greenDim },
    changed: { icon: "⚠️", label: "Changes detected", color: C.yellow, bg: C.yellowDim },
    error: { icon: "❌", label: "Error", color: C.red, bg: C.redDim },
    pending: { icon: "⏳", label: "Pending", color: C.blue, bg: C.blueDim },
  };
  const sc = statusConfig[status] || statusConfig.pending;

  const hasChanges = data && (
    (data.pricing?.changes?.length > 0) ||
    data.cancel_guides ||
    data.refund ||
    (data.dark_patterns?.length > 0) ||
    (data.alternatives?.length > 0)
  );

  return (
    <div style={{
      background: C.card, borderRadius: 12, border: `1px solid ${approved === true ? C.green : approved === false ? C.red : C.border}`,
      overflow: "hidden", transition: "all 0.2s",
    }}>
      <div
        onClick={() => setExpanded(!expanded)}
        style={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          padding: "14px 18px", cursor: "pointer",
        }}
      >
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <span style={{
            display: "inline-block", width: 28, height: 28, borderRadius: 6,
            background: service.brand_color || C.textMuted, textAlign: "center",
            lineHeight: "28px", fontSize: 11, color: "#fff", fontWeight: 700,
          }}>
            {(service.icon_letter || service.name[0]).slice(0, 2)}
          </span>
          <div>
            <div style={{ fontSize: 13, fontWeight: 600, color: C.text }}>{service.name}</div>
            <div style={{ fontSize: 10, color: C.textMuted }}>{service.category}</div>
          </div>
        </div>
        <div style={{ display: "flex", alignItems: "center", gap: 8 }}>
          {approved === true && <span style={{ fontSize: 10, padding: "3px 8px", borderRadius: 100, background: C.greenDim, color: C.green, fontWeight: 600 }}>Approved</span>}
          {approved === false && <span style={{ fontSize: 10, padding: "3px 8px", borderRadius: 100, background: C.redDim, color: C.red, fontWeight: 600 }}>Rejected</span>}
          <span style={{ fontSize: 10, padding: "3px 8px", borderRadius: 100, background: sc.bg, color: sc.color, fontWeight: 600 }}>
            {sc.icon} {sc.label}
          </span>
          <span style={{ color: C.textMuted, fontSize: 14, transform: expanded ? "rotate(180deg)" : "rotate(0deg)", transition: "transform 0.2s" }}>▼</span>
        </div>
      </div>

      {expanded && (
        <div style={{ padding: "0 18px 18px", borderTop: `1px solid ${C.border}` }}>
          {error && <div style={{ padding: 12, background: C.redDim, borderRadius: 8, color: C.red, fontSize: 12, marginTop: 12 }}>{error}</div>}

          {data?.pricing?.changes?.length > 0 && (
            <DiffSection title="💰 Pricing Changes" items={data.pricing.changes.map(c => ({
              label: `${c.tier} → ${c.field}`,
              old: c.old != null ? `${c.old}` : "—",
              new: c.new != null ? `${c.new}` : "—",
            }))} />
          )}

          {data?.cancel_guides && (
            <div style={{ marginTop: 12 }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: C.text, marginBottom: 6 }}>🚪 Cancel Guides</div>
              {data.cancel_guides.cancel_difficulty && (
                <div style={{ fontSize: 11, color: C.textDim, marginBottom: 6 }}>
                  Difficulty: <span style={{ color: data.cancel_guides.cancel_difficulty > 6 ? C.red : data.cancel_guides.cancel_difficulty > 3 ? C.yellow : C.green, fontWeight: 600 }}>
                    {data.cancel_guides.cancel_difficulty}/10
                  </span>
                </div>
              )}
              {data.cancel_guides.platforms && Object.entries(data.cancel_guides.platforms).filter(([, v]) => v).map(([platform, guide]) => (
                <div key={platform} style={{ background: C.surface, borderRadius: 8, padding: 10, marginBottom: 6, fontSize: 11 }}>
                  <div style={{ fontWeight: 600, color: C.blue, textTransform: "uppercase", fontSize: 10, marginBottom: 4 }}>{platform}</div>
                  {guide.steps?.map((step, i) => (
                    <div key={i} style={{ color: C.textDim, marginBottom: 2 }}>
                      <span style={{ color: C.accent, fontWeight: 600 }}>{i + 1}.</span> {step}
                    </div>
                  ))}
                  {guide.warning && <div style={{ color: C.yellow, marginTop: 4, fontSize: 10 }}>⚠️ {guide.warning}</div>}
                  {guide.pro_tip && <div style={{ color: C.green, marginTop: 2, fontSize: 10 }}>💡 {guide.pro_tip}</div>}
                </div>
              ))}
            </div>
          )}

          {data?.refund && (
            <div style={{ marginTop: 12 }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: C.text, marginBottom: 6 }}>💸 Refund Info</div>
              <div style={{ background: C.surface, borderRadius: 8, padding: 10, fontSize: 11 }}>
                {data.refund.refund_window_days && <div style={{ color: C.textDim }}>Window: <span style={{ color: C.text }}>{data.refund.refund_window_days} days</span></div>}
                {data.refund.contact_email && <div style={{ color: C.textDim }}>Email: <span style={{ color: C.blue }}>{data.refund.contact_email}</span></div>}
                {data.refund.success_rate_pct && <div style={{ color: C.textDim }}>Success rate: <span style={{ color: C.green }}>{data.refund.success_rate_pct}%</span></div>}
                {data.refund.process_notes && <div style={{ color: C.textDim, marginTop: 4 }}>{data.refund.process_notes}</div>}
              </div>
            </div>
          )}

          {data?.dark_patterns?.length > 0 && (
            <div style={{ marginTop: 12 }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: C.text, marginBottom: 6 }}>🕳️ Dark Patterns</div>
              {data.dark_patterns.map((dp, i) => (
                <div key={i} style={{ background: C.surface, borderRadius: 8, padding: 10, marginBottom: 4, fontSize: 11 }}>
                  <div style={{ display: "flex", gap: 6, alignItems: "center" }}>
                    <span style={{ fontWeight: 600, color: C.text }}>{dp.title}</span>
                    <span style={{
                      fontSize: 9, padding: "2px 6px", borderRadius: 100, fontWeight: 600,
                      background: dp.severity === "severe" ? C.redDim : dp.severity === "moderate" ? C.yellowDim : `${C.textMuted}30`,
                      color: dp.severity === "severe" ? C.red : dp.severity === "moderate" ? C.yellow : C.textDim,
                    }}>{dp.severity}</span>
                  </div>
                  <div style={{ color: C.textDim, marginTop: 2 }}>{dp.description}</div>
                </div>
              ))}
            </div>
          )}

          {data?.alternatives?.length > 0 && (
            <div style={{ marginTop: 12 }}>
              <div style={{ fontSize: 11, fontWeight: 700, color: C.text, marginBottom: 6 }}>🔄 Alternatives</div>
              {data.alternatives.map((alt, i) => (
                <div key={i} style={{ background: C.surface, borderRadius: 8, padding: 10, marginBottom: 4, fontSize: 11, display: "flex", justifyContent: "space-between" }}>
                  <div>
                    <span style={{ fontWeight: 600, color: C.text }}>{alt.name}</span>
                    <div style={{ color: C.textDim, marginTop: 2 }}>{alt.reason}</div>
                  </div>
                  {alt.price_comparison && <span style={{ color: C.green, fontSize: 10, fontWeight: 600, whiteSpace: "nowrap" }}>{alt.price_comparison}</span>}
                </div>
              ))}
            </div>
          )}

          {data?.notes && (
            <div style={{ marginTop: 12, fontSize: 11, color: C.textDim, padding: 10, background: C.surface, borderRadius: 8 }}>
              📝 {data.notes}
            </div>
          )}

          {raw && !data && (
            <details style={{ marginTop: 12 }}>
              <summary style={{ fontSize: 11, color: C.textMuted, cursor: "pointer" }}>Raw response</summary>
              <pre style={{ fontSize: 10, color: C.textDim, background: C.surface, padding: 10, borderRadius: 8, overflowX: "auto", whiteSpace: "pre-wrap", marginTop: 6 }}>{raw}</pre>
            </details>
          )}

          {(status === "changed" || hasChanges) && approved == null && (
            <div style={{ display: "flex", gap: 8, marginTop: 14 }}>
              <button onClick={() => onApprove(service.id)} style={btnStyle(C.green)}>✓ Approve</button>
              <button onClick={() => onReject(service.id)} style={btnStyle(C.red)}>✗ Reject</button>
            </div>
          )}
        </div>
      )}
    </div>
  );
}

function DiffSection({ title, items }) {
  return (
    <div style={{ marginTop: 12 }}>
      <div style={{ fontSize: 11, fontWeight: 700, color: C.text, marginBottom: 6 }}>{title}</div>
      {items.map((item, i) => (
        <div key={i} style={{ display: "flex", gap: 8, alignItems: "center", fontSize: 11, padding: "4px 0" }}>
          <span style={{ color: C.textDim, minWidth: 140, fontFamily: "'JetBrains Mono', monospace", fontSize: 10 }}>{item.label}</span>
          <span style={{ color: C.red, background: C.redDim, padding: "2px 6px", borderRadius: 4, fontFamily: "monospace", fontSize: 10 }}>{item.old}</span>
          <span style={{ color: C.textMuted }}>→</span>
          <span style={{ color: C.green, background: C.greenDim, padding: "2px 6px", borderRadius: 4, fontFamily: "monospace", fontSize: 10 }}>{item.new}</span>
        </div>
      ))}
    </div>
  );
}

// ━━━ MAIN APP ━━━
export default function ChompdSweep() {
  const [config, setConfig] = useState({ url: "", key: "" });
  const [connected, setConnected] = useState(false);
  const [services, setServices] = useState([]);
  const [selected, setSelected] = useState([]);
  const [selectedPhases, setSelectedPhases] = useState(PHASES.map(p => p.id));
  const [search, setSearch] = useState("");
  const [running, setRunning] = useState(false);
  const [progress, setProgress] = useState({ current: 0, total: 0, name: "" });
  const [results, setResults] = useState([]);
  const [commitStatus, setCommitStatus] = useState(null);
  const abortRef = useRef(false);

  const handleConnect = async () => {
    try {
      const data = await fetchServices(config.url, config.key);
      const mapped = data.map(s => ({ ...s, tiers: s.service_tiers || [] }));
      setServices(mapped);
      setConnected(true);
    } catch (e) {
      alert("Connection failed: " + e.message);
    }
  };

  const handleRun = async () => {
    setRunning(true);
    setResults([]);
    setCommitStatus(null);
    abortRef.current = false;

    const toSweep = services.filter(s => selected.includes(s.id));
    setProgress({ current: 0, total: toSweep.length, name: "" });

    const newResults = [];
    for (let i = 0; i < toSweep.length; i++) {
      if (abortRef.current) break;
      const svc = toSweep[i];
      setProgress({ current: i + 1, total: toSweep.length, name: svc.name });

      const result = await runSweep(svc, selectedPhases);

      const hasChanges = result.success && result.data && (
        (result.data.pricing?.changes?.length > 0) ||
        result.data.cancel_guides ||
        result.data.refund ||
        (result.data.dark_patterns?.length > 0) ||
        (result.data.alternatives?.length > 0)
      );

      newResults.push({
        service: svc,
        status: result.success ? (hasChanges ? "changed" : "unchanged") : "error",
        data: result.data,
        raw: result.raw,
        error: result.error,
        approved: null,
      });
      setResults([...newResults]);

      // Rate limit: 2s delay between calls
      if (i < toSweep.length - 1) await new Promise(r => setTimeout(r, 2000));
    }

    setRunning(false);
  };

  const handleApprove = (id) => setResults(r => r.map(x => x.service.id === id ? { ...x, approved: true } : x));
  const handleReject = (id) => setResults(r => r.map(x => x.service.id === id ? { ...x, approved: false } : x));

  const handleCommit = async () => {
    setCommitStatus("committing");
    const approved = results.filter(r => r.approved === true && r.data);
    let pricesChanged = 0, guidesUpdated = 0, patternsAdded = 0, errors = 0;

    for (const r of approved) {
      try {
        // Update pricing
        if (r.data.pricing?.changes?.length > 0) {
          for (const change of r.data.pricing.changes) {
            const tier = r.service.tiers?.find(t => t.tier_name === change.tier);
            if (tier) {
              await supabaseUpdate(config.url, config.key, "service_tiers", tier.id, { [change.field]: change.new });
              pricesChanged++;
            }
          }
        }

        // Update cancel difficulty
        if (r.data.cancel_guides?.cancel_difficulty) {
          await supabaseUpdate(config.url, config.key, "services", r.service.id, {
            cancel_difficulty: r.data.cancel_guides.cancel_difficulty,
          });
          guidesUpdated++;
        }

        // Update refund success rate
        if (r.data.refund?.success_rate_pct) {
          await supabaseUpdate(config.url, config.key, "services", r.service.id, {
            refund_success_rate: r.data.refund.success_rate_pct,
          });
        }

        // Insert dark patterns
        if (r.data.dark_patterns?.length > 0) {
          for (const dp of r.data.dark_patterns) {
            await supabaseInsert(config.url, config.key, "dark_pattern_flags", {
              service_id: r.service.id,
              pattern_type: dp.type,
              severity: dp.severity,
              title: dp.title,
              description: dp.description,
              is_active: true,
            });
            patternsAdded++;
          }
        }

        // Insert alternatives
        if (r.data.alternatives?.length > 0) {
          for (const alt of r.data.alternatives) {
            await supabaseInsert(config.url, config.key, "service_alternatives", {
              service_id: r.service.id,
              alt_name: alt.name,
              reason: alt.reason,
              price_comparison: alt.price_comparison,
              relevance_score: 5,
            });
          }
        }
      } catch (e) {
        errors++;
        console.error(`Error committing ${r.service.name}:`, e);
      }
    }

    // Log the sweep
    try {
      await supabaseInsert(config.url, config.key, "service_update_log", {
        update_type: "manual",
        model_used: "claude-sonnet-4-5-20250929",
        services_checked: results.length,
        prices_changed: pricesChanged,
        guides_updated: guidesUpdated,
        patterns_flagged: patternsAdded,
        errors: errors,
        summary_json: { approved: approved.length, rejected: results.filter(r => r.approved === false).length },
      });
    } catch {}

    setCommitStatus({ pricesChanged, guidesUpdated, patternsAdded, errors, total: approved.length });
  };

  const approvedCount = results.filter(r => r.approved === true).length;
  const summaryChanged = results.filter(r => r.status === "changed").length;
  const summaryUnchanged = results.filter(r => r.status === "unchanged").length;
  const summaryErrors = results.filter(r => r.status === "error").length;

  return (
    <div style={{ minHeight: "100vh", background: C.bg, color: C.text, fontFamily: "'DM Sans', 'Segoe UI', sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet" />

      {/* Header */}
      <div style={{ padding: "24px 24px 0", display: "flex", alignItems: "center", gap: 12, marginBottom: 20 }}>
        <div style={{ width: 40, height: 40, borderRadius: 10, background: `linear-gradient(135deg, ${C.accent}, #ff8f65)`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 22 }}>
          🐟
        </div>
        <div>
          <div style={{ fontSize: 20, fontWeight: 700, letterSpacing: "-0.02em" }}>Chompd Service Sweep</div>
          <div style={{ fontSize: 11, color: C.textDim }}>AI-powered subscription database maintenance</div>
        </div>
      </div>

      <div style={{ padding: "0 24px 40px" }}>
        <ConfigPanel config={config} setConfig={setConfig} onConnect={handleConnect} connected={connected} serviceCount={services.length} />

        {connected && (
          <>
            <ServiceSelector services={services} selected={selected} setSelected={setSelected} search={search} setSearch={setSearch} />
            <PhaseSelector selectedPhases={selectedPhases} setSelectedPhases={setSelectedPhases} />

            {/* Run Button */}
            <div style={{ display: "flex", gap: 10, marginBottom: 16, alignItems: "center" }}>
              <button
                onClick={running ? () => { abortRef.current = true; } : handleRun}
                disabled={!running && (selected.length === 0 || selectedPhases.length === 0)}
                style={{
                  ...btnStyle(running ? C.red : C.accent, !running && (selected.length === 0 || selectedPhases.length === 0)),
                  padding: "12px 28px", fontSize: 14, fontWeight: 700,
                }}
              >
                {running ? `⏹ Abort` : `🔍 Run Sweep (${selected.length} services)`}
              </button>
              {running && (
                <div style={{ fontSize: 12, color: C.textDim }}>
                  <span style={{ color: C.accent, fontWeight: 600 }}>{progress.name}</span>
                  {" "}({progress.current}/{progress.total})
                  <div style={{ width: 200, height: 4, background: C.border, borderRadius: 2, marginTop: 4 }}>
                    <div style={{ width: `${(progress.current / progress.total) * 100}%`, height: "100%", background: C.accent, borderRadius: 2, transition: "width 0.3s" }} />
                  </div>
                </div>
              )}
            </div>

            {/* Results */}
            {results.length > 0 && (
              <>
                {/* Summary bar */}
                <div style={{ display: "flex", gap: 8, marginBottom: 12, flexWrap: "wrap" }}>
                  {summaryChanged > 0 && <span style={{ fontSize: 11, padding: "4px 10px", borderRadius: 100, background: C.yellowDim, color: C.yellow, fontWeight: 600 }}>⚠️ {summaryChanged} changed</span>}
                  {summaryUnchanged > 0 && <span style={{ fontSize: 11, padding: "4px 10px", borderRadius: 100, background: C.greenDim, color: C.green, fontWeight: 600 }}>✅ {summaryUnchanged} unchanged</span>}
                  {summaryErrors > 0 && <span style={{ fontSize: 11, padding: "4px 10px", borderRadius: 100, background: C.redDim, color: C.red, fontWeight: 600 }}>❌ {summaryErrors} errors</span>}
                </div>

                <div style={{ display: "flex", flexDirection: "column", gap: 8, marginBottom: 16 }}>
                  {results.map(r => (
                    <ResultCard key={r.service.id} result={r} onApprove={handleApprove} onReject={handleReject} />
                  ))}
                </div>

                {/* Commit */}
                {approvedCount > 0 && !commitStatus && (
                  <button onClick={handleCommit} style={{ ...btnStyle(C.green), padding: "12px 28px", fontSize: 14, fontWeight: 700 }}>
                    ✓ Commit {approvedCount} Approved Change{approvedCount !== 1 ? "s" : ""} to Supabase
                  </button>
                )}
                {commitStatus === "committing" && (
                  <div style={{ fontSize: 13, color: C.accent, fontWeight: 600 }}>Committing to Supabase...</div>
                )}
                {commitStatus && typeof commitStatus === "object" && (
                  <div style={{ background: C.greenDim, border: `1px solid ${C.green}`, borderRadius: 12, padding: 16, fontSize: 12 }}>
                    <div style={{ fontWeight: 700, color: C.green, marginBottom: 6 }}>✅ Committed to Supabase</div>
                    <div style={{ color: C.textDim }}>
                      {commitStatus.total} services updated — {commitStatus.pricesChanged} prices, {commitStatus.guidesUpdated} guides, {commitStatus.patternsAdded} dark patterns
                      {commitStatus.errors > 0 && <span style={{ color: C.red }}> — {commitStatus.errors} errors</span>}
                    </div>
                  </div>
                )}
              </>
            )}
          </>
        )}
      </div>
    </div>
  );
}

// ━━━ SHARED STYLES ━━━
const inputStyle = {
  flex: 1, padding: "8px 12px", borderRadius: 8,
  border: `1px solid ${C.border}`, background: C.surface,
  color: C.text, fontSize: 12, outline: "none",
  fontFamily: "'JetBrains Mono', monospace",
};

const btnStyle = (color, disabled = false) => ({
  padding: "8px 16px", borderRadius: 8, border: "none",
  background: disabled ? `${C.textMuted}30` : `${color}25`,
  color: disabled ? C.textMuted : color,
  cursor: disabled ? "not-allowed" : "pointer",
  fontSize: 12, fontWeight: 600,
  fontFamily: "'DM Sans', sans-serif",
  transition: "all 0.15s",
});

const tagBtn = {
  padding: "4px 10px", borderRadius: 100, border: "none",
  fontSize: 10, fontWeight: 600, cursor: "pointer",
  fontFamily: "'DM Sans', sans-serif",
};

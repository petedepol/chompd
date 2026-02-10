import { useState, useEffect, useRef } from "react";

const C = {
  bg: "#0a0a0f", surface: "#14141f", surface2: "#1c1c2e", border: "#2a2a3e",
  text: "#e8e8f0", dim: "#8888a8", accent: "#6ee7b7", accent2: "#34d399",
  warn: "#fbbf24", bad: "#f87171", purple: "#a78bfa", blue: "#60a5fa",
};

/* ─── Scenario Data ─── */
const SCENARIOS = [
  {
    id: "easy", label: "Clear Email", desc: "Netflix renewal — auto-detected", tier: "no-question",
    screenshot: "📧 Netflix — Your membership renews on March 14, 2026. You'll be charged £15.99/month to your Visa ending 4521.",
    aiResult: { name: "Netflix", price: "£15.99", cycle: "Monthly", nextRenewal: "14 March 2026", trial: false, confidence: 0.98, icon: "N", color: "#E50914" },
    questions: [], scanCost: "$0.00",
  },
  {
    id: "learned", label: "Learned Match", desc: "AMZN charge — DB suggests Kindle", tier: "quick-confirm",
    screenshot: "💳 Bank Statement\n━━━━━━━━━━━━━━━━━━━━\n02 Feb  AMZN DIGITAL*RT3K9  £7.99\n02 Jan  AMZN DIGITAL*RT3K9  £7.99\n02 Dec  AMZN DIGITAL*RT3K9  £7.99",
    aiResult: { name: "Kindle Unlimited", price: "£7.99", cycle: "Monthly", nextRenewal: "2 March 2026", trial: false, confidence: 0.82, icon: "K", color: "#FF9900" },
    questions: [{
      type: "confirm",
      text: "78% of users with this charge say it's Kindle Unlimited. Sound right?",
      confirmLabel: "Yes, it's Kindle Unlimited", confirmValue: "Kindle Unlimited",
      options: ["Amazon Prime", "Audible", "Amazon Music", "Other"],
      field: "name",
    }], scanCost: "$0.0015",
  },
  {
    id: "ambiguous", label: "Ambiguous Charge", desc: "MSFT charge — no DB match", tier: "full-question",
    screenshot: "💳 Bank Statement\n━━━━━━━━━━━━━━━━━━━━\n05 Feb  MSFT*STORE      £10.99\n05 Jan  MSFT*STORE      £10.99\n05 Dec  MSFT*STORE      £10.99",
    aiResult: { name: "Microsoft Service", price: "£10.99", cycle: "Monthly", nextRenewal: "5 March 2026", trial: false, confidence: 0.55, icon: "M", color: "#00A4EF" },
    questions: [{
      type: "choose",
      text: "Found a Microsoft charge for £10.99/month. Which service is this?",
      options: ["Xbox Game Pass Ultimate", "Microsoft 365 Family", "Microsoft 365 Personal", "Xbox Game Pass Core", "Other"],
      field: "name",
    }], scanCost: "$0.0022",
  },
  {
    id: "trial", label: "Trial + Currency", desc: "Figma trial — 2 questions", tier: "full-question",
    screenshot: "📧 Welcome to your free trial!\n\nHi Pete, thanks for signing up!\nPlan: Pro · Price: $9.99/mo after trial\nTrial: 14 days free · Starts: 8 Feb 2026\nCard: Visa •••• 4521\n\n— The Figma Team",
    aiResult: { name: "Figma Pro", price: "$9.99", cycle: "Monthly", nextRenewal: "22 Feb 2026", trial: true, trialDays: 14, confidence: 0.88, icon: "F", color: "#A259FF" },
    questions: [
      { type: "choose", text: "Personal subscription or team/business plan?", options: ["Personal", "Team/Business", "Not sure"], field: "plan_type" },
      { type: "choose", text: "The price is in USD ($9.99). How should we track it?", options: ["Convert to £ (GBP)", "Keep in $ (USD)"], field: "currency" },
    ], scanCost: "$0.0029",
  },
  {
    id: "multi", label: "Multi-Sub Statement", desc: "4 charges — mixed confidence", tier: "mixed",
    screenshot: "💳 Monthly Statement — Feb 2026\n━━━━━━━━━━━━━━━━━━━━\n01 Feb  SPOTIFY.COM      £10.99\n03 Feb  GOOGLE*SVCS      £1.99\n05 Feb  CRU*ZWIFT        £17.99\n08 Feb  PP*HEADSPACE     £9.99",
    aiResult: { name: "4 subscriptions", price: "£40.96/mo total", cycle: "Monthly", nextRenewal: "Various", trial: false, confidence: 0.7, icon: "4", color: C.blue },
    multiResults: [
      { name: "Spotify", price: "£10.99", cycle: "Monthly", icon: "S", color: "#1DB954", auto: true },
      { name: "Zwift", price: "£17.99", cycle: "Monthly", icon: "Z", color: "#FC6719", auto: true },
      { name: "Google One", price: "£1.99", cycle: "Monthly", icon: "G", color: "#4285F4", auto: false },
      { name: "Headspace", price: "£9.99", cycle: "Monthly", icon: "H", color: "#F47D31", auto: false },
    ],
    questions: [
      { type: "info", text: "Found 4 recurring charges totalling £40.96/month." },
      { type: "info", text: "Spotify (£10.99) and Zwift (£17.99) auto-detected ✓" },
      { type: "choose", text: "GOOGLE*SVCS for £1.99 — which Google service?", options: ["Google One (Storage)", "YouTube Premium", "Google Workspace", "Other"], field: "name_google" },
      { type: "confirm", text: "PP*HEADSPACE for £9.99 — is this Headspace?", confirmLabel: "Yes, Headspace", confirmValue: "Headspace", options: ["No, something else"], field: "name_headspace" },
    ], scanCost: "$0.0036",
  },
];

/* ─── Animations ─── */
const STYLES = `
  @keyframes fadeUp { from { opacity:0; transform:translateY(8px); } to { opacity:1; transform:translateY(0); } }
  @keyframes toastIn { from { opacity:0; transform:translateY(20px) scale(0.95); } to { opacity:1; transform:translateY(0) scale(1); } }
  @keyframes toastOut { from { opacity:1; transform:translateY(0); } to { opacity:0; transform:translateY(-12px) scale(0.95); } }
  @keyframes shimmer { 0% { transform: translateX(-100%); } 100% { transform: translateX(200%); } }
  @keyframes pulse { 0%,100% { box-shadow: 0 0 0 0 rgba(110,231,183,0.4); } 50% { box-shadow: 0 0 0 8px rgba(110,231,183,0); } }
  @keyframes checkDraw { from { stroke-dashoffset: 20; } to { stroke-dashoffset: 0; } }
  @keyframes slideDown { from { opacity:0; max-height:0; } to { opacity:1; max-height:200px; } }
`;

/* ─── Typing Indicator ─── */
function TypingDots() {
  const [d, setD] = useState(0);
  useEffect(() => { const i = setInterval(() => setD(p => (p + 1) % 3), 350); return () => clearInterval(i); }, []);
  return (
    <span style={{ display: "inline-flex", gap: 4 }}>
      {[0, 1, 2].map(i => (
        <span key={i} style={{
          width: 6, height: 6, borderRadius: "50%", display: "inline-block",
          background: C.accent, opacity: d === i ? 1 : 0.3,
          transition: "opacity 0.2s",
        }} />
      ))}
    </span>
  );
}

/* ─── Toast ─── */
function Toast({ visible, data, onDone }) {
  const [show, setShow] = useState(false);
  const [exit, setExit] = useState(false);

  useEffect(() => {
    if (visible && data) {
      setShow(true); setExit(false);
      const t1 = setTimeout(() => setExit(true), 2800);
      const t2 = setTimeout(() => { setShow(false); onDone(); }, 3300);
      return () => { clearTimeout(t1); clearTimeout(t2); };
    }
  }, [visible, data]);

  if (!show || !data) return null;

  const isTrial = data.trial || data.trialDays;
  const isMulti = data.count > 1;

  return (
    <div style={{
      position: "fixed", bottom: 32, left: "50%", transform: "translateX(-50%)",
      zIndex: 100, animation: exit ? "toastOut 0.4s ease forwards" : "toastIn 0.4s cubic-bezier(0.34,1.56,0.64,1)",
    }}>
      <div style={{
        display: "flex", alignItems: "center", gap: 12,
        background: isTrial ? "linear-gradient(135deg, #2e2a1a, #24201c)" : "linear-gradient(135deg, #1a2e24, #14241c)",
        border: `1px solid ${isTrial ? C.warn + "55" : C.accent + "55"}`,
        borderRadius: 16, padding: "14px 22px",
        boxShadow: `0 8px 32px rgba(0,0,0,0.5), 0 0 24px ${isTrial ? C.warn : C.accent}12`,
      }}>
        <div style={{
          width: 36, height: 36, borderRadius: 10,
          background: data.color || C.accent2,
          display: "flex", alignItems: "center", justifyContent: "center",
          fontSize: 14, fontWeight: 700, color: "white",
        }}>
          {isMulti ? `${data.count}` : (data.icon || "✓")}
        </div>
        <div>
          <div style={{ fontSize: 14, fontWeight: 600 }}>
            {isMulti ? `${data.count} subscriptions added` : `${data.name} added`}
          </div>
          <div style={{ fontSize: 11.5, color: C.dim }}>
            {isMulti ? data.price : `${data.price}/${(data.cycle || "month").toLowerCase()}`}
          </div>
          {isTrial && (
            <div style={{ fontSize: 10, color: C.warn, fontWeight: 600, marginTop: 2 }}>
              ⚠️ Trial — {data.trialDays || "?"} days remaining
            </div>
          )}
        </div>
        <div style={{
          width: 28, height: 28, borderRadius: "50%",
          background: `${isTrial ? C.warn : C.accent}22`,
          display: "flex", alignItems: "center", justifyContent: "center", marginLeft: 4,
        }}>
          <svg width="14" height="14" viewBox="0 0 16 16" fill="none">
            <path d="M3 8.5L6.5 12L13 4" stroke={isTrial ? C.warn : C.accent} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"
              strokeDasharray="20" strokeDashoffset="20" style={{ animation: "checkDraw 0.4s ease 0.1s forwards" }} />
          </svg>
        </div>
      </div>
    </div>
  );
}

/* ─── Scan Shimmer ─── */
function ScanShimmer({ active }) {
  if (!active) return null;
  return (
    <div style={{
      position: "absolute", inset: 0, overflow: "hidden", borderRadius: 12, pointerEvents: "none",
    }}>
      <div style={{
        position: "absolute", top: 0, bottom: 0, width: "40%",
        background: `linear-gradient(90deg, transparent, ${C.accent}15, ${C.accent}25, ${C.accent}15, transparent)`,
        animation: "shimmer 1.8s ease-in-out infinite",
      }} />
    </div>
  );
}

/* ─── Message Bubble ─── */
function Bubble({ children, emoji, accent, borderColor, align }) {
  if (align === "right") {
    return (
      <div style={{ display: "flex", justifyContent: "flex-end", animation: "fadeUp 0.3s ease" }}>
        <div style={{
          background: `${C.accent}15`, border: `1px solid ${C.accent}35`,
          borderRadius: "12px 4px 12px 12px", padding: "7px 14px",
          fontSize: 12.5, color: C.accent, fontWeight: 500, maxWidth: "80%",
        }}>{children}</div>
      </div>
    );
  }
  return (
    <div style={{ display: "flex", alignItems: "flex-start", gap: 8, animation: "fadeUp 0.3s ease" }}>
      <div style={{
        width: 28, height: 28, borderRadius: 8, flexShrink: 0,
        background: accent || C.surface2,
        display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12,
      }}>{emoji || "🤖"}</div>
      <div style={{
        background: C.surface2, borderRadius: "4px 12px 12px 12px",
        padding: borderColor ? 12 : "8px 12px", fontSize: 12.5,
        color: borderColor ? C.text : C.dim, maxWidth: "85%",
        borderLeft: borderColor ? `3px solid ${borderColor}` : "none",
      }}>{children}</div>
    </div>
  );
}

/* ─── Multi-Sub Result Card ─── */
function MultiResultCard({ items }) {
  return (
    <Bubble emoji="✅" accent={`linear-gradient(135deg, ${C.accent2}, ${C.accent})`} borderColor={C.accent}>
      <div style={{ fontFamily: "monospace", fontSize: 9, textTransform: "uppercase", letterSpacing: "0.1em", color: C.accent, marginBottom: 10 }}>
        ✓ {items.length} subscriptions confirmed
      </div>
      <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
        {items.map((item, i) => (
          <div key={i} style={{
            display: "flex", alignItems: "center", gap: 10, padding: "8px 10px",
            background: `${C.bg}80`, borderRadius: 8,
          }}>
            <div style={{
              width: 28, height: 28, borderRadius: 7, flexShrink: 0,
              background: item.color || C.accent2,
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 11, fontWeight: 700, color: "white",
            }}>{item.icon}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 12, fontWeight: 600 }}>{item.name}</div>
              <div style={{ fontSize: 10.5, color: C.dim }}>{item.price}/month</div>
            </div>
            {item.auto && (
              <span style={{ fontSize: 8, fontFamily: "monospace", padding: "2px 6px", borderRadius: 100, background: `${C.accent}22`, color: C.accent }}>AUTO</span>
            )}
          </div>
        ))}
      </div>
      <div style={{ fontSize: 11, color: C.dim, marginTop: 8, textAlign: "right" }}>
        Total: <strong style={{ color: C.text }}>£{items.reduce((s, i) => s + parseFloat(i.price.replace(/[^0-9.]/g, "")), 0).toFixed(2)}</strong>/month
      </div>
    </Bubble>
  );
}

/* ─── Question Options (handles "Other" text input) ─── */
function QuestionOptions({ question, onAnswer }) {
  const [showOther, setShowOther] = useState(false);
  const [otherText, setOtherText] = useState("");
  const inputRef = useRef(null);

  useEffect(() => { if (showOther && inputRef.current) inputRef.current.focus(); }, [showOther]);

  const handleOptionClick = (opt) => {
    if (opt === "Other" || opt === "No, something else") {
      setShowOther(true);
    } else {
      onAnswer(opt);
    }
  };

  const handleOtherSubmit = () => {
    const val = otherText.trim();
    if (val) onAnswer(val);
  };

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 5, marginLeft: 36, animation: "fadeUp 0.25s ease" }}>
      {question.type === "confirm" && question.confirmLabel && (
        <button onClick={() => onAnswer(question.confirmLabel)} style={{
          padding: "10px 16px", borderRadius: 10, border: `1px solid ${C.accent}66`,
          background: `${C.accent}15`, color: C.accent, fontSize: 12,
          cursor: "pointer", fontFamily: "inherit", fontWeight: 600,
          textAlign: "left", display: "flex", alignItems: "center", gap: 8, transition: "all 0.2s",
        }}
          onMouseEnter={e => { e.currentTarget.style.background = C.accent; e.currentTarget.style.color = C.bg; }}
          onMouseLeave={e => { e.currentTarget.style.background = `${C.accent}15`; e.currentTarget.style.color = C.accent; }}
        >
          <span style={{ fontSize: 16 }}>👍</span> {question.confirmLabel}
        </button>
      )}
      {!showOther && (
        <div style={{ display: "flex", flexWrap: "wrap", gap: 5 }}>
          {question.options.map(opt => (
            <button key={opt} onClick={() => handleOptionClick(opt)} style={{
              padding: "7px 14px", borderRadius: 100, border: `1px solid ${C.border}`,
              background: C.surface, color: C.dim, fontSize: 11.5,
              cursor: "pointer", fontFamily: "inherit", transition: "all 0.2s",
            }}
              onMouseEnter={e => { e.currentTarget.style.borderColor = C.accent; e.currentTarget.style.color = C.accent; }}
              onMouseLeave={e => { e.currentTarget.style.borderColor = C.border; e.currentTarget.style.color = C.dim; }}
            >{opt}</button>
          ))}
        </div>
      )}
      {showOther && (
        <div style={{ display: "flex", gap: 6, animation: "fadeUp 0.25s ease" }}>
          <input
            ref={inputRef}
            type="text"
            value={otherText}
            onChange={e => setOtherText(e.target.value)}
            onKeyDown={e => { if (e.key === "Enter") handleOtherSubmit(); }}
            placeholder="Type the service name..."
            style={{
              flex: 1, padding: "9px 14px", borderRadius: 10,
              border: `1px solid ${C.accent}55`, background: C.bg,
              color: C.text, fontSize: 12, fontFamily: "inherit",
              outline: "none",
            }}
          />
          <button onClick={handleOtherSubmit} disabled={!otherText.trim()} style={{
            padding: "9px 16px", borderRadius: 10, border: "none",
            background: otherText.trim() ? C.accent : C.surface2,
            color: otherText.trim() ? C.bg : C.dim,
            fontSize: 12, fontWeight: 600, cursor: otherText.trim() ? "pointer" : "default",
            fontFamily: "inherit", transition: "all 0.2s",
          }}>Done</button>
        </div>
      )}
    </div>
  );
}

/* ─── Main Scan Flow ─── */
function ScanFlow({ scenario, onComplete }) {
  const [phase, setPhase] = useState("scanning");
  const [qIdx, setQIdx] = useState(0);
  const [msgs, setMsgs] = useState([]);
  const [done, setDone] = useState(false);
  const [added, setAdded] = useState(false);
  const [finalResult, setFinalResult] = useState(null);
  const endRef = useRef(null);

  useEffect(() => { endRef.current?.scrollIntoView({ behavior: "smooth" }); }, [msgs]);

  // Reset on scenario change
  useEffect(() => {
    setPhase("scanning"); setQIdx(0); setMsgs([]); setDone(false); setAdded(false); setFinalResult(null);

    const timers = [];
    timers.push(setTimeout(() => setMsgs([{ id: "s1", type: "system", text: "Screenshot received. Analyzing..." }]), 300));
    timers.push(setTimeout(() => setMsgs(m => [...m, { id: "s2", type: "system", text: "Extracting text and identifying subscriptions..." }]), 1100));
    timers.push(setTimeout(() => {
      const r = scenario.aiResult;
      // High confidence + no questions = instant result
      if (r.confidence >= 0.9 && scenario.questions.length === 0) {
        setMsgs(m => [...m, { id: "r1", type: "result", data: r }]);
        setFinalResult(r); setPhase("done"); setDone(true);
      } else {
        setMsgs(m => [...m, { id: "p1", type: "partial", data: r }]);
        // Queue first question (or first info message)
        timers.push(setTimeout(() => {
          const first = scenario.questions[0];
          if (!first) { setFinalResult(r); setPhase("done"); setDone(true); return; }
          if (first.type === "info") {
            setMsgs(m => [...m, { id: "info0", type: "info", text: first.text }]);
            advanceFromInfo(0, timers);
          } else {
            setMsgs(m => [...m, { id: "q0", type: "question", data: first, active: true }]);
          }
          setPhase("asking");
        }, 600));
      }
    }, 2200));

    return () => timers.forEach(clearTimeout);
  }, [scenario]);

  // Advance past consecutive info messages
  const advanceFromInfo = (idx, timers) => {
    const next = idx + 1;
    if (next >= scenario.questions.length) return;
    const nextQ = scenario.questions[next];
    const t = setTimeout(() => {
      if (nextQ.type === "info") {
        setMsgs(m => [...m, { id: `info${next}`, type: "info", text: nextQ.text }]);
        setQIdx(next);
        advanceFromInfo(next, timers);
      } else {
        setMsgs(m => [...m, { id: `q${next}`, type: "question", data: nextQ, active: true }]);
        setQIdx(next);
      }
    }, 500);
    timers.push(t);
  };

  const handleAnswer = (answer, question) => {
    // Deactivate current question
    setMsgs(m => m.map(msg => msg.type === "question" && msg.active ? { ...msg, active: false } : msg));
    // User answer bubble
    setMsgs(m => [...m, { id: `a${qIdx}`, type: "answer", text: answer }]);

    const next = qIdx + 1;
    if (next < scenario.questions.length) {
      setTimeout(() => {
        const nextQ = scenario.questions[next];
        if (nextQ.type === "info") {
          setMsgs(m => [...m, { id: `info${next}`, type: "info", text: nextQ.text }]);
          setQIdx(next);
          advanceFromInfo(next, []);
        } else {
          setMsgs(m => [...m, { id: `q${next}`, type: "question", data: nextQ, active: true }]);
          setQIdx(next);
        }
      }, 400);
    } else {
      // All questions answered — show final result
      setTimeout(() => {
        // Build final result with user's answers
        const fr = { ...scenario.aiResult, confidence: 0.99 };
        if (question?.field === "name" || question?.field?.startsWith("name_")) {
          const isConfirm = question.type === "confirm" && answer === question.confirmLabel;
          fr.name = isConfirm ? question.confirmValue : answer;
        }

        if (scenario.multiResults) {
          // Multi-sub: show individual cards
          const updated = scenario.multiResults.map(r => ({ ...r }));
          setMsgs(m => [...m,
            { id: "conf", type: "system", text: "All confirmed!" },
            { id: "mr", type: "multiResult", data: updated },
          ]);
          setFinalResult({ ...fr, count: updated.length, multiResults: updated });
        } else {
          setMsgs(m => [...m,
            { id: "conf", type: "system", text: "Perfect, confirmed!" },
            { id: "fr", type: "result", data: fr },
          ]);
          setFinalResult(fr);
        }
        setPhase("done"); setDone(true);
      }, 500);
    }
  };

  const handleAdd = () => {
    if (added) return;
    setAdded(true);
    onComplete(finalResult);
  };

  const isScanning = phase === "scanning";

  return (
    <div style={{ display: "flex", flexDirection: "column", height: "100%", maxHeight: 600 }}>
      {/* Screenshot preview with scan shimmer */}
      <div style={{
        background: C.surface2, border: `1px solid ${isScanning ? C.accent + "44" : C.border}`,
        borderRadius: 12, padding: 14, marginBottom: 12,
        fontFamily: "monospace", fontSize: 11, color: C.dim,
        whiteSpace: "pre-wrap", lineHeight: 1.6,
        maxHeight: 85, overflow: "hidden", position: "relative",
        transition: "border-color 0.5s",
      }}>
        {scenario.screenshot}
        <div style={{ position: "absolute", bottom: 0, left: 0, right: 0, height: 28, background: `linear-gradient(transparent, ${C.surface2})` }} />
        <ScanShimmer active={isScanning} />
      </div>

      {/* Tier + cost badges */}
      <div style={{ display: "flex", gap: 6, marginBottom: 10, flexWrap: "wrap" }}>
        <span style={{
          fontSize: 9, fontFamily: "monospace", textTransform: "uppercase", letterSpacing: "0.08em",
          padding: "3px 8px", borderRadius: 100,
          background: scenario.tier === "no-question" ? `${C.accent}22` : scenario.tier === "quick-confirm" ? `${C.blue}22` : `${C.purple}22`,
          color: scenario.tier === "no-question" ? C.accent : scenario.tier === "quick-confirm" ? C.blue : C.purple,
        }}>
          {scenario.tier === "no-question" ? "⚡ Auto-detect" : scenario.tier === "quick-confirm" ? "👍 Quick Confirm" : scenario.tier === "mixed" ? "🔀 Mixed" : "💬 Full Questions"}
        </span>
        <span style={{ fontSize: 9, fontFamily: "monospace", padding: "3px 8px", borderRadius: 100, background: `${C.dim}18`, color: C.dim }}>
          {scenario.questions.filter(q => q.type !== "info").length === 0 ? "0 questions" : `${scenario.questions.filter(q => q.type !== "info").length} question${scenario.questions.filter(q => q.type !== "info").length !== 1 ? "s" : ""}`}
        </span>
        <span style={{ fontSize: 9, fontFamily: "monospace", padding: "3px 8px", borderRadius: 100, background: `${C.accent}12`, color: C.accent }}>
          cost: {scenario.scanCost}
        </span>
      </div>

      {/* Messages */}
      <div style={{ flex: 1, overflowY: "auto", display: "flex", flexDirection: "column", gap: 8, minHeight: 0, paddingRight: 4 }}>
        {msgs.map(msg => {
          if (msg.type === "system") return <Bubble key={msg.id} emoji="🤖" accent={`linear-gradient(135deg, ${C.accent2}, ${C.accent})`}>{msg.text}</Bubble>;
          if (msg.type === "info") return <Bubble key={msg.id} emoji="ℹ️" accent={`${C.blue}44`} borderColor={C.blue}>{msg.text}</Bubble>;
          if (msg.type === "answer") return <Bubble key={msg.id} align="right">{msg.text}</Bubble>;

          if (msg.type === "partial") {
            return (
              <Bubble key={msg.id} emoji="🔍" accent={`${C.warn}33`} borderColor={C.warn}>
                <div style={{ fontFamily: "monospace", fontSize: 9, textTransform: "uppercase", letterSpacing: "0.1em", color: C.warn, marginBottom: 8 }}>
                  Partial match — {Math.round(msg.data.confidence * 100)}% confident
                </div>
                {msg.data.name && <div style={{ fontSize: 12 }}><span style={{ color: C.dim }}>Service: </span><strong>{msg.data.name}</strong></div>}
                {msg.data.price && <div style={{ fontSize: 12 }}><span style={{ color: C.dim }}>Price: </span><strong>{msg.data.price}</strong></div>}
                {msg.data.trial && <div style={{ fontSize: 11, color: C.warn, marginTop: 4, fontWeight: 600 }}>⚠️ Free trial — {msg.data.trialDays || "?"} days</div>}
                <div style={{ fontSize: 10.5, color: C.dim, marginTop: 6, opacity: 0.8 }}>Need a few details to confirm...</div>
              </Bubble>
            );
          }

          if (msg.type === "question") {
            const q = msg.data;
            if (q.type === "info") return <Bubble key={msg.id} emoji="ℹ️" accent={`${C.blue}44`} borderColor={C.blue}>{q.text}</Bubble>;
            return (
              <div key={msg.id} style={{ display: "flex", flexDirection: "column", gap: 6, animation: "fadeUp 0.3s ease" }}>
                <Bubble emoji="💬" accent={`${C.purple}44`}>{q.text}</Bubble>
                {msg.active && q.options && (
                  <QuestionOptions question={q} onAnswer={(answer) => handleAnswer(answer, q)} />
                )}
              </div>
            );
          }

          if (msg.type === "result") {
            const d = msg.data;
            return (
              <Bubble key={msg.id} emoji="✅" accent={`linear-gradient(135deg, ${C.accent2}, ${C.accent})`} borderColor={C.accent}>
                <div style={{ fontFamily: "monospace", fontSize: 9, textTransform: "uppercase", letterSpacing: "0.1em", color: C.accent, marginBottom: 8 }}>✓ Confirmed — Ready to add</div>
                <div style={{ fontSize: 16, fontWeight: 700, marginBottom: 6 }}>{d.name}</div>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "3px 16px", fontSize: 12 }}>
                  <div><span style={{ color: C.dim }}>Price: </span>{d.price}</div>
                  {d.cycle && <div><span style={{ color: C.dim }}>Billing: </span>{d.cycle}</div>}
                  {d.nextRenewal && <div><span style={{ color: C.dim }}>Renews: </span>{d.nextRenewal}</div>}
                  {d.trial && <div style={{ color: C.warn, fontWeight: 600 }}>⚠️ Trial — {d.trialDays || "?"} days</div>}
                </div>
              </Bubble>
            );
          }

          if (msg.type === "multiResult") return <MultiResultCard key={msg.id} items={msg.data} />;
          return null;
        })}

        {isScanning && <Bubble emoji="🤖" accent={`linear-gradient(135deg, ${C.accent2}, ${C.accent})`}><TypingDots /></Bubble>}
        <div ref={endRef} />
      </div>

      {/* Add button */}
      {done && (
        <button onClick={handleAdd} disabled={added} style={{
          marginTop: 12, padding: "13px 0", borderRadius: 12, border: "none",
          background: added ? C.surface2 : `linear-gradient(135deg, ${C.accent2}, ${C.accent})`,
          color: added ? C.accent : C.bg, fontSize: 13.5, fontWeight: 700,
          cursor: added ? "default" : "pointer", fontFamily: "inherit",
          animation: added ? "none" : "fadeUp 0.4s ease, pulse 2s ease-in-out 0.5s infinite",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          transition: "all 0.3s",
        }}>
          {added ? (
            <>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8.5L6.5 12L13 4" stroke={C.accent} strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" /></svg>
              Added to SubSnap
            </>
          ) : (
            <>
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M8 3v10M3 8h10" stroke={C.bg} strokeWidth="2.5" strokeLinecap="round" /></svg>
              Add to SubSnap
            </>
          )}
        </button>
      )}
    </div>
  );
}

/* ─── Recognition DB View ─── */
function DbView({ db }) {
  const entries = Object.entries(db);
  const tiers = [
    { label: "Tier 1 — Auto-detect", desc: "Unambiguous. One possible match. Zero questions, zero AI cost.", color: C.accent, icon: "⚡", entries: entries.filter(([, v]) => v.tier === 1) },
    { label: "Tier 2 — Quick Confirm", desc: "Learned from users. Pre-selected suggestion, single tap to confirm.", color: C.blue, icon: "👍", entries: entries.filter(([, v]) => v.tier === 2) },
    { label: "Tier 3 — Full Question", desc: "New or ambiguous. Multiple choice question required.", color: C.purple, icon: "💬", entries: entries.filter(([, v]) => v.tier === 3) },
  ];

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 20 }}>
      <div style={{ display: "flex", gap: 10, justifyContent: "center", flexWrap: "wrap" }}>
        {tiers.map(t => (
          <div key={t.label} style={{
            padding: "10px 16px", borderRadius: 10, background: C.bg,
            border: `1px solid ${t.color}33`, textAlign: "center", flex: "1 1 140px", maxWidth: 180,
          }}>
            <div style={{ fontSize: 20, marginBottom: 4 }}>{t.icon}</div>
            <div style={{ fontSize: 22, fontWeight: 700, color: t.color }}>{t.entries.length}</div>
            <div style={{ fontSize: 9, fontFamily: "monospace", color: C.dim, textTransform: "uppercase" }}>
              {t.label.split("—")[1]?.trim()}
            </div>
          </div>
        ))}
      </div>

      {tiers.map(tier => (
        <div key={tier.label}>
          <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 8 }}>
            <div style={{ width: 8, height: 8, borderRadius: "50%", background: tier.color }} />
            <span style={{ fontFamily: "monospace", fontSize: 10, textTransform: "uppercase", letterSpacing: "0.1em", color: tier.color }}>{tier.label}</span>
          </div>
          {tier.entries.map(([key, val]) => (
            <div key={key} style={{
              display: "flex", alignItems: "center", justifyContent: "space-between",
              background: C.surface2, borderRadius: 8, padding: "8px 12px", marginBottom: 4,
              fontSize: 11.5, borderLeft: `3px solid ${tier.color}33`,
            }}>
              <div style={{ display: "flex", alignItems: "center", gap: 8, minWidth: 0 }}>
                <code style={{ fontSize: 10, color: C.dim, background: C.bg, padding: "2px 6px", borderRadius: 4, whiteSpace: "nowrap", overflow: "hidden", textOverflow: "ellipsis", maxWidth: 150 }}>
                  {key}
                </code>
                <span style={{ fontWeight: 600 }}>{val.name}</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 6, flexShrink: 0 }}>
                {val.users && <span style={{ fontSize: 9.5, color: C.dim }}>{val.users.toLocaleString()}</span>}
                <span style={{ fontSize: 10, color: tier.color }}>{Math.round(val.confidence * 100)}%</span>
              </div>
            </div>
          ))}
        </div>
      ))}

      <div style={{ padding: 14, background: C.bg, borderRadius: 10, fontSize: 11.5, color: C.dim, lineHeight: 1.7 }}>
        <strong style={{ color: C.accent }}>Flywheel effect:</strong> At launch, most charges hit Tier 3. After 1K users, common charges migrate to Tier 2. After 10K users, 80% of merchants are Tier 1 — zero questions, zero AI cost. <strong style={{ color: C.text }}>The app gets cheaper the more people use it.</strong>
      </div>
    </div>
  );
}

/* ─── Tier Explainer ─── */
function TierView() {
  const tiers = [
    { label: "Tier 1 — Auto-detect", color: C.accent, icon: "⚡", when: "Merchant is unambiguous (NETFLIX.COM, SPOTIFY.COM)", ux: "No question. Data auto-fills instantly.", cost: "$0.00 — local DB, no AI call", example: "Netflix £15.99/month → Added ✓", pct: "~60% at 10K users" },
    { label: "Tier 2 — Quick Confirm", color: C.blue, icon: "👍", when: "Learned from users, but could have multiple meanings", ux: "Big confirm button + smaller alternatives", cost: "$0.0015 — one AI call, pre-suggested answer", example: "\"78% say this is Kindle Unlimited. Right?\" → [Yes]", pct: "~25% at 10K users" },
    { label: "Tier 3 — Full Question", color: C.purple, icon: "💬", when: "New or unseen merchant, very low confidence", ux: "Multiple choice question from AI-generated options", cost: "$0.0022 — AI call + follow-up", example: "\"MSFT*STORE £10.99 — which service?\" → [Xbox Game Pass]", pct: "~15% at 10K users" },
  ];

  const evolution = [
    { label: "Launch", users: "0", avg: "$0.0022", t1: 10, t2: 20, t3: 70 },
    { label: "1K Users", users: "1,000", avg: "$0.0018", t1: 30, t2: 30, t3: 40 },
    { label: "10K Users", users: "10,000", avg: "$0.0011", t1: 60, t2: 25, t3: 15 },
    { label: "100K Users", users: "100,000", avg: "$0.0006", t1: 80, t2: 15, t3: 5 },
  ];

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: 16 }}>
      {tiers.map(t => (
        <div key={t.label} style={{
          background: C.surface, border: `1px solid ${C.border}`, borderRadius: 14,
          padding: 20, borderLeft: `4px solid ${t.color}`,
        }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 12 }}>
            <span style={{ fontSize: 22 }}>{t.icon}</span>
            <span style={{ fontFamily: "monospace", fontSize: 12, textTransform: "uppercase", letterSpacing: "0.08em", color: t.color, fontWeight: 700 }}>{t.label}</span>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "80px 1fr", gap: "6px 14px", fontSize: 12.5 }}>
            <span style={{ color: C.dim }}>When</span><span>{t.when}</span>
            <span style={{ color: C.dim }}>UX</span><span>{t.ux}</span>
            <span style={{ color: C.dim }}>Cost</span><span>{t.cost}</span>
            <span style={{ color: C.dim }}>Example</span><span style={{ fontStyle: "italic", color: C.dim }}>{t.example}</span>
            <span style={{ color: C.dim }}>Volume</span><span style={{ color: t.color, fontWeight: 600 }}>{t.pct}</span>
          </div>
        </div>
      ))}

      <div style={{ background: C.surface, border: `1px solid ${C.border}`, borderRadius: 14, padding: 20 }}>
        <div style={{ fontFamily: "monospace", fontSize: 10, textTransform: "uppercase", letterSpacing: "0.1em", color: C.accent, marginBottom: 14 }}>
          Cost Evolution — Intelligence Flywheel
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))", gap: 10 }}>
          {evolution.map(s => (
            <div key={s.label} style={{ background: C.surface2, borderRadius: 10, padding: 14, textAlign: "center" }}>
              <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 2 }}>{s.label}</div>
              <div style={{ fontSize: 10, color: C.dim, marginBottom: 8 }}>{s.users} users</div>
              <div style={{ fontSize: 20, fontWeight: 700, color: C.accent, marginBottom: 2 }}>{s.avg}</div>
              <div style={{ fontSize: 9, color: C.dim, marginBottom: 10 }}>per scan avg</div>
              <div style={{ display: "flex", height: 8, borderRadius: 4, overflow: "hidden", gap: 1 }}>
                <div style={{ width: `${s.t1}%`, background: C.accent, borderRadius: 4, transition: "width 0.5s" }} />
                <div style={{ width: `${s.t2}%`, background: C.blue, borderRadius: 4, transition: "width 0.5s" }} />
                <div style={{ width: `${s.t3}%`, background: C.purple, borderRadius: 4, transition: "width 0.5s" }} />
              </div>
              <div style={{ display: "flex", justifyContent: "space-between", fontSize: 8, color: C.dim, marginTop: 4 }}>
                <span style={{ color: C.accent }}>T1:{s.t1}%</span>
                <span style={{ color: C.blue }}>T2:{s.t2}%</span>
                <span style={{ color: C.purple }}>T3:{s.t3}%</span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

/* ─── App ─── */
export default function App() {
  const [selected, setSelected] = useState(0);
  const [view, setView] = useState("scan");
  const [toastData, setToastData] = useState(null);
  const [toastVisible, setToastVisible] = useState(false);
  const [addedCount, setAddedCount] = useState(0);
  const [freeScans] = useState(3);
  const [usedScans, setUsedScans] = useState(0);

  const db = {
    "NETFLIX.COM": { name: "Netflix", confidence: 0.99, tier: 1, users: 8420 },
    "SPOTIFY.COM": { name: "Spotify", confidence: 0.99, tier: 1, users: 7891 },
    "APPLE.COM/BILL": { name: "iCloud+", confidence: 0.95, tier: 1, users: 6102 },
    "CRU*ZWIFT": { name: "Zwift", confidence: 0.97, tier: 1, users: 1205 },
    "AMZN DIGITAL*7.99": { name: "Kindle Unlimited", confidence: 0.78, tier: 2, users: 342 },
    "PP*HEADSPACE": { name: "Headspace", confidence: 0.88, tier: 2, users: 567 },
    "AMZN DIGITAL*14.99": { name: "Audible", confidence: 0.72, tier: 2, users: 289 },
    "GOOGLE*SVCS*1.99": { name: "Unknown", confidence: 0.3, tier: 3, users: 45 },
    "MSFT*STORE*10.99": { name: "Unknown", confidence: 0.25, tier: 3, users: 23 },
  };

  const handleComplete = (result) => {
    setToastData(result);
    setToastVisible(true);
    setAddedCount(c => c + (result?.count || 1));
    setUsedScans(s => s + 1);
  };

  return (
    <div style={{ background: C.bg, minHeight: "100vh", color: C.text, fontFamily: "'DM Sans',-apple-system,sans-serif", padding: "24px 20px" }}>
      <style>{STYLES}</style>
      <div style={{ maxWidth: 900, margin: "0 auto" }}>
        {/* Header */}
        <div style={{ textAlign: "center", marginBottom: 24 }}>
          <h1 style={{ fontSize: 26, fontWeight: 700, letterSpacing: "-0.03em", marginBottom: 4, lineHeight: 1.2 }}>
            Sub<span style={{ color: C.accent }}>Snap</span> <span style={{ fontSize: 14, color: C.dim, fontWeight: 400 }}>AI Scan Flow v3</span>
          </h1>
          <p style={{ color: C.dim, fontSize: 12.5, margin: 0 }}>
            3-tier recognition · Conversational clarification · Intelligence flywheel
          </p>
          <div style={{ display: "flex", justifyContent: "center", gap: 14, marginTop: 10 }}>
            {addedCount > 0 && (
              <span style={{ fontSize: 11, color: C.accent, background: `${C.accent}15`, padding: "3px 10px", borderRadius: 100 }}>
                ✓ {addedCount} added
              </span>
            )}
            <span style={{
              fontSize: 11, padding: "3px 10px", borderRadius: 100,
              color: usedScans >= freeScans ? C.warn : C.dim,
              background: usedScans >= freeScans ? `${C.warn}15` : `${C.dim}15`,
            }}>
              📸 {Math.max(0, freeScans - usedScans)} of {freeScans} free scans
            </span>
          </div>
        </div>

        {/* View toggle */}
        <div style={{ display: "flex", justifyContent: "center", gap: 6, marginBottom: 22 }}>
          {[
            { key: "scan", label: "📸 Scan Flow" },
            { key: "db", label: `🧠 Recognition DB (${Object.keys(db).length})` },
            { key: "tiers", label: "📊 Tier System" },
          ].map(v => (
            <button key={v.key} onClick={() => setView(v.key)} style={{
              padding: "7px 16px", borderRadius: 100,
              border: `1px solid ${view === v.key ? C.accent : C.border}`,
              background: view === v.key ? C.accent : "transparent",
              color: view === v.key ? C.bg : C.dim,
              fontSize: 11, fontFamily: "monospace", cursor: "pointer",
              transition: "all 0.2s",
            }}>{v.label}</button>
          ))}
        </div>

        {/* Scan Flow View */}
        {view === "scan" && (
          <div style={{ display: "flex", gap: 14, flexWrap: "wrap" }}>
            <div style={{ width: 190, flexShrink: 0 }}>
              <div style={{ fontFamily: "monospace", fontSize: 9, textTransform: "uppercase", letterSpacing: "0.12em", color: C.dim, marginBottom: 8 }}>
                Test Scenarios
              </div>
              {SCENARIOS.map((s, i) => (
                <button key={s.id} onClick={() => setSelected(i)} style={{
                  width: "100%", textAlign: "left", padding: "10px 12px", marginBottom: 5,
                  borderRadius: 10, cursor: "pointer", fontFamily: "inherit",
                  border: `1px solid ${selected === i ? C.accent : C.border}`,
                  background: selected === i ? `${C.accent}08` : C.surface,
                  color: selected === i ? C.text : C.dim, transition: "all 0.2s",
                }}>
                  <div style={{ fontSize: 12, fontWeight: 600, marginBottom: 2 }}>{s.label}</div>
                  <div style={{ fontSize: 10, color: C.dim }}>{s.desc}</div>
                  <div style={{ marginTop: 5 }}>
                    <span style={{
                      fontSize: 8, fontFamily: "monospace", textTransform: "uppercase",
                      padding: "2px 6px", borderRadius: 100,
                      background: s.tier === "no-question" ? `${C.accent}22` : s.tier === "quick-confirm" ? `${C.blue}22` : `${C.purple}22`,
                      color: s.tier === "no-question" ? C.accent : s.tier === "quick-confirm" ? C.blue : C.purple,
                    }}>
                      {s.tier === "no-question" ? "Auto" : s.tier === "quick-confirm" ? "Confirm" : s.tier === "mixed" ? "Mixed" : "Questions"}
                    </span>
                  </div>
                </button>
              ))}
            </div>
            <div style={{
              flex: 1, minWidth: 320, background: C.surface,
              border: `1px solid ${C.border}`, borderRadius: 16, padding: 16,
            }}>
              <ScanFlow key={`${selected}-${usedScans}`} scenario={SCENARIOS[selected]} onComplete={handleComplete} />
            </div>
          </div>
        )}

        {view === "db" && (
          <div style={{ background: C.surface, border: `1px solid ${C.border}`, borderRadius: 16, padding: 22 }}>
            <DbView db={db} />
          </div>
        )}

        {view === "tiers" && <TierView />}
      </div>

      <Toast visible={toastVisible} data={toastData} onDone={() => setToastVisible(false)} />
    </div>
  );
}

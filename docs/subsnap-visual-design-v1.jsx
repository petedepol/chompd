import { useState, useEffect, useRef } from "react";

/* ─── Design Tokens ─── */
const T = {
  bg: "#07070c", bgCard: "#111118", bgElevated: "#1a1a24", bgGlass: "rgba(26,26,36,0.85)",
  border: "#242436", borderLight: "#2e2e44",
  text: "#f0f0f5", textMid: "#a0a0b8", textDim: "#6a6a82",
  mint: "#6ee7b7", mintDark: "#34d399", mintGlow: "rgba(110,231,183,0.15)",
  amber: "#fbbf24", amberGlow: "rgba(251,191,36,0.12)",
  red: "#f87171", redGlow: "rgba(248,113,113,0.12)",
  purple: "#a78bfa", blue: "#60a5fa", pink: "#f472b6",
};

const CAT_COLORS = {
  Entertainment: "#E50914", Music: "#1DB954", Design: "#A259FF",
  Fitness: "#FC6719", Productivity: "#00A4EF", Storage: "#4285F4",
  News: "#1DA1F2", Gaming: "#107C10",
};

const SUBS = [
  { name: "Netflix", price: 15.99, cycle: "mo", cat: "Entertainment", icon: "N", color: "#E50914", renew: 22, trial: false },
  { name: "Spotify", price: 10.99, cycle: "mo", cat: "Music", icon: "S", color: "#1DB954", renew: 1, trial: false },
  { name: "Figma Pro", price: 9.99, cycle: "mo", cat: "Design", icon: "F", color: "#A259FF", renew: 5, trial: true, trialDays: 11 },
  { name: "Zwift", price: 17.99, cycle: "mo", cat: "Fitness", icon: "Z", color: "#FC6719", renew: 12, trial: false },
  { name: "iCloud+", price: 2.99, cycle: "mo", cat: "Storage", icon: "☁", color: "#4285F4", renew: 18, trial: false },
  { name: "ChatGPT Plus", price: 20.00, cycle: "mo", cat: "Productivity", icon: "G", color: "#10A37F", renew: 8, trial: false },
  { name: "Xbox Game Pass", price: 10.99, cycle: "mo", cat: "Gaming", icon: "X", color: "#107C10", renew: 15, trial: true, trialDays: 3 },
  { name: "Strava", price: 6.99, cycle: "mo", cat: "Fitness", icon: "▲", color: "#FC4C02", renew: 28, trial: false },
];

const CANCELLED = [
  { name: "Adobe CC", price: 54.99, saved: 274.95, months: 5, icon: "Ai", color: "#FF0000" },
  { name: "YouTube Premium", price: 12.99, saved: 38.97, months: 3, icon: "▶", color: "#FF0000" },
];

const STYLES = `
  @import url('https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,500;0,9..40,700&family=Space+Mono:wght@400;700&display=swap');
  @keyframes fadeUp { from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)} }
  @keyframes fadeIn { from{opacity:0}to{opacity:1} }
  @keyframes pulse { 0%,100%{opacity:1}50%{opacity:0.6} }
  @keyframes ringDraw { from{stroke-dashoffset:314}to{stroke-dashoffset:var(--target)} }
  @keyframes shimmer { 0%{transform:translateX(-100%)}100%{transform:translateX(200%)} }
  @keyframes glow { 0%,100%{box-shadow:0 0 15px rgba(110,231,183,0.2)}50%{box-shadow:0 0 30px rgba(110,231,183,0.4)} }
  @keyframes countUp { from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)} }
  @keyframes confettiDrop { 0%{transform:translateY(-20px) rotate(0deg);opacity:1}100%{transform:translateY(40px) rotate(360deg);opacity:0} }
  * { box-sizing: border-box; margin: 0; padding: 0; }
`;

/* ─── Spending Ring SVG ─── */
function SpendingRing({ total, budget = 150, size = 160 }) {
  const pct = Math.min(total / budget, 1);
  const r = 50; const circ = 2 * Math.PI * r;
  const offset = circ * (1 - pct);
  const overBudget = total > budget;
  return (
    <div style={{ position: "relative", width: size, height: size }}>
      <svg width={size} height={size} viewBox="0 0 120 120" style={{ transform: "rotate(-90deg)" }}>
        <circle cx="60" cy="60" r={r} fill="none" stroke={T.border} strokeWidth="8" />
        <circle cx="60" cy="60" r={r} fill="none"
          stroke={overBudget ? T.red : `url(#mintGrad)`}
          strokeWidth="8" strokeLinecap="round"
          strokeDasharray={circ} strokeDashoffset={offset}
          style={{ transition: "stroke-dashoffset 1.2s ease", filter: `drop-shadow(0 0 8px ${overBudget ? T.red : T.mint}44)` }}
        />
        <defs>
          <linearGradient id="mintGrad" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor={T.mintDark} />
            <stop offset="100%" stopColor={T.mint} />
          </linearGradient>
        </defs>
      </svg>
      <div style={{
        position: "absolute", inset: 0, display: "flex", flexDirection: "column",
        alignItems: "center", justifyContent: "center",
      }}>
        <div style={{ fontSize: 11, color: T.textDim, fontFamily: "'Space Mono',monospace", letterSpacing: "0.05em" }}>MONTHLY</div>
        <div style={{
          fontSize: 28, fontWeight: 700, color: T.text, letterSpacing: "-0.03em",
          animation: "countUp 0.8s ease",
        }}>£{total.toFixed(2)}</div>
        <div style={{ fontSize: 10, color: overBudget ? T.red : T.textDim }}>
          {overBudget ? `£${(total - budget).toFixed(0)} over budget` : `of £${budget} budget`}
        </div>
      </div>
    </div>
  );
}

/* ─── Subscription Card ─── */
function SubCard({ sub, delay = 0, onClick }) {
  return (
    <div onClick={onClick} style={{
      display: "flex", alignItems: "center", gap: 12, padding: "12px 14px",
      background: T.bgCard, borderRadius: 14, cursor: "pointer",
      border: `1px solid ${sub.trial && sub.trialDays <= 3 ? T.amber + "44" : T.border}`,
      animation: `fadeUp 0.4s ease ${delay}s both`,
      transition: "all 0.2s",
      boxShadow: sub.trial && sub.trialDays <= 3 ? `0 0 16px ${T.amberGlow}` : "none",
    }}
      onMouseEnter={e => e.currentTarget.style.background = T.bgElevated}
      onMouseLeave={e => e.currentTarget.style.background = T.bgCard}
    >
      {/* Service icon */}
      <div style={{
        width: 40, height: 40, borderRadius: 12, flexShrink: 0,
        background: `linear-gradient(135deg, ${sub.color}dd, ${sub.color}88)`,
        display: "flex", alignItems: "center", justifyContent: "center",
        fontSize: 16, fontWeight: 700, color: "white",
        boxShadow: `0 4px 12px ${sub.color}33`,
      }}>{sub.icon}</div>
      {/* Details */}
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
          <span style={{ fontSize: 13.5, fontWeight: 600, color: T.text }}>{sub.name}</span>
          {sub.trial && (
            <span style={{
              fontSize: 8, fontFamily: "'Space Mono',monospace", fontWeight: 700,
              padding: "2px 6px", borderRadius: 100, textTransform: "uppercase",
              background: sub.trialDays <= 3 ? T.amberGlow : `${T.amber}18`,
              color: T.amber, animation: sub.trialDays <= 3 ? "pulse 1.5s ease infinite" : "none",
            }}>
              {sub.trialDays}d trial
            </span>
          )}
        </div>
        <div style={{ fontSize: 11, color: T.textDim, marginTop: 1 }}>
          Renews in {sub.renew} days
        </div>
      </div>
      {/* Price */}
      <div style={{ textAlign: "right", flexShrink: 0 }}>
        <div style={{ fontSize: 14, fontWeight: 700, color: T.text, fontFamily: "'Space Mono',monospace" }}>
          £{sub.price.toFixed(2)}
        </div>
        <div style={{ fontSize: 9.5, color: T.textDim }}>/{sub.cycle}</div>
      </div>
    </div>
  );
}

/* ─── Category Pill ─── */
function CatBar({ subs }) {
  const cats = {};
  subs.forEach(s => { cats[s.cat] = (cats[s.cat] || 0) + s.price; });
  const total = subs.reduce((s, x) => s + x.price, 0);
  const sorted = Object.entries(cats).sort((a, b) => b[1] - a[1]);
  return (
    <div>
      <div style={{ display: "flex", height: 6, borderRadius: 3, overflow: "hidden", gap: 2, marginBottom: 8 }}>
        {sorted.map(([cat, val]) => (
          <div key={cat} style={{
            width: `${(val / total) * 100}%`,
            background: CAT_COLORS[cat] || T.textDim,
            borderRadius: 3, minWidth: 4, transition: "width 0.8s ease",
          }} />
        ))}
      </div>
      <div style={{ display: "flex", gap: 10, flexWrap: "wrap" }}>
        {sorted.slice(0, 4).map(([cat, val]) => (
          <div key={cat} style={{ display: "flex", alignItems: "center", gap: 4, fontSize: 10, color: T.textDim }}>
            <div style={{ width: 6, height: 6, borderRadius: 2, background: CAT_COLORS[cat] || T.textDim }} />
            {cat} <span style={{ color: T.textMid, fontFamily: "'Space Mono',monospace" }}>£{val.toFixed(0)}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

/* ─── Phone Frame ─── */
function PhoneFrame({ children, title }) {
  return (
    <div style={{
      width: 375, height: 740, borderRadius: 40, overflow: "hidden",
      background: T.bg, position: "relative",
      border: `2px solid ${T.borderLight}`,
      boxShadow: `0 20px 60px rgba(0,0,0,0.6), 0 0 40px ${T.mintGlow}`,
    }}>
      {/* Status bar */}
      <div style={{
        display: "flex", justifyContent: "space-between", alignItems: "center",
        padding: "12px 28px 8px", fontSize: 12, fontWeight: 600, color: T.text,
      }}>
        <span>9:41</span>
        <div style={{ width: 120, height: 28, borderRadius: 14, background: T.bgCard }} />
        <div style={{ display: "flex", gap: 4, alignItems: "center" }}>
          <span style={{ fontSize: 10 }}>📶</span>
          <span style={{ fontSize: 10 }}>🔋</span>
        </div>
      </div>
      {/* Content */}
      <div style={{ height: "calc(100% - 48px)", overflowY: "auto", overflowX: "hidden" }}>
        {children}
      </div>
    </div>
  );
}

/* ─── HOME SCREEN ─── */
function HomeScreen({ onSubClick }) {
  const total = SUBS.reduce((s, x) => s + x.price, 0);
  const trials = SUBS.filter(s => s.trial);

  return (
    <PhoneFrame>
      <div style={{ padding: "8px 20px 100px" }}>
        {/* Header */}
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
          <div>
            <div style={{ fontSize: 22, fontWeight: 700, color: T.text, letterSpacing: "-0.02em" }}>
              Sub<span style={{ color: T.mint }}>Snap</span>
            </div>
            <div style={{ fontSize: 11, color: T.textDim }}>8 active · 2 cancelled</div>
          </div>
          <div style={{
            width: 36, height: 36, borderRadius: 12, background: T.bgElevated,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 18, cursor: "pointer", border: `1px solid ${T.border}`,
          }}>⚙</div>
        </div>

        {/* Spending Ring */}
        <div style={{
          display: "flex", justifyContent: "center", padding: "10px 0 20px",
          animation: "fadeIn 0.6s ease",
        }}>
          <SpendingRing total={total} />
        </div>

        {/* Category Bar */}
        <div style={{ marginBottom: 20, animation: "fadeUp 0.5s ease 0.2s both" }}>
          <CatBar subs={SUBS} />
        </div>

        {/* Trial Alert */}
        {trials.filter(t => t.trialDays <= 7).length > 0 && (
          <div style={{
            padding: "12px 14px", borderRadius: 12, marginBottom: 16,
            background: T.amberGlow, border: `1px solid ${T.amber}33`,
            display: "flex", alignItems: "center", gap: 10,
            animation: "fadeUp 0.4s ease 0.3s both",
          }}>
            <span style={{ fontSize: 20 }}>⚠️</span>
            <div>
              <div style={{ fontSize: 12, fontWeight: 600, color: T.amber }}>
                {trials.filter(t => t.trialDays <= 7).length} trial{trials.filter(t => t.trialDays <= 7).length > 1 ? "s" : ""} expiring soon
              </div>
              <div style={{ fontSize: 10.5, color: T.textDim }}>
                {trials.filter(t => t.trialDays <= 3).map(t => t.name).join(", ")} — {trials.filter(t => t.trialDays <= 3)[0]?.trialDays} days left
              </div>
            </div>
          </div>
        )}

        {/* Subscription List */}
        <div style={{
          display: "flex", alignItems: "center", justifyContent: "space-between",
          marginBottom: 10,
        }}>
          <span style={{
            fontSize: 10, fontFamily: "'Space Mono',monospace", textTransform: "uppercase",
            letterSpacing: "0.12em", color: T.textDim,
          }}>Active Subscriptions</span>
          <span style={{ fontSize: 10, color: T.textMid }}>{SUBS.length}</span>
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 6 }}>
          {SUBS.map((sub, i) => (
            <SubCard key={sub.name} sub={sub} delay={0.05 * i} onClick={() => onSubClick(sub)} />
          ))}
        </div>

        {/* Cancelled */}
        <div style={{ marginTop: 20 }}>
          <div style={{
            fontSize: 10, fontFamily: "'Space Mono',monospace", textTransform: "uppercase",
            letterSpacing: "0.12em", color: T.textDim, marginBottom: 10,
          }}>Cancelled — Money Saved</div>
          {CANCELLED.map((c, i) => (
            <div key={c.name} style={{
              display: "flex", alignItems: "center", gap: 12, padding: "10px 14px",
              background: T.bgCard, borderRadius: 12, marginBottom: 5,
              border: `1px solid ${T.border}`, opacity: 0.7,
              animation: `fadeUp 0.4s ease ${0.6 + i * 0.1}s both`,
            }}>
              <div style={{
                width: 36, height: 36, borderRadius: 10, background: `${c.color}22`,
                display: "flex", alignItems: "center", justifyContent: "center",
                fontSize: 12, color: c.color, fontWeight: 700,
              }}>{c.icon}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 12.5, fontWeight: 600, color: T.textMid, textDecoration: "line-through" }}>{c.name}</div>
                <div style={{ fontSize: 10, color: T.textDim }}>Cancelled {c.months}mo ago</div>
              </div>
              <div style={{ fontSize: 13, fontWeight: 700, color: T.mint, fontFamily: "'Space Mono',monospace" }}>
                +£{c.saved.toFixed(0)}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Bottom Nav */}
      <div style={{
        position: "absolute", bottom: 0, left: 0, right: 0,
        background: `linear-gradient(transparent, ${T.bg} 30%)`,
        padding: "24px 20px 28px",
      }}>
        <div style={{
          display: "flex", justifyContent: "space-around", alignItems: "center",
          background: T.bgGlass, backdropFilter: "blur(20px)",
          borderRadius: 20, padding: "10px 0",
          border: `1px solid ${T.border}`,
        }}>
          <div style={{ textAlign: "center", color: T.mint }}>
            <div style={{ fontSize: 18 }}>🏠</div>
            <div style={{ fontSize: 8, marginTop: 2, fontFamily: "'Space Mono',monospace" }}>HOME</div>
          </div>
          <div style={{
            width: 52, height: 52, borderRadius: 16,
            background: `linear-gradient(135deg, ${T.mintDark}, ${T.mint})`,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 24, boxShadow: `0 4px 20px ${T.mint}44`,
            marginTop: -20, cursor: "pointer",
          }}>📸</div>
          <div style={{ textAlign: "center", color: T.textDim }}>
            <div style={{ fontSize: 18 }}>💰</div>
            <div style={{ fontSize: 8, marginTop: 2, fontFamily: "'Space Mono',monospace" }}>SAVED</div>
          </div>
        </div>
      </div>
    </PhoneFrame>
  );
}

/* ─── DETAIL SCREEN ─── */
function DetailScreen({ sub }) {
  if (!sub) sub = SUBS[0];
  const pct = Math.max(0, 1 - (sub.renew / 30));
  return (
    <PhoneFrame>
      <div style={{ padding: "8px 20px 100px" }}>
        {/* Back + title */}
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 24 }}>
          <div style={{
            width: 32, height: 32, borderRadius: 10, background: T.bgElevated,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 14, cursor: "pointer", border: `1px solid ${T.border}`,
          }}>←</div>
          <span style={{ fontSize: 16, fontWeight: 600 }}>Subscription Detail</span>
        </div>

        {/* Hero card */}
        <div style={{
          background: `linear-gradient(145deg, ${sub.color}22, ${T.bgCard})`,
          border: `1px solid ${sub.color}33`,
          borderRadius: 20, padding: 24, textAlign: "center", marginBottom: 20,
          animation: "fadeUp 0.5s ease",
        }}>
          <div style={{
            width: 64, height: 64, borderRadius: 18, margin: "0 auto 14px",
            background: `linear-gradient(135deg, ${sub.color}dd, ${sub.color}88)`,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 28, fontWeight: 700, color: "white",
            boxShadow: `0 8px 24px ${sub.color}44`,
          }}>{sub.icon}</div>
          <div style={{ fontSize: 20, fontWeight: 700, marginBottom: 4 }}>{sub.name}</div>
          <div style={{ fontSize: 28, fontWeight: 700, fontFamily: "'Space Mono',monospace", color: T.mint }}>
            £{sub.price.toFixed(2)}<span style={{ fontSize: 14, color: T.textDim }}>/{sub.cycle}</span>
          </div>
          {sub.trial && (
            <div style={{
              marginTop: 10, padding: "6px 14px", borderRadius: 100,
              background: T.amberGlow, border: `1px solid ${T.amber}44`,
              fontSize: 11, fontWeight: 600, color: T.amber, display: "inline-block",
            }}>⚠️ Trial — {sub.trialDays} days remaining</div>
          )}
        </div>

        {/* Renewal countdown */}
        <div style={{
          background: T.bgCard, borderRadius: 16, padding: 18,
          border: `1px solid ${T.border}`, marginBottom: 12,
          animation: "fadeUp 0.5s ease 0.1s both",
        }}>
          <div style={{ fontSize: 10, fontFamily: "'Space Mono',monospace", color: T.textDim, textTransform: "uppercase", letterSpacing: "0.1em", marginBottom: 10 }}>
            Next Renewal
          </div>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 10 }}>
            <span style={{ fontSize: 15, fontWeight: 600 }}>
              {new Date(Date.now() + sub.renew * 86400000).toLocaleDateString("en-GB", { day: "numeric", month: "short", year: "numeric" })}
            </span>
            <span style={{
              fontSize: 12, fontWeight: 700, fontFamily: "'Space Mono',monospace",
              color: sub.renew <= 3 ? T.red : sub.renew <= 7 ? T.amber : T.mint,
            }}>{sub.renew} days</span>
          </div>
          <div style={{ height: 6, borderRadius: 3, background: T.bgElevated, overflow: "hidden" }}>
            <div style={{
              height: "100%", borderRadius: 3, transition: "width 1s ease",
              width: `${pct * 100}%`,
              background: sub.renew <= 3 ? T.red : sub.renew <= 7 ? `linear-gradient(90deg, ${T.amber}, ${T.red})` : `linear-gradient(90deg, ${T.mintDark}, ${T.mint})`,
              boxShadow: `0 0 8px ${sub.renew <= 3 ? T.red : T.mint}44`,
            }} />
          </div>
        </div>

        {/* Reminders */}
        <div style={{
          background: T.bgCard, borderRadius: 16, padding: 18,
          border: `1px solid ${T.border}`, marginBottom: 12,
          animation: "fadeUp 0.5s ease 0.2s both",
        }}>
          <div style={{ fontSize: 10, fontFamily: "'Space Mono',monospace", color: T.textDim, textTransform: "uppercase", letterSpacing: "0.1em", marginBottom: 12 }}>
            Reminders
          </div>
          {[
            { label: "7 days before", on: true, pro: true },
            { label: "3 days before", on: true, pro: true },
            { label: "1 day before", on: true, pro: false },
            { label: "Morning of", on: true, pro: false },
          ].map((r, i) => (
            <div key={i} style={{
              display: "flex", alignItems: "center", justifyContent: "space-between",
              padding: "8px 0", borderBottom: i < 3 ? `1px solid ${T.border}` : "none",
            }}>
              <span style={{ fontSize: 12.5, color: r.on ? T.text : T.textDim }}>{r.label}</span>
              <div style={{ display: "flex", alignItems: "center", gap: 6 }}>
                {r.pro && (
                  <span style={{
                    fontSize: 7, fontFamily: "'Space Mono',monospace", fontWeight: 700,
                    padding: "2px 5px", borderRadius: 4,
                    background: `${T.mint}18`, color: T.mint, textTransform: "uppercase",
                  }}>PRO</span>
                )}
                <div style={{
                  width: 36, height: 20, borderRadius: 10, padding: 2, cursor: "pointer",
                  background: r.on ? T.mint : T.bgElevated, transition: "background 0.3s",
                }}>
                  <div style={{
                    width: 16, height: 16, borderRadius: 8, background: "white",
                    transform: r.on ? "translateX(16px)" : "translateX(0)",
                    transition: "transform 0.3s",
                    boxShadow: "0 1px 3px rgba(0,0,0,0.3)",
                  }} />
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* History */}
        <div style={{
          background: T.bgCard, borderRadius: 16, padding: 18,
          border: `1px solid ${T.border}`, marginBottom: 12,
          animation: "fadeUp 0.5s ease 0.3s both",
        }}>
          <div style={{ fontSize: 10, fontFamily: "'Space Mono',monospace", color: T.textDim, textTransform: "uppercase", letterSpacing: "0.1em", marginBottom: 12 }}>
            Payment History
          </div>
          {["Feb 2026", "Jan 2026", "Dec 2025", "Nov 2025"].map((m, i) => (
            <div key={m} style={{
              display: "flex", justifyContent: "space-between", padding: "7px 0",
              borderBottom: i < 3 ? `1px solid ${T.border}` : "none",
              fontSize: 12,
            }}>
              <span style={{ color: T.textMid }}>{m}</span>
              <span style={{ fontFamily: "'Space Mono',monospace", color: T.text }}>£{sub.price.toFixed(2)}</span>
            </div>
          ))}
          <div style={{
            display: "flex", justifyContent: "space-between", marginTop: 10,
            padding: "8px 0 0", borderTop: `1px solid ${T.borderLight}`,
          }}>
            <span style={{ fontSize: 11, fontWeight: 600, color: T.textMid }}>Total paid</span>
            <span style={{ fontSize: 13, fontWeight: 700, fontFamily: "'Space Mono',monospace", color: T.mint }}>
              £{(sub.price * 4).toFixed(2)}
            </span>
          </div>
        </div>

        {/* Cancel button */}
        <button style={{
          width: "100%", padding: "14px 0", borderRadius: 14,
          background: T.redGlow, border: `1px solid ${T.red}33`,
          color: T.red, fontSize: 13, fontWeight: 600,
          cursor: "pointer", fontFamily: "'DM Sans',sans-serif",
          animation: "fadeUp 0.5s ease 0.4s both",
        }}>
          Cancel Subscription
        </button>
      </div>
    </PhoneFrame>
  );
}

/* ─── SCAN SCREEN ─── */
function ScanScreen() {
  const [step, setStep] = useState(0);
  useEffect(() => {
    const t = [
      setTimeout(() => setStep(1), 800),
      setTimeout(() => setStep(2), 2000),
      setTimeout(() => setStep(3), 3200),
      setTimeout(() => setStep(4), 4000),
    ];
    return () => t.forEach(clearTimeout);
  }, []);

  return (
    <PhoneFrame>
      <div style={{ padding: "8px 20px 100px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 20 }}>
          <div style={{
            width: 32, height: 32, borderRadius: 10, background: T.bgElevated,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 14, border: `1px solid ${T.border}`,
          }}>←</div>
          <span style={{ fontSize: 16, fontWeight: 600 }}>AI Scan</span>
          <div style={{ marginLeft: "auto", fontSize: 10, color: T.textDim, fontFamily: "'Space Mono',monospace" }}>
            2 of 3 free scans
          </div>
        </div>

        {/* Screenshot preview */}
        <div style={{
          background: T.bgCard, borderRadius: 16, padding: 16, marginBottom: 16,
          border: `1px solid ${step >= 1 ? T.mint + "44" : T.border}`,
          position: "relative", overflow: "hidden", transition: "border-color 0.5s",
        }}>
          <div style={{ fontFamily: "'Space Mono',monospace", fontSize: 10, color: T.textDim, lineHeight: 1.8, whiteSpace: "pre-wrap" }}>
            {"📧 Netflix — Your membership renews\non March 14, 2026.\n\nYou'll be charged £15.99/month\nto your Visa ending 4521."}
          </div>
          {step < 2 && (
            <div style={{ position: "absolute", inset: 0, overflow: "hidden", borderRadius: 16, pointerEvents: "none" }}>
              <div style={{
                position: "absolute", top: 0, bottom: 0, width: "40%",
                background: `linear-gradient(90deg, transparent, ${T.mint}10, ${T.mint}20, ${T.mint}10, transparent)`,
                animation: "shimmer 1.8s ease infinite",
              }} />
            </div>
          )}
          {step >= 2 && (
            <div style={{
              position: "absolute", top: 0, right: 0, padding: "6px 10px",
              background: `${T.mint}22`, borderBottomLeftRadius: 12,
              fontSize: 9, fontFamily: "'Space Mono',monospace", color: T.mint,
              animation: "fadeIn 0.3s ease",
            }}>98% confident</div>
          )}
        </div>

        {/* Conversation */}
        <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
          {step >= 1 && (
            <div style={{ display: "flex", gap: 8, animation: "fadeUp 0.3s ease" }}>
              <div style={{
                width: 28, height: 28, borderRadius: 8, flexShrink: 0,
                background: `linear-gradient(135deg, ${T.mintDark}, ${T.mint})`,
                display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12,
              }}>🤖</div>
              <div style={{
                background: T.bgElevated, borderRadius: "4px 12px 12px 12px",
                padding: "8px 12px", fontSize: 12, color: T.textMid,
              }}>Analysing screenshot...</div>
            </div>
          )}

          {step >= 2 && (
            <div style={{ display: "flex", gap: 8, animation: "fadeUp 0.3s ease" }}>
              <div style={{
                width: 28, height: 28, borderRadius: 8, flexShrink: 0,
                background: `linear-gradient(135deg, ${T.mintDark}, ${T.mint})`,
                display: "flex", alignItems: "center", justifyContent: "center", fontSize: 12,
              }}>✅</div>
              <div style={{
                background: T.bgElevated, borderRadius: "4px 12px 12px 12px",
                padding: 12, fontSize: 12, color: T.text,
                borderLeft: `3px solid ${T.mint}`,
              }}>
                <div style={{ fontFamily: "'Space Mono',monospace", fontSize: 9, color: T.mint, textTransform: "uppercase", letterSpacing: "0.1em", marginBottom: 8 }}>
                  ✓ Auto-detected
                </div>
                <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 8 }}>
                  <div style={{
                    width: 36, height: 36, borderRadius: 10,
                    background: "linear-gradient(135deg, #E50914dd, #E5091488)",
                    display: "flex", alignItems: "center", justifyContent: "center",
                    fontSize: 14, fontWeight: 700, color: "white",
                  }}>N</div>
                  <div>
                    <div style={{ fontSize: 15, fontWeight: 700 }}>Netflix</div>
                    <div style={{ fontSize: 11, color: T.textDim }}>Entertainment</div>
                  </div>
                </div>
                <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: "4px 12px", fontSize: 11.5 }}>
                  <div><span style={{ color: T.textDim }}>Price </span>£15.99/mo</div>
                  <div><span style={{ color: T.textDim }}>Renews </span>14 Mar</div>
                  <div><span style={{ color: T.textDim }}>Cycle </span>Monthly</div>
                  <div><span style={{ color: T.textDim }}>Source </span>Email</div>
                </div>
              </div>
            </div>
          )}

          {step >= 3 && (
            <div style={{
              display: "flex", gap: 8, justifyContent: "flex-end",
              animation: "fadeUp 0.3s ease",
            }}>
              <div style={{
                background: `${T.mint}15`, border: `1px solid ${T.mint}35`,
                borderRadius: "12px 4px 12px 12px", padding: "7px 14px",
                fontSize: 12, color: T.mint, fontWeight: 500,
              }}>Looks right! ✓</div>
            </div>
          )}
        </div>

        {/* Add button */}
        {step >= 4 && (
          <button style={{
            width: "100%", marginTop: 20, padding: "14px 0", borderRadius: 14,
            background: `linear-gradient(135deg, ${T.mintDark}, ${T.mint})`,
            border: "none", color: T.bg, fontSize: 14, fontWeight: 700,
            cursor: "pointer", fontFamily: "'DM Sans',sans-serif",
            animation: "fadeUp 0.4s ease, glow 2s ease infinite",
            display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          }}>
            <span style={{ fontSize: 18 }}>+</span> Add to SubSnap
          </button>
        )}

        {/* Scan cost */}
        {step >= 2 && (
          <div style={{
            textAlign: "center", marginTop: 14, fontSize: 10,
            fontFamily: "'Space Mono',monospace", color: T.textDim,
            animation: "fadeIn 0.5s ease",
          }}>
            ⚡ Tier 1 auto-detect · Cost: $0.00 · DB match
          </div>
        )}
      </div>
    </PhoneFrame>
  );
}

/* ─── PAYWALL SCREEN ─── */
function PaywallScreen() {
  return (
    <PhoneFrame>
      <div style={{ padding: "8px 20px 40px", display: "flex", flexDirection: "column", minHeight: "100%" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 20 }}>
          <div style={{
            width: 32, height: 32, borderRadius: 10, background: T.bgElevated,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 14, border: `1px solid ${T.border}`,
          }}>✕</div>
        </div>

        {/* Hero */}
        <div style={{ textAlign: "center", marginBottom: 28, animation: "fadeUp 0.5s ease" }}>
          <div style={{ fontSize: 44, marginBottom: 8 }}>✨</div>
          <div style={{ fontSize: 24, fontWeight: 700, letterSpacing: "-0.03em", marginBottom: 6 }}>
            Unlock <span style={{ color: T.mint }}>Pro</span>
          </div>
          <div style={{ fontSize: 13, color: T.textDim, lineHeight: 1.6 }}>
            You've hit 3 subscriptions.<br />
            Unlock everything with a single payment.
          </div>
        </div>

        {/* Features */}
        <div style={{
          display: "flex", flexDirection: "column", gap: 8, marginBottom: 28,
        }}>
          {[
            { icon: "∞", label: "Unlimited subscriptions", desc: "Track everything in one place" },
            { icon: "📸", label: "Unlimited AI scans", desc: "Screenshot → subscription in seconds" },
            { icon: "🔔", label: "Smart reminders", desc: "7 days, 3 days, 1 day, morning-of" },
            { icon: "⏱", label: "Trial countdown", desc: "Never miss a cancellation deadline" },
            { icon: "💰", label: "Money saved tracker", desc: "Celebrate what you've saved" },
            { icon: "📱", label: "Widgets & Shortcuts", desc: "Quick glance from home screen" },
          ].map((f, i) => (
            <div key={f.label} style={{
              display: "flex", alignItems: "center", gap: 12, padding: "10px 14px",
              background: T.bgCard, borderRadius: 12, border: `1px solid ${T.border}`,
              animation: `fadeUp 0.4s ease ${0.1 + i * 0.06}s both`,
            }}>
              <div style={{
                width: 36, height: 36, borderRadius: 10, flexShrink: 0,
                background: T.bgElevated, display: "flex", alignItems: "center",
                justifyContent: "center", fontSize: 18,
              }}>{f.icon}</div>
              <div>
                <div style={{ fontSize: 13, fontWeight: 600, color: T.text }}>{f.label}</div>
                <div style={{ fontSize: 10.5, color: T.textDim }}>{f.desc}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Price card */}
        <div style={{
          background: `linear-gradient(145deg, ${T.mint}11, ${T.bgCard})`,
          border: `1px solid ${T.mint}33`, borderRadius: 18,
          padding: "20px 20px 16px", textAlign: "center", marginBottom: 16,
          animation: "fadeUp 0.5s ease 0.5s both",
        }}>
          <div style={{ fontSize: 36, fontWeight: 700, fontFamily: "'Space Mono',monospace", color: T.mint }}>
            £4.99
          </div>
          <div style={{ fontSize: 12, color: T.textMid, marginTop: 4 }}>One-time payment. No subscription. Ever.</div>
          <div style={{
            marginTop: 10, fontSize: 11, fontStyle: "italic", color: T.textDim,
          }}>"A subscription tracker that isn't a subscription." 🎯</div>
        </div>

        {/* CTA */}
        <button style={{
          width: "100%", padding: "15px 0", borderRadius: 14,
          background: `linear-gradient(135deg, ${T.mintDark}, ${T.mint})`,
          border: "none", color: T.bg, fontSize: 15, fontWeight: 700,
          cursor: "pointer", fontFamily: "'DM Sans',sans-serif",
          animation: "fadeUp 0.4s ease 0.6s both, glow 2s ease 1s infinite",
        }}>
          Unlock Pro — £4.99
        </button>
        <div style={{
          textAlign: "center", marginTop: 10, fontSize: 11, color: T.textDim,
          animation: "fadeUp 0.4s ease 0.7s both",
        }}>
          Restore Purchase
        </div>
      </div>
    </PhoneFrame>
  );
}

/* ─── MONEY SAVED SCREEN ─── */
function SavedScreen() {
  const totalSaved = CANCELLED.reduce((s, c) => s + c.saved, 0);
  const coffees = Math.floor(totalSaved / 4.50);
  return (
    <PhoneFrame>
      <div style={{ padding: "8px 20px 100px" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 24 }}>
          <div style={{
            width: 32, height: 32, borderRadius: 10, background: T.bgElevated,
            display: "flex", alignItems: "center", justifyContent: "center",
            fontSize: 14, border: `1px solid ${T.border}`,
          }}>←</div>
          <span style={{ fontSize: 16, fontWeight: 600 }}>Money Saved</span>
        </div>

        {/* Hero stat */}
        <div style={{
          textAlign: "center", padding: "30px 20px",
          background: `linear-gradient(145deg, ${T.mint}08, ${T.bgCard})`,
          borderRadius: 20, border: `1px solid ${T.mint}22`,
          marginBottom: 20, animation: "fadeUp 0.5s ease",
        }}>
          <div style={{ fontSize: 10, fontFamily: "'Space Mono',monospace", color: T.mintDark, textTransform: "uppercase", letterSpacing: "0.15em", marginBottom: 8 }}>
            Total Saved
          </div>
          <div style={{
            fontSize: 48, fontWeight: 700, fontFamily: "'Space Mono',monospace",
            color: T.mint, letterSpacing: "-0.03em",
            textShadow: `0 0 30px ${T.mint}44`,
            animation: "countUp 0.8s ease",
          }}>
            £{totalSaved.toFixed(2)}
          </div>
          <div style={{ fontSize: 13, color: T.textDim, marginTop: 8 }}>
            That's <strong style={{ color: T.mint }}>{coffees} coffees</strong> ☕ or <strong style={{ color: T.mint }}>{Math.floor(totalSaved / 15.99)} months</strong> of Netflix
          </div>
        </div>

        {/* Milestones */}
        <div style={{
          fontSize: 10, fontFamily: "'Space Mono',monospace", textTransform: "uppercase",
          letterSpacing: "0.12em", color: T.textDim, marginBottom: 10,
        }}>Milestones</div>

        <div style={{ display: "flex", gap: 8, marginBottom: 20, overflow: "auto", paddingBottom: 4 }}>
          {[
            { amount: 50, emoji: "☕", label: "Coffee Fund" },
            { amount: 100, emoji: "🎮", label: "Game Pass" },
            { amount: 250, emoji: "✈️", label: "Weekend Away" },
            { amount: 500, emoji: "💻", label: "New Gadget" },
          ].map((m, i) => {
            const reached = totalSaved >= m.amount;
            const pct = Math.min(1, totalSaved / m.amount);
            return (
              <div key={m.amount} style={{
                minWidth: 120, padding: "14px 12px", borderRadius: 14,
                background: reached ? `${T.mint}11` : T.bgCard,
                border: `1px solid ${reached ? T.mint + "33" : T.border}`,
                textAlign: "center", animation: `fadeUp 0.4s ease ${i * 0.1}s both`,
              }}>
                <div style={{ fontSize: 28, marginBottom: 4, filter: reached ? "none" : "grayscale(1) opacity(0.4)" }}>
                  {m.emoji}
                </div>
                <div style={{ fontSize: 14, fontWeight: 700, fontFamily: "'Space Mono',monospace", color: reached ? T.mint : T.textDim }}>
                  £{m.amount}
                </div>
                <div style={{ fontSize: 9, color: T.textDim, marginBottom: 6 }}>{m.label}</div>
                <div style={{ height: 4, borderRadius: 2, background: T.bgElevated, overflow: "hidden" }}>
                  <div style={{
                    height: "100%", borderRadius: 2,
                    width: `${pct * 100}%`,
                    background: reached ? T.mint : `linear-gradient(90deg, ${T.mintDark}, ${T.mint})`,
                    transition: "width 1s ease",
                  }} />
                </div>
                {reached && (
                  <div style={{ fontSize: 8, color: T.mint, marginTop: 4, fontWeight: 600 }}>✓ REACHED</div>
                )}
              </div>
            );
          })}
        </div>

        {/* Cancelled list */}
        <div style={{
          fontSize: 10, fontFamily: "'Space Mono',monospace", textTransform: "uppercase",
          letterSpacing: "0.12em", color: T.textDim, marginBottom: 10,
        }}>Cancelled Subscriptions</div>

        {CANCELLED.map((c, i) => (
          <div key={c.name} style={{
            display: "flex", alignItems: "center", gap: 12, padding: "14px",
            background: T.bgCard, borderRadius: 14, marginBottom: 6,
            border: `1px solid ${T.border}`,
            animation: `fadeUp 0.4s ease ${0.3 + i * 0.1}s both`,
          }}>
            <div style={{
              width: 40, height: 40, borderRadius: 12,
              background: `${c.color}22`,
              display: "flex", alignItems: "center", justifyContent: "center",
              fontSize: 14, fontWeight: 700, color: c.color,
            }}>{c.icon}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontSize: 13, fontWeight: 600, color: T.textMid }}>{c.name}</div>
              <div style={{ fontSize: 10.5, color: T.textDim }}>
                Was £{c.price.toFixed(2)}/mo · Cancelled {c.months} months ago
              </div>
            </div>
            <div style={{ textAlign: "right" }}>
              <div style={{ fontSize: 15, fontWeight: 700, color: T.mint, fontFamily: "'Space Mono',monospace" }}>
                +£{c.saved.toFixed(0)}
              </div>
              <div style={{ fontSize: 9, color: T.textDim }}>saved</div>
            </div>
          </div>
        ))}

        {/* Share */}
        <button style={{
          width: "100%", marginTop: 16, padding: "13px 0", borderRadius: 14,
          background: T.bgElevated, border: `1px solid ${T.border}`,
          color: T.textMid, fontSize: 12.5, fontWeight: 600,
          cursor: "pointer", fontFamily: "'DM Sans',sans-serif",
          display: "flex", alignItems: "center", justifyContent: "center", gap: 8,
          animation: "fadeUp 0.4s ease 0.5s both",
        }}>
          📤 Share My Savings
        </button>
      </div>
    </PhoneFrame>
  );
}

/* ─── MAIN APP ─── */
export default function App() {
  const [screen, setScreen] = useState("home");
  const [selectedSub, setSelectedSub] = useState(null);

  const screens = [
    { key: "home", label: "Home" },
    { key: "detail", label: "Detail" },
    { key: "scan", label: "AI Scan" },
    { key: "paywall", label: "Paywall" },
    { key: "saved", label: "Money Saved" },
  ];

  return (
    <div style={{
      background: "#040408", minHeight: "100vh", color: T.text,
      fontFamily: "'DM Sans',-apple-system,sans-serif",
      display: "flex", flexDirection: "column", alignItems: "center",
      padding: "30px 20px",
    }}>
      <style>{STYLES}</style>

      {/* Title */}
      <div style={{ textAlign: "center", marginBottom: 24 }}>
        <h1 style={{ fontSize: 28, fontWeight: 700, letterSpacing: "-0.03em" }}>
          Sub<span style={{ color: T.mint }}>Snap</span>
          <span style={{ fontSize: 13, color: T.textDim, fontWeight: 400, marginLeft: 8 }}>Visual Design v1</span>
        </h1>
        <p style={{ color: T.textDim, fontSize: 12, marginTop: 4 }}>
          Inspired by Trackizer · Revolut · Wealthsimple · 2025/26 fintech trends
        </p>
      </div>

      {/* Screen selector */}
      <div style={{ display: "flex", gap: 6, marginBottom: 30, flexWrap: "wrap", justifyContent: "center" }}>
        {screens.map(s => (
          <button key={s.key} onClick={() => { setScreen(s.key); if (s.key !== "detail") setSelectedSub(null); }} style={{
            padding: "8px 16px", borderRadius: 100,
            border: `1px solid ${screen === s.key ? T.mint : T.border}`,
            background: screen === s.key ? T.mint : "transparent",
            color: screen === s.key ? T.bg : T.textDim,
            fontSize: 11, fontFamily: "'Space Mono',monospace", cursor: "pointer",
            transition: "all 0.2s",
          }}>{s.label}</button>
        ))}
      </div>

      {/* Phone */}
      <div style={{ animation: "fadeUp 0.5s ease" }}>
        {screen === "home" && (
          <HomeScreen onSubClick={(sub) => { setSelectedSub(sub); setScreen("detail"); }} />
        )}
        {screen === "detail" && <DetailScreen sub={selectedSub} />}
        {screen === "scan" && <ScanScreen />}
        {screen === "paywall" && <PaywallScreen />}
        {screen === "saved" && <SavedScreen />}
      </div>

      {/* Design notes */}
      <div style={{
        marginTop: 30, maxWidth: 500, textAlign: "center",
        fontSize: 11, color: T.textDim, lineHeight: 1.7,
      }}>
        <strong style={{ color: T.mint }}>Design DNA:</strong> Dark-first with layered depth · Space Mono for data, DM Sans for UI ·
        Mint accent with amber urgency · Card-based with subtle glow · Color-coded categories ·
        Gamified savings with milestone rewards · Glassmorphic bottom nav
      </div>
    </div>
  );
}

# SLOP.COMPUTER prep — E.H. Vicky (@bc1beat), BlockRunAI

Guest: **E.H. Vicky** · X [@bc1beat](https://x.com/bc1beat) · GitHub `1bcMax` · Telegram t.me/blockrunAI
Topics: **ClawRouter** and **Franklin** (both [github.com/BlockRunAI](https://github.com/BlockRunAI))
Research date: 2026-06-25. All numbers pulled live from GitHub/npm/web on that date.

---

## TL;DR — the whole thing in 6 lines

- One real thesis: **agents can't do credit cards or KYC — they can only sign transactions — so they should pay per-request in USDC** (via the x402 protocol, on Base & Solana).
- **ClawRouter** = the "which model" layer: scores each prompt locally, routes to the cheapest capable model. The hit: **★6,591 / 613 forks**, v0.12.212, 388 npm versions in ~4.5 months.
- **Franklin** = the "agent that pays" layer: a Claude-Code-style CLI coding agent with its own USDC wallet that spends per action. **★622**, v3.29.15, 784 commits, and **it can execute real on-chain swaps** (Jupiter on Solana, 0x on Base).
- Both are **real, daily-shipping TypeScript**, not vaporware. The payment rail (x402), identity layer (ERC-8004), and USDC-on-Base/Solana are all real, recently-shipped infra.
- The surrounding "claw/lobster" universe (OpenClaw, Clawdbot, SLOP.COMPUTER, lobster.cash) is whimsical branding over the real local-agent ecosystem. Products real, branding meme.
- **Two demos are very doable live** (playbooks below): (1) pay USDC for inference through ClawRouter, (2) fund Franklin and watch it swap on-chain.

---

## Verified facts vs. dossier (what changed)

| Claim | Original dossier | Live now (2026-06-25) |
|---|---|---|
| ClawRouter stars | 4.8k | **6,591** |
| ClawRouter forks | 377 | **613** |
| ClawRouter latest | — | **v0.12.212** (Jun 23), 388 npm versions |
| Franklin | "agent with a wallet" | **★622, v3.29.15, 784 commits, real swap code** |
| Savings claim | 92% | **92% (README) / 85% (npm) / 63% (old npm)** — all live at once |
| Model count | 41+ | **"41+" tagline vs "55+" README** — inconsistent |
| Routing dimensions | "14 vs 15" | **15 everywhere; never enumerated** |
| `state-of-x402` repo | cited as a source | **404 — does not exist** |
| `1bcMax` GitHub account | active | **currently 404s** (renamed/deleted/suspended?) |
| Bankless "botconomy" piece | "quotes @bc1beat" | **never names her, Franklin, or BlockRunAI** — names *Austin Griffith* |

**Don't assert on air:** her real name/background (persona only — "@bc1beat" + bech32 styling is the whole footprint); that Bankless cited her; the "15 dimensions"; an LLM fallback classifier (not documented); the savings/volume numbers (her company's own figures, unverifiable externally).

---

## What each product actually is

### ClawRouter (★6,591, MIT, TypeScript)
A local **OpenAI-compatible proxy** (port 8402) — also an OpenClaw plugin. Scores each request across "15 dimensions" in `<1ms`, buckets into **SIMPLE / MEDIUM / COMPLEX / REASONING** tiers, routes to the cheapest model on that tier's ladder, settles in USDC via x402. Wallet-signature auth, non-custodial, no API keys. **Free NVIDIA tier** (8 models) needs no signup/money at all.
- Tier ladders (from README): SIMPLE → free NVIDIA → Gemini Flash → Kimi; REASONING → Grok-4-Fast ($0.20/$0.50) → Claude Sonnet ($3/$15).
- Cost math cited: "$2.05/M blended vs $25/M Claude Opus = 92% savings."
- Real x402 stack confirmed in deps: `@x402/evm`, `@x402/svm`, `@x402/core`, `viem`, `@scure/bip39`.

### Franklin (★622, Apache-2.0, TypeScript)
A CLI coding agent (like Claude Code/Aider) that **pays its own way**. Slogan: **YOPO — "You Only Pay Outcome,"** provider cost +5%, settled per action in USDC. Every tool call shows its cost inline (`✓ Edit src/auth.ts $0.008`).
- Real x402 sign-and-pay loop in `src/payments/post-with-payment.ts` (gets 402 → signs USDC → retries).
- **Real swap tools** (verified in source): `src/tools/jupiter.ts` (Solana, Jupiter Ultra, 545 lines) and `src/tools/zerox-base.ts` (Base, 0x Permit2, 655 lines). Note: `src/trading/` is **paper-only**; the real swaps live in `src/tools/`.
- Also has `onramp/` (Coinbase Onramp), `phone/`, `social/` modules — much more than a code tool.
- **Closed-loop caveat:** "autonomous spending" today = mostly paying BlockRun's own gateway at cost +5%.

---

## DEMO 1 — Pay USDC for inference through ClawRouter

**Goal on screen:** an agent picks a model itself and pays per-request in USDC, no key, no card.

**Pre-stream (off camera):**
- `npx @blockrun/clawrouter@0.12.212` running on `:8402` (PIN THE VERSION — it shipped 2 days ago and auto-updates; installing cold on camera is the #1 risk).
- Fund the Base wallet ~$10 USDC (address prints on start; `/wallet` shows it). Use an Alchemy RPC, not public (per your global rules).
- Open a Basescan tab on the address. Do one warm-up paid request.

**On camera (3 min):**
1. **(20s)** `/wallet` → show address + USDC balance. *"This agent has its own money."*
2. **(40s)** The money shot — `curl -i` so the headers render live:
   ```bash
   curl -i -X POST http://localhost:8402/v1/chat/completions \
     -H "Content-Type: application/json" \
     -d '{"model":"blockrun/auto","messages":[{"role":"user","content":"Write a haiku about gas fees"}]}'
   ```
   Point at `x-clawrouter-model` + `x-clawrouter-tier` + `x-clawrouter-confidence`. *"Chose the model itself, sub-millisecond, locally."*
3. **(30s)** Narrate the x402 line: 402 → wallet signs USDC → retry → answer.
4. **(30s)** `/wallet` again → balance dropped; `/stats` → cost + savings. *(Optional)* flip to Basescan, refresh for the USDC transfer.
5. **(20s)** Close: `/model free` → same request, **$0**. *"And if you don't want to spend anything — 8 models, free forever."*

**Fallback if anything paid breaks:** the **free NVIDIA tier (`/model free`)** runs the entire routing demo with $0 and no chain dependency. Keep it in your pocket.
**Fragile bit:** the on-chain Basescan moment — no tx-hash surfacing is documented and settlement may batch. Treat it as *bonus if it works*, not the spine.

---

## DEMO 2 — Fund Franklin, watch it act on-chain (the jaw-dropper)

**Verified:** Franklin executes **real** swaps — `JupiterSwap` (Solana) signs with the real key and broadcasts; `Base0x` does quote → Permit2 → raw tx → BaseScan link. Not aspirational.

**Sequence (5 min, all real commands):**
1. `franklin setup base` → `franklin balance` (show address + USDC).
2. Give it a goal: *"Research the top 3 Solana memecoins by 24h volume, generate a thumbnail, write me a summary."* Viewer sees **each tool call itemized with its USDC cost**, the router picking cheap models, image-gen billed from the wallet.
3. `/cost` (session spend) + `/insights` — the "it spent its own money autonomously" beat.
4. **Swap finale:** *"Swap $2 of my USDC into SOL on Jupiter."* → quote line → **AskUser confirm panel** (amount, big-swap warning, `Live-swap session count: 1/10`) → click Confirm → signs locally, broadcasts → **Solscan link** (open it live).
5. `/wallet` → balance dropped, now holds SOL.

### ⚠️ Safety — this is a key-holding, bash-running agent on a streamed machine
- **Use a brand-new single-use wallet, funded $15–25**, nothing else ever touched the key. Discard after. Treat the whole balance as at-risk.
- **Run plain `franklin` — NEVER `--trust`** (`src/agent/permissions.ts:125` — trust mode auto-allows *everything*, skipping swap confirms and bash prompts). The confirm gate is good TV anyway.
- Set belt-and-suspenders: `--max-spend 5` (caps inference), `FRANKLIN_LIVE_SWAP_CAP=2`, `FRANKLIN_LIVE_SWAP_WARN_USD=3`.
- **Key gap to know:** `--max-spend` caps *inference only, NOT swap value*. Swaps cap the *count* (default 10/session) and only *warn* above $20 — **no hard USD ceiling on swap size.** The protection is the human Confirm gate. *Read the confirm panel's amount out loud before clicking.* You are the dollar ceiling the code doesn't enforce.
- **Do NOT feed it viewer-supplied text or URLs while funded** — no "paste this address from chat," no fetching chat links. That's the live prompt-injection vector (the source comment literally warns a steered model "could SUBSTITUTE the private key so future x402 spends sign from an attacker's key").
- Keys are stored **plaintext at rest** (`~/.blockrun/.session`, `.solana-session`). Structural risk you're accepting on a streamed box.
- Dry-run = the read-only quote tools (`JupiterQuote`, `Base0xQuote`) — price without signing. No swap testnet.
- **Skip Polymarket/franklin-bet live** — different repos, more setup. x402 spend loop + one Jupiter swap is the whole story.

---

## Question bank

### A. The two flagship products (concrete, source-grounded)
1. Your headline savings number is 92% in the README, 85% on npm, 63% in older versions. The model count says "41+" in the tagline and "55+" in the README. Which is real, and why does the number keep moving?
2. You score every request across "15 dimensions" in under a millisecond — but they're never listed anywhere. Name them. And is there *any* LLM fallback when the local scorer is unsure, or is it purely deterministic?
3. 388 npm versions in four and a half months — six releases in a single day on Jun 23. Healthy iteration or thrash? What's your test story for a tool that signs crypto transactions and auto-updates via `curl | bash`?
4. Franklin holds a plaintext private key on disk and runs arbitrary bash. Your commit log from *this week* is wall-to-wall security — "close the 16 guard bypasses," "wallet-key guard," "prompt-injection framing." How many of those holes were caught before vs. after someone could've lost funds? Has any real wallet been drained?
5. Franklin's `--max-spend` caps inference but **not swap size** — a single confirmed swap can move the whole balance. Is the only thing between an agent and a drained wallet a human clicking "Confirm"? What happens in `--trust` mode?

### B. Business / moat (the sharp ones)
6. Your +5% take rate is *identical* to OpenRouter's — and when Vercel shipped a zero-markup AI Gateway, OpenRouter zeroed out its first 1M requests within weeks. What stops your 5% going to zero the moment a bigger player treats routing as a loss-leader?
7. ClawRouter is two commodity halves stapled together — routing (OpenRouter, LiteLLM, Vercel) and payments (Coinbase's own **x402 Bazaar** already has an "Inference" category at *zero* fees). You're the stapler between two things both your giant neighbors are building natively. What's the one asset they can't copy?
8. You front the provider's bill and settle USDC *after* — that's extending unsecured credit to anonymous agents. What's your bad-debt exposure if a high-volume agent's wallet is empty at settlement? Ever eaten a bill an agent didn't pay?

### C. The hard technical question (routing quality)
9. "Cheapest *capable* model" means predicting capability before you run inference. Under-routing ships a downgraded answer the customer never sees; over-routing ("routing collapse" in the literature) just wastes their money. Which way is your router biased, and how would a customer ever *catch* you silently sending a hard prompt to a cheap model?
10. RouteLLM-style benchmarks are MT-Bench and MMLU — clean academic sets, not messy production traffic with no ground-truth label. How do you benchmark routing *honestly* live, and defend against classifier drift as the models under you change weekly?

### D. The standards bet & the topical landmine
11. x402 is the dumb settlement pipe; Google's AP2, Stripe's MPP, and Mastercard's Agent Pay are the layers deciding *which* pipe and *who's* authorized. You built on the pipe — the layer with zero pricing power. If the card networks treat all rails as interchangeable, doesn't x402 commoditize out from under you?
12. **(make-news question)** Artemis reported ~half of all x402 volume is wash trading, and CoinDesk quoted an analyst calling agent payments "mostly a mirage" — real volume around $28K/day. You claim 1M+ calls/month. How much of *your* volume is real production traffic vs. the testnet-farming and meme-coin churn inflating the whole ecosystem? Can you show the breakdown?

### E. Persona / fun (SLOP-flavored)
13. Your GitHub account `1bcMax` 404s right now. What happened there?
14. You ship ClawRouter and Franklin in 2026 — the year OpenClaw became the biggest AI-security story on record. Is the "Claw" branding a bet that the agent boom is real, or are you surfing the same hype the wash-traders are?
15. The $4,660.87 Anthropic bill origin story — walk us through that month. At what point did "I'll build a smart router" beat "I'll just use less Claude"?
16. The other side of you — "I gave my Instagram to Claude, 30M views," Clawdbot + Kling cranking out 550 videos a day. Serious business line, research project, or shitposting that happens to work?

---

## Sources
ClawRouter: github.com/BlockRunAI/ClawRouter, raw README, /releases, npm @blockrun/clawrouter, blockrun.ai/docs. Franklin: github.com/BlockRunAI/Franklin (v3.29.15 clone — src/tools/jupiter.ts, zerox-base.ts, payments/post-with-payment.ts, agent/permissions.ts, tools/sensitive-paths.ts). Context: github.com/BlockRunAI (org API), x.com/bc1beat, bankless.com "OpenClaw and the Body of the Agent Economy," docs.cdp.coinbase.com/x402, ERC-8004 (ethereum-magicians). Ecosystem: OpenRouter/Vercel AI Gateway (coplay.dev, truefoundry), x402 Bazaar (coinbase.com), routing-collapse (arxiv 2602.03478), x402 wash-trading (coindesk, startuphub.ai), wallet-drain incident (giskard.ai, oecd.ai).

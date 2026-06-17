# 00 — What is and isn't in the open-source release

> Upstream pinned: `xai-org/x-algorithm` @ `0bfc279` (2026-05-15)

**The single most important thing to understand before quoting anyone on "the X algorithm."**

## ✅ What the code DOES ship

- **The scoring architecture.** Candidates are sourced (in-network + out-of-network),
  scored by **Phoenix** (a Grok-based transformer that predicts engagement
  probabilities), then combined by a **Weighted Scorer**.
  Final score = Σ (weightᵢ × P(actionᵢ)). — `upstream/README.md:53,114,289`
- **The exact list of signals** that feed the weighted score, and their **sign**
  (positive vs negative). — `upstream/home-mixer/scorers/weighted_scorer.rs:48-67`
- **The structural prioritizations**, e.g. out-of-network posts are multiplied by a
  factor to favor in-network. — `upstream/home-mixer/scorers/oon_scorer.rs:7,24`
- **The pipeline stages**: sources, hydrators, filters, scorers, selectors, side-effects.
  — `upstream/home-mixer/` subdirs.

## ❌ What the code does NOT ship

- **The numeric weights.** Every weight is a runtime feature-switch:
  `params.get(ReplyWeight)`, `p::REPLY_WEIGHT`, etc. The defaults are **not in the repo.**
  — `upstream/home-mixer/scorers/ranking_scorer.rs:43-46`,
  `upstream/home-mixer/scorers/weighted_scorer.rs:49-67`
- **The trained Phoenix model weights** (the actual ML predictions). Only the
  architecture/training scaffolding is present (`upstream/phoenix/`, `upstream/grox/`).
- **Spam/abuse heuristics and many tuning constants** — these live behind the
  feature-switch system / model and are tuned server-side.

## ⚠️ Consequence: be skeptical of every number you read online

Blog posts circulating in 2026 ("a reply is worth **13.5**", "OP replying back is
worth **75**", "retweet = **20×** a like", "links get **−80%** reach") state these as if
they came from the new release. **They did not** — the new release contains no such
numbers. They are recycled from the **2023 Scala leak** (`twitter/the-algorithm`) and
should be treated as *historical, directional, and possibly stale*, not current fact.

**What we can still say with confidence** comes from structure + sign, not magnitude:

| Signal | In code? | Sign | Source |
|---|---|---|---|
| reply | yes | **+** | weighted_scorer.rs:50 |
| retweet | yes | **+** | weighted_scorer.rs:51 |
| favorite (like) | yes | **+** | weighted_scorer.rs:49 |
| profile click | yes | **+** | weighted_scorer.rs:54 |
| dwell / dwell time | yes | **+** | weighted_scorer.rs:59,62 |
| video quality view (vqv) | yes | **+** (gated on min duration) | weighted_scorer.rs:55,72-80 |
| share / share via DM / copy link | yes | **+** | weighted_scorer.rs:56-58 |
| quote / quoted click | yes | **+** | weighted_scorer.rs:60-61 |
| follow author | yes | **+** | weighted_scorer.rs:63 |
| not interested / block / mute / report | yes | **−** | weighted_scorer.rs:64-67 |
| out-of-network | yes | **× penalty factor** | oon_scorer.rs:24 |

So the *direction* of the popular advice (replies & conversation ≫ likes; negative
signals tank you; in-network beats out-of-network) is supported by the code. The
*specific multipliers* are not verifiable from it.

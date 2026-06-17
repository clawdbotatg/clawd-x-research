# Questions to answer from the code

Each answered question becomes a `findings/NN-*.md` citing `upstream/file:line`.

## Answered
- [x] What's actually in the open-source release vs not? → `findings/00`
- [x] What is the scoring formula and what signals feed it? → `findings/01`
- [x] Do links hurt reach, and how? → `findings/02`
- [x] How does scoring work end-to-end + the "formula for success"? → `findings/03`
- [x] What gets you in trouble (filters, safety, spam, slop)? → `findings/04`
- [x] **Emojis** — answered: no explicit emoji feature/penalty anywhere in code
      (grep for `emoji` is empty). Emergent only, via the banger/slop screen + engagement. → `findings/03`
- [x] **Timing / recency** — answered: no time-decay term in the score; recency is a hard
      gate (`age_filter.rs`). Timing matters only via early engagement velocity. → `findings/03`
- [x] **Author diversity** — `author_diversity_scorer.rs` decays repeated authors. → `findings/03`
- [x] **OON factor** — multiplier in `ranking_scorer.rs:265-275`; new users get a more
      generous factor (cold-start). Value is a runtime switch. → `findings/03`

## Open
- [ ] **Premium boost** — is there a verifiable subscription multiplier? `subscription_hydrator.rs`
      attaches status; need to find where (if anywhere) it multiplies score vs just gating.
- [ ] **What features does Phoenix see per post?** Map `upstream/phoenix/recsys_model.py` inputs.
- [ ] **VM ranker DPP** — how does the determinantal-point-process diversity re-rank work?
- [ ] **Diff across upstream releases** — re-run update script monthly, diff the structure.

## Original motivating questions (from the chat that started this)
- Best time to tweet? → timing/recency item above. (Hypothesis: minor; first-N-min
  engagement velocity dominates, which is an emergent property, not a constant.)
- Do links get downvoted? → `findings/02` (yes, emergently via dwell).
- Do emojis get downvoted? → emoji item above (hypothesis: no direct penalty).

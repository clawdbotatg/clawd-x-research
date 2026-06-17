# Questions to answer from the code

Each answered question becomes a `findings/NN-*.md` citing `upstream/file:line`.

## Answered
- [x] What's actually in the open-source release vs not? → `findings/00`
- [x] What is the scoring formula and what signals feed it? → `findings/01`
- [x] Do links hurt reach, and how? → `findings/02`

## Open
- [ ] **Emojis** — any tokenization/penalty signal? (likely none; emergent via engagement)
- [ ] **Timing / recency** — is there a time-decay term? Check `age_filter.rs`, recency in scorer.
- [ ] **OON factor** — how hard is out-of-network penalized? (`oon_scorer.rs` value is a switch)
- [ ] **Premium boost** — is there a verifiable subscription multiplier? Check
      `ineligible_subscription_filter.rs` and scorers.
- [ ] **Author diversity** — how does `author_diversity_scorer.rs` limit same-author spam?
- [ ] **Muted keywords / safety** — `muted_keyword_filter.rs`, `vf_filter.rs` behavior.
- [ ] **What features does Phoenix see per post?** Map `upstream/phoenix/` inputs.
- [ ] **Diff across upstream releases** — re-run update script monthly, diff the structure.

## Original motivating questions (from the chat that started this)
- Best time to tweet? → timing/recency item above. (Hypothesis: minor; first-N-min
  engagement velocity dominates, which is an emergent property, not a constant.)
- Do links get downvoted? → `findings/02` (yes, emergently via dwell).
- Do emojis get downvoted? → emoji item above (hypothesis: no direct penalty).

# 02 — Do links hurt your reach?

> Upstream pinned: `xai-org/x-algorithm` @ `0bfc279` (2026-05-15)

## Short answer

Directionally **yes**, but the mechanism is more subtle than the blogs claim, and there
is **no hardcoded "if post contains URL, subtract X%" rule in the open-source code.**

## What the code actually shows

- A `grep` of `upstream/` for `url` / `link` / `outbound` / `external` finds **no
  dedicated link-penalty scorer or filter.** There is no `LinkPenaltyScorer`.
- The real lever the code exposes is the **Phoenix model's predicted engagement
  probabilities** feeding the weighted score, plus **dwell** as an explicit positive
  signal (`dwell_score`, `dwell_time` — `weighted_scorer.rs:59,62`).

This matches Musk's own stated rationale: *"Our algorithm tries to optimize time spent
on X, so links don't get as much attention, because there is less time spent if people
click away."* In other words the penalty is **emergent**, not a rule:

> A link → users tap away → **dwell time drops** → the model predicts lower dwell/
> engagement → the weighted score is lower. The post isn't "flagged"; it just scores
> worse on the signals that are explicitly rewarded.

## What this means for the popular claims

- "Links get −80% reach" / "non-Premium link posts get ~zero engagement": **not
  verifiable from the code** — these are third-party measurements/estimates, not
  constants in the repo. Treat as directional, not gospel.
- The effect is **real but indirect**, and it scales with how much the link actually
  reduces dwell/engagement for *your* audience.

## Practical takeaway (unchanged, and consistent with the code)

- **Put the link in the first reply**, deliver the value (hook/thread/media) in the main
  post so it earns dwell + replies. The main post scores on the rewarded signals; the
  link rides underneath.
- **Native media keeps people in-app** → higher dwell → higher score. Lead with it.
- If link-clicks are the whole point and your audience is small/tight, in-body may still
  be worth the hit — but expect lower distribution.

## Open follow-ups

- Confirm whether Phoenix training data / features explicitly include a "has_link"
  feature (would make the penalty semi-explicit). Check `upstream/phoenix/` features.
- Quantify in-network vs OON factor (`oon_scorer.rs`) — see backlog.

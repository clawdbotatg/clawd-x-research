# 03 — How scoring works & the "formula for success"

> Upstream pinned: `xai-org/x-algorithm` @ `0bfc279` (2026-05-15)
> Primary source: `home-mixer/scorers/ranking_scorer.rs` (the real, full version)

## The actual pipeline (in order)

1. **Candidate sourcing** — in-network (people you follow) + out-of-network (everyone
   else), pulled by the sources in `home-mixer/sources/`.
2. **Hydration** — attach features: media, engagement counts, social-graph, subscription
   status, video duration, etc. (`home-mixer/candidate_hydrators/`).
3. **Filtering** — drop ineligible posts (see `04-what-gets-you-in-trouble.md` + the
   filter list below).
4. **Phoenix prediction** — a Grok-based transformer predicts the *probability* of each
   engagement action for this (viewer, post) pair (`scorers/phoenix_scorer.rs`,
   `phoenix/recsys_model.py`).
5. **Weighted combine** — multiply each predicted probability by its weight and sum
   (`ranking_scorer.rs:146-170`).
6. **Author-diversity decay** — repeated authors get exponentially down-weighted
   (`ranking_scorer.rs:186-217`).
7. **Out-of-network multiplier** — OON posts multiplied by a penalty factor
   (`ranking_scorer.rs:265-275`).
8. **(Optional) VM ranker** — a value-model + DPP diversity re-rank
   (`scorers/vm_ranker.rs`).
9. **Selection / blending** — top-K + blender + ad injection (`selectors/`, `ads/`).

## The formula (verbatim from `ranking_scorer.rs:146-170`)

```
weighted_score =
  Σ  weightᵢ × P(actionᵢ)          // Phoenix-predicted probabilities

positive actions  (ranking_scorer.rs:68-82):
  favorite, reply, retweet, photo_expand, click, profile_click,
  vqv (video quality view), share, share_via_dm, share_via_copy_link,
  dwell, quote, quoted_click, quoted_vqv, follow_author
continuous positives (163-164): dwell_time, click_dwell_time
negative actions  (83):
  not_interested, block_author, mute_author, report, not_dwelled

then:
  author_diversity decay  →  ×(1-floor)·decayᵖᵒˢⁱᵗⁱᵒⁿ + floor   (per repeated author)
  out-of-network          →  × OON_WEIGHT_FACTOR  (if not in your network)
```

The weights are runtime feature-switches — **the numbers are NOT in the repo**
(`ranking_scorer.rs:42-66`). See `00-what-is-and-isnt-in-the-code.md`. So we read the
*structure*, not magnitudes.

## What this means — the real "formula for success"

Ranked by what the code actually rewards:

1. **Provoke deep, two-way engagement.** reply, quote, share, profile-click, follow are
   all weighted positives and are "expensive" actions a viewer only takes if the post
   genuinely lands. Likes are in there too but a like is the cheapest signal. Write to
   get *replies and reposts*, not just taps.
2. **Win dwell time.** `dwell`, `dwell_time`, and `click_dwell_time` are explicit
   positives, and `not_dwelled` is an explicit **negative** (`ranking_scorer.rs:170`).
   Posts people scroll straight past are actively penalized. Make people *stop and read*:
   threads, a strong first line, readable formatting, native media.
3. **Native media beats links.** Video earns a `vqv` (video-quality-view) signal — but
   only past a minimum duration (`vqv_weight`, `MinVideoDurationMs`). Anything that sends
   people off-platform (a link) competes against dwell and earns nothing. See
   `02-links.md`.
4. **Don't trip the negatives.** not-interested / block / mute / report subtract directly,
   and `offset_score` (`ranking_scorer.rs:175-183`) means a net-negative post gets
   crushed. Bait that annoys people is worse than a post that's merely ignored.
5. **In-network is structurally favored.** OON posts are multiplied down
   (`OonWeightFactor`). Building a following that actually engages is a durable
   advantage. (New accounts get a *different*, more generous OON factor —
   `NEW_USER_OON_WEIGHT_FACTOR`, `ranking_scorer.rs:234-238` — a cold-start boost.)
6. **Don't flood — author diversity decays you.** Each *additional* post from the same
   author in one feed response is multiplied down exponentially
   (`ranking_scorer.rs:186-217`, `author_diversity_scorer.rs`). Posting 5 times in an
   hour cannibalizes your own reach within a single user's feed. Space it out.
7. **Freshness is a gate, not a curve.** There is **no time-decay term in the score**.
   Recency is enforced by `AgeFilter` (`filters/age_filter.rs`) — too old → removed
   entirely; fresh enough → competes purely on the engagement signals above. So "best
   time to post" matters only insofar as your audience is around to generate the early
   engagement that the score is built from. (Timing = minor; first-N-minutes engagement
   velocity = everything.)

## On the "Grok banger screen"

Before/around ranking, posts also get scored by a **vision-LLM "banger" classifier**
(`grox/classifiers/content/banger_initial_screen.py`) that emits a
`quality_score`, `tags`, a **`slop_score`** (graded 1/2/3 AI-slop rating —
`grox/tasks/task_pub.py:166-177`), and a `has_minor_score`. So "quality" isn't only
emergent from engagement — there's an explicit model judging whether your post is good
or slop. (The prompt text that defines "banger" vs "slop" is **not** shipped — it's
imported from `grox.prompts.template`, which isn't in the repo.)

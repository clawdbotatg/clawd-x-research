# 01 — The scoring formula & signals

> Upstream pinned: `xai-org/x-algorithm` @ `0bfc279` (2026-05-15)

## The formula (verbatim structure from the code)

`upstream/home-mixer/scorers/weighted_scorer.rs:48-67` computes:

```
combined_score =
    FAVORITE_WEIGHT          × P(favorite)
  + REPLY_WEIGHT             × P(reply)
  + RETWEET_WEIGHT           × P(retweet)
  + PHOTO_EXPAND_WEIGHT      × P(photo_expand)
  + CLICK_WEIGHT            × P(click)
  + PROFILE_CLICK_WEIGHT     × P(profile_click)
  + VQV_WEIGHT               × P(video_quality_view)   // only if video > MIN_VIDEO_DURATION_MS
  + SHARE_WEIGHT             × P(share)
  + SHARE_VIA_DM_WEIGHT      × P(share_via_dm)
  + SHARE_VIA_COPY_LINK_WEIGHT × P(share_via_copy_link)
  + DWELL_WEIGHT            × P(dwell)
  + QUOTE_WEIGHT            × P(quote)
  + QUOTED_CLICK_WEIGHT      × P(quoted_click)
  + CONT_DWELL_TIME_WEIGHT   × dwell_time
  + FOLLOW_AUTHOR_WEIGHT     × P(follow_author)
  + NOT_INTERESTED_WEIGHT    × P(not_interested)   // negative
  + BLOCK_AUTHOR_WEIGHT      × P(block_author)     // negative
  + MUTE_AUTHOR_WEIGHT       × P(mute_author)      // negative
  + REPORT_WEIGHT            × P(report)           // negative
```

Then `offset_score()` normalizes negatives (`weighted_scorer.rs:82-90`). Out-of-network
candidates are separately multiplied by `OON_WEIGHT_FACTOR` to favor in-network content
(`oon_scorer.rs:24`).

The `P(action)` values are predicted by **Phoenix**, a Grok-based transformer
(`README.md:53`). So the pipeline is: Phoenix predicts probabilities → weighted scorer
combines them → ranker/selector orders the feed.

## The weights themselves

**Not in the repo.** Each `*_WEIGHT` is a runtime feature-switch
(`ranking_scorer.rs:43-63` reads them via `params.get(...)`). See
`00-what-is-and-isnt-in-the-code.md`. Do not trust specific numbers from blogs.

## What you can actually act on (verified by sign, not magnitude)

1. **Conversation > everything cheap.** reply, quote, share, profile-click, follow are all
   positive and are "deeper" actions than a like — engineer posts to provoke them.
2. **Dwell is explicitly rewarded twice** (`dwell_score` + continuous `dwell_time`).
   Posts people *linger on* (threads, native media, readable text) win. Anything that
   makes people tap away (links) competes against this.
3. **Negative signals are real and direct** — not-interested / block / mute / report
   subtract. Bait that annoys people actively hurts you.
4. **Video has a quality bar** — VQV only counts past `MIN_VIDEO_DURATION_MS`
   (`weighted_scorer.rs:72-80`). Sub-threshold clips don't earn the video signal.
5. **In-network is structurally favored** over out-of-network (`oon_scorer.rs`). Building
   a real follower graph that engages still matters.

## Backlog

- Find/observe the OON factor value and VQV min duration (feature-switch dump, not in repo).
- Map Phoenix input features (`upstream/phoenix/`) to see what the model "sees" per post.

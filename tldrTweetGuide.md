# TL;DR Tweet Guide

A short, practical guide to writing high-performing posts on X — derived from reading the
**actual open-source algorithm** ([`xai-org/x-algorithm`](https://github.com/xai-org/x-algorithm),
the code powering the For You feed), not from blog speculation.

> **Drop-in note for other products:** this file is meant to be copied or fetched as a
> reference / system-prompt snippet. It's intentionally self-contained.

---

## The one thing to understand first

The algorithm scores a post by **summing predicted engagement signals**, each multiplied
by a weight:

```
score = Σ  weightᵢ × P(actionᵢ)
```

A Grok-based model predicts how likely *you* are to reply, repost, dwell, etc. on a post;
those probabilities are weighted and summed. **The exact weight numbers are NOT public**
(they're runtime config). So ignore anyone quoting "a reply = 13.5" — that's from a 2023
leak, not the current code. What *is* knowable is which signals count and their direction.

---

## ✅ What makes a post score HIGH

1. **Earn replies and reposts, not just likes.** Reply, repost, quote, share,
   profile-click, and follow are all positive signals — and they're "expensive" actions a
   viewer only takes when a post genuinely lands. A like is the cheapest signal. Write to
   start a conversation.
2. **Win dwell time.** Time-spent-reading is rewarded *and* "scrolled past without
   dwelling" is an explicit penalty. Make people stop: a strong first line, a thread,
   readable formatting, a reason to linger.
3. **Lead with native content.** Text/images/video that keep people in-app beat anything
   that sends them away. Video earns a bonus "quality view" signal (past a minimum watch
   duration).
4. **Nail the hook.** The first line decides whether anyone engages in the first ~30
   minutes — and early engagement velocity is what propels a post into more feeds.
5. **Build a real following.** In-network (your followers) is structurally favored over
   out-of-network. Followers who actually engage are a durable advantage. New accounts get
   a temporary cold-start boost into out-of-network feeds.

## ❌ What gets you suppressed

1. **Links in the post body.** There's no explicit "link penalty" rule — but a link makes
   people tap away, which kills dwell, which is exactly what the score rewards. Net effect:
   lower reach. **Put the link in the first reply** and keep the value in the main post.
2. **Posting too often.** Repeated posts from the same author in one feed are
   exponentially down-weighted (author-diversity decay). Posting 5× in an hour
   cannibalizes your own reach. Space it out.
3. **Slop.** A Grok vision model assigns posts a graded **slop score** (1–3). Generic,
   templated, mass-produced/AI-slop content is explicitly detected and down-ranked — not
   just ignored.
4. **Tripping safety policies.** Seven categories flag content: violent media, adult
   content, spam, illegal/regulated behavior, hate or abuse, violent speech, and
   suicide/self-harm.
5. **Spammy replies from small accounts.** There's a dedicated reply-spam screen that
   applies extra scrutiny to low-follower accounts. Replying to grow works — but only with
   substantive, on-topic replies.
6. **Bait that annoys.** Mute, block, "not interested," and report are direct negative
   signals that subtract from your score (and mutes/blocks remove you from that viewer
   entirely).

## 🤷 What does NOT matter (myths)

- **Emojis** — no penalty exists in the code. A few are fine; a wall of them just *reads*
  as spam to humans (and the slop model). Use as seasoning.
- **Exact post time** — there is **no time-decay term** in the score. Recency is a simple
  freshness gate (very old posts are dropped). Timing only matters because your audience
  has to be awake to create the early engagement the score is built on. Post when *your*
  people are online; don't obsess over a magic hour.
- **Specific weight numbers from blog posts** — not public. Treat any exact multiplier as
  unverified.

---

## The checklist

- [ ] Strong first line (the hook)?
- [ ] Gives a reason to **reply** or **repost**?
- [ ] Keeps people **in-app** (no body link; media if possible)?
- [ ] **Not** slop / generic / over-emoji'd?
- [ ] Link (if any) moved to the **first reply**?
- [ ] Not your 4th post this hour?
- [ ] Posted when your audience is actually online?

---

*Source: analysis of `xai-org/x-algorithm` @ commit pinned in this repo. Full,
line-cited findings live in [`findings/`](./findings). Corrections welcome — this tracks
the code, and xAI updates it ~monthly.*

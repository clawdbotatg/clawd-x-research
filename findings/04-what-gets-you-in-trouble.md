# 04 — What gets you in trouble (filters, safety, spam, slop)

> Upstream pinned: `xai-org/x-algorithm` @ `0bfc279` (2026-05-15)

Two separate ways to lose: **hard filters** (removed from the candidate set entirely) and
**classifier penalties** (Grok labels your post spam/unsafe/slop).

## 1. Hard filters — instant removal (`home-mixer/filters/`)

| Filter | Removes you if… | Source |
|---|---|---|
| `age_filter` | post is older than max_age (freshness gate) | age_filter.rs:17-21 |
| `author_socialgraph_filter` | viewer blocked/muted you, or you block them (also covers quoted/retweeted authors) | author_socialgraph_filter.rs:46-52 |
| `muted_keyword_filter` | your text matches a keyword the viewer muted | muted_keyword_filter.rs:46-51 |
| `dedup_conversation_filter` | a higher-scoring post from the same conversation already won | dedup_conversation_filter.rs:22-29 |
| `previously_seen/served_posts` | the viewer already saw it | filters/previously_*.rs |
| `self_tweet_filter` | you're the viewer (you don't see your own in For You) | self_tweet_filter.rs:16-17 |
| `ineligible_subscription_filter` | subscription-gated content the viewer can't see | filters/ineligible_subscription_filter.rs |

Most of these are viewer-specific (mutes/blocks/seen). The universal one you control is
**freshness** — stale posts are dropped.

## 2. Safety classifiers — Grok judges your content (`grox/classifiers/content/`)

X runs vision-LLM classifiers (Grok) over posts. The **policy taxonomy** that can flag
you (`grox/tasks/task_safety_ptos_policy.py:71-77`):

- `violent_media`
- `adult_content`  (sub-graded: `AdultContentSexualHard`, `AdultContentSexualSoft` —
  `task_write_safety_post_annotations_result_sink.py:79-93`)
- `spam`
- `illegal_and_regulated_behaviors`
- `hate_or_abuse`
- `violent_speech`
- `suicide_or_self_harm`

Hitting these gets your post annotated and down-ranked/restricted. (The exact policy
*prompt text* defining each category is imported from `grox.prompts.template`, which is
**not** shipped — only the category names are visible.)

## 3. The "slop" score — AI-slop detection

The banger screen emits a **`slop_score`** graded **1 / 2 / 3**
(`grox/tasks/task_pub.py:166-177`) plus a `quality_score` and `has_minor_score`
(`grox/classifiers/content/banger_initial_screen.py:30-39`). Low-effort / AI-generated
"slop" is explicitly detected and labeled. Translation: mass-produced, generic,
template-y content is a named, scored failure mode — not just "ignored."

## 4. Reply spam — extra scrutiny for small accounts

There's a dedicated **reply-spam** path (`SpamEapiLowFollowerClassifier`,
`grox/classifiers/content/spam.py`; pipeline in `task_filters.py` / `task_pub.py`). Key
facts from the code:

- It runs specifically on **replies** (`task_filters.py:55+`: skipped if the post is
  *not* a reply).
- It is **gated by a follower-count threshold** —
  `FOLLOWER_COUNT_THRESHOLD_FOR_SPAM_DETECTION` (`task_filters.py:56`). The constant is
  blanked in the open source (values not shipped), but the mechanism is explicit:
  **low-follower accounts replying get screened for spam.**

So the "reply under big accounts to grow" tactic is real but policed: spammy,
templated, or off-topic replies from small accounts are exactly what this classifier
targets. Make replies genuinely substantive.

## Bottom line — how to *not* get in trouble

- Don't post stale; don't repost dupes of an existing conversation.
- Stay clear of the 7 safety categories above (obvious, but it's a real model, not vibes).
- Don't produce **slop** — generic/AI-template content is explicitly scored against you.
- If you're a smaller account, **don't spam replies** — they get extra spam screening.
- Don't write mute-bait / block-bait — viewer mutes/blocks remove you and the negative
  signals (`block_author`, `mute_author`, `report`, `not_interested`) subtract from score.

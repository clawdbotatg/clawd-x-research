# clawd-x-research

Answering "how does the X algorithm *actually* work?" from the **source code**, not
from blogspam that recycles 2023 numbers and presents them as current.

X open-sourced the For You feed algorithm at
[`xai-org/x-algorithm`](https://github.com/xai-org/x-algorithm) (Apache-2.0, Rust+Python,
"Algorithm powering the For You feed on X"). xAI says they update it ~every 4 weeks.
The older 2023 Scala leak lives at
[`twitter/the-algorithm`](https://github.com/twitter/the-algorithm) and is useful for
historical comparison.

## Ground rules

1. **Every claim cites `upstream/<file>:<line>`.** If it's not in the code, we say so.
2. **Distinguish _structure_ from _values_.** The repo ships the scoring *formula* and the
   *list of signals* — it does **not** ship the numeric weights (they're runtime
   feature-switches). Any specific number ("reply = 13.5", "conversation = 75x") is NOT
   from this code. See `findings/00-what-is-and-isnt-in-the-code.md`.
3. **Pin the version.** Analyses reference the upstream commit recorded in
   `UPSTREAM_VERSION`. Re-run `scripts/update-upstream.sh` to refresh and diff.

## Layout

```
upstream/         vendored clone of xai-org/x-algorithm (gitignored; fetch via script)
UPSTREAM_VERSION  pinned commit SHA + date of the analyzed upstream
scripts/
  update-upstream.sh   (re)clone upstream and record the SHA
findings/         markdown answers, each citing upstream file:line
QUESTIONS.md      running backlog of questions to answer from the code
```

## Quick start

```bash
./scripts/update-upstream.sh     # pulls upstream into ./upstream, pins SHA
# then read findings/, or grep upstream/ yourself:
grep -rn REPLY_WEIGHT upstream/home-mixer
```

## Status

- [x] Verified upstream repo is real (HEAD pinned in `UPSTREAM_VERSION`)
- [x] Located the scoring formula (`home-mixer/scorers/weighted_scorer.rs`)
- [x] Established what is / isn't in the code (00)
- [x] Scoring signals + the "where are the numbers" question (01)
- [x] Links: what the code actually does vs. the blog narrative (02)
- [x] How scoring works end-to-end + the "formula for success" (03)
- [x] What gets you in trouble: filters, safety taxonomy, spam, slop (04)
- [x] Emojis, timing/recency, author-diversity, OON factor (folded into 03)
- [ ] Premium boost, Phoenix feature map, VM-ranker DPP (backlog)

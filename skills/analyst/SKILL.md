---
name: analyst
description: >-
  Computes circadian risk episodes and strain for NightClaw from ordered
  schedule blocks—rapid flip, short turnaround, low recovery, unsafe drive plus
  clustering and dedup. Use when interpreting risk output, tuning detectors, or
  explaining circadian_strain_score.
---

# NightClaw — Analyst (risk detection)

## Code layout

Paths are relative to the NightClaw repository root (e.g. `backend/`).

## Role

Analyst is the **risk engine**: given `List[ScheduleBlock]`, produce `RiskComputeResponse` with `circadian_strain_score`, `risk_episodes`, and a short summary string.

## Implementation map

| Concern | Location |
|--------|----------|
| Orchestration: detector order, cluster multiplier, overlap dedup, **strain score**, summary | `backend/app/risk_engine/engine.py` |
| Four detectors (functions in one module) | `backend/app/risk_engine/detectors.py` — `detect_rapid_flip`, `detect_short_turnaround`, `detect_low_recovery`, `detect_unsafe_drive` |
| HTTP glue: normalize commutes, call engine, persist episodes | `backend/app/routes/risks.py` |
| `RiskEpisode`, `RiskLabel`, `RiskComputeRequest`/`Response` | `backend/app/models/schemas.py` |

**Note:** All four detectors live in **`detectors.py`** (not four separate files). Treat each function as the source for its risk type.

## Strain score (authoritative)

From `RiskEngine._compute_strain_score`: average `severity_score` over up to **10** episodes, multiplied by `min(1.6, 1.0 + (n-1)*0.06)` for episode count, capped at **100**.

## Personalization hooks

- `risk_profile.sleep_minimum_hours` → low_recovery thresholding.
- `risk_profile.rapid_flip_sensitivity` (`high` / `normal` / `low`) → score multiplier on rapid_flip.

## Agent instructions

- Explain episodes using `label`, `severity_score`, `explanation.message`, and `suggested_interventions` keys—not invented clinical text.
- Clustering marks `cluster_flag` and bumps scores; dedup merges overlapping *different-label* episodes ≥50% overlap.

## Out of scope

Skip: auth, Supabase saves in explanations, JWT, rate limiting, FastAPI boilerplate.

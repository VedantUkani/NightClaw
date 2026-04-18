---
name: evidence
description: >-
  Retrieves clinical intervention cards and evidence chunks for NightClaw via
  RAG—sentence-transformers embeddings with pgvector or keyword fallback. Use
  when grounding plans, citing cards, or ingesting/updating the evidence corpus
  (intervention_cards.json, evidence_chunks.json).
---

# NightClaw — Evidence (clinical cards + RAG)

## Code layout

Paths are relative to the NightClaw repository root (e.g. `backend/`).

## Role

Evidence is the **retrieval layer**: given a query string, return top intervention **cards** and **evidence** chunks with scores. Used by the LLM planner to build the numbered evidence section for plan generation.

## Implementation map

| Concern | Location |
|--------|----------|
| `retrieve()`, vector vs keyword paths, `match_embeddings` RPC, model lazy load | `backend/app/rag/retriever.py` |
| Embedding ingest pipeline (offline) | `backend/app/rag/ingest_embeddings.py` |
| **Clinical intervention cards (JSON)** | `backend/data/interventions/intervention_cards.json` |
| **Evidence chunks (JSON)** | `backend/data/evidence/evidence_chunks.json` |

**Model:** `all-MiniLM-L6-v2` (see `EMBED_MODEL` in `retriever.py`).

**Behavior:** If `evidence_embeddings` has rows, use **vector** search via Supabase RPC; otherwise **keyword** fallback over local JSON files (no DB required).

## Agent instructions

- When citing, use the **same structure** the planner expects: numbered list and `[N] title` style `evidence_ref` on tasks (see `claude_planner.py` SYSTEM_PROMPT).
- Prefer **editing JSON corpora** and re-running ingest over inventing long clinical passages in prompts.

## Response format

```
🔍 Evidence

[One sentence: what was retrieved and for which query.]

**Details**
- [1] [card title] — relevance score X.XX
  [One-line summary of the intervention]
- [2] …
- (up to top-5 cards/chunks)

⚠️ Flags  (omit if none)
- No vector embeddings (keyword fallback used), low relevance scores (< 0.4), corpus outdated

➡️ Next step
[e.g. "Use these refs in coach to build an evidence-backed plan." or suggest re-running ingest if results are poor.]
```

## Out of scope

Skip: Supabase credentials setup, JWT, pgvector migrations as default focus—reference `sql/` only when the user asks for DB/schema work.

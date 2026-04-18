# NightClaw — Multi-Agent Architecture

NightClaw uses 6 OpenClaw agents, each with a dedicated role.

## Agent Roles

| Agent | Role | Data Source (Demo) | Future Integration |
|-------|------|-------------------|-------------------|
| **orchestrator** | Central router, assembles dashboards | All 3 JSON files | Coordinates all agents |
| **scout** | Fetch & present schedule data only | `mock_data/schedule.json` | Google Calendar, Kronos |
| **medic** | Fetch & present vitals data only | `mock_data/vitals.json` | Apple Watch, Fitbit, Oura |
| **analyst** | Risk analysis, web research, strain scoring | JSON + web_search | Real-time feeds |
| **coach** | Recovery plans from analyst output + web sources | JSON + web_search | DB-stored plans |
| **evidence** | Clinical citations, invoked by analyst & coach | evidence cards + web_search | Full RAG pipeline |

## Data Flow

```
User
  ↓
Orchestrator ──→ Scout (schedule data)
              ──→ Medic (vitals data)
              ──→ Analyst (risk scoring + web research) ←──→ Evidence
              ──→ Coach (recovery plan + web sources)   ←──→ Evidence
```

## Setup (OpenClaw)

Each agent needs its own workspace with a `SOUL.md`. See `agents/<name>/SOUL.md` for each agent's personality and instructions.

### Quick Setup

```bash
# Register all 6 agents
openclaw agents add nightclaw-orchestrator --workspace <path>/agents/orchestrator
openclaw agents add nightclaw-scout --workspace <path>/agents/scout
openclaw agents add nightclaw-medic --workspace <path>/agents/medic
openclaw agents add nightclaw-analyst --workspace <path>/agents/analyst
openclaw agents add nightclaw-coach --workspace <path>/agents/coach
openclaw agents add nightclaw-evidence --workspace <path>/agents/evidence

# Enable agent-to-agent communication (in openclaw.json)
# tools.agentToAgent.enabled = true
# tools.agentToAgent.allow = ["nightclaw-orchestrator", "nightclaw-scout", ...]

# Set web search provider to duckduckgo (in openclaw.json)
# tools.web.search.provider = "duckduckgo"
```

### Test

```bash
openclaw agent --agent nightclaw-orchestrator --message "Give me today's dashboard"
openclaw agent --agent nightclaw-scout --message "Get my schedule"
openclaw agent --agent nightclaw-medic --message "What are my vitals?"
openclaw agent --agent nightclaw-analyst --message "What's my strain level?"
openclaw agent --agent nightclaw-coach --message "Build me a recovery plan"
openclaw agent --agent nightclaw-evidence --message "Evidence on caffeine timing"
```

## Tools

Python scripts in `tools/` that agents call via OpenClaw's `exec` tool:

- `get_schedule.py` — returns schedule JSON (mock: `mock_data/schedule.json`)
- `get_vitals.py` — returns vitals JSON (mock: `mock_data/vitals.json`)
- `get_user_profile.py` — returns user profile JSON (mock: `mock_data/user_profile.json`)

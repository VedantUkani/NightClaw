import { notFound } from 'next/navigation'
import { resolveToken } from '@/lib/auth'
import sql from '@/lib/db'
import type { OutcomeMemory, PlanMode } from '@/lib/types'

// ─── Helpers ─────────────────────────────────────────────────────────────────

const MONTHS_SHORT = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

const MODE_BADGE: Record<string, string> = {
  protect:   'bg-red-900 text-red-300',
  recover:   'bg-orange-900 text-orange-300',
  stabilize: 'bg-yellow-900 text-yellow-300',
  perform:   'bg-green-900 text-green-300',
}

function fmtDate(iso: string): string {
  const str = typeof iso === 'string' ? iso : new Date(iso).toISOString()
  const [, mStr, dStr] = str.split('T')[0].split('-')
  return `${MONTHS_SHORT[parseInt(mStr, 10) - 1]} ${parseInt(dStr, 10)}`
}

function pct(rate: number | null): string {
  if (rate == null) return '—'
  return `${Math.round(rate * 100)}%`
}

// ─── Page ────────────────────────────────────────────────────────────────────

export default async function WeeklyPage({ params }: { params: Promise<{ token: string }> }) {
  const { token } = await params
  const user = await resolveToken(token)
  if (!user) notFound()

  const outcomes = await sql<OutcomeMemory[]>`
    SELECT id, to_char(date, 'YYYY-MM-DD') AS date, plan_mode, recovery_score,
           anchors_completed, anchors_total, anchor_completion_rate,
           to_char(recorded_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS recorded_at
    FROM public.outcome_memory
    WHERE user_id = ${user.id}
    ORDER BY date DESC
    LIMIT 14
  `.catch(e => { console.error('[weekly] error:', e.message); return [] })

  if (outcomes.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-24 text-center">
        <p className="text-zinc-300 font-medium">No recovery history yet</p>
        <p className="mt-2 text-sm text-zinc-500">
          OpenClaw logs your outcomes daily after your plans are complete.
        </p>
      </div>
    )
  }

  // Compute this-week summary from the last 7 entries
  const thisWeek  = outcomes.slice(0, 7)
  const lastWeek  = outcomes.slice(7, 14)

  const avgRecovery = (arr: OutcomeMemory[]) => {
    const valid = arr.filter(o => o.recovery_score != null)
    if (!valid.length) return null
    return valid.reduce((s, o) => s + Number(o.recovery_score), 0) / valid.length
  }

  const anchorRate = (arr: OutcomeMemory[]) => {
    const total = arr.reduce((s, o) => s + (o.anchors_total ?? 0), 0)
    const done  = arr.reduce((s, o) => s + (o.anchors_completed ?? 0), 0)
    return total > 0 ? done / total : null
  }

  const thisAvg    = avgRecovery(thisWeek)
  const lastAvg    = avgRecovery(lastWeek)
  const thisAnchor = anchorRate(thisWeek)
  const improvement = thisAvg != null && lastAvg != null ? thisAvg - lastAvg : null

  const newestDate = fmtDate(thisWeek[0].date)
  const oldestDate = fmtDate(thisWeek[thisWeek.length - 1].date)

  return (
    <div className="space-y-6">

      {/* Header */}
      <div>
        <p className="text-xs text-zinc-500 uppercase tracking-widest font-semibold">Weekly Update</p>
        <h1 className="mt-1 text-xl font-bold text-white">
          {oldestDate} – {newestDate}
        </h1>
      </div>

      {/* Stats row */}
      <div className="grid grid-cols-3 gap-3">
        <StatCard
          label="Anchor Rate"
          value={pct(thisAnchor)}
          sub="this week"
          color={thisAnchor == null ? 'text-zinc-400' : thisAnchor >= 0.7 ? 'text-green-400' : thisAnchor >= 0.4 ? 'text-yellow-400' : 'text-red-400'}
        />
        <StatCard
          label="Avg Recovery"
          value={thisAvg != null ? Math.round(thisAvg).toString() : '—'}
          sub="out of 100"
          color={thisAvg == null ? 'text-zinc-400' : thisAvg >= 65 ? 'text-green-400' : thisAvg >= 45 ? 'text-yellow-400' : 'text-orange-400'}
        />
        <StatCard
          label="vs Last Week"
          value={improvement != null ? (improvement >= 0 ? `+${improvement.toFixed(1)}` : improvement.toFixed(1)) : '—'}
          sub="recovery pts"
          color={improvement == null ? 'text-zinc-400' : improvement > 0 ? 'text-green-400' : improvement === 0 ? 'text-zinc-400' : 'text-red-400'}
        />
      </div>

      {/* Daily log */}
      <section>
        <p className="mb-3 text-xs font-semibold uppercase tracking-widest text-zinc-500">Daily Log</p>
        <div className="divide-y divide-zinc-800 rounded-xl border border-zinc-800 bg-zinc-900">
          {thisWeek.map(o => {
            const mode  = o.plan_mode as PlanMode | null
            const score = o.recovery_score != null ? Math.round(Number(o.recovery_score)) : null
            return (
              <div key={o.id} className="flex items-center justify-between px-4 py-3 gap-3">
                <div className="flex items-center gap-3">
                  <p className="text-sm text-zinc-300 w-16">{fmtDate(o.date)}</p>
                  {mode && (
                    <span className={`rounded px-2 py-0.5 text-xs ${MODE_BADGE[mode] ?? 'bg-zinc-800 text-zinc-400'}`}>
                      {mode}
                    </span>
                  )}
                </div>
                <div className="flex items-center gap-4 shrink-0">
                  <span className="text-xs text-zinc-500">
                    {o.anchors_completed}/{o.anchors_total} anchors
                  </span>
                  <span className={`text-sm font-semibold ${score == null ? 'text-zinc-600' : score >= 65 ? 'text-green-400' : score >= 45 ? 'text-yellow-400' : 'text-orange-400'}`}>
                    {score != null ? score : '—'}
                  </span>
                </div>
              </div>
            )
          })}
        </div>
      </section>

      {/* Previous week summary */}
      {lastWeek.length > 0 && (
        <section>
          <p className="mb-3 text-xs font-semibold uppercase tracking-widest text-zinc-500">Previous Week</p>
          <div className="rounded-xl border border-zinc-800 bg-zinc-900 px-4 py-3 flex items-center justify-between gap-4">
            <p className="text-sm text-zinc-400">
              {fmtDate(lastWeek[lastWeek.length - 1].date)} – {fmtDate(lastWeek[0].date)}
            </p>
            <div className="flex items-center gap-4 shrink-0">
              <span className="text-xs text-zinc-500">{pct(anchorRate(lastWeek))} anchors</span>
              <span className="text-sm text-zinc-300">
                {lastAvg != null ? Math.round(lastAvg) : '—'} avg recovery
              </span>
            </div>
          </div>
        </section>
      )}
    </div>
  )
}

// ─── Sub-components ──────────────────────────────────────────────────────────

function StatCard({ label, value, sub, color }: { label: string; value: string; sub: string; color: string }) {
  return (
    <div className="rounded-xl border border-zinc-800 bg-zinc-900 px-3 py-4 text-center">
      <p className="text-xs text-zinc-500">{label}</p>
      <p className={`mt-1 text-3xl font-bold leading-none ${color}`}>{value}</p>
      <p className="mt-1 text-xs text-zinc-600">{sub}</p>
    </div>
  )
}

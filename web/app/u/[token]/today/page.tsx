import { notFound } from 'next/navigation'
import { resolveToken } from '@/lib/auth'
import sql from '@/lib/db'
import type { Plan, PlanTask, PlanMode } from '@/lib/types'

interface ShiftBlock {
  id: string
  block_type: string
  title: string | null
  start_time: string
  end_time: string
  commute_before_minutes: number
  commute_after_minutes: number
}

// ─── Styles ────────────────────────────────────────────────────────────────

const MODE_STYLES: Record<PlanMode, { banner: string; badge: string; accent: string }> = {
  protect:   { banner: 'border-red-800 bg-red-950',       badge: 'bg-red-900 text-red-300',       accent: 'text-red-400' },
  recover:   { banner: 'border-orange-800 bg-orange-950', badge: 'bg-orange-900 text-orange-300', accent: 'text-orange-400' },
  stabilize: { banner: 'border-yellow-800 bg-yellow-950', badge: 'bg-yellow-900 text-yellow-300', accent: 'text-yellow-400' },
  perform:   { banner: 'border-green-800 bg-green-950',   badge: 'bg-green-900 text-green-300',   accent: 'text-green-400' },
}

const MODE_LABEL: Record<PlanMode, string> = {
  protect:   'Protect Mode',
  recover:   'Recover Mode',
  stabilize: 'Stabilize Mode',
  perform:   'Perform Mode',
}

const CAT_BADGE: Record<string, string> = {
  sleep:          'bg-indigo-900 text-indigo-300',
  nap:            'bg-purple-900 text-purple-300',
  light_timing:   'bg-yellow-900 text-yellow-300',
  caffeine_cutoff:'bg-amber-900 text-amber-300',
  meal:           'bg-green-900 text-green-300',
  movement:       'bg-blue-900 text-blue-300',
  mindfulness:    'bg-violet-900 text-violet-300',
  safety:         'bg-red-900 text-red-300',
  social:         'bg-pink-900 text-pink-300',
  relaxation:     'bg-teal-900 text-teal-300',
}

const STATUS_STYLE: Record<string, string> = {
  completed: 'text-green-400',
  skipped:   'text-zinc-500',
  expired:   'text-red-500',
  planned:   'text-zinc-200',
}

// ─── Helpers ────────────────────────────────────────────────────────────────

const MONTHS_LONG = ['January','February','March','April','May','June','July','August','September','October','November','December']
const DAYS_LONG   = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']

function fmt12h(iso: string): string {
  const m = iso.match(/[T ](\d{2}):(\d{2})/)
  if (!m) return iso
  const h = parseInt(m[1], 10), min = parseInt(m[2], 10)
  const ampm = h < 12 ? 'AM' : 'PM'
  const h12  = h === 0 ? 12 : h > 12 ? h - 12 : h
  return `${h12}:${min.toString().padStart(2, '0')} ${ampm}`
}

function todayLabel(): string {
  const d = new Date()
  return `${DAYS_LONG[d.getDay()]}, ${MONTHS_LONG[d.getMonth()]} ${d.getDate()}`
}

// ─── Sub-components ─────────────────────────────────────────────────────────

function TaskRow({ task }: { task: PlanTask }) {
  const catColor  = CAT_BADGE[task.category] ?? 'bg-zinc-800 text-zinc-400'
  const textStyle = STATUS_STYLE[task.status] ?? 'text-zinc-200'
  const faded     = task.status === 'skipped' || task.status === 'expired'

  return (
    <div className={`flex items-start gap-3 rounded-lg border border-zinc-800 bg-zinc-900 px-4 py-3 ${faded ? 'opacity-50' : ''}`}>
      <div className="w-16 shrink-0 text-right">
        <span className="text-xs text-zinc-500">{fmt12h(task.scheduled_time)}</span>
        {task.duration_minutes && (
          <p className="text-xs text-zinc-600">{task.duration_minutes}m</p>
        )}
      </div>

      <div className="min-w-0 flex-1">
        <div className="flex flex-wrap items-center gap-2">
          <span className={`text-sm font-medium ${textStyle} ${task.status === 'skipped' ? 'line-through' : ''}`}>
            {task.title}
          </span>
          {task.anchor_flag && (
            <span className="rounded bg-zinc-800 px-1.5 py-0.5 text-xs text-zinc-400">anchor</span>
          )}
          {task.status === 'completed' && (
            <span className="text-xs text-green-500">✓</span>
          )}
        </div>
        {task.description && (
          <p className="mt-0.5 text-xs text-zinc-500">{task.description}</p>
        )}
        {task.evidence_ref && (
          <p className="mt-0.5 text-xs text-zinc-600 italic">{task.evidence_ref}</p>
        )}
      </div>

      <span className={`shrink-0 rounded-full px-2 py-0.5 text-xs ${catColor}`}>
        {task.category.replace(/_/g, ' ')}
      </span>
    </div>
  )
}

function SectionLabel({ children }: { children: React.ReactNode }) {
  return (
    <p className="mb-3 text-xs font-semibold uppercase tracking-widest text-zinc-500">
      {children}
    </p>
  )
}

const SHIFT_LABEL: Record<string, { label: string; icon: string; color: string }> = {
  night_shift: { label: 'Night Shift', icon: '🌙', color: 'border-violet-800 bg-violet-950' },
  day_shift:   { label: 'Day Shift',   icon: '☀',  color: 'border-amber-800  bg-amber-950'  },
  evening_shift:{ label: 'Evening Shift', icon: '🌆', color: 'border-orange-800 bg-orange-950' },
}

function ShiftCard({ shift }: { shift: ShiftBlock }) {
  const meta   = SHIFT_LABEL[shift.block_type] ?? { label: shift.block_type.replace(/_/g, ' '), icon: '📋', color: 'border-zinc-700 bg-zinc-900' }
  const start  = fmt12h(shift.start_time)
  const end    = fmt12h(shift.end_time)

  // Duration in hours
  const startMs = new Date(shift.start_time).getTime()
  const endMs   = new Date(shift.end_time).getTime()
  const hrs     = Math.round((endMs - startMs) / 36e5 * 10) / 10

  return (
    <div className={`rounded-xl border p-4 ${meta.color}`}>
      <div className="flex items-center justify-between gap-3">
        <div className="flex items-center gap-3">
          <span className="text-2xl">{meta.icon}</span>
          <div>
            <p className="font-semibold text-white">{shift.title ?? meta.label}</p>
            <p className="text-sm text-zinc-400 mt-0.5">
              {start} – {end}
              <span className="ml-2 text-zinc-500">({hrs}h)</span>
            </p>
          </div>
        </div>
        {(shift.commute_before_minutes > 0 || shift.commute_after_minutes > 0) && (
          <div className="text-right shrink-0">
            <p className="text-xs text-zinc-500">Commute</p>
            <p className="text-sm text-zinc-300">
              {shift.commute_before_minutes}m before
            </p>
          </div>
        )}
      </div>
    </div>
  )
}

// ─── Page ───────────────────────────────────────────────────────────────────

export default async function TodayPage({ params }: { params: Promise<{ token: string }> }) {
  const { token } = await params
  const user = await resolveToken(token)
  if (!user) notFound()

  const today = new Date().toISOString().split('T')[0]

  const [plan] = await sql<Plan[]>`
    SELECT id, plan_mode,
           to_char(plan_start AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS plan_start,
           to_char(plan_end   AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS plan_end,
           circadian_strain_score, recovery_status_score,
           risk_summary, next_best_action
    FROM public.plans
    WHERE user_id = ${user.id}
      AND plan_start::date = ${today}::date
    ORDER BY created_at DESC
    LIMIT 1
  `.catch(e => { console.error('[today] plan error:', e.message); return [] })

  if (!plan) {
    return (
      <div className="flex flex-col items-center justify-center py-24 text-center">
        <p className="text-zinc-300 font-medium">No plan for today yet</p>
        <p className="mt-2 text-sm text-zinc-500">
          OpenClaw will generate your plan once your shifts are uploaded via Telegram.
        </p>
      </div>
    )
  }

  const [tasks, shifts] = await Promise.all([
    sql<PlanTask[]>`
      SELECT id, category, title, description,
             to_char(scheduled_time AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS scheduled_time,
             duration_minutes, anchor_flag, optional_flag, status, evidence_ref, sort_order
      FROM public.plan_tasks
      WHERE plan_id = ${plan.id}
      ORDER BY sort_order, scheduled_time
    `.catch(e => { console.error('[today] tasks error:', e.message); return [] }),

    sql<ShiftBlock[]>`
      SELECT id, block_type, title,
             to_char(start_time AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS start_time,
             to_char(end_time   AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS end_time,
             commute_before_minutes, commute_after_minutes
      FROM public.schedule_blocks
      WHERE user_id = ${user.id}
        AND start_time::date = ${today}::date
      ORDER BY start_time
    `.catch(e => { console.error('[today] shifts error:', e.message); return [] }),
  ])

  const mode   = (plan.plan_mode ?? 'stabilize') as PlanMode
  const colors = MODE_STYLES[mode]
  const nba    = plan.next_best_action
  const risk   = plan.risk_summary

  const anchors = tasks.filter(t => t.anchor_flag)
  const rest    = tasks.filter(t => !t.anchor_flag)

  return (
    <div className="space-y-5">

      {/* Mode banner */}
      <div className={`rounded-xl border p-5 ${colors.banner}`}>
        <div className="flex items-start justify-between gap-4">
          <div>
            <span className={`text-xs font-semibold uppercase tracking-widest ${colors.accent}`}>
              {MODE_LABEL[mode]}
            </span>
            <p className="mt-1 text-xl font-bold text-white">{todayLabel()}</p>
          </div>
          <div className="text-right shrink-0">
            <p className="text-xs text-zinc-400">Circadian Strain</p>
            <p className={`text-4xl font-bold leading-none ${colors.accent}`}>
              {Math.round(Number(plan.circadian_strain_score))}
            </p>
            <p className="text-xs text-zinc-500">/ 100</p>
          </div>
        </div>

        <div className="mt-4 h-1.5 w-full overflow-hidden rounded-full bg-zinc-800">
          <div
            className={`h-full rounded-full ${colors.accent.replace('text-', 'bg-')}`}
            style={{ width: `${Math.min(Number(plan.circadian_strain_score), 100)}%` }}
          />
        </div>

        {risk?.summary && (
          <p className="mt-3 text-sm leading-relaxed text-zinc-300">{risk.summary}</p>
        )}
      </div>

      {/* Today's shift(s) */}
      {shifts.length > 0 && (
        <section>
          <SectionLabel>Today&apos;s shift</SectionLabel>
          <div className="space-y-2">
            {shifts.map(s => <ShiftCard key={s.id} shift={s} />)}
          </div>
        </section>
      )}

      {/* Next Best Action */}
      {nba && (
        <div className="rounded-xl border border-blue-800 bg-blue-950 p-5">
          <p className="mb-2 text-xs font-semibold uppercase tracking-widest text-blue-400">
            Next Best Action
          </p>
          <p className="text-lg font-semibold text-white">{nba.title}</p>
          {nba.description && (
            <p className="mt-1 text-sm text-zinc-300">{nba.description}</p>
          )}
          {nba.why_now && (
            <p className="mt-2 text-xs italic text-blue-400">↳ {nba.why_now}</p>
          )}
          {nba.duration_minutes > 0 && (
            <p className="mt-1 text-xs text-zinc-500">{nba.duration_minutes} min</p>
          )}
        </div>
      )}

      {/* Anchor tasks */}
      {anchors.length > 0 && (
        <section>
          <SectionLabel>Critical — must do</SectionLabel>
          <div className="space-y-2">
            {anchors.map(t => <TaskRow key={t.id} task={t} />)}
          </div>
        </section>
      )}

      {/* Remaining tasks */}
      {rest.length > 0 && (
        <section>
          <SectionLabel>Today&apos;s plan</SectionLabel>
          <div className="space-y-2">
            {rest.map(t => <TaskRow key={t.id} task={t} />)}
          </div>
        </section>
      )}
    </div>
  )
}

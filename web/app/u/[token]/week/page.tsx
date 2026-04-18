import Link from 'next/link'
import { notFound } from 'next/navigation'
import { resolveToken } from '@/lib/auth'
import sql from '@/lib/db'
import type { Plan, PlanTask, PlanMode } from '@/lib/types'

// ─── Styles ─────────────────────────────────────────────────────────────────

const MODE_BADGE: Record<PlanMode, string> = {
  protect:   'bg-red-900 text-red-300',
  recover:   'bg-orange-900 text-orange-300',
  stabilize: 'bg-yellow-900 text-yellow-300',
  perform:   'bg-green-900 text-green-300',
}

const MODE_BAR: Record<PlanMode, string> = {
  protect:   'bg-red-500',
  recover:   'bg-orange-500',
  stabilize: 'bg-yellow-500',
  perform:   'bg-green-500',
}

const CAT_DOT: Record<string, string> = {
  sleep:          'bg-indigo-400',
  nap:            'bg-purple-400',
  light_timing:   'bg-yellow-400',
  caffeine_cutoff:'bg-amber-400',
  meal:           'bg-green-400',
  movement:       'bg-blue-400',
  mindfulness:    'bg-violet-400',
  safety:         'bg-red-400',
  social:         'bg-pink-400',
  relaxation:     'bg-teal-400',
}

// ─── Date helpers ────────────────────────────────────────────────────────────

const MONTHS_SHORT = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
const MONTHS_LONG  = ['January','February','March','April','May','June','July','August','September','October','November','December']
const DAYS_LONG    = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']

function getWeekMonday(ref: Date): Date {
  const d = new Date(ref)
  const day = d.getDay()
  d.setDate(d.getDate() - (day === 0 ? 6 : day - 1))
  d.setHours(0, 0, 0, 0)
  return d
}

function addDays(d: Date, n: number): Date {
  const r = new Date(d)
  r.setDate(r.getDate() + n)
  return r
}

function toISO(d: Date): string {
  return d.toISOString().split('T')[0]
}

function fmt12h(iso: string): string {
  const m = iso.match(/[T ](\d{2}):(\d{2})/)
  if (!m) return iso
  const h = parseInt(m[1], 10), min = parseInt(m[2], 10)
  const ampm = h < 12 ? 'AM' : 'PM'
  const h12  = h === 0 ? 12 : h > 12 ? h - 12 : h
  return `${h12}:${min.toString().padStart(2, '0')} ${ampm}`
}

function fmtShort(isoDate: string): string {
  const [, mStr, dStr] = isoDate.split('-')
  return `${MONTHS_SHORT[parseInt(mStr, 10) - 1]} ${parseInt(dStr, 10)}`
}

function fmtLong(isoDate: string): string {
  const d = new Date(isoDate + 'T12:00:00')
  return `${DAYS_LONG[d.getDay()]}, ${MONTHS_LONG[d.getMonth()]} ${d.getDate()}`
}

// ─── Page ────────────────────────────────────────────────────────────────────

export default async function WeekPage({
  params,
  searchParams,
}: {
  params: Promise<{ token: string }>
  searchParams: Promise<{ w?: string; d?: string }>
}) {
  const { token } = await params
  const { w, d } = await searchParams

  const user = await resolveToken(token)
  if (!user) notFound()

  const today = toISO(new Date())

  const weekMonday  = w ? getWeekMonday(new Date(w + 'T00:00:00')) : getWeekMonday(new Date())
  const weekDays    = Array.from({ length: 7 }, (_, i) => toISO(addDays(weekMonday, i)))
  const weekEnd     = weekDays[6]
  const prevMonday  = toISO(addDays(weekMonday, -7))
  const nextMonday  = toISO(addDays(weekMonday, 7))
  const selectedDate = weekDays.includes(d ?? '') ? d! : today

  const rows = await sql<Plan[]>`
    SELECT id, plan_mode,
           to_char(plan_start AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS plan_start,
           to_char(plan_end   AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS plan_end,
           circadian_strain_score, recovery_status_score, risk_summary
    FROM public.plans
    WHERE user_id = ${user.id}
      AND plan_start::date >= ${weekDays[0]}::date
      AND plan_start::date <= ${weekEnd}::date
    ORDER BY plan_start
  `.catch(e => { console.error('[week] plans error:', e.message); return [] })

  const planIds = rows.map(r => r.id)
  const allTasks = planIds.length
    ? await sql<PlanTask[]>`
        SELECT id, plan_id, category, title, description,
               to_char(scheduled_time AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS') AS scheduled_time,
               duration_minutes, anchor_flag, status, sort_order
        FROM public.plan_tasks
        WHERE plan_id = ANY(${planIds})
      `.catch(e => { console.error('[week] tasks error:', e.message); return [] })
    : []

  const tasksByPlan = new Map<string, PlanTask[]>()
  for (const t of allTasks) {
    const bucket = tasksByPlan.get(t.plan_id) ?? []
    bucket.push(t)
    tasksByPlan.set(t.plan_id, bucket)
  }

  // One plan per day (latest if multiple)
  const dayMap = new Map<string, Plan>()
  for (const row of rows) {
    const date = row.plan_start.split('T')[0]
    const full = { ...row, tasks: tasksByPlan.get(row.id) ?? [] }
    if (!dayMap.has(date)) dayMap.set(date, full)
  }

  const weekLabel      = `${fmtShort(weekDays[0])} – ${fmtShort(weekEnd)}`
  const selectedPlan   = dayMap.get(selectedDate) ?? null

  return (
    <div className="space-y-6">

      {/* Week navigation */}
      <div className="flex items-center justify-between">
        <Link
          href={`/u/${token}/week?w=${prevMonday}`}
          className="rounded-lg border border-zinc-800 bg-zinc-900 px-3 py-1.5 text-sm text-zinc-400 hover:text-white transition"
        >
          ← Prev
        </Link>
        <p className="text-sm font-medium text-zinc-300">{weekLabel}</p>
        <Link
          href={`/u/${token}/week?w=${nextMonday}`}
          className="rounded-lg border border-zinc-800 bg-zinc-900 px-3 py-1.5 text-sm text-zinc-400 hover:text-white transition"
        >
          Next →
        </Link>
      </div>

      {/* 7-day grid */}
      <div className="grid grid-cols-7 gap-1.5">
        {weekDays.map((date, i) => {
          const plan     = dayMap.get(date)
          const mode     = plan?.plan_mode as PlanMode | undefined
          const isToday  = date === today
          const isSel    = date === selectedDate

          return (
            <Link
              key={date}
              href={`/u/${token}/week?w=${toISO(weekMonday)}&d=${date}`}
              className={`flex flex-col items-center rounded-lg border px-1 py-2 transition
                ${isSel
                  ? 'border-blue-600 bg-blue-950'
                  : isToday
                    ? 'border-zinc-600 bg-zinc-800'
                    : 'border-zinc-800 bg-zinc-900 hover:border-zinc-700'}`}
            >
              <span className={`text-xs font-semibold ${isToday ? 'text-white' : 'text-zinc-500'}`}>
                {['MON','TUE','WED','THU','FRI','SAT','SUN'][i]}
              </span>
              <span className={`text-base font-bold mt-0.5 ${isToday ? 'text-white' : 'text-zinc-300'}`}>
                {new Date(date + 'T12:00:00').getDate()}
              </span>

              {mode ? (
                <>
                  <span className={`mt-1.5 rounded px-1 py-0.5 text-xs ${MODE_BADGE[mode]}`}>
                    {mode.slice(0, 4)}
                  </span>
                  <div className="mt-1.5 w-full px-1">
                    <div className="h-1 w-full overflow-hidden rounded-full bg-zinc-800">
                      <div
                        className={`h-full rounded-full ${MODE_BAR[mode]}`}
                        style={{ width: `${Math.min(Number(plan!.circadian_strain_score), 100)}%` }}
                      />
                    </div>
                    <p className="mt-0.5 text-center text-xs text-zinc-600">
                      {Math.round(Number(plan!.circadian_strain_score))}
                    </p>
                  </div>
                  <p className="mt-1 text-xs text-zinc-600">
                    {plan!.tasks?.length ?? 0} tasks
                  </p>
                </>
              ) : (
                <span className="mt-2 text-xs text-zinc-700">—</span>
              )}
            </Link>
          )
        })}
      </div>

      {/* Selected day detail */}
      {selectedPlan ? (
        <DayDetail plan={selectedPlan} date={selectedDate} today={today} />
      ) : (
        <div className="rounded-xl border border-zinc-800 bg-zinc-900 p-6 text-center">
          <p className="text-zinc-400">
            {selectedDate === today
              ? 'No plan generated for today yet.'
              : `No plan for ${fmtShort(selectedDate)}.`}
          </p>
          <p className="mt-1 text-xs text-zinc-600">
            OpenClaw generates plans after your shifts are uploaded.
          </p>
        </div>
      )}
    </div>
  )
}

// ─── Day Detail Panel ────────────────────────────────────────────────────────

function DayDetail({ plan, date, today }: { plan: Plan; date: string; today: string }) {
  const mode    = (plan.plan_mode ?? 'stabilize') as PlanMode
  const isToday = date === today

  const tasks = [...(plan.tasks ?? [])].sort(
    (a, b) => a.sort_order - b.sort_order || new Date(a.scheduled_time).getTime() - new Date(b.scheduled_time).getTime()
  )

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h2 className="font-semibold text-white">{isToday ? 'Today' : fmtLong(date)}</h2>
        <span className={`rounded-full px-2.5 py-1 text-xs font-medium ${MODE_BADGE[mode]}`}>
          {mode}
        </span>
      </div>

      {plan.risk_summary?.summary && (
        <p className="text-sm text-zinc-400 leading-relaxed">{plan.risk_summary.summary}</p>
      )}

      {tasks.length > 0 && (
        <div className="space-y-2">
          {tasks.map(task => {
            const dot   = CAT_DOT[task.category] ?? 'bg-zinc-500'
            const faded = task.status === 'skipped' || task.status === 'expired'
            return (
              <div
                key={task.id}
                className={`flex items-start gap-3 rounded-lg border border-zinc-800 bg-zinc-900 px-4 py-3 ${faded ? 'opacity-50' : ''}`}
              >
                <div className="mt-1.5">
                  <div className={`h-2 w-2 rounded-full ${dot}`} />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex flex-wrap items-center gap-2">
                    <span className={`text-sm font-medium ${task.status === 'completed' ? 'text-green-400' : task.status === 'skipped' ? 'text-zinc-500 line-through' : 'text-zinc-200'}`}>
                      {task.title}
                    </span>
                    {task.anchor_flag && (
                      <span className="rounded bg-zinc-800 px-1.5 py-0.5 text-xs text-zinc-400">anchor</span>
                    )}
                  </div>
                  {task.description && (
                    <p className="mt-0.5 text-xs text-zinc-500">{task.description}</p>
                  )}
                </div>
                <div className="text-right shrink-0">
                  <p className="text-xs text-zinc-500">{fmt12h(task.scheduled_time)}</p>
                  {task.duration_minutes && (
                    <p className="text-xs text-zinc-700">{task.duration_minutes}m</p>
                  )}
                </div>
              </div>
            )
          })}
        </div>
      )}
    </div>
  )
}

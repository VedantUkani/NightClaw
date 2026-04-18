export type PlanMode = 'protect' | 'recover' | 'stabilize' | 'perform'

export type TaskCategory =
  | 'sleep' | 'nap' | 'light_timing' | 'caffeine_cutoff' | 'meal'
  | 'movement' | 'mindfulness' | 'safety' | 'social' | 'relaxation'

export type TaskStatus = 'planned' | 'completed' | 'skipped' | 'expired'

export type RecoveryTrend = 'improving' | 'steady' | 'declining' | 'insufficient_data'

export interface ResolvedUser {
  id: string
  name: string
  role: string
  timezone: string
}

export interface RiskSummary {
  summary: string
  episodes: number
  plan_hours: number
  circadian_strain_score: number
}

export interface NextBestAction {
  title: string
  task_id?: string
  why_now: string
  category?: string
  description: string
  duration_minutes: number
}

export interface Plan {
  id: string
  user_id: string
  plan_mode: PlanMode
  plan_start: string
  plan_end: string
  circadian_strain_score: number
  recovery_status_score: number
  risk_summary: RiskSummary | null
  next_best_action: NextBestAction | null
  is_active: boolean
  created_at: string
  // populated client-side from plan_tasks query
  tasks?: PlanTask[]
}

export interface PlanTask {
  id: string
  plan_id: string
  user_id: string
  category: TaskCategory
  title: string
  description: string | null
  scheduled_time: string
  duration_minutes: number | null
  anchor_flag: boolean
  optional_flag: boolean
  source_reason: string | null
  evidence_ref: string | null
  status: TaskStatus
  sort_order: number
}

export interface OutcomeMemory {
  id: string
  user_id: string
  date: string
  plan_mode: PlanMode | null
  recovery_score: number | null
  anchors_completed: number
  anchors_total: number
  anchor_completion_rate: number | null
  recorded_at: string
}

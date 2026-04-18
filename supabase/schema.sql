-- ============================================================
-- NightClaw — Supabase Schema
-- Paste this entire file into Supabase SQL Editor and run it.
-- OpenClaw uses the service_role key to write all data.
-- The web dashboard uses service_role in Next.js API routes
-- (never exposed to the browser) and looks up users by view_token.
-- ============================================================

-- UUID extension (already enabled in Supabase by default)
create extension if not exists "uuid-ossp";


-- ============================================================
-- TABLE 1: users
-- Created by the Telegram bot when a user registers.
-- view_token is the UUID embedded in the personal web link.
-- ============================================================
create table public.users (
  id                    uuid primary key default gen_random_uuid(),
  telegram_user_id      text unique not null,
  view_token            uuid unique not null default gen_random_uuid(),
  view_token_expires_at timestamptz not null default (now() + interval '30 days'),
  name                  text not null,
  role                  text not null default 'nurse',        -- nurse | paramedic | factory_worker | resident | other
  commute_minutes       integer not null default 30,
  timezone              text not null default 'UTC',
  chronotype            text not null default 'neutral',     -- early_bird | neutral | night_owl
  medications           text[] not null default '{}',
  medical_conditions    text[] not null default '{}',
  smartwatch_connected  boolean not null default false,
  google_cal_connected  boolean not null default false,
  created_at            timestamptz not null default now()
);

comment on column public.users.view_token is
  'Unique token embedded in the web dashboard URL. '
  'Send user: https://yourapp.com/u/<view_token>';
comment on column public.users.view_token_expires_at is
  'MVP: 30-day expiry. Telegram bot regenerates on request.';


-- ============================================================
-- TABLE 2: user_shifts
-- Raw shift blocks uploaded via Excel or synced from Google Cal.
-- OpenClaw reads these as input for schedule generation.
-- ============================================================
create table public.user_shifts (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.users(id) on delete cascade,
  shift_type  text not null,       -- day_shift | night_shift | evening_shift | off_day | transition_day
  title       text,                -- e.g. "ICU Night", "ER Day"
  start_time  timestamptz not null,
  end_time    timestamptz not null,
  source      text not null default 'manual',  -- excel | google_cal | manual
  created_at  timestamptz not null default now()
);

create index idx_user_shifts_user_date on public.user_shifts(user_id, start_time);


-- ============================================================
-- TABLE 3: generated_schedule
-- OpenClaw writes one row per user per day after generation.
-- This is the top-level container for each day's plan.
-- ============================================================
create table public.generated_schedule (
  id                     uuid primary key default gen_random_uuid(),
  user_id                uuid not null references public.users(id) on delete cascade,
  schedule_date          date not null,
  plan_mode              text not null default 'stabilize',
    -- protect (severe strain) | recover | stabilize | perform (low risk)
  circadian_strain_score numeric(5,2) not null default 0
    check (circadian_strain_score between 0 and 100),
  recovery_status_score  numeric(5,2) not null default 0
    check (recovery_status_score between 0 and 100),
  avoid_list             text[] not null default '{}',
    -- e.g. ["Drive during 3–7 AM", "Caffeine after 3 PM"]
  next_best_action       jsonb,
    -- { title, description, why_now, duration_minutes }
  day_summary            text,    -- short narrative OpenClaw writes for the day
  generated_at           timestamptz not null default now(),

  unique (user_id, schedule_date)
);

create index idx_generated_schedule_user_date
  on public.generated_schedule(user_id, schedule_date);


-- ============================================================
-- TABLE 4: schedule_tasks
-- Individual tasks within a generated day.
-- OpenClaw writes these alongside generated_schedule rows.
-- status is updated by OpenClaw when user taps done/skip in Telegram.
-- ============================================================
create table public.schedule_tasks (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.users(id) on delete cascade,
  schedule_id    uuid not null references public.generated_schedule(id) on delete cascade,
  schedule_date  date not null,
  category       text not null,
    -- sleep | nap | light_timing | caffeine_cutoff | meal
    -- movement | mindfulness | safety | social | relaxation
  title          text not null,
  description    text,
  scheduled_time timestamptz not null,
  duration_min   integer,
  is_anchor      boolean not null default false,  -- true = critical, must-do
  is_optional    boolean not null default false,
  status         text not null default 'planned',
    -- planned | completed | skipped | expired
  evidence_ref   text,   -- e.g. "[1] Night shift sleep study"
  sort_order     integer not null default 0,
  created_at     timestamptz not null default now()
);

create index idx_schedule_tasks_user_date
  on public.schedule_tasks(user_id, schedule_date);
create index idx_schedule_tasks_schedule
  on public.schedule_tasks(schedule_id);


-- ============================================================
-- TABLE 5: task_events
-- Written by OpenClaw each time a user taps done/not-done
-- in the Telegram bot. Used to compute weekly reports.
-- Multiple events can exist per task (e.g. marked done, then undone).
-- The latest event per task is the authoritative status.
-- ============================================================
create table public.task_events (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.users(id) on delete cascade,
  task_id     uuid not null references public.schedule_tasks(id) on delete cascade,
  status      text not null,   -- completed | skipped | expired
  notes       text,
  recorded_at timestamptz not null default now()
);

create index idx_task_events_user_time
  on public.task_events(user_id, recorded_at desc);
create index idx_task_events_task
  on public.task_events(task_id);


-- ============================================================
-- TABLE 6: weekly_summary
-- OpenClaw writes one row per user per week (end of week).
-- The "Weekly Update" web page reads exclusively from this table.
-- ============================================================
create table public.weekly_summary (
  id                     uuid primary key default gen_random_uuid(),
  user_id                uuid not null references public.users(id) on delete cascade,
  week_start             date not null,   -- Monday
  week_end               date not null,   -- Sunday
  tasks_completed        integer not null default 0,
  tasks_skipped          integer not null default 0,
  tasks_expired          integer not null default 0,
  anchor_tasks_completed integer not null default 0,
  anchor_tasks_total     integer not null default 0,
  anchor_completion_rate numeric(5,4) not null default 0,
    -- 0.0000 to 1.0000  e.g. 0.7143 = 71.43%
  avg_recovery_score     numeric(5,2) not null default 0,
    -- 0–100 from wearable data
  circadian_strain_avg   numeric(5,2) not null default 0,
    -- average strain score for the week
  recovery_trend         text not null default 'insufficient_data',
    -- improving | steady | declining | insufficient_data
  improvement_pct        numeric(6,2) not null default 0,
    -- % change vs previous week, negative = declined
  highlights             text[] not null default '{}',
    -- e.g. ["Maintained sleep anchor 5/7 days", "Zero caffeine violations"]
  suggestions            text[] not null default '{}',
    -- e.g. ["Try avoiding caffeine after 2 PM", "Add a 20-min nap on night shift days"]
  anomaly_flag           text,
    -- sharp_drop | zero_anchors | streak_broken | null
  narrative              text,
    -- full paragraph OpenClaw writes summarising the week
  created_at             timestamptz not null default now(),

  unique (user_id, week_start)
);

create index idx_weekly_summary_user_week
  on public.weekly_summary(user_id, week_start desc);


-- ============================================================
-- ROW LEVEL SECURITY
-- RLS is enabled on all tables.
-- OpenClaw uses the service_role key which bypasses RLS entirely.
-- The Next.js web app also uses service_role on the server side
-- (API routes only — never in browser/client code).
-- No anon/public read policies are needed because all reads
-- go through server-side Next.js API routes that validate the
-- view_token before querying.
-- ============================================================
alter table public.users            enable row level security;
alter table public.user_shifts      enable row level security;
alter table public.generated_schedule enable row level security;
alter table public.schedule_tasks   enable row level security;
alter table public.task_events      enable row level security;
alter table public.weekly_summary   enable row level security;


-- ============================================================
-- HELPER FUNCTION: get_user_by_token
-- Used in Next.js API routes to resolve a view_token to a user.
-- Returns null if token not found or expired.
-- ============================================================
create or replace function public.get_user_by_token(token uuid)
returns table (
  id                   uuid,
  name                 text,
  role                 text,
  timezone             text,
  smartwatch_connected boolean,
  google_cal_connected boolean
)
language sql
security definer
stable
as $$
  select
    id,
    name,
    role,
    timezone,
    smartwatch_connected,
    google_cal_connected
  from public.users
  where view_token = token
    and view_token_expires_at > now()
  limit 1;
$$;

comment on function public.get_user_by_token is
  'Resolves a view_token from the URL to the user row. '
  'Call this first in every Next.js API route before fetching user data.';

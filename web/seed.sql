-- NightClaw test seed
-- Paste this entire file into Supabase SQL Editor and click Run.

-- ── Clean up any previous test run ──────────────────────────────────────────
delete from public.users where telegram_user_id = 'test_sarah_001';

-- ── User ─────────────────────────────────────────────────────────────────────
insert into public.users (
  id, telegram_user_id, view_token, view_token_expires_at,
  name, role, commute_minutes, timezone, chronotype,
  medications, medical_conditions, smartwatch_connected, google_cal_connected
) values (
  '11111111-1111-1111-1111-111111111111',
  'test_sarah_001',
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
  '2026-07-18 00:00:00+00',
  'Sarah Mitchell', 'nurse', 25, 'America/Phoenix', 'neutral',
  array['Melatonin 5mg', 'Vitamin D3'],
  array['shift_work_disorder'],
  true, false
);

-- ── Shifts ────────────────────────────────────────────────────────────────────
insert into public.user_shifts (user_id, shift_type, title, start_time, end_time, source) values
  ('11111111-1111-1111-1111-111111111111', 'night_shift', 'ICU Night', '2026-04-13 19:00:00', '2026-04-14 07:00:00', 'excel'),
  ('11111111-1111-1111-1111-111111111111', 'day_shift',   'ICU Day',   '2026-04-15 07:00:00', '2026-04-15 19:30:00', 'excel'),
  ('11111111-1111-1111-1111-111111111111', 'day_shift',   'ICU Day',   '2026-04-16 07:00:00', '2026-04-16 19:00:00', 'excel'),
  ('11111111-1111-1111-1111-111111111111', 'night_shift', 'ICU Night', '2026-04-17 19:00:00', '2026-04-18 07:00:00', 'excel');

-- ── Generated schedules ───────────────────────────────────────────────────────
insert into public.generated_schedule (
  id, user_id, schedule_date, plan_mode,
  circadian_strain_score, recovery_status_score,
  avoid_list, next_best_action, day_summary
) values

('aaaaaaaa-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111',
 '2026-04-13', 'recover', 72, 38,
 array['Caffeine after 6 PM', 'Heavy meals before shift', 'Blue light 2 hours before sleep'],
 '{"title":"Pre-shift nap","description":"90 min nap before 17:00","why_now":"Night shift starts at 19:00 — last chance to top up sleep","duration_minutes":90}',
 'Night shift begins. Protect your pre-shift sleep window — arriving alert is your priority.'),

('aaaaaaaa-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111',
 '2026-04-14', 'perform', 15, 78,
 array['Driving between 3–7 AM', 'Alcohol', 'Long naps after 15:00'],
 '{"title":"Anchor sleep","description":"Full 8-hour sleep window","why_now":"Post-night recovery window is critical in the first 24 hours","duration_minutes":480}',
 'Rest day after night shift. Your body is resetting — take it easy and protect your sleep.'),

('aaaaaaaa-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111',
 '2026-04-15', 'stabilize', 42, 61,
 array['Caffeine after 2 PM', 'Skipping breaks', 'Screen use at bedtime'],
 '{"title":"Morning light","description":"15 min natural light within 30 min of waking","why_now":"Anchors your circadian clock before day shift","duration_minutes":15}',
 'Day shift after a rest day. Near baseline — maintain anchor tasks and watch caffeine timing.'),

('aaaaaaaa-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111',
 '2026-04-16', 'stabilize', 38, 65,
 array['Caffeine after 2 PM', 'Irregular meal timing', 'Staying up past 23:00'],
 '{"title":"Caffeine cutoff","description":"No caffeine after 14:00","why_now":"Day 2 of day shifts — sleep debt can creep up unnoticed","duration_minutes":null}',
 'Second day shift in a row. Consistency is your friend — same caffeine cutoff, same bedtime.'),

('aaaaaaaa-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111',
 '2026-04-17', 'protect', 81, 32,
 array['Driving between 3–7 AM', 'Caffeine after 8 PM', 'Any alcohol today', 'Skipping the pre-shift nap'],
 '{"title":"Pre-shift nap (anchor)","description":"2-hour nap before 17:00 — do not skip","why_now":"Rapid flip detected — highest fatigue risk of the week","duration_minutes":120}',
 'Rapid flip: Day→Night in under 36 hours. Highest-risk day this week. Non-negotiable: protect your pre-shift sleep.'),

('aaaaaaaa-0000-0000-0000-000000000006', '11111111-1111-1111-1111-111111111111',
 '2026-04-18', 'recover', 55, 48,
 array['Driving this morning', 'Caffeine after 3 PM', 'Bright light before sleeping', 'Social commitments that cut into sleep'],
 '{"title":"Core sleep window","description":"7 hours sleep immediately after arriving home","why_now":"Post-night — you need sleep now while your body still wants it","duration_minutes":420}',
 'Post-night recovery day. Your circadian clock is inverted — prioritise sleep now and ease back to daytime rhythm by tomorrow.'),

('aaaaaaaa-0000-0000-0000-000000000007', '11111111-1111-1111-1111-111111111111',
 '2026-04-19', 'perform', 20, 72,
 array['Sleeping in past 08:00', 'Afternoon naps over 20 min', 'Caffeine after 14:00'],
 '{"title":"Morning light","description":"15 min outdoor light at wake time","why_now":"Locking in your wake time anchors the week ahead","duration_minutes":15}',
 'Full rest day. Circadian rhythm nearly restored — maintain consistent sleep/wake times today.');

-- ── Tasks — Apr 13 (Night shift / recover) ───────────────────────────────────
insert into public.schedule_tasks (user_id, schedule_id, schedule_date, category, title, description, scheduled_time, duration_min, is_anchor, is_optional, status, sort_order) values
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000001', '2026-04-13', 'meal',            'Recovery breakfast',   'High-protein meal before sleeping',            '2026-04-13 07:45:00', 20,   false, false, 'completed', 0),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000001', '2026-04-13', 'sleep',           'Core sleep window',    'Sleep immediately after arriving home',         '2026-04-13 08:00:00', 420,  true,  false, 'completed', 1),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000001', '2026-04-13', 'light_timing',    'Blackout curtains on', 'Block all morning light for daytime sleep',     '2026-04-13 08:15:00', 5,    true,  false, 'completed', 2),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000001', '2026-04-13', 'nap',             'Pre-shift nap',        '90 min before shift starts',                   '2026-04-13 15:30:00', 90,   true,  false, 'completed', 3),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000001', '2026-04-13', 'meal',            'Pre-shift meal',       'Balanced meal — avoid heavy carbs',             '2026-04-13 17:30:00', 30,   false, false, 'skipped',   4),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000001', '2026-04-13', 'caffeine_cutoff', 'Caffeine cutoff',      'Last caffeine before 18:00',                    '2026-04-13 18:00:00', null, true,  false, 'completed', 5);

-- ── Tasks — Apr 14 (OFF post-night / perform) ────────────────────────────────
insert into public.schedule_tasks (user_id, schedule_id, schedule_date, category, title, description, scheduled_time, duration_min, is_anchor, is_optional, status, sort_order) values
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000002', '2026-04-14', 'sleep',        'Post-night anchor sleep',  '7–8 hours of uninterrupted sleep',            '2026-04-14 08:00:00', 480, true,  false, 'completed', 1),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000002', '2026-04-14', 'light_timing', 'Afternoon light exposure', '15 min natural light to reset circadian clock','2026-04-14 16:00:00', 15,  true,  false, 'completed', 2),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000002', '2026-04-14', 'movement',     'Gentle walk',              '20 min low-intensity walk outdoors',           '2026-04-14 16:30:00', 20,  false, false, 'completed', 3),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000002', '2026-04-14', 'meal',         'Light dinner',             'Avoid heavy meals to support overnight sleep', '2026-04-14 19:00:00', 30,  false, false, 'completed', 4),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000002', '2026-04-14', 'relaxation',   'Wind-down routine',        'No screens, dim lights, light reading',        '2026-04-14 21:30:00', 60,  false, false, 'skipped',   5);

-- ── Tasks — Apr 15 (Day shift / stabilize) ───────────────────────────────────
insert into public.schedule_tasks (user_id, schedule_id, schedule_date, category, title, description, scheduled_time, duration_min, is_anchor, is_optional, status, sort_order) values
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000003', '2026-04-15', 'light_timing',    'Morning light exposure', '15 min natural light after waking',       '2026-04-15 06:15:00', 15,   true,  false, 'completed', 1),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000003', '2026-04-15', 'meal',            'Pre-shift breakfast',    'High-protein, avoid high-sugar',          '2026-04-15 06:30:00', 20,   false, false, 'completed', 2),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000003', '2026-04-15', 'caffeine_cutoff', 'Caffeine cutoff',        'No caffeine after 14:00',                 '2026-04-15 14:00:00', null, true,  false, 'completed', 3),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000003', '2026-04-15', 'movement',        'Post-shift stretch',     '10 min light stretching after shift',     '2026-04-15 19:45:00', 10,   false, false, 'skipped',   4),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000003', '2026-04-15', 'relaxation',      'Wind-down',              'No screens, dim lights',                  '2026-04-15 21:30:00', 60,   false, false, 'completed', 5),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000003', '2026-04-15', 'sleep',           'Anchor sleep',           'Aim for 7.5 hours',                       '2026-04-15 22:30:00', 450,  true,  false, 'completed', 6);

-- ── Tasks — Apr 16 (Day shift / stabilize) ───────────────────────────────────
insert into public.schedule_tasks (user_id, schedule_id, schedule_date, category, title, description, scheduled_time, duration_min, is_anchor, is_optional, status, sort_order) values
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000004', '2026-04-16', 'light_timing',    'Morning light',    '15 min outdoor light after waking',          '2026-04-16 06:15:00', 15,   true,  false, 'completed', 1),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000004', '2026-04-16', 'meal',            'Lunch break',      'Proper meal — step away from the floor',     '2026-04-16 12:30:00', 30,   false, false, 'completed', 2),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000004', '2026-04-16', 'caffeine_cutoff', 'Caffeine cutoff',  'Last coffee before 14:00',                   '2026-04-16 14:00:00', null, true,  false, 'completed', 3),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000004', '2026-04-16', 'movement',        'Evening walk',     '20 min moderate walk',                       '2026-04-16 20:00:00', 20,   false, false, 'completed', 4),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000004', '2026-04-16', 'mindfulness',     'Decompression',    '10 min of stillness — shift off before bed', '2026-04-16 21:30:00', 10,   false, false, 'skipped',   5),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000004', '2026-04-16', 'sleep',           'Anchor sleep',     '7.5 hours target',                           '2026-04-16 22:30:00', 450,  true,  false, 'completed', 6);

-- ── Tasks — Apr 17 (Night shift / protect) ───────────────────────────────────
insert into public.schedule_tasks (user_id, schedule_id, schedule_date, category, title, description, scheduled_time, duration_min, is_anchor, is_optional, status, sort_order) values
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000005', '2026-04-17', 'sleep',           'Extended morning sleep',      'Sleep in as long as possible before the flip',       '2026-04-17 00:00:00', 420,  true,  false, 'completed', 1),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000005', '2026-04-17', 'light_timing',    'Avoid bright light till 14:00','Wear sunglasses outdoors to delay circadian shift',  '2026-04-17 07:00:00', null, true,  false, 'completed', 2),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000005', '2026-04-17', 'nap',             'Pre-shift nap (anchor)',       '2 hours before shift — do not skip',                 '2026-04-17 14:30:00', 120,  true,  false, 'completed', 3),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000005', '2026-04-17', 'meal',            'Pre-shift meal',               'Light, easy-to-digest meal before night shift',      '2026-04-17 17:30:00', 30,   false, false, 'completed', 4),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000005', '2026-04-17', 'safety',          'Do not drive 03:00–07:00',    'Peak circadian low — unsafe to operate vehicle',     '2026-04-17 19:00:00', null, true,  false, 'completed', 5),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000005', '2026-04-17', 'caffeine_cutoff', 'Caffeine cutoff',              'Last caffeine before 20:00',                         '2026-04-17 20:00:00', null, true,  false, 'skipped',   6);

-- ── Tasks — Apr 18 TODAY (OFF post-night / recover) — all planned ────────────
insert into public.schedule_tasks (user_id, schedule_id, schedule_date, category, title, description, scheduled_time, duration_min, is_anchor, is_optional, status, sort_order) values
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', '2026-04-18', 'meal',            'Light recovery meal',        'Eat before sleeping — nothing heavy',                    '2026-04-18 07:15:00', 15,   false, false, 'planned', 0),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', '2026-04-18', 'sleep',           'Post-night core sleep',      '7 hours immediately after shift ends',                   '2026-04-18 07:30:00', 420,  true,  false, 'planned', 1),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', '2026-04-18', 'light_timing',    'Blackout & blue-light block', 'Block all morning light before sleeping',                '2026-04-18 07:35:00', 5,    true,  false, 'planned', 2),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', '2026-04-18', 'caffeine_cutoff', 'Caffeine cutoff',             'No caffeine after 15:00',                               '2026-04-18 15:00:00', null, true,  false, 'planned', 3),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', '2026-04-18', 'light_timing',    'Afternoon light exposure',    '20 min outdoor light to begin resetting to daytime',    '2026-04-18 15:30:00', 20,   true,  false, 'planned', 4),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', '2026-04-18', 'movement',        'Gentle walk',                 '15–20 min light activity',                              '2026-04-18 16:00:00', 20,   false, false, 'planned', 5),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', '2026-04-18', 'relaxation',      'Evening wind-down',           'Dim lights, no work, gentle reading',                   '2026-04-18 21:00:00', 60,   false, false, 'planned', 6),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000006', '2026-04-18', 'sleep',           'Recovery night sleep',        'Target 22:00–06:00 to reset circadian rhythm',          '2026-04-18 22:00:00', 480,  true,  false, 'planned', 7);

-- ── Tasks — Apr 19 (OFF / perform) ───────────────────────────────────────────
insert into public.schedule_tasks (user_id, schedule_id, schedule_date, category, title, description, scheduled_time, duration_min, is_anchor, is_optional, status, sort_order) values
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000007', '2026-04-19', 'light_timing',  'Morning light',           '15 min outdoor light at 07:00',                    '2026-04-19 07:00:00', 15,   true,  false, 'planned', 1),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000007', '2026-04-19', 'meal',          'Consistent breakfast',    'Eat at same time as a day-shift morning',          '2026-04-19 07:30:00', 20,   false, false, 'planned', 2),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000007', '2026-04-19', 'movement',      'Morning walk or run',     '30 min moderate activity',                         '2026-04-19 08:00:00', 30,   false, false, 'planned', 3),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000007', '2026-04-19', 'social',        'Social time',             'Connect with family — social bonding aids recovery','2026-04-19 13:00:00', 120,  false, false, 'planned', 4),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000007', '2026-04-19', 'mindfulness',   'Mindfulness / breathing', '10 min breathing exercises',                       '2026-04-19 21:00:00', 10,   false, false, 'planned', 5),
  ('11111111-1111-1111-1111-111111111111', 'aaaaaaaa-0000-0000-0000-000000000007', '2026-04-19', 'sleep',         'Consistent bedtime',      'Aim for 22:00 to solidify rhythm',                 '2026-04-19 22:00:00', 480,  true,  false, 'planned', 6);

-- ── Weekly summary (last week Apr 6–12) ──────────────────────────────────────
insert into public.weekly_summary (
  user_id, week_start, week_end,
  tasks_completed, tasks_skipped, tasks_expired,
  anchor_tasks_completed, anchor_tasks_total, anchor_completion_rate,
  avg_recovery_score, circadian_strain_avg,
  recovery_trend, improvement_pct,
  highlights, suggestions, anomaly_flag, narrative
) values (
  '11111111-1111-1111-1111-111111111111',
  '2026-04-06', '2026-04-12',
  28, 6, 2,
  14, 18, 0.7778,
  58.4, 47.2,
  'improving', 15.3,
  array[
    'Maintained sleep anchor 5 out of 7 days',
    'Zero caffeine violations all week',
    'Completed all pre-shift naps on night shift days'
  ],
  array[
    'Try a 20-min walk on rest days to accelerate circadian reset',
    'Move caffeine cutoff to 13:00 on day shifts — your sleep data suggests sensitivity',
    'Add a short mindfulness session after high-stress shifts to reduce cortisol before sleep'
  ],
  null,
  'Solid week for recovery discipline. Anchor completion improved from 62% to 78%, and average recovery score held above 55 despite two night shifts. The rapid flip Wednesday→Thursday night was well-managed — pre-shift nap compliance was 100%. Main area to work on: post-shift wind-down. On two nights your sleep window started over 90 minutes later than planned. Fixing that alone could push recovery scores into the 70s.'
);

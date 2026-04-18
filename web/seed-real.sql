-- Seed for user 11111111-1111-1111-1111-111111111111
-- Run in Supabase SQL Editor

-- Update user name/timezone
UPDATE public.users
SET name = 'Sarah Mitchell', timezone = 'America/Chicago'
WHERE id = '11111111-1111-1111-1111-111111111111';

-- ─── Plans (one per day Apr 13-18 2026) ─────────────────────────────────────

INSERT INTO public.plans
  (id, user_id, plan_mode, plan_start, plan_end,
   circadian_strain_score, recovery_status_score,
   risk_summary, next_best_action, is_active)
VALUES

-- Apr 13 — Recover (post night shift)
('aa000000-0413-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'recover',
 '2026-04-13 07:00:00+00', '2026-04-14 07:00:00+00',
 71.0, 38.0,
 '{"summary":"Moderate circadian strain after 12-hr night shift. Anchor sleep critical before next shift.","episodes":2,"plan_hours":24,"circadian_strain_score":71.0}',
 '{"title":"Anchor sleep block","why_now":"Your body needs consolidated recovery sleep after the night shift.","description":"Sleep now before circadian pressure builds into the afternoon.","duration_minutes":480}',
 false),

-- Apr 14 — Stabilize
('aa000000-0414-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'stabilize',
 '2026-04-14 07:00:00+00', '2026-04-15 07:00:00+00',
 55.0, 58.0,
 '{"summary":"Recovery trending upward. Maintain sleep hygiene and light schedule to stabilize circadian rhythm.","episodes":1,"plan_hours":24,"circadian_strain_score":55.0}',
 '{"title":"Evening wind-down routine","why_now":"Consistent pre-sleep routine tonight will anchor your rhythm for tomorrow.","description":"Dim lights and avoid screens 90 min before bed.","duration_minutes":60}',
 false),

-- Apr 15 — Perform
('aa000000-0415-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'perform',
 '2026-04-15 07:00:00+00', '2026-04-16 07:00:00+00',
 38.0, 74.0,
 '{"summary":"Low circadian strain. Good recovery trend. Full performance day — lean into physical activity and social engagement.","episodes":0,"plan_hours":24,"circadian_strain_score":38.0}',
 '{"title":"Morning movement session","why_now":"Your recovery score is high. Exercise now to lock in the circadian anchor.","description":"30-min brisk walk or light jog outside in natural light.","duration_minutes":30}',
 false),

-- Apr 16 — Recover (another night shift last night)
('aa000000-0416-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'recover',
 '2026-04-16 07:00:00+00', '2026-04-17 07:00:00+00',
 76.0, 34.0,
 '{"summary":"High strain after back-to-back nights. Short turnaround detected. Anchor sleep is non-negotiable.","episodes":3,"plan_hours":24,"circadian_strain_score":76.0}',
 '{"title":"Protect anchor sleep","why_now":"Back-to-back night shift detected — short turnaround risk is active.","description":"Block your bedroom, blackout curtains, phone on silent for 7-8 hours.","duration_minutes":480}',
 false),

-- Apr 17 — Stabilize
('aa000000-0417-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'stabilize',
 '2026-04-17 07:00:00+00', '2026-04-18 07:00:00+00',
 52.0, 55.0,
 '{"summary":"Strain easing. Day-off — use it to recalibrate sleep timing and light exposure.","episodes":1,"plan_hours":24,"circadian_strain_score":52.0}',
 '{"title":"Caffeine cutoff at 2 PM","why_now":"Cutting caffeine early today protects tonight pre-shift sleep quality.","description":"Switch to water or herbal tea after 2 PM to allow adenosine to build naturally.","duration_minutes":0}',
 false),

-- Apr 18 — Protect (today, night shift tonight)
('aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'protect',
 '2026-04-18 07:00:00+00', '2026-04-19 07:00:00+00',
 82.0, 42.0,
 '{"summary":"High circadian strain. Night shift tonight. Focus entirely on pre-shift readiness — nap, light management, and safe commute.","episodes":3,"plan_hours":24,"circadian_strain_score":82.0}',
 '{"title":"Strategic pre-shift nap","why_now":"Night shift starts in 10h. A 90-min nap now gives you a recovery buffer before the shift.","description":"Set blackout curtains, nap 90 min starting around 2 PM local time.","duration_minutes":90}',
 true);

-- ─── Tasks for Apr 18 plan (today) ──────────────────────────────────────────

INSERT INTO public.plan_tasks
  (id, plan_id, user_id, category, title, description,
   scheduled_time, duration_minutes, anchor_flag, optional_flag,
   source_reason, evidence_ref, status, sort_order)
VALUES

('bb000000-0418-0001-0000-000000000001',
 'aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'light_timing', 'Morning bright light exposure',
 'Get 15-20 min of outdoor sunlight before 9 AM to anchor your morning cortisol peak.',
 '2026-04-18 08:00:00+00', 20, true, false,
 'Circadian anchor — light exposure in AM suppresses melatonin and sets wake signal.',
 'Czeisler et al. (1989) — timed light exposure shifts circadian phase.',
 'completed', 1),

('bb000000-0418-0002-0000-000000000001',
 'aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'meal', 'High-protein breakfast',
 'Eggs, Greek yogurt or similar. Avoid simple carbs. Sets energy baseline for the day.',
 '2026-04-18 09:00:00+00', 30, false, false,
 'Pre-shift nutrition: protein-rich meals sustain alertness during night work.',
 NULL,
 'completed', 2),

('bb000000-0418-0003-0000-000000000001',
 'aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'caffeine_cutoff', 'Last caffeine before cutoff',
 'Final coffee or tea by noon. Caffeine half-life ~5h — you need it cleared before your pre-shift nap.',
 '2026-04-18 12:00:00+00', NULL, true, false,
 'Caffeine cutoff 6h before nap to allow adenosine to build for pre-shift sleep.',
 'Drake et al. (2013) — caffeine 6h before bed cuts sleep by 1h.',
 'planned', 3),

('bb000000-0418-0004-0000-000000000001',
 'aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'movement', 'Light movement — no hard exercise',
 'A 15-min gentle walk is fine. Avoid strenuous exercise today — it elevates cortisol and disrupts pre-shift nap.',
 '2026-04-18 13:00:00+00', 15, false, true,
 'Pre-shift day: high-intensity exercise spikes cortisol and delays sleep onset.',
 NULL,
 'planned', 4),

('bb000000-0418-0005-0000-000000000001',
 'aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'nap', 'Pre-shift anchor nap',
 'Blackout curtains, phone silent, 90 min. This is your recovery buffer before a full night shift. Do not skip.',
 '2026-04-18 14:00:00+00', 90, true, false,
 'Pre-shift nap reduces fatigue by up to 45% during the night shift.',
 'Bonnefond et al. (2001) — prophylactic nap before night shift improves vigilance.',
 'planned', 5),

('bb000000-0418-0006-0000-000000000001',
 'aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'meal', 'Pre-shift meal',
 'Balanced meal 2h before shift. Avoid heavy carbs — they cause post-meal dip in alertness.',
 '2026-04-18 17:00:00+00', 30, false, false,
 'Pre-shift nutrition: balanced meal avoids post-meal dip during critical early shift hours.',
 NULL,
 'planned', 6),

('bb000000-0418-0007-0000-000000000001',
 'aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'safety', 'Safe commute check',
 'If driving to shift, assess alertness before getting in the car. Sleepiness impairs driving as much as 0.08 BAC.',
 '2026-04-18 18:30:00+00', NULL, true, false,
 'Drowsy driving risk is highest in shift workers on morning commutes.',
 'Williamson & Feyer (2000) — 17-19h awake = 0.05 BAC impairment.',
 'planned', 7),

('bb000000-0418-0008-0000-000000000001',
 'aa000000-0418-0000-0000-000000000001',
 '11111111-1111-1111-1111-111111111111',
 'mindfulness', 'Pre-shift mindfulness reset',
 '5-min breathing exercise before you walk through the hospital doors. Lowers cortisol spike from anticipatory stress.',
 '2026-04-18 18:45:00+00', 5, false, true,
 'Mindfulness reduces anticipatory stress and improves first-hour shift performance.',
 NULL,
 'planned', 8);

-- ─── Tasks for a few other days (Apr 13, Apr 15, Apr 16) for week view ───────

-- Apr 13 tasks
INSERT INTO public.plan_tasks
  (id, plan_id, user_id, category, title, description,
   scheduled_time, duration_minutes, anchor_flag, optional_flag,
   source_reason, evidence_ref, status, sort_order)
VALUES
('bb000000-0413-0001-0000-000000000001','aa000000-0413-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'sleep','Anchor sleep block','7-8 hours consolidated sleep immediately after shift.','2026-04-13 08:00:00+00',480,true,false,NULL,NULL,'completed',1),
('bb000000-0413-0002-0000-000000000001','aa000000-0413-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'light_timing','Avoid bright light after shift','Sunglasses on your commute home — light suppresses melatonin and delays sleep.','2026-04-13 07:30:00+00',NULL,true,false,NULL,NULL,'completed',2),
('bb000000-0413-0003-0000-000000000001','aa000000-0413-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'meal','Light post-shift meal','Small, easy-to-digest meal before sleep. Avoid heavy protein or high-fat meals.','2026-04-13 07:45:00+00',20,false,false,NULL,NULL,'skipped',3),
('bb000000-0413-0004-0000-000000000001','aa000000-0413-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'relaxation','Wind-down before sleep','Dark room, cool temperature, 10 min of deep breathing before getting into bed.','2026-04-13 16:30:00+00',30,false,true,NULL,NULL,'completed',4);

-- Apr 15 tasks (perform day)
INSERT INTO public.plan_tasks
  (id, plan_id, user_id, category, title, description,
   scheduled_time, duration_minutes, anchor_flag, optional_flag,
   source_reason, evidence_ref, status, sort_order)
VALUES
('bb000000-0415-0001-0000-000000000001','aa000000-0415-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'movement','Morning jog — 30 min','Full exercise session. Your recovery score supports high output today.','2026-04-15 09:00:00+00',30,false,false,NULL,NULL,'completed',1),
('bb000000-0415-0002-0000-000000000001','aa000000-0415-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'social','Social engagement','Connect with friends or family. Social interaction supports recovery and mood regulation.','2026-04-15 14:00:00+00',120,false,true,NULL,NULL,'completed',2),
('bb000000-0415-0003-0000-000000000001','aa000000-0415-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'meal','Balanced lunch','Full balanced meal — today you can eat more freely given low circadian strain.','2026-04-15 12:30:00+00',30,false,false,NULL,NULL,'completed',3),
('bb000000-0415-0004-0000-000000000001','aa000000-0415-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'sleep','Consistent sleep time','In bed by 10:30 PM to protect your rhythm heading into the next shift block.','2026-04-15 20:30:00+00',480,true,false,NULL,NULL,'completed',4);

-- Apr 16 tasks (recover, high strain)
INSERT INTO public.plan_tasks
  (id, plan_id, user_id, category, title, description,
   scheduled_time, duration_minutes, anchor_flag, optional_flag,
   source_reason, evidence_ref, status, sort_order)
VALUES
('bb000000-0416-0001-0000-000000000001','aa000000-0416-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'sleep','Protect anchor sleep','Block off 7-8 hours immediately. Back-to-back nights means no compromise on sleep.','2026-04-16 08:00:00+00',480,true,false,NULL,NULL,'completed',1),
('bb000000-0416-0002-0000-000000000001','aa000000-0416-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'light_timing','Blackout on wake','Keep lights dim for 30 min after waking. Gradual light exposure helps avoid sleep inertia.','2026-04-16 17:00:00+00',30,false,false,NULL,NULL,'completed',2),
('bb000000-0416-0003-0000-000000000001','aa000000-0416-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'caffeine_cutoff','Caffeine allowed — shift tonight','One coffee 1h after waking only. Cut off by 10 PM.','2026-04-16 18:00:00+00',NULL,false,false,NULL,NULL,'skipped',3),
('bb000000-0416-0004-0000-000000000001','aa000000-0416-0000-0000-000000000001','11111111-1111-1111-1111-111111111111',
 'safety','Safe commute check','High fatigue day — assess alertness before driving. Consider rideshare if unsure.','2026-04-16 19:00:00+00',NULL,true,false,NULL,NULL,'completed',4);

-- ─── Outcome Memory (Apr 6-17 for weekly view) ───────────────────────────────

INSERT INTO public.outcome_memory
  (id, user_id, date, plan_mode, recovery_score, anchors_completed, anchors_total, anchor_completion_rate, recorded_at)
VALUES
('cc000000-0406-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-06','recover',52.0,2,3,0.67,'2026-04-06 23:00:00+00'),
('cc000000-0407-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-07','stabilize',58.0,3,3,1.00,'2026-04-07 23:00:00+00'),
('cc000000-0408-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-08','perform',71.0,2,2,1.00,'2026-04-08 23:00:00+00'),
('cc000000-0409-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-09','recover',44.0,2,4,0.50,'2026-04-09 23:00:00+00'),
('cc000000-0410-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-10','recover',40.0,1,3,0.33,'2026-04-10 23:00:00+00'),
('cc000000-0411-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-11','stabilize',61.0,3,3,1.00,'2026-04-11 23:00:00+00'),
('cc000000-0412-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-12','perform',68.0,2,2,1.00,'2026-04-12 23:00:00+00'),
('cc000000-0413-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-13','recover',48.0,2,3,0.67,'2026-04-13 23:00:00+00'),
('cc000000-0414-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-14','stabilize',56.0,3,3,1.00,'2026-04-14 23:00:00+00'),
('cc000000-0415-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-15','perform',72.0,4,4,1.00,'2026-04-15 23:00:00+00'),
('cc000000-0416-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-16','recover',41.0,2,3,0.67,'2026-04-16 23:00:00+00'),
('cc000000-0417-0000-0000-000000000001','11111111-1111-1111-1111-111111111111','2026-04-17','stabilize',59.0,2,2,1.00,'2026-04-17 23:00:00+00');

# Waqt — Roadmap

Order of work: **Figma (all screens) -> Flutter frontend -> Firebase and project setup -> real features -> release.**
See `docs/DOCUMENTATION.md` for scope, architecture and policy notes.

Legend: [x] done, [ ] to do

---

## Phase A — Foundation (done)

- [x] Research (5 AI reports) and merged `DOCUMENTATION.md`
- [x] Name: Waqt, Android only
- [x] Flutter project, GitHub repo, `.gitignore` for secrets
- [x] Folder structure (feature-first: data / providers / presentation)
- [x] `pubspec.yaml` cleaned, Inter font bundled
- [x] `AppColors`, `AppTheme`, router, Home screen (sample data)

---

## Phase B — Figma: complete frontend

Design language: dark-first, deep green background, gold accent, Inter, calm tone.

**Batch 1 (done, 13 screens)**
- [x] Home, Prayer overlay, Prayer Mode setup
- [x] Onboarding x5 (welcome, location, method, Azan alerts, Prayer Mode permissions)
- [x] Azan screen, Health check, Stats, Settings, Qibla

**Batch 2**
- [ ] Splash
- [ ] Prayer times (week strip + timetable)
- [ ] Prayer log (month calendar + streak)
- [ ] City search (manual location)
- [ ] App picker (search + toggles)
- [ ] Adjustments (per-prayer minutes)

**Batch 3**
- [ ] Bottom navigation bar (Home, Times, Prayer Mode, Stats, Settings)
- [ ] Azan sound picker
- [ ] Language picker
- [ ] Prayer Mode states: "Allow 5 minutes" overlay, permission revoked banner
- [ ] Dialogs: delete all data, permission explainers
- [ ] About / Privacy screen
- [ ] Urdu (RTL) version of Home

**Batch 4**
- [ ] Reusable components (button, row, card, toggle, chip) and color variables
- [ ] Light theme (optional, later)

---

## Phase C — Flutter frontend (sample data only)

Build in this order, one feature at a time, commit after each:

- [ ] App shell: bottom navigation + go_router shell route
- [ ] Shared widgets in `core/widgets` (button, list row, card, toggle)
- [ ] Splash and Onboarding flow (UI only, permissions stubbed)
- [ ] Prayer times and Prayer log screens
- [ ] Prayer Mode: setup, app picker, overlay preview
- [ ] Health check, Stats, Settings (+ sub-pages), Qibla UI
- [ ] Localization setup: English + Urdu (RTL)
- [ ] `flutter analyze` and `flutter test` clean before moving on

**Done when:** every Figma screen exists in the app and can be navigated end to end.

---

## Checkpoint — Phase 0 native prototype (1-2 days, recommended)

The riskiest parts are native Android, not UI. Before investing weeks in more UI, prove on a **real Android phone**:

- [x] `setAlarmClock` fires with the app killed and the screen off
- [x] UsageStats detects a chosen app and an overlay appears over it

If either fails, the design or scope may need to change. Better to know early.

---

## Phase D — Firebase and project setup

- [ ] Create Firebase project, register Android app (`com.fahadapps.waqt`)
- [ ] `flutterfire configure`
- [ ] Add `google-services.json` to `.gitignore` **before** committing anything
- [ ] Crashlytics (crash reports, non-fatal logs)
- [ ] Analytics (optional, anonymized, no location or app-usage events)
- [ ] Remote Config (optional, feature flags)
- [ ] Later, only if needed: Auth + Firestore for opt-in sync
- [ ] Release signing key (`key.properties`, keystore) stored outside git
- [ ] Debug/release build configs, app icon, app name, splash

---

## Phase E — Prayer engine

- [ ] `adhan_dart`, `timezone`, `geolocator`
- [ ] Drift database (settings, prayer days, prayer records)
- [ ] Location + manual city, method, madhab, adjustments
- [ ] Replace sample data on Home and Prayer times with real calculation
- [ ] Golden test dataset vs reference timetables

## Phase F — Azan engine

- [ ] Native Kotlin scheduler (`setAlarmClock`), boot/timezone receivers
- [ ] Notification channel, Azan audio, actions
- [ ] Permission flow (notifications, alarms, battery guide)
- [ ] Health-check screen wired to real status

## Phase G — Prayer Mode

- [ ] Foreground service (`specialUse`), usage monitor, overlay
- [ ] App picker (`<queries>`, no `QUERY_ALL_PACKAGES`), allowlist
- [ ] MethodChannel bridge, "I prayed" logging
- [ ] Revoked-permission detection and notice

## Phase H — Tracking and polish

- [ ] Prayer records, streaks, stats from Drift
- [ ] Widget, more Azan voices, Qibla with sensor
- [ ] OEM battery guides (Xiaomi, Oppo, Vivo, Samsung)

## Phase I — Release

- [ ] Privacy policy, Data safety form, permission declarations, demo video
- [ ] Closed beta (50-100 users, real devices)
- [ ] Play Store listing and launch

---

## Rough timeline (solo, part-time)

| Phase | Estimate |
|---|---|
| B Figma | about 1 week |
| C Flutter frontend | 1-2 weeks |
| Checkpoint | 1-2 days |
| D Firebase and setup | 2-3 days |
| E Prayer engine | 2-3 weeks |
| F Azan engine | 2-3 weeks |
| G Prayer Mode | about 3 weeks |
| H Tracking and polish | 1-2 weeks |
| I Release | 3 weeks |

**Total:** about 14-18 weeks. Phases F and G carry the schedule risk.

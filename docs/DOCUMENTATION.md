# Waqt — Project Documentation

> Status: **Draft v0.1** — merged from 5 AI research reports (ChatGPT, Gemini, Kimi, DeepSeek, Claude).
> Items marked **[VERIFY]** must be checked against official docs (Android, Play Console, pub.dev) before building.

---

## 1. Product Requirements (PRD)

### 1.1 Overview

**Waqt** is an Android prayer-time app that does two things well:

1. Gives accurate, fully offline prayer times and a reliable Azan.
2. Protects prayer time from digital distraction: during a short "Prayer Mode" window, user-selected apps (Instagram, TikTok, etc.) are covered by a calm overlay asking "Have you prayed?".

- **Platform:** Android only (for now)
- **Stack:** Flutter / Dart + native Kotlin
- **Primary market:** Pakistan (Karachi method, Hanafi Asr), global-ready
- **Audience:** Young Muslims (16-35), Urdu / English / Arabic
- **Tone:** Calm, respectful, motivating. Not preachy, not guilt-driven.
- **Tagline candidates:** "Make Time for Prayer" / "Pray on time. Every time."

### 1.2 Positioning

- Prayer apps (Muslim Pro, Athan, Salatuk, etc.) do times + Azan but not distraction control.
- Blocker apps (AppBlock, StayFree, etc.) block apps but have no religious context.
- Waqt = prayer + digital self-control. Ad-free, privacy-first (nothing leaves the device).
- **Competitor note [VERIFY]:** Two reports mention "Just Pray" having a "Prayer Focus" mode. Check it on Play Store; differentiate on reliability, Urdu-first UX, and privacy.
- Honest positioning: *"Designed to reduce distraction"*, not an unbreakable lock.

### 1.3 MVP scope

| # | Feature | Notes |
|---|---|---|
| 1 | Offline prayer times | GPS or manual city; Karachi + Hanafi default |
| 2 | Azan notifications | Exact time, works in Doze, survives reboot |
| 3 | Prayer Mode (blocker) | Overlay on selected apps during a prayer window |
| 4 | "Have you prayed?" flow | Yes = lift early + log; Not yet = stays until window ends |
| 5 | Allowlist | Phone, SMS, maps, banking never blocked |
| 6 | Prayer log | Mark prayed from notification, overlay, or app |
| 7 | Settings | Method, Asr (madhab), per-prayer adjustment (±min), Azan sound, block window |
| 8 | Health-check screen | Shows permission / battery status with fix links |
| 9 | Onboarding | Reason-first permission flow (see §5) |
| 10 | Localization | English + Urdu (RTL) at MVP; Arabic later |

### 1.4 Post-MVP

Qibla, Hijri date (±1 day adjust), widget, streaks and stats, multiple Azan voices, pre-prayer reminder, per-prayer block intensity (light banner for Fajr, full overlay for Maghrib), congregation mode (window after prayer start), Ramadan mode, Crashlytics dashboards.

### 1.5 Non-goals (for now)

iOS, Quran/Hadith content, social features, accounts and cloud sync, family / parental-control mode, ads.

### 1.6 Key product decisions

- **Prayer Mode has a fixed window** (default 20 min, configurable 10-30). It ends automatically. Yes/No is self-reported and never "verified".
- **"I prayed" lifts the block early** for that prayer and logs it. It is a habit tracker, not religious verification.
- **"Not yet"** keeps the block until the window ends (optional short snooze).
- **Emergency:** an allowlist plus an optional "allow 5 minutes" button.
- **Blocker is optional:** prayer times, Azan and tracking must work fully without it.
- **No ads**, ever, on prayer screens. Freemium later (see §9).

---

## 2. Technical Architecture

### 2.1 Stack

| Concern | Choice |
|---|---|
| UI / logic | Flutter, Dart |
| State management | Riverpod |
| Local DB | Drift (SQLite) |
| Settings | SharedPreferences (or Drift table) |
| Prayer calculation | `adhan_dart` (offline) **[VERIFY version and API]** |
| Timezones | `timezone` package (`latest_all` dataset) |
| Location | `geolocator` (coarse location is enough) |
| Notifications (UI) | `flutter_local_notifications` |
| Native Android | Kotlin: alarms, receivers, blocker service, overlay |
| Crash reporting | Firebase Crashlytics (only Firebase service in MVP) |
| Routing | `go_router` |
| Localization | Flutter gen-l10n (ARB files) |

**Principle:** Flutter = product (UI, settings, data, calculation). Kotlin = Android system integration (alarms, blocker). Bridge with a small number of MethodChannels.

### 2.2 Folder structure

```
lib/
├── main.dart
├── app/                 # app.dart, router.dart, theme.dart
├── core/                # constants, utils, permissions, native channels
├── features/
│   ├── prayer_times/    # data / domain / application / presentation
│   ├── notifications/
│   ├── blocker/
│   ├── tracking/        # prayer log, streaks
│   ├── onboarding/
│   └── settings/
└── l10n/                # app_en.arb, app_ur.arb

android/app/src/main/kotlin/.../
├── scheduler/           # AlarmScheduler, AlarmReceiver, BootReceiver
├── blocker/             # BlockerService (FGS), UsageMonitor, OverlayController
└── channels/            # MethodChannel handlers
```

### 2.3 Data flow

```
Location + settings
   -> adhan_dart (offline calc, 7-30 days ahead)
   -> Drift cache
   -> Native AlarmScheduler (setAlarmClock)
   -> AlarmReceiver at prayer time
        |-- Azan notification
        '-- start BlockerService for the prayer window (if enabled)
   -> UsageMonitor detects a blocked app -> Overlay
   -> "I prayed" -> MethodChannel -> Flutter -> Drift (PrayerRecord)
```

### 2.4 Firebase

- **MVP:** Crashlytics only.
- **Not needed:** Firestore, FCM, Auth, Storage.
- **Later (optional):** Auth + Firestore for opt-in sync of settings and prayer log. Never upload location history or blocked-app lists.

---

## 3. Prayer Time Logic

- **Calculate locally.** No network is required at prayer time. AlAdhan API is optional verification only.
- **Defaults:** Karachi method (Fajr 18°, Isha 18°), Hanafi Asr. Expose other methods: MWL, ISNA, Umm al-Qura, Moonsighting, etc.
- **Per-prayer adjustment** (±minutes): masjid tables differ by 1-3 minutes and users will ask for this.
- **High latitude:** support Middle of Night / One-Seventh / Angle-Based rules. **[VERIFY]** the exact `adhan_dart` API for this.
- **Caching:** compute the next 7-30 days on start, on location change, and daily after midnight. Never compute at alarm-fire time.
- **Timezones:** store UTC instants plus `timezoneId`. Recompute when the device UTC offset or timezone changes. Pakistan has no DST, but global users do.
- **Day boundary:** Isha after midnight belongs to the previous prayer day.
- **Location:** request coarse location; manual city search as fallback. Don't track GPS continuously.

---

## 4. Azan Alarms (Android)

- **Scheduler:** native Kotlin `AlarmManager.setAlarmClock()` for each prayer. Treated by the OS as a user alarm clock, so it is the most reliable in Doze.
  - **[VERIFY]** whether `setAlarmClock` needs `SCHEDULE_EXACT_ALARM` on your target SDK. Several reports disagree with each other.
  - Do **not** declare `USE_EXACT_ALARM` (Play restricts it to alarm-clock/calendar apps).
  - If exact alarms are unavailable: fall back to `setAndAllowWhileIdle` and show a warning in the health-check screen.
  - Known side effect: a small alarm icon appears in the status bar.
- **Schedule window:** today + next few days, refreshed daily. Don't schedule a full year.
- **Receivers:** `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `TIMEZONE_CHANGED`, `TIME_SET` -> recalculate and reschedule everything.
- **Notification:** high-importance channel with Azan sound, action buttons ("I prayed"). Full-screen intent is optional only (restricted on Android 14+; don't build the UX around it). `setBypassDnd` needs DND access, so don't rely on it.
- **OEM battery killers** (Xiaomi, Oppo, Realme, Vivo, Infinix/Tecno, Samsung): show an OEM-specific guide (Autostart, battery "no restrictions"). Do **not** declare `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`; deep-link to settings instead.
- **Health-check screen:** per-permission status (notifications, exact alarm, battery, usage access, overlay) with fix links, plus a "last Azan fired" indicator.
- Never claim 100% reliability.

---

## 5. Prayer Mode (Blocker)

### 5.1 Approach

**UsageStatsManager + overlay**, run in a short-lived foreground service. AccessibilityService is **not** used in MVP (high Google Play policy risk). It may be added later as an optional, clearly disclosed "enhanced mode".

### 5.2 Flow

1. `AlarmReceiver` fires at prayer time and starts `BlockerService` for the window (for example 20 min).
2. The service polls `UsageStatsManager.queryEvents()` about every 1 s while the screen is on (slower or paused when the screen is off).
3. When a blocked package comes to the foreground, show the overlay: **"Maghrib has started. Have you prayed?"** with [I prayed] [Not yet].
4. The service stops itself when the window ends. Blocking auto-lifts.

### 5.3 Implementation notes

- Use `ACTIVITY_RESUMED` events (`MOVE_TO_FOREGROUND` is deprecated). **[VERIFY]**
- Polling guards:
  - Don't reset the "current app" when a query returns no events. `queryEvents` returns events, not state.
  - Use a rolling `[lastQueryTime, now]` window; advance it only after a successful read.
  - Backdate the first query by 2-3 s at service start.
  - Keep a single overlay instance (`singleInstance` / `SINGLE_TOP`, or a single `WindowManager` view).
- Launching an activity from a background service needs the overlay permission (`SYSTEM_ALERT_WINDOW`) as its exemption. **[VERIFY]**
- **FGS type:** `specialUse` with a declared subtype. Play needs a justification and demo video. **[VERIFY]**
- **App picker:** don't declare `QUERY_ALL_PACKAGES` casually. Use a `<queries>` launcher-intent entry to list launchable apps. Fall back to a fixed list of popular social apps.
- **Allowlist:** never block phone/dialer, SMS, emergency, maps, banking.
- All overlay text is localized in Flutter and passed to Kotlin (no hardcoded English in native code).

### 5.4 Bypass and limits (state honestly in-product)

The user can revoke Usage Access or Overlay, force-stop the app, uninstall, or use safe mode. The service must detect a revoked permission and show a persistent "Prayer Mode inactive" notice. Marketing wording: "helps you protect your prayer", not "locks your phone".

---

## 6. Permissions and Play Store Policy

| Permission / feature | Why | Risk | Notes |
|---|---|---|---|
| `ACCESS_COARSE_LOCATION` | Prayer times | Low | Coarse is enough; manual city fallback |
| `POST_NOTIFICATIONS` | Azan | Low | Runtime, Android 13+ |
| Exact alarm (`SCHEDULE_EXACT_ALARM`) | Azan timing | Medium | See §4 **[VERIFY]**; needs Play declaration if used |
| `RECEIVE_BOOT_COMPLETED` | Reschedule after reboot | Low | |
| `PACKAGE_USAGE_STATS` | Detect foreground app | Low-Medium | Special access via Settings; prominent in-app disclosure |
| `SYSTEM_ALERT_WINDOW` | Overlay | Medium | Special access via Settings; declare purpose |
| `FOREGROUND_SERVICE` + `_SPECIAL_USE` | Blocker window | Medium | Declaration + video |
| `QUERY_ALL_PACKAGES` | App picker | Medium-High | Avoid; use `<queries>` |
| AccessibilityService | (not in MVP) | **High** | Optional later, full disclosure |
| `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` | (not used) | High | Deep-link to OEM settings instead |
| Full-screen intent | (optional) | High | Don't depend on it |

**Play Console prep:** privacy policy, Data safety form (accurate), permission declarations, foreground-service declaration + demo video, exact-alarm justification if applicable. Store copy: avoid the word "blocker"; use "Prayer Mode / digital focus for salah".

**Onboarding rule:** reason-first cards, never more than 2 permissions per session. Order: location -> notifications -> alarms -> battery guide -> (only when the user enables Prayer Mode) usage access -> overlay. Expect high drop-off at Usage Access, so use screenshot-guided instructions.

---

## 7. Database (Drift)

```
UserSettings     id, latitude, longitude, timezoneId, city, country,
                 calcMethod, madhab, highLatRule, adjustments(json),
                 azanSound, blockWindowMinutes, language, theme,
                 notificationsEnabled, blockerEnabled

PrayerDay        date, timezoneId, calcMethod, madhab,
                 fajr, sunrise, dhuhr, asr, maghrib, isha   (UTC instants)

PrayerRecord     id, date, prayer, status(pending|prayed|late|missed),
                 loggedAt, source(manual|notification|overlay),
                 wasBlockerActive, blockAttempts

BlockedApp       packageName, appName, enabled

BlockSession     id, prayer, startedAt, endedAt, confirmed, blockedAttempts
```

- Streaks are computed from `PrayerRecord`, never stored as the only source of truth.
- Blocker rules (package list, window, per-prayer toggles) are also mirrored to native `SharedPreferences` so Kotlin can read them without Flutter running.
- "Delete all my data" button in Settings.

---

## 8. Screens and UX

**Screens:** Splash -> Onboarding -> Home -> Prayer Times / Month view -> Prayer Mode setup (apps, prayers, window, allowlist) -> Overlay (native) -> Prayer log / Stats -> Settings -> Health check.

**Home:** current and next prayer, live countdown, today's five prayers with status, Prayer Mode pill (armed / inactive).

**Design:** dark-first, Material 3, calm palette, no gamified competition or guilt language.

**Localization:** English + Urdu at MVP (RTL; use `EdgeInsetsDirectional`), Arabic later. Urdu font: Noto Nastaliq Urdu. Toggle for Western vs Eastern digits.

---

## 9. Privacy, Security, Monetization

- Location, blocked-app list, usage events and prayer log stay **on device**. Usage data is used in memory only, never stored or transmitted.
- Privacy policy must disclose location, usage access, overlay, exact alarms and Crashlytics.
- No ads. Freemium later. Free: prayer times, Azan, basic Prayer Mode (for example 3 apps). Premium (one-time purchase preferred): more Azan voices, themes, advanced stats, unlimited blocked apps, widgets. Never paywall the Azan.

---

## 10. Testing Plan

- **Prayer accuracy:** golden dataset (Faisalabad, Lahore, Karachi, Islamabad, London, New York, Dubai, Tromsø) vs reference tables; tolerance about ±1 min.
- **Timezones:** Asia/Karachi, Asia/Dubai, Europe/London, America/New_York, DST transition dates.
- **Alarms:** developer-mode "Test Azan in 10 s"; test screen off, locked, app killed, reboot, timezone change, battery saver, Doze (`adb shell dumpsys deviceidle force-idle`).
- **Blocker:** Instagram, WhatsApp, TikTok, YouTube, Chrome; launch via notification, recents, share sheet; split-screen; revoke permissions mid-session; window expiry auto-lift; no overlay stacking.
- **OEM matrix:** Pixel/Samsung, Xiaomi/Redmi/POCO, Oppo/Realme, Vivo, Infinix/Tecno.
- **Beta:** closed track, 50-100 users, with an in-app one-tap "Did your Azan fire today?" report.

---

## 11. Roadmap (solo, part-time)

| Phase | Scope | Est. |
|---|---|---|
| 0 | Prototype the risky parts: `setAlarmClock` test + UsageStats overlay on a real phone | 1 week |
| 1 | Project setup, Riverpod, prayer engine, location, settings, home screen, l10n (en/ur) | 2-3 weeks |
| 2 | Azan engine: native scheduler, permissions flow, boot receivers, notification, health-check | 2-3 weeks |
| 3 | Prayer Mode: monitor service, overlay, app picker, allowlist, MethodChannel bridge | 3 weeks |
| 4 | Tracking + stats (Drift), notification and overlay actions | 1-2 weeks |
| 5 | Onboarding polish, OEM guides, dark/RTL, Play declarations, privacy policy, closed beta | 2-3 weeks |
| 6 | Launch and iterate (widget, voices, premium) | ongoing |

**Total to MVP:** about 10-14 weeks. Phases 2 and 3 carry the schedule risk.

---

## 12. Open Questions and To-Verify List

1. `setAlarmClock` and the exact-alarm permission on Android 12-15 (read the official AlarmManager docs).
2. `adhan_dart`: current version, exact API names for Karachi/Hanafi and high-latitude rules.
3. Foreground service `specialUse`: exact manifest subtype property and Play declaration wording.
4. Usage events: `ACTIVITY_RESUMED` availability (API 29+) and behavior on Samsung/Xiaomi.
5. Background activity launch rules with `SYSTEM_ALERT_WINDOW` on Android 14-15.
6. Play Store check for "Just Pray" and its Prayer Focus feature.
7. App package name and availability: `com.fahadapps.waqt` (not yet checked). Also check Play Store search, `.com` domain, Instagram/TikTok handle for "Waqt".
8. Final Azan audio: licensing of the recordings.

---

## Changelog

- v0.1 - Initial draft (name: Waqt; Android-only; Flutter + Kotlin)

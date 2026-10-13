# Waqt — Phase 2 Roadmap (Improved)

**Status:** Closed testing live (1.0.0)  
**Goal:** Testers ko 100% bharosemand Azan dena + app ko production-ready banana.  
**Core Rule:** Har release se pehle Section 6 ki checklist poori karni hai. "verify" likha ho to pehle code/docs check karo.

---

## 0. Release Plan (ek nazar mein)

| Release | Maqsad                                      | Items     | Kab                  |
| ------- | ------------------------------------------- | --------- | -------------------- |
| 1.0.1   | Testers ka sabse bara masla theek karna     | A1 – A8   | Sabse pehle          |
| 1.0.2   | Testing ke dauran feedback aur features     | B1 – B7   | Testing ke dauran    |
| 1.1     | Polish aur bari features                    | C1 – C6   | Production ke baad   |
| 1.2+    | Advanced / long-term                        | D1 – D4   | Future               |

**Asool:** 1.0.1 mein koi nayi feature nahi. Sirf "jo wada kiya tha wo poora karo" aur "alarm marne ki wajahen band karo".

---

## 1. Release 1.0.1 — Tester-blocking fixes

### A1. Asli permission flow (sabse zaroori)

**Masla:** Onboarding ka "Enable Azan alerts" button sirf agle step par le jata hai. Android 13+ par notification permission ke baghair Azan nahi bajta, aur tester ko pata bhi nahi chalta.

**Hal (tarteeb zaroori hai):**

1. Notification permission (Android 13+): native `requestNotificationPermission` use karo (pehle se maujood hai). Android 12 ya kam par ye step khud skip ho.
2. Exact alarm: `AlarmManager.canScheduleExactAlarms()` check karo. Agar false ho to `ACTION_REQUEST_SCHEDULE_EXACT_ALARM` settings screen kholo. (Android 14 par ye naye installs ko by default nahi milti.)
3. Full-screen intent (Android 14+): `NotificationManager.canUseFullScreenIntent()` check karo. False ho to `ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT` kholo. Iske baghair lock screen par Azan screen nahi aati, sirf notification aati hai.
4. Battery optimization: seedha system dialog (`REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`) par mat jao, Play policy isse restrict karti hai. Iski jagah `ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS` ki list kholo aur user ko samjhao ke "Waqt" ko "Unrestricted/Don't optimize" karna hai.
5. Phir A4 (phone brand guide) dikhao.

**Behaviour ke qawaid:**

- Har step se pehle current status check karo; pehle se granted ho to step skip.
- User "Deny" kare to dobara na pooche; "Open settings" ka button dikhao (permanently denied case).
- Settings se wapas aane par `AppLifecycleState.resumed` par status dobara check karo aur UI update karo.
- Har step par "Skip" ho, lekin skip karne par Home par saaf warning chip dikhe ("Azan alerts band hain").
- Onboarding ke baad ka Health Check screen isi logic ko dobara use kare (ek hi code, do jagah).

**Acceptance:**

- Fresh install (Android 13/14/15) par Azan sirf onboarding se bina Health Check ke bajta hai.
- Notification deny karne par app crash nahi karti aur warning dikhati hai.
- Settings se permission on karke wapas aane par screen khud update hoti hai.

---

### A2. "Allow location" ka faisla

**Masla:** Button jhoota wada karta hai kyunke location ka code hi nahi hai.

**Mera mashwara:** 1.0.1 mein button hata do, sirf "Choose city" rakho.  
Wajah: asli location ke saath Privacy Policy, Terms aur Play Data safety form badalna parta hai, aur ye 1.0.1 ko bhari bana dega. Pakistan ke liye city-based timings kaafi accurate hain.

- Asli location B1 mein lagao (agar tum chaho).
- Onboarding mein location ka koi text/icon na bache jo permission ka tassur de.

**Acceptance:** App mein koi bhi button aisa na ho jo kuch kiye baghair agle step par le jaye.

---

### A3. Alarm reliability layer

Ye cheezein user ko nazar nahi aatin lekin Azan marne ki asal wajah yahi hoti hain. Sab "verify" karo:

1. **Reboot ke baad:** `RECEIVE_BOOT_COMPLETED` receiver, jo saare alarms dobara schedule kare.
2. **App update ke baad:** `MY_PACKAGE_REPLACED` par bhi reschedule (warna 1.0.1 install karte hi purane alarms ud jayenge).
3. **Waqt/timezone badalne par:** `TIMEZONE_CHANGED`, `TIME_SET`, `DATE_CHANGED` par reschedule.
4. **Rolling window:** sirf agle 3–7 din ke alarms schedule karo aur app khulne/boot par window aage barhao. (Aik sath mahine ke alarms mat lagao.)
5. **Notification channel:** channel ki sound/importance ek baar ban jaye to code se badli nahi ja sakti. Agar sound ya importance badalni ho to naya channel ID banao.
6. **Foreground service (Android 14+):** Azan audio service ka type `mediaPlayback` ho aur manifest mein `FOREGROUND_SERVICE_MEDIA_PLAYBACK` ho.
7. **Audio:** audio focus lo aur khatam hone par chhor do; volume/mute ka behaviour tumhari pehle wali requirement ke mutabiq (mute = awaaz nahi, vibration + notification).
8. **Duplicate alarms:** ek hi prayer ke do alarm na lagen (har prayer ki fixed request code).

**Acceptance:** Phone restart, app update, aur time zone badalne ke baad agla Azan sahi waqt par bajta hai.

---

### A4. Phone brands ki guide (Pakistan ke liye)

In-app screen "Azan band ho jaye to?" jismein brand detect karke (`Build.MANUFACTURER`) sahi steps dikhaye.  
Menu ke naam Android version ke hisab se mukhtalif ho sakte hain, isliye asli phones par verify karo.  
Reference: dontkillmyapp.com

| Brand                  | Kya karna hai |
| ---------------------- | ------------- |
| Xiaomi / Redmi / Poco  | Autostart on, Battery saver mein "No restrictions", app ko recents mein lock, "Show on lock screen" aur "Display pop-up windows while running in background" allow |
| Oppo / Realme          | Auto-launch on, Battery mein background activity allow |
| Vivo / iQOO            | Autostart on, "High background power consumption" allow |
| Samsung                | "Never sleeping apps" mein Waqt add, "Put unused apps to sleep" band |
| Infinix / Tecno / Itel | Phone Master/Battery settings mein Autostart on aur app lock |
| Pixel / baqi           | Battery "Unrestricted" kaafi hai |

**Tareeqa:** Har brand ke liye 3 chhote steps, ek "Open app settings" button, aur ek "Test Azan (1 minute baad)" button taake user confirm kar sake.

**Acceptance:** Kam az kam 2 non-Pixel phones par steps ke baad screen-off Azan test pass ho.

---

### A5. Tester feedback aur diagnostics

- Settings mein "Report a problem" button (mailto ya Google Form link), jo phone model, Android version, app version, aur permission status khud likh de.
- Health Check mein status ek nazar mein: notification, exact alarm, full-screen, battery, next scheduled alarm ka waqt.
- Crashlytics: release build mein chal raha hai ya nahi, ye A6 se pehle confirm karo.

---

### A6. Play Console aur release compliance

- **Permission declarations:** `USE_FULL_SCREEN_INTENT`, exact alarm (`SCHEDULE_EXACT_ALARM` ya `USE_EXACT_ALARM`), foreground service. Console mein jo declaration maange wahan saaf likho: "Azan alarm app, prayer time par user-set alarm".
- `USE_EXACT_ALARM` sirf alarm/calendar jaise apps ke liye allowed hai; Play ki current policy check karke ek hi option chuno.
- Data safety form: jo data jama hota hai (Firebase/Crashlytics) wahi likho.
- Privacy Policy ka URL maujood aur chalta hua ho.
- Target SDK Play ki maujooda requirement ke mutabiq ho (Console warning dekho).
- Release build par ProGuard/R8 ke baad native code (EventChannel, receivers) ka test, kyunke debug mein chalne wali cheez release mein toot sakti hai.
- `pubspec.yaml` mein build number badhao aur release isi closed track mein dalo.

---

### A7. Azan screen reliability (naya)

**Masla:** Reported issue – asli Azan par Home khulti hai, Azan screen nahi (screen off ho tab bhi).

**Hal:**
- Full-screen intent aur activity flags (`showWhenLocked`, `turnScreenOn`, `FLAG_SHOW_WHEN_LOCKED`, `FLAG_TURN_SCREEN_ON`) verify karo.
- A1 ke step 3 ke baad dobara test karo.
- Screen off + locked + app killed state pe test.

**Acceptance:** Lock screen par Azan screen reliably aati hai.

---

### A8. "I prayed" + Reminder flow fix

- Azan ke baad agar user mark na kare to reminder (10/20/30 min) sahi se aaye.
- "I prayed" se alarm cancel + prayer log save.
- Duplicate reminders na aayein.

**Acceptance:** Reminder flow stable hai aur "I prayed" se state correctly update hoti hai.

---

## 2. Release 1.0.2 — Testing ke dauran

### B1. Asli location (optional)

- Sirf foreground, approximate/coarse location; background location nahi.
- Nazdeeki city ya coordinates, aur manual "Choose city" hamesha fallback rahe.
- Permission deny ho to app bilkul theek chale.
- Timezone ka khayal (musafir user ke liye).
- Saath mein: Privacy Policy, Terms aur Data safety form update.
- Package (jaise `geolocator`) lagane se pehle tumse manzoori leni hai.

### B2. Urdu ki safai

- Maujooda `t()` map ko mat chhero.
- Baqi raw English `Text(...)` ka Urdu add karo.
- RTL check: alignment, icons ki simt, numbers, Urdu font ki line-height (Nastaliq ka text kat jata hai).
- Prayer names ka Urdu aur Home par har namaz ke saath tick box ("maine parh li").
- Acceptance: Urdu mode mein koi English string na bache (sirf brand name).

### B3. Prayer calculation settings

- Pakistan ke liye default calculation method aur Asr (Hanafi/Shafi) verify karo aur user ko choose karne do.
- Har namaz ke liye manual minutes offset (±) taake local masjid ke waqt se milaya ja sake.
- Acceptance: kisi ek mustanad local timetable se muqabla kar ke fark documented ho.

### B4. Azan screen ka masla

- Reported issue: asli Azan par Home khulti hai, Azan screen nahi.  
  Full-screen intent aur activity flags ke saath debug karo (A7 ke baad dobara test).

### B5. Crashlytics aur feedback

- Har hafte crashes aur testers ki rai dekho, sabse zyada impact wala pehle theek karo.
- 12 testers ka 14 din ka opt-in count barqarar rakho (Play Console Dashboard par exact requirement apne account ke hisab se check karo).

### B6. Basic Prayer Log & Streaks

- Month calendar view.
- Simple streak counter (guilt-free language).
- "I prayed" se auto log.

### B7. Health Check improvements

- Last Azan fired time dikhao.
- "Test Azan now" button.

---

## 3. Release 1.1 — Polish + bari features

| Item | Description |
|------|-------------|
| C1   | Short tone aur Azan options ki polish (abhi 4 files: makkah, madinah, aqsa, fajr) + volume control |
| C2   | Qibla compass ki calibration hint aur accuracy indicator |
| C3   | Home screen Widget (next prayer + countdown) |
| C4   | Multiple Azan voices + custom sound support |
| C5   | Hijri date + basic Ramadan mode (Imsak / Iftar) |
| C6   | Prayer Mode blocker (Phase G): design, native service, `SYSTEM_ALERT_WINDOW`, Play ki nayi declarations, alag release. Sabse zyada waqt aur policy risk, isliye akhir mein. |

---

## 4. Future (1.2+)

- D1. Prayer Mode full implementation (UsageStats + Overlay + specialUse FGS)
- D2. Advanced stats + export
- D3. Light theme
- D4. iOS version (agar demand ho)

---

## 5. Test matrix

| Cheez           | Kam az kam |
| --------------- | ---------- |
| Android version | 12, 13, 14, 15 |
| Brands          | Pixel 7a (maujood), ek Xiaomi/Redmi, ek Samsung, ek Oppo/Vivo/Infinix |
| States          | Screen on, screen off/locked, silent, DND, battery saver, app swiped from recents |

---

## 6. Har release ke test scenarios

1. Fresh install, saari permissions allow karke Azan.
2. Notification deny karke app ka behaviour.
3. Phone restart ke baad agla Azan.
4. App update ke baad agla Azan.
5. Silent/DND mein behaviour.
6. Lock screen par Azan screen, Pause, Stop, "I prayed".
7. Time zone badalna.
8. Data delete par saare alarms band.

---

## 7. Release checklist

- [ ] `flutter analyze` aur `flutter test` saaf
- [ ] Release build real phone par chala kar dekha (debug nahi)
- [ ] Build number barha
- [ ] Section 6 ke scenarios pass
- [ ] Play declarations aur Data safety form current
- [ ] Release notes (testers ke liye saaf aur chhote)
- [ ] Crashlytics release build mein working

---

## 8. Risks

| Risk                                  | Asar                 | Bachao                   |
| ------------------------------------- | -------------------- | ------------------------ |
| OEM battery killers                   | Azan miss            | A4 guide + test button   |
| Full-screen intent/exact alarm policy | Play review reject   | A6 mein saaf declaration |
| Location ka jaldi shamil karna        | Policy/forms ka bojh | A2: pehle button hatao   |
| Alarm duplicates                      | Do Azan              | Fixed request codes      |
| Prayer Mode complexity                | Long delay + policy  | Last mein alag release   |

---

## 9. Pending faisle

- A2: abhi location button hatana (mera mashwara) ya asli location lagana?
- B1: asli location kab aur kis package ke saath?
- Prayer Mode: 1.1 mein shuru karein ya 1.2?
- Database: SharedPreferences se Drift pe migrate kab?

---

**Last updated:** 13 October 2026  
**Author:** Fahad Apps + AI-assisted improvements

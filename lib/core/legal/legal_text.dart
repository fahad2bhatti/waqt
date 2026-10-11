// Same text as docs/terms.md and docs/privacy.md (those are published online).
// When you change one, change the other too.

/// Bump this when the terms or privacy policy change in a way users must
/// re-accept. The agreement screen shows again when it differs from the
/// version the user accepted.
const kTermsVersion = '2026-10-11';

const termsText = r'''# Terms & Conditions

Last updated: 11 October 2026

Please read these terms carefully. By tapping "Agree and continue" or by using Waqt, you agree to them. If you do not agree, please do not use the app.

## 1. About Waqt
Waqt is a free app that shows prayer times, plays the Azan, reminds you to pray, tracks your prayers on your phone and shows the Qibla direction. It is developed by Fahad Apps in Faisalabad, Pakistan ("we", "us").

## 2. License to use the app
We grant you a personal, non-exclusive, non-transferable, revocable license to install and use Waqt on your own devices for your own non-commercial use, under these terms. Waqt is licensed, not sold.

## 3. What you may not do
- Copy, modify or create derivative works of the app, except as the law allows or as an open-source license for a part of it allows
- Reverse engineer, decompile or try to extract the source code, except where the law allows it
- Sell, rent, sublicense or redistribute the app, or publish it under another name
- Use the app in a way that is unlawful or that interferes with its operation or other people's use of it
- Remove copyright or credit notices

## 4. Prayer times, Qibla and Azan: please verify
Waqt is a helper, not a religious authority.
- Prayer times are calculated on your phone from the city, calculation method, Asr setting and adjustments you choose. Different methods and local practice give different times. Please confirm times with your local mosque or scholars, especially for Fajr, Isha, Ramadan and Eid.
- The Qibla compass depends on your phone's sensors. Metal, magnets, cases and poor calibration can make it inaccurate.
- The Azan and reminders depend on your phone. Battery saving, Do Not Disturb, silent mode, denied permissions or manufacturer restrictions may delay or stop them. Please check "Azan protection" in Settings, and do not rely on Waqt as your only way of knowing prayer time.
- Prayer tracking and streaks are a personal aid. They are not a religious record or judgement.

## 5. Permissions
For the app to work you may need to allow notifications, exact alarms and full-screen notifications. You can change these in your phone's Settings at any time, but some features may stop working. See the Privacy Policy for details.

## 6. Features and changes
Waqt is provided free of charge. We may add, change or remove features, including features marked "coming soon", at any time, and may update or stop the app. We do not promise that any planned feature will be released.

## 7. Third-party materials
Waqt includes open-source software, fonts and audio recordings that belong to their respective owners and remain under their own licenses. Open-source licenses are listed under Settings > Licenses. Nothing in these terms gives you any rights in third-party materials.

## 8. Intellectual property
The Waqt name, logo, design and code belong to Fahad Apps, except for third-party materials. These terms do not give you ownership of any of them.

## 9. Disclaimer
Waqt is provided "as is" and "as available", without warranties of any kind, express or implied, including accuracy, reliability, availability and fitness for a particular purpose. We do not promise that the app will be error-free or uninterrupted, or that alarms will always start on time.

## 10. Limitation of liability
To the fullest extent permitted by law, Fahad Apps is not liable for any indirect, incidental or consequential loss, or for any loss arising from missed, late or incorrect prayer times, Azan, reminders or Qibla direction, or from your use of or inability to use the app. Nothing in these terms limits any right you have under the law that cannot be limited.

## 11. Ending these terms
You can stop using Waqt at any time by uninstalling it. We may end or restrict your license if you break these terms. Sections that by their nature should continue (such as sections 7 to 10) will continue after that.

## 12. Changes to these terms
We may update these terms. The date at the top shows the latest version. If a change is significant, the app will ask you to agree again before you continue.

## 13. Governing law
These terms are governed by the laws of Pakistan. Any dispute will be handled by the courts of Pakistan, unless the law of your country gives you the right to bring a claim elsewhere.

## 14. Contact
Fahad Apps, Faisalabad, Pakistan
Email: fahadsaeed2622@gmail.com
''';

const privacyText = r'''# Privacy Policy

Last updated: 11 October 2026

Waqt ("the app", "we", "us") is a prayer times and Azan app developed by Fahad Apps in Faisalabad, Pakistan. This policy explains what the app does with information. In short: Waqt has no accounts, no ads and no analytics, and your prayer history and settings stay on your phone.

## 1. Information stored on your device
The following is saved only on your phone and is never uploaded to us:
- The city you choose (or, if you allow it, your device location) used to calculate prayer times
- Your calculation method, Asr setting, time adjustments, language and Azan sound choices
- Your prayer log ("I prayed" marks) and streaks
- Prayer Mode settings, when that feature is available
You can erase all of this at any time with Settings > Delete all data, or by uninstalling the app.

## 2. Location
Waqt calculates prayer times on your device. If you grant location permission, your location is used on your phone only to calculate prayer times and the Qibla direction. The app does not send it to us or to any third party.

## 3. Crash reports
Release versions of Waqt use Google's Firebase Crashlytics to receive crash reports so that we can fix bugs. A crash report can include technical details such as your device model, Android version, app version, the state of the app when it crashed, and an installation identifier created by Firebase. We do not add your prayer log, name or contact details to crash reports. This data is processed by Google under its own privacy terms (https://firebase.google.com/support/privacy) and is kept for a limited period.

## 4. Permissions
Waqt asks for the following Android permissions, only for the purpose given:
- Notifications: to show the Azan and reminder notifications
- Exact alarms: to start the Azan at the correct prayer time
- Full-screen notifications: to show the Azan screen when your phone is locked
- Foreground service: to keep the Azan audio playing
- Vibration: to vibrate with the Azan, including when the phone is on silent
- Run at startup: to set your Azan alarms again after your phone restarts or the time zone changes
- Location (optional): see section 2
The compass reads your phone's motion and magnetic sensors to show the Qibla direction. These readings are used live and are not stored or sent anywhere.

## 5. What we do not do
- We do not require an account or ask for your name, phone number or email
- We do not show ads
- We do not sell your information or share it with advertisers
- We do not use analytics or tracking beyond the crash reports described above

## 6. Children
Waqt is a general-audience app and is not directed at children under 13. We do not knowingly collect personal information from children.

## 7. Your choices
- Use Settings > Delete all data to erase everything the app has stored on your phone
- Turn off any permission at any time in your phone's Settings
- Uninstall the app to remove all local data
To ask about crash data or anything else in this policy, contact us (section 9).

## 8. Changes to this policy
We may update this policy as the app changes. The date at the top shows the latest version. If a change is significant, the app will ask you to review it again.

## 9. Contact
Fahad Apps, Faisalabad, Pakistan
Email: fahadsaeed2622@gmail.com
''';

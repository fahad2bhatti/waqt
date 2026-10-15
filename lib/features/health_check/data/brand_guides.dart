/// Background-restriction steps for phones that stop apps aggressively.
/// Android cannot report these settings, so the app can only show the steps.
class BrandGuide {
  const BrandGuide({required this.name, required this.en, required this.ur});

  final String name;
  final List<String> en;
  final List<String> ur;
}

BrandGuide guideFor(String manufacturer) {
  final m = manufacturer.toLowerCase();
  if (m.contains('xiaomi') || m.contains('redmi') || m.contains('poco')) {
    return _xiaomi;
  }
  if (m.contains('oppo') || m.contains('realme')) return _oppo;
  if (m.contains('vivo') || m.contains('iqoo')) return _vivo;
  if (m.contains('samsung')) return _samsung;
  if (m.contains('infinix') || m.contains('tecno') || m.contains('itel')) {
    return _transsion;
  }
  return _other;
}

const _xiaomi = BrandGuide(
  name: 'Xiaomi / Redmi / Poco',
  en: [
    'Open Autostart and turn Waqt on.',
    'Settings > Apps > Manage apps > Waqt > Battery saver: choose No restrictions.',
    'In recent apps, long-press Waqt and tap the lock icon. Also allow Show on lock screen and Display pop-up windows while running in background.',
  ],
  ur: [
    'Autostart کھولیں اور Waqt کو آن کریں۔',
    'Settings > Apps > Manage apps > Waqt > Battery saver میں No restrictions منتخب کریں۔',
    'Recent apps میں Waqt کو دبا کر رکھیں اور لاک کا آئیکن دبائیں۔ Show on lock screen اور Display pop-up windows while running in background کی اجازت بھی دیں۔',
  ],
);

const _oppo = BrandGuide(
  name: 'Oppo / Realme',
  en: [
    'Allow Auto-launch (Startup manager) for Waqt.',
    'Settings > Battery: turn on Allow background activity for Waqt.',
    'Lock Waqt in recent apps.',
  ],
  ur: [
    'Waqt کے لیے Auto-launch (Startup manager) کی اجازت دیں۔',
    'Settings > Battery میں Waqt کے لیے Allow background activity آن کریں۔',
    'Recent apps میں Waqt کو لاک کریں۔',
  ],
);

const _vivo = BrandGuide(
  name: 'Vivo / iQOO',
  en: [
    'Settings > Apps > Autostart: turn Waqt on.',
    'Settings > Battery > Background power consumption management: choose Waqt, then Allow high background power consumption.',
    'Lock Waqt in recent apps.',
  ],
  ur: [
    'Settings > Apps > Autostart میں Waqt کو آن کریں۔',
    'Settings > Battery > Background power consumption management میں Waqt کے لیے Allow high background power consumption منتخب کریں۔',
    'Recent apps میں Waqt کو لاک کریں۔',
  ],
);

const _samsung = BrandGuide(
  name: 'Samsung',
  en: [
    'Settings > Battery > Background usage limits > Never sleeping apps: add Waqt.',
    'Turn off Put unused apps to sleep.',
    'Settings > Apps > Waqt > Battery: choose Unrestricted.',
  ],
  ur: [
    'Settings > Battery > Background usage limits > Never sleeping apps میں Waqt شامل کریں۔',
    'Put unused apps to sleep کو بند کریں۔',
    'Settings > Apps > Waqt > Battery میں Unrestricted منتخب کریں۔',
  ],
);

const _transsion = BrandGuide(
  name: 'Infinix / Tecno / itel',
  en: [
    'In Phone Master or Settings > Battery, turn Autostart on for Waqt.',
    'Settings > Battery > App battery management: set Waqt to No restrictions.',
    'Lock Waqt in recent apps.',
  ],
  ur: [
    'Phone Master یا Settings > Battery میں Waqt کے لیے Autostart آن کریں۔',
    'Settings > Battery > App battery management میں Waqt کو No restrictions پر رکھیں۔',
    'Recent apps میں Waqt کو لاک کریں۔',
  ],
);

const _other = BrandGuide(
  name: 'Pixel / other phones',
  en: [
    'Settings > Apps > Waqt > Battery: choose Unrestricted.',
    'Allow notifications, alarms and full-screen notifications for Waqt.',
    'Run the Azan test below with the screen off to confirm.',
  ],
  ur: [
    'Settings > Apps > Waqt > Battery میں Unrestricted منتخب کریں۔',
    'Waqt کے لیے نوٹیفیکیشنز، الارمز اور فل اسکرین نوٹیفیکیشنز کی اجازت دیں۔',
    'تصدیق کے لیے اسکرین بند کر کے نیچے والا اذان ٹیسٹ چلائیں۔',
  ],
);

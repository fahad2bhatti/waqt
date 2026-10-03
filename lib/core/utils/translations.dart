import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

class TranslationService {
  static const Map<String, Map<String, String>> _localizedValues = {
    'app_title': {
      'en': 'Waqt',
      'ur': 'وقت',
    },
    'home_title': {
      'en': 'Home',
      'ur': 'ہوم',
    },
    'prayer_mode': {
      'en': 'Prayer Mode',
      'ur': 'نماز موڈ',
    },
    'stats': {
      'en': 'Stats',
      'ur': 'اعداد و شمار',
    },
    'settings': {
      'en': 'Settings',
      'ur': 'سیٹنگز',
    },
    'qibla': {
      'en': 'Qibla',
      'ur': 'قبلہ',
    },
    'azan_playing': {
      'en': 'Azan is playing',
      'ur': 'اذان ہو رہی ہے',
    },
    'prayer_started': {
      'en': 'Prayer time has started',
      'ur': 'نماز کا وقت شروع ہو گیا ہے',
    },
    'i_prayed': {
      'en': 'I Prayed',
      'ur': 'میں نے نماز پڑھ لی',
    },
    'stop_azan': {
      'en': 'Stop Azan',
      'ur': 'اذان بند کریں',
    },
    // Settings & General
    'about': {
      'en': 'About',
      'ur': 'ہمارے بارے میں',
    },
    'language': {
      'en': 'Language',
      'ur': 'زبان',
    },
    'azan_sound': {
      'en': 'Azan Sound',
      'ur': 'اذان کی آواز',
    },
    'adjustments': {
      'en': 'Adjustments',
      'ur': 'ترمیم',
    },
    'delete_data': {
      'en': 'Delete All Data',
      'ur': 'تمام ڈیٹا ڈیلیٹ کریں',
    },
    // Health Check
    'azan_protection': {
      'en': 'Azan Protection',
      'ur': 'اذان پروٹیکشن',
    },
    'protection_desc': {
      'en': 'Everything Waqt needs to reach you on time.',
      'ur': 'وقت کو وقت پر پہنچنے کے لیے ہر چیز کی ضرورت ہے۔',
    },
    'health_ready': {
      'en': 'ready',
      'ur': 'تیار ہے',
    },
    'health_fix': {
      'en': 'Fix the rest for reliable Azan.',
      'ur': 'اذان کی یقین دہانی کے لیے باقی چیزیں درست کریں۔',
    },
    'health_ok': {
      'en': 'On',
      'ur': 'آن',
    },
    'health_not_ok': {
      'en': 'Fix',
      'ur': 'درست کریں',
    },
    // Tracking & Stats
    'prayer_log': {
      'en': 'Prayer log',
      'ur': 'نماز کا ریکارڈ',
    },
    'streak_day': {
      'en': 'day streak',
      'ur': 'دن کی اسٹریک',
    },
    'streak_start': {
      'en': 'Log all 5 prayers today to start a streak',
      'ur': 'اسٹریک شروع کرنے کے لیے آج کی پانچوں نمازیں ریکارڈ کریں',
    },
    'streak_complete': {
      'en': 'All 5 prayers logged',
      'ur': 'پانچوں نمازیں ریکارڈ ہو گئیں',
    },
    // Prayer Mode
    'mode_title': {
      'en': 'Prayer Mode',
      'ur': 'نماز موڈ',
    },
    'mode_desc': {
      'en': 'Pause distracting apps during prayer time.',
      'ur': 'نماز کے وقت توجہ ہٹانے والی ایپس کو روکیں۔',
    },
    'apps_to_pause': {
      'en': 'APPS TO PAUSE',
      'ur': 'روکنے والی ایپس',
    },
    'choose_apps': {
      'en': 'Choose apps',
      'ur': 'ایپس منتخب کریں',
    },
    'prayer_window': {
      'en': 'PRAYER WINDOW',
      'ur': 'نماز کا وقت',
    },
    'duration': {
      'en': 'Duration',
      'ur': 'دورانیہ',
    },
    'preview_overlay': {
      'en': 'Preview overlay',
      'ur': 'اوورلے دیکھیں',
    },
    'always_allowed': {
      'en': 'Always allowed: Phone, SMS, Maps',
      'ur': 'ہمیشہ اجازت: فون، ایس ایم ایس، میپس',
    },
    // Qibla
    'qibla_direction': {
      'en': 'Qibla Direction',
      'ur': 'قبلہ کی سمت',
    },
    'calibrate_compass': {
      'en': 'Calibrate your compass',
      'ur': 'اپنا کمپاس درست کریں',
    },
    // Onboarding
    'welcome': {
      'en': 'Welcome to Waqt',
      'ur': 'وقت میں خوش آمدید',
    },
    'get_started': {
      'en': 'Get Started',
      'ur': 'شروع کریں',
    },
    'make_time': {
      'en': 'Make time for prayer',
      'ur': 'نماز کے لیے وقت نکالیں',
    },
    'onboard_1_body': {
      'en': 'Accurate prayer times and a calm reminder when it matters most.',
      'ur': 'نماز کے درست اوقات اور ایک پرسکون یاد دہانی جب اس کی سب سے زیادہ ضرورت ہو۔',
    },
    'onboard_2_title': {
      'en': 'Your prayer times',
      'ur': 'آپ کے نماز کے اوقات',
    },
    'onboard_2_body': {
      'en': 'We calculate Salah times on your phone from your location. Nothing is uploaded.',
      'ur': 'ہم آپ کے مقام سے آپ کے فون پر نماز کے اوقات کا حساب لگاتے ہیں۔ کچھ بھی اپ لوڈ نہیں کیا جاتا۔',
    },
    'onboard_2_primary': {
      'en': 'Allow location',
      'ur': 'لوکیشن کی اجازت دیں',
    },
    'onboard_2_secondary': {
      'en': 'Choose city manually',
      'ur': 'شہر دستی طور پر منتخب کریں',
    },
    'onboard_3_title': {
      'en': 'Calculation settings',
      'ur': 'حساب کی ترتیبات',
    },
    'onboard_3_body': {
      'en': 'Pakistan defaults are selected. You can change these anytime.',
      'ur': 'پاکستان کے ڈیفالٹ سیٹنگز منتخب ہیں۔ آپ انہیں کسی بھی وقت تبدیل کر سکتے ہیں۔',
    },
    'onboard_3_primary': {
      'en': 'Continue',
      'ur': 'جاری رکھیں',
    },
    'onboard_4_title': {
      'en': 'Never miss the Azan',
      'ur': 'اذان کبھی نہ چھوڑیں',
    },
    'onboard_4_body': {
      'en': 'Waqt needs permission for notifications and exact alarms so the Azan plays on time.',
      'ur': 'وقت کو نوٹیفیکیشنز اور درست الارم کے لیے اجازت چاہیے تاکہ اذان وقت پر چلے۔',
    },
    'onboard_4_primary': {
      'en': 'Enable Azan alerts',
      'ur': 'اذان الرٹس فعال کریں',
    },
    'onboard_4_secondary': {
      'en': 'Maybe later',
      'ur': 'شاید بعد میں',
    },
    'onboard_5_title': {
      'en': 'Protect your prayer time',
      'ur': 'اپنی نماز کے وقت کی حفاظت کریں',
    },
    'onboard_5_body': {
      'en': 'Prayer Mode covers apps you choose during prayer. Nothing is stored or sent anywhere.',
      'ur': 'نماز موڈ نماز کے دوران آپ کی منتخب کردہ ایپس کو روکتا ہے۔ کچھ بھی کہیں محفوظ یا بھیجا نہیں جاتا۔',
    },
    'onboard_5_primary': {
      'en': 'Enable Prayer Mode',
      'ur': 'نماز موڈ فعال کریں',
    },
    'onboard_5_secondary': {
      'en': 'Maybe later',
      'ur': 'شاید بعد میں',
    },
    'jummah': {
      'en': 'Jummah',
      'ur': 'جمعہ',
    },
  };

  static String translate(String key, String language) {
    final lang = language == 'Urdu' ? 'ur' : 'en';
    return _localizedValues[key]?[lang] ?? key;
  }
}

final translationProvider = Provider<String Function(String)>((ref) {
  final language = ref.watch(languageProvider);
  return (key) => TranslationService.translate(key, language);
});

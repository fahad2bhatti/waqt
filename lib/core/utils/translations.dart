import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqt/features/settings/providers/language_provider.dart';

class TranslationService {
  static const Map<String, Map<String, String>> _localizedValues = {
    'app_title': {'en': 'Waqt', 'ur': 'وقت'},
    'home_title': {'en': 'Home', 'ur': 'ہوم'},
    'prayer_mode': {'en': 'Prayer Mode', 'ur': 'نماز موڈ'},
    'stats': {'en': 'Stats', 'ur': 'اعداد و شمار'},
    'settings': {'en': 'Settings', 'ur': 'سیٹنگز'},
    'qibla': {'en': 'Qibla', 'ur': 'قبلہ'},
    'azan_playing': {'en': 'Azan is playing', 'ur': 'اذان ہو رہی ہے'},
    'prayer_started': {
      'en': 'Prayer time has started',
      'ur': 'نماز کا وقت شروع ہو گیا ہے',
    },
    'i_prayed': {'en': 'I Prayed', 'ur': 'میں نے نماز پڑھ لی'},
    'stop_azan': {'en': 'Stop Azan', 'ur': 'اذان بند کریں'},
    // Settings & General
    'about': {'en': 'About', 'ur': 'ہمارے بارے میں'},
    'language': {'en': 'Language', 'ur': 'زبان'},
    'azan_sound': {'en': 'Azan Sound', 'ur': 'اذان کی آواز'},
    'adjustments': {'en': 'Adjustments', 'ur': 'ترمیم'},
    'delete_data': {'en': 'Delete All Data', 'ur': 'تمام ڈیٹا ڈیلیٹ کریں'},
    // Health Check
    'azan_protection': {'en': 'Azan Protection', 'ur': 'اذان پروٹیکشن'},
    'protection_desc': {
      'en': 'Everything Waqt needs to reach you on time.',
      'ur': 'وقت کو وقت پر پہنچنے کے لیے ہر چیز کی ضرورت ہے۔',
    },
    'health_ready': {'en': 'ready', 'ur': 'تیار ہے'},
    'health_fix': {
      'en': 'Fix the rest for reliable Azan.',
      'ur': 'اذان کی یقین دہانی کے لیے باقی چیزیں درست کریں۔',
    },
    'health_ok': {'en': 'On', 'ur': 'آن'},
    'health_not_ok': {'en': 'Fix', 'ur': 'درست کریں'},
    // Tracking & Stats
    'prayer_log': {'en': 'Prayer log', 'ur': 'نماز کا ریکارڈ'},
    'streak_day': {'en': 'day streak', 'ur': 'دن کی اسٹریک'},
    'streak_start': {
      'en': 'Log all 5 prayers today to start a streak',
      'ur': 'اسٹریک شروع کرنے کے لیے آج کی پانچوں نمازیں ریکارڈ کریں',
    },
    'streak_complete': {
      'en': 'All 5 prayers logged',
      'ur': 'پانچوں نمازیں ریکارڈ ہو گئیں',
    },
    // Prayer Mode
    'coming_soon': {'en': 'Coming soon', 'ur': 'جلد آ رہا ہے'},
    'mode_coming_soon_body': {
      'en':
          'Prayer Mode will pause the apps you choose during prayer. It is coming in a future update.',
      'ur':
          'نماز موڈ نماز کے وقت آپ کی منتخب کردہ ایپس کو روک دے گا۔ یہ آنے والی اپڈیٹ میں شامل ہوگا۔',
    },
    'mode_title': {'en': 'Prayer Mode', 'ur': 'نماز موڈ'},
    'mode_desc': {
      'en': 'Pause distracting apps during prayer time.',
      'ur': 'نماز کے وقت توجہ ہٹانے والی ایپس کو روکیں۔',
    },
    'apps_to_pause': {'en': 'APPS TO PAUSE', 'ur': 'روکنے والی ایپس'},
    'choose_apps': {'en': 'Choose apps', 'ur': 'ایپس منتخب کریں'},
    'prayer_window': {'en': 'PRAYER WINDOW', 'ur': 'نماز کا وقت'},
    'duration': {'en': 'Duration', 'ur': 'دورانیہ'},
    'preview_overlay': {'en': 'Preview overlay', 'ur': 'اوورلے دیکھیں'},
    'always_allowed': {
      'en': 'Always allowed: Phone, SMS, Maps',
      'ur': 'ہمیشہ اجازت: فون، ایس ایم ایس، میپس',
    },
    // Qibla
    'qibla_direction': {'en': 'Qibla Direction', 'ur': 'قبلہ کی سمت'},
    'calibrate_compass': {
      'en': 'Calibrate your compass',
      'ur': 'اپنا کمپاس درست کریں',
    },
    // Onboarding
    'welcome': {'en': 'Welcome to Waqt', 'ur': 'وقت میں خوش آمدید'},
    'get_started': {'en': 'Get Started', 'ur': 'شروع کریں'},
    'make_time': {'en': 'Make time for prayer', 'ur': 'نماز کے لیے وقت نکالیں'},
    'onboard_1_body': {
      'en': 'Accurate prayer times and a calm reminder when it matters most.',
      'ur':
          'نماز کے درست اوقات اور ایک پرسکون یاد دہانی جب اس کی سب سے زیادہ ضرورت ہو۔',
    },
    'onboard_2_title': {'en': 'Your prayer times', 'ur': 'آپ کے نماز کے اوقات'},
    'onboard_2_body': {
      'en':
          'We calculate Salah times on your phone from your location. Nothing is uploaded.',
      'ur':
          'ہم آپ کے مقام سے آپ کے فون پر نماز کے اوقات کا حساب لگاتے ہیں۔ کچھ بھی اپ لوڈ نہیں کیا جاتا۔',
    },
    'onboard_2_primary': {'en': 'Allow location', 'ur': 'لوکیشن کی اجازت دیں'},
    'onboard_2_secondary': {
      'en': 'Choose city manually',
      'ur': 'شہر دستی طور پر منتخب کریں',
    },
    'onboard_3_title': {'en': 'Calculation settings', 'ur': 'حساب کی ترتیبات'},
    'onboard_3_body': {
      'en': 'Pakistan defaults are selected. You can change these anytime.',
      'ur':
          'پاکستان کے ڈیفالٹ سیٹنگز منتخب ہیں۔ آپ انہیں کسی بھی وقت تبدیل کر سکتے ہیں۔',
    },
    'onboard_3_primary': {'en': 'Continue', 'ur': 'جاری رکھیں'},
    'onboard_4_title': {
      'en': 'Never miss the Azan',
      'ur': 'اذان کبھی نہ چھوڑیں',
    },
    'onboard_4_body': {
      'en':
          'Waqt needs a few permissions so the Azan plays on time, even when your phone is locked.',
      'ur':
          'وقت کو چند اجازتیں چاہییں تاکہ فون لاک ہونے پر بھی اذان وقت پر چلے۔',
    },
    'onboard_4_primary': {
      'en': 'Enable Azan alerts',
      'ur': 'اذان الرٹس فعال کریں',
    },
    'onboard_4_secondary': {'en': 'Maybe later', 'ur': 'شاید بعد میں'},
    'alert_notifications': {'en': 'Notifications', 'ur': 'نوٹیفیکیشنز'},
    'alert_exactAlarms': {'en': 'Exact alarms', 'ur': 'درست الارم'},
    'alert_fullScreenIntent': {
      'en': 'Full-screen Azan',
      'ur': 'فل اسکرین اذان',
    },
    'alert_battery': {
      'en': 'Battery: no restrictions',
      'ur': 'بیٹری: کوئی پابندی نہیں',
    },
    'alert_hint_notifications': {
      'en': 'Tap Allow when Android asks.',
      'ur': 'جب اینڈرائیڈ پوچھے تو "اجازت دیں" دبائیں۔',
    },
    'alert_hint_exactAlarms': {
      'en': 'Allow Waqt to set alarms and reminders, then come back.',
      'ur': 'وقت کو الارم اور ریمائنڈر لگانے کی اجازت دیں، پھر واپس آئیں۔',
    },
    'alert_hint_fullScreenIntent': {
      'en': 'Allow Waqt to show full-screen notifications, then come back.',
      'ur': 'وقت کو فل اسکرین نوٹیفیکیشن کی اجازت دیں، پھر واپس آئیں۔',
    },
    'alert_hint_battery': {
      'en':
          'Find Waqt in the list and remove its battery restriction, then come back.',
      'ur':
          'فہرست میں وقت کو تلاش کریں اور اس کی بیٹری پابندی ہٹا دیں، پھر واپس آئیں۔',
    },
    'onboard_5_title': {
      'en': 'Protect your prayer time',
      'ur': 'اپنی نماز کے وقت کی حفاظت کریں',
    },
    'onboard_5_body': {
      'en':
          'Prayer Mode covers apps you choose during prayer. Nothing is stored or sent anywhere.',
      'ur':
          'نماز موڈ نماز کے دوران آپ کی منتخب کردہ ایپس کو روکتا ہے۔ کچھ بھی کہیں محفوظ یا بھیجا نہیں جاتا۔',
    },
    'onboard_5_primary': {
      'en': 'Enable Prayer Mode',
      'ur': 'نماز موڈ فعال کریں',
    },
    'onboard_5_secondary': {'en': 'Maybe later', 'ur': 'شاید بعد میں'},
    'qibla_turn': {
      'en': 'Turn until the marker points up',
      'ur': 'نشان اوپر کی طرف آنے تک گھومیں',
    },
    'qibla_found': {'en': 'Qibla found', 'ur': 'قبلہ مل گیا'},
    'compass_calibrate': {
      'en': 'Move your phone in a figure 8 to calibrate',
      'ur': 'کیلیبریٹ کرنے کے لیے فون کو 8 کی شکل میں گھمائیں',
    },
    'compass_unavailable': {
      'en': 'No compass sensor on this phone',
      'ur': 'اس فون میں کمپاس سینسر نہیں ہے',
    },
    'remind_me_in': {'en': 'Remind me in', 'ur': 'مجھے یاد دلائیں'},
    'min_short': {'en': 'min', 'ur': 'منٹ'},
    'jummah': {'en': 'Jummah', 'ur': 'جمعہ'},
    'Fajr': {'en': 'Fajr', 'ur': 'فجر'},
    'Dhuhr': {'en': 'Dhuhr', 'ur': 'ظہر'},
    'Asr': {'en': 'Asr', 'ur': 'عصر'},
    'Maghrib': {'en': 'Maghrib', 'ur': 'مغرب'},
    'Isha': {'en': 'Isha', 'ur': 'عشاء'},
    'nav_times': {'en': 'Times', 'ur': 'اوقات'},
    'nav_mode': {'en': 'Mode', 'ur': 'موڈ'},
    'nav_stats': {'en': 'Stats', 'ur': 'شماریات'},
    'next_prayer': {'en': 'NEXT PRAYER', 'ur': 'اگلی نماز'},
    'next_label': {'en': 'Next', 'ur': 'اگلی'},
    'starts_in_min': {'en': 'Starts in {m} min', 'ur': '{m} منٹ میں شروع'},
    'starts_in_hm': {
      'en': 'Starts in {h} h {m} min',
      'ur': '{h} گھنٹے {m} منٹ میں شروع',
    },
    'prayer_times': {'en': 'Prayer times', 'ur': 'نماز کے اوقات'},
    'times_caption': {
      'en': '{method} method, {asr} Asr',
      'ur': '{method} طریقہ، {asr} عصر',
    },
    'section_prayer_times': {'en': 'PRAYER TIMES', 'ur': 'نماز کے اوقات'},
    'location': {'en': 'Location', 'ur': 'مقام'},
    'calc_method': {'en': 'Calculation method', 'ur': 'حساب کا طریقہ'},
    'custom': {'en': 'Custom', 'ur': 'حسب ضرورت'},
    'section_azan_mode': {'en': 'AZAN AND MODE', 'ur': 'اذان اور موڈ'},
    'configure': {'en': 'Configure', 'ur': 'ترتیب دیں'},
    'check': {'en': 'Check', 'ur': 'جانچیں'},
    'section_app': {'en': 'APP', 'ur': 'ایپ'},
    'lang_name': {'en': 'English', 'ur': 'اردو'},
    'terms': {'en': 'Terms & Conditions', 'ur': 'شرائط و ضوابط'},
    'privacy': {'en': 'Privacy Policy', 'ur': 'پرائیویسی پالیسی'},
    'licenses': {'en': 'Licenses', 'ur': 'لائسنس'},
    'calc_title': {'en': 'Calculation', 'ur': 'حساب'},
    'calc_desc': {
      'en':
          'Pakistan defaults are Karachi and Hanafi. Times and Azan alarms update as soon as you change these.',
      'ur':
          'پاکستان کے ڈیفالٹ کراچی اور حنفی ہیں۔ آپ کے بدلتے ہی اوقات اور اذان کے الارم اپڈیٹ ہو جاتے ہیں۔',
    },
    'calc_section_method': {'en': 'METHOD', 'ur': 'طریقہ'},
    'calc_section_asr': {'en': 'ASR', 'ur': 'عصر'},
    'method_karachi': {'en': 'Karachi', 'ur': 'کراچی'},
    'method_karachi_note': {
      'en': 'University of Islamic Sciences, Karachi',
      'ur': 'یونیورسٹی آف اسلامک سائنسز، کراچی',
    },
    'method_muslimWorldLeague': {
      'en': 'Muslim World League',
      'ur': 'مسلم ورلڈ لیگ',
    },
    'method_muslimWorldLeague_note': {
      'en': 'Fajr 18°, Isha 17°',
      'ur': 'فجر 18°، عشاء 17°',
    },
    'method_egyptian': {'en': 'Egyptian', 'ur': 'مصری'},
    'method_egyptian_note': {
      'en': 'Egyptian General Authority of Survey',
      'ur': 'مصری جنرل اتھارٹی آف سروے',
    },
    'method_ummAlQura': {'en': 'Umm al-Qura', 'ur': 'ام القریٰ'},
    'method_ummAlQura_note': {
      'en': 'Makkah, Saudi Arabia',
      'ur': 'مکہ مکرمہ، سعودی عرب',
    },
    'method_northAmerica': {'en': 'ISNA', 'ur': 'ISNA'},
    'method_northAmerica_note': {
      'en': 'Islamic Society of North America',
      'ur': 'اسلامک سوسائٹی آف نارتھ امریکا',
    },
    'method_moonsightingCommittee': {
      'en': 'Moonsighting Committee',
      'ur': 'مون سائٹنگ کمیٹی',
    },
    'method_moonsightingCommittee_note': {
      'en': 'Moonsighting Committee Worldwide',
      'ur': 'مون سائٹنگ کمیٹی ورلڈ وائیڈ',
    },
    'asr_hanafi': {'en': 'Hanafi', 'ur': 'حنفی'},
    'asr_hanafi_note': {
      'en': 'Later Asr (shadow = 2x object)',
      'ur': 'دیر سے عصر (سایہ = چیز کا دوگنا)',
    },
    'asr_shafi': {'en': 'Shafi', 'ur': 'شافعی'},
    'asr_shafi_note': {
      'en': 'Earlier Asr (shadow = 1x object)',
      'ur': 'جلدی عصر (سایہ = چیز کے برابر)',
    },
    'adjust_desc': {
      'en': 'Match your local masjid timetable, minute by minute.',
      'ur': 'اپنی مقامی مسجد کے ٹائم ٹیبل سے منٹ بہ منٹ ملائیں۔',
    },
    'sound_Makkah': {'en': 'Makkah', 'ur': 'مکہ'},
    'sound_Madinah': {'en': 'Madinah', 'ur': 'مدینہ'},
    'sound_Al-Aqsa': {'en': 'Al-Aqsa', 'ur': 'مسجد اقصیٰ'},
    'sound_Short tone': {'en': 'Short tone', 'ur': 'مختصر آواز'},
    'selected': {'en': 'Selected', 'ur': 'منتخب'},
    'select': {'en': 'Select', 'ur': 'منتخب کریں'},
    'additional_options': {'en': 'Additional Options', 'ur': 'اضافی آپشنز'},
    'different_fajr': {
      'en': 'Different Azan for Fajr',
      'ur': 'فجر کے لیے الگ اذان',
    },
    'about_data_title': {
      'en': 'Your data stays on this device',
      'ur': 'آپ کا ڈیٹا اسی ڈیوائس پر رہتا ہے',
    },
    'about_data_body': {
      'en':
          'Location, blocked apps and prayer history are never uploaded. Only crash reports are sent, to help us fix bugs.',
      'ur':
          'لوکیشن، بلاک کی گئی ایپس اور نماز کی ہسٹری کبھی اپ لوڈ نہیں ہوتی۔ صرف کریش رپورٹس بھیجی جاتی ہیں تاکہ ہم خرابیاں ٹھیک کر سکیں۔',
    },
    'version': {'en': 'Version', 'ur': 'ورژن'},
    'send_feedback': {'en': 'Send feedback', 'ur': 'رائے بھیجیں'},
    'open': {'en': 'Open', 'ur': 'کھولیں'},
    'link_error': {
      'en': 'Could not open this link',
      'ur': 'یہ لنک نہیں کھل سکا',
    },
    'delete_title': {'en': 'Delete all data?', 'ur': 'تمام ڈیٹا ڈیلیٹ کریں؟'},
    'delete_body': {
      'en':
          'Your prayer log, settings and blocked apps will be removed from this device. This cannot be undone.',
      'ur':
          'آپ کا نماز کا ریکارڈ، سیٹنگز اور بلاک کی گئی ایپس اس ڈیوائس سے ہٹا دی جائیں گی۔ یہ عمل واپس نہیں ہو سکتا۔',
    },
    'delete': {'en': 'Delete', 'ur': 'ڈیلیٹ کریں'},
    'cancel': {'en': 'Cancel', 'ur': 'منسوخ کریں'},
    'choose_city': {'en': 'Choose city', 'ur': 'شہر منتخب کریں'},
    'search_city': {'en': 'Search city', 'ur': 'شہر تلاش کریں'},
    'use_location': {
      'en': 'Use current location',
      'ur': 'موجودہ مقام استعمال کریں',
    },
    'results': {'en': 'RESULTS', 'ur': 'نتائج'},
    'your_week': {'en': 'Your week', 'ur': 'آپ کا ہفتہ'},
    'prayer_consistency': {'en': 'Prayer consistency', 'ur': 'نماز کی پابندی'},
    'per_prayer': {'en': 'PER PRAYER', 'ur': 'ہر نماز'},
    'legend_all': {'en': 'All 5', 'ur': 'پانچوں'},
    'legend_some': {'en': 'Some', 'ur': 'کچھ'},
    'legend_missed': {'en': 'Missed', 'ur': 'رہ گئیں'},
    'health_notifications': {'en': 'Notifications', 'ur': 'نوٹیفیکیشنز'},
    'health_exactAlarms': {'en': 'Exact alarms', 'ur': 'درست الارم'},
    'health_battery': {
      'en': 'Battery: no restrictions',
      'ur': 'بیٹری: کوئی پابندی نہیں',
    },
    'health_usageAccess': {'en': 'Usage access', 'ur': 'یوزیج ایکسس'},
    'health_overlay': {
      'en': 'Display over other apps',
      'ur': 'دوسری ایپس کے اوپر دکھائیں',
    },
    'health_fullScreenIntent': {
      'en': 'Full-screen notifications',
      'ur': 'فل اسکرین نوٹیفیکیشنز',
    },
    'test_azan': {'en': 'Test Azan (10 s)', 'ur': 'اذان ٹیسٹ (10 سیکنڈ)'},
    'test_scheduled': {
      'en': 'Test Azan scheduled for 10s',
      'ur': 'ٹیسٹ اذان 10 سیکنڈ میں بجے گی',
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

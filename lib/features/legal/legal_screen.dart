import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:retainly/l10n/app_localizations.dart';

class LegalScreen extends ConsumerWidget {
  final String documentKey;
  const LegalScreen({super.key, required this.documentKey});

  String _title(AppLocalizations l10n) {
    switch (documentKey) {
      case 'privacy_policy':
        return l10n.privacyPolicy;
      case 'terms_of_service':
        return l10n.termsOfService;
      case 'data_retention_policy':
        return l10n.dataRetentionPolicy;
      case 'age_minor_policy':
        return l10n.ageMinorPolicy;
      case 'threat_model':
        return l10n.threatModel;
      default:
        return documentKey;
    }
  }

  String _body(AppLocalizations l10n) {
    switch (documentKey) {
      case 'privacy_policy':
        return l10n.localeName == 'ur' ? _privacyPolicyUr : _privacyPolicyEn;
      case 'terms_of_service':
        return l10n.localeName == 'ur' ? _termsOfServiceUr : _termsOfServiceEn;
      case 'data_retention_policy':
        return l10n.localeName == 'ur'
            ? _dataRetentionPolicyUr
            : _dataRetentionPolicyEn;
      case 'age_minor_policy':
        return l10n.localeName == 'ur' ? _ageMinorPolicyUr : _ageMinorPolicyEn;
      case 'threat_model':
        return l10n.localeName == 'ur' ? _threatModelUr : _threatModelEn;
      default:
        return 'Document not found.';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) async {},
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: () {
                final router = GoRouter.of(context);
                if (router.canPop()) {
                  router.pop();
                } else {
                  router.go('/');
                }
              },
            ),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Loading...'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    final router = GoRouter.of(context);
                    if (router.canPop()) {
                      router.pop();
                    } else {
                      router.go('/');
                    }
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          final router = GoRouter.of(context);
          if (router.canPop()) {
            router.pop();
          } else {
            router.go('/');
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            onPressed: () {
              final router = GoRouter.of(context);
              if (router.canPop()) {
                router.pop();
              } else {
                router.go('/');
              }
            },
          ),
          title: Text(_title(l10n)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(_body(l10n), style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  static const _privacyPolicyEn = '''Privacy Policy

Overview
Retainly ("the App") is built to help students plan their studies while respecting user privacy. This policy explains what data the App collects, how it is used, and the controls available to you.

Data We Collect
- Local device data: subjects, chapters, tasks, focus sessions, revisions, and preferences are stored primarily in local SQLite/Drift databases on your device.
- AI / OCR consents: if you enable AI features, consent flags and daily quota counters are stored locally.

How We Use Data
- To provide core study-planning functionality (tasks, revisions, progress).
- To provide AI-generated suggestions when you explicitly opt in.

Data Sharing
We do not sell your personal data. Third-party processors used by the App:
- OpenAI (optional AI provider): task breakdowns, quiz generation, flashcard drafts when you enable AI assistance.

Your Rights & Controls
- You can export all local data at any time from Settings.
- You can delete all data from Settings, which removes local databases.
- You can disable AI assistance and OCR independently.
- You can clear app data via your device OS settings.

Children
The App is designed for Pakistani Matric students, generally aged 14-16. It is not directed at children under 13, and it does not knowingly collect personal data from children under 13. Parents or guardians should review the Age & Minor Policy.

Contact
For privacy inquiries, contact the developer through the in-app "Report a problem" flow.''';

  static const _termsOfServiceEn = '''Terms of Service

Acceptance of Terms
By using Retainly, you agree to these Terms. If you do not agree, do not use the App.

Use License
Permission is granted to use the App for personal, non-commercial study planning purposes only.

Prohibited Uses
- Reverse-engineering, scraping, or automated access to app services.
- Uploading illegal, harmful, or copyrighted content.
- Circumventing access controls or security measures.

AI-Generated Content
AI-generated task breakdowns, quizzes, and flashcards are suggestions only. Verify all content against your official textbook or teacher guidance.

Service Changes & Termination
Features may change or be removed without prior notice. We may suspend access if terms are violated.

Disclaimer
The App is provided "as is" without warranties of any kind. We are not liable for lost study data, academic outcomes, or device issues arising from use.

Governing Law
These terms are governed by the laws applicable in the jurisdiction of the service operator.''';

  static const _dataRetentionPolicyEn = '''Data Retention Policy

Local Data
- All study data is stored locally on your device by default.
- Data persists until you delete it through the App or your device OS.

Cloud Data
- When online sync is enabled, data is retained on your device until you delete your account or disable sync.

AI / OCR Data
- AI request logs are retained for quota enforcement.
- OCR outputs are stored locally and may be deleted via the App.

Crash / Analytics Data
- Crash reports are logged locally.


Deletion
- "Delete Account and All Data" in Settings removes local data.
- Backups are stored where you choose; we do not manage external backup copies.''';

  static const _ageMinorPolicyEn = '''Age & Minor Policy

Target Audience
The App is designed for students preparing for Pakistani Matriculation examinations (typically ages 14-16).

Minimum Age
- The App is not directed at children under 13.
- If you are under 13, do not use the App or create an account.

Parental Guidance
- For users aged 13-17, parental or guardian guidance is recommended.
- Parents should review privacy settings, AI consents, and export permissions with minors.

Consent
- By using the App, you confirm that you are at least 13 years old or have parental consent.
- We do not knowingly collect personal data from children under 13. If we become aware of such collection, we will delete it promptly.

Special Protections
- AI features are disabled by default for new users.
- Minors should avoid enabling AI features without understanding implications.''';

  static const _threatModelEn = '''Threat Model

Assets
- Local study data: subjects, chapters, tasks, focus sessions, revisions, resources.
- Authentication state: PIN hash (encrypted).
- AI / OCR data: consents, request logs, OCR outputs.

Threats
- Device loss / theft: local SQLite database and encrypted token vault may be accessed if device is unlocked.
- AI prompt injection: external AI provider could return malicious content; responses are not sanitized for code execution.
- Man-in-the-middle: external API traffic uses HTTPS; local HTTP calls use encrypted channels.
- Insider threat: developer or maintainer access to backend infrastructure could read data.
- Denial of service: quota exhaustion or AI provider outages.

Mitigations
- Local encryption: secrets stored via FlutterSecureStorage (platform Keychain / Keystore).
- AI consents: explicit opt-in required; daily quota enforced; no AI access without consent.
- HTTPS everywhere: external APIs use TLS.
- Crash reporting: unhandled exceptions captured locally to detect exploitation attempts.

Residual Risks
- A rooted / jailbroken device with OS-level access could bypass app-level encryption.
- AI provider outages will degrade AI features; the App falls back to local-only planning.''';

  static const _privacyPolicyUr = '''رازداری کی پالیسی

جائزہ
میٹرک سٹڈی پلینر ("ایپ") طلباء کے مطالعے کی منصوبہ بندی کرنے کے لیے بنائی گئی ہے اور صارف کی رازداری کا احترام کرتی ہے۔ یہ پالیسی وضاحت کرتی ہے کہ ایپ کس ڈیٹا اکٹھا کرتی ہے، اس کا استعمال کیسے ہوتا ہے، اور آپ کے پاس کون سے کنٹرول دستیاب ہیں۔

ڈیٹا جو ہم اکٹھا کرتے ہیں
- مقامی آلے کا ڈیٹا: مضامین، ابواب، کام، فوکس سیشنز، مراجعات، اور ترجیحات عمدہ طور پر آپ کے آلے پر مقامی SQLite/Drift ڈیٹابیس میں محفوظ ہوتے ہیں۔
- AI / OCR رضامندی: اگر آپ AI خصوصیات فعال کرتے ہیں، تو رضامندی اور روزانہ کوٹا کاؤنٹر مقامی طور پر محفوظ ہوتے ہیں۔

ڈیٹا کا استعمال
- بنیادی مطالعہ منصوبہ بندی کے فعالیت (کام، مراجعات، ترقی) فراہم کرنے کے لیے۔
- جب آپ واضح طور پر آپشن میں داخل ہوں تو AI تجویزات فراہم کرنے کے لیے۔

ڈیٹا کا اشتراک
ہم آپ کا ذاتی ڈیٹا نہیں بیچتے۔ ایپ کے ذریعے استعمال ہونے والے تھرڈ پارٹی پروسیسرز:
- OpenAI (اختیاری AI فراہم کار): جب آپ AI معاونت فعال کرتے ہیں تو کاموں کی تفکیک، کویز تیاری، اور فلش کارڈ کے مسودات۔

آپ کے حقوق اور کنٹرولز
- آپ کسی بھی وقت ترتیبات سے تمام مقامی ڈیٹا برآمد کر سکتے ہیں۔
- آپ ترتیبات سے تمام ڈیٹا حذف کر سکتے ہیں، جو مقامی ڈیٹابیس کو حذف کرتا ہے۔
- آپ AI معاونت اور OCR کو الگ الگ غیر فعال کر سکتے ہیں۔
- آپ اپنے آلے کی OS ترتیبات کے ذریعے ایپ ڈیٹا صاف کر سکتے ہیں۔

بچے
ایپ کو پاکستانی میٹرک طلباء کے لیے ڈیزائن کیا گیا ہے، عام طور پر عمر 14-16 سال۔ یہ 13 سال سے کم بچوں کے لیے ہدایت یافتہ نہیں ہے، اور یہ جانی بوجھ کر 13 سال سے کم بچوں کا ذاتی ڈیٹا اکٹھا نہیں کرتی۔ والدین یا سربراہان عمر کی پالیسی کا جائزہ لیں۔

رابطہ
رازداری سے متعلق استفسارات کے لیے، ایپ کے اندر "مسئلہ کی رپورٹ کریں" کے بہاوٴے سے ڈیولپر سے رابطہ کریں۔''';

  static const _termsOfServiceUr = '''خدمات کے شرائط

شرائط کی قبولیت
میٹرک سٹڈی پلینر کے استعمال کر کے، آپ ان شرائط سے اتفاق کرتے ہیں۔ اگر آپ اتفاق نہیں کرتے، تو ایپ استعمال نہ کریں۔

استعمال کا لائسنس
ایپ کو ذاتی، غیر تجاری مطالعہ منصوبہ بندی کے مقاصد کے لیے استعمال کرنے کی اجازت دی گئی ہے۔

ممنوعہ استعمالات
- بیک اینڈ سروسز کے ریورس انجینئرنگ، اسکرپنگ، یا خودکار رسائی۔
- غیر قانونی، نقصان دہ، یا کاپی رائٹ مواد اپ لوڈ کرنا۔
- رسائی کنٹرولز یا سیکیورٹی کے قوانین کی خلاف ورزی۔

AI تیار کردہ مواد
AI سے تیار کردہ کاموں کی تفکیک، کویز، اور فلش کارڈز صرف تجاویز ہیں۔ تمام مواد کو اپنے سرکاری ٹیکسٹ بک یا استاد کی ہدایت کے خلاف تصدیق کریں۔

خدمت کی تبدیلیوں اور اختتام
خصوصیات بغیر پیشگی اطلاع کے تبدیل یا ہٹائی جا سکتی ہیں۔ اگر شرائط کی خلاف ورزی ہو تو ہم رسائی معطل کر سکتے ہیں۔

دستبرداری
ایپ "جیسا ہے" شرائط کے بغیر کسی بھی قسم کی ضمانتوں کے بغیر فراہم کی گئی ہے۔ ہم استعمال سے ہونے والے کسی بھی نقصان مطالعہ ڈیٹا، تعلیمی نتائج، یا آلے کے مسائل کے لیے ذمہ دار نہیں ہیں۔

حکومت کا قانون
ان شرائط پر خدمت آپریٹر کے مطابق مخصوص علاقائی حصے کے قوانین لاگو ہوتے ہیں۔''';

  static const _dataRetentionPolicyUr = '''ڈیٹا برقرار رکھنے کی پالیسی

مقامی ڈیٹا
- تمام مطالعہ ڈیٹا پہلے سے آپ کے آلے پر مقامی طور پر محفوظ ہوتا ہے۔
- ڈیٹا تب تک برقرار رہتا ہے جب تک آپ اسے ایپ یا اپنے آلے کی OS کے ذریعے حذف نہیں کرتے۔

کلاؤڈ ڈیٹا
- جب آن لائن سنک فعال ہو تو، ڈیٹا آپ اکاؤنٹ حذف کرنے یا سنک غیر فعال کرنے تک برقرار رہتا ہے۔

AI / OCR ڈیٹا
- AI درخواست لاگز کوٹا کے نفاذ کے لیے برقرار رکھے جاتے ہیں۔
- OCR آؤٹ پٹ مقامی طور پر محفوظ ہوتا ہے اور ایپ کے ذریعے حذف کیا جا سکتا ہے۔

کراش / اینالیٹکس ڈیٹا
- کراش رپورٹس مقامی طور پر لاگ ہوتے ہیں۔


حذف
- ترتیبات میں "اکاؤنٹ اور تمام ڈیٹا حذف کریں" مقامی ڈیٹا کو حذف کرنے کی کوشش کرتا ہے۔
- بیک اپ جہاں آپ منتخب کرتے ہیں وہاں محفوظ ہوتے ہیں؛ ہم بیرونی بیک اپ کاپیز کا انتظام نہیں کرتے۔''';

  static const _ageMinorPolicyUr = '''عمر اور زیرین پالیسی

ہدف سامع
ایپ کو پاکستانی میٹرک امتحانات کے لیے تیار طلباء کے لیے ڈیزائن کیا گیا ہے (عام طور پر عمر 14-16 سال)۔

کم از کم عمر
- ایپ 13 سال سے کم بچوں کے لیے ہدایت یافتہ نہیں ہے۔
- اگر آپ 13 سال سے کم ہیں، تو ایپ استعمال نہ کریں یا اکاؤنٹ بنائیں۔

والدین کی رہنمائی
- 13-17 سال کے صارفین کے لیے والدین یا سربراہان کی رہنمائی کی سفارش کی جاتی ہے۔
- والدین کو زیرینوں کے ساتھ رازداری کی ترتیبات، AI رضامندیاں، اور برآمد کی اجازتیں کا جائزہ لینا چاہیے۔

رضامندی
- ایپ کے استعمال کر کے، آپ تصدیق کرتے ہیں کہ آپ کم از کم 13 سال کے ہیں یا والدین کی رضامندی رکھتے ہیں۔
- ہم جانی بوجھ کر 13 سال سے کم بچوں کا ذاتی ڈیٹا اکٹھا نہیں کرتے۔ اگر ہم ایسی اکٹھائے کے بارے میں آگاہ ہوں، تو ہم اسے فوری طور پر حذف کر دیں گے۔

خاص حفاظتی اقدامات
- AI خصوصیات نئے صارفین کے لیے پہلے سے غیر فعال ہیں۔
- زیرینوں کو ای آئی خصوصیات فعال کرنے سے پہلے اثرات کو سمجھنا چاہیے۔''';

  static const _threatModelUr = '''خطرے کا ماڈل

اثاثہ
- مقامی مطالعہ ڈیٹا: مضامین، ابواب، کام، فوکس سیشنز، مراجعات، مصالح۔
- تصدیقی حالت: PIN ہیش (خفیہ)۔
- AI / OCR ڈیٹا: رضامندیاں، درخواست لاگز، OCR آؤٹ پٹ۔

خطرات
- آلے کا نقصان / چوری: مقامی SQLite ڈیٹابیس اور خفیہ ٹوکن والٹ اگر آلے غیر مقفل ہو تو قابل رسائی ہو سکتا ہے۔
- AI پرامپٹ انجیکشن: بیرون AI فراہم کار نقصان دہ مواد واپس کر سکتا ہے؛ جوابات کو کوڈ کے اجراء کے لیے صاف نہیں کیا جاتا۔
- میڈل آف دی میڈل: بیرونی API کا ٹریفک HTTPS استعمال کرتا ہے؛ مقامی HTTP کالز خفیہ چینلز استعمال کرتے ہیں۔
- اندرونی خطرہ: ڈیولپر یا ایڈمن کی بنیادی ڈیٹا تک رسائی ممکن ہے۔
- انکارِ خدمت: کوٹا ختم ہو جانا یا AI فراہم کار کے outages۔

سازگارانہ تدابیر
- مقامی خفیہ کاری: رازوں کی محفوظ مقام FlutterSecureStorage (پلیٹ فارم Keychain / Keystore) کے ذریعے۔
- AI رضامندی: واضح آپٹ ان ضروری؛ روزانہ کوٹا نفی کر؛ رضامندی کے بغیر AI تک رسائی نہیں۔
- ہر جگہ HTTPS: بیرونی APIS TLS استعمال کرتے ہیں۔
- کراش رپورٹنگ: غیر ہینڈلڈ استثناء کو مقامی طور پر capture کرنا استغلام کے کوششوں کی پہچان کے لیے۔

باقی خطرات
- ایک روٹ یا جیل سے نکالا ہوا آلہ OS سطح تک رسائی کے ساتھ ایپ سطح کی خفیہ کاری کو bypass کر سکتا ہے۔
- AI فراہم کار کے outages AI خصوصیات کو کمزور کر دیں گے؛ ایپ مقامی صرف منصوبہ بندی پر واپس آ جاتا ہے۔''';
}

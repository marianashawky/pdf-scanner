import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants.dart';

enum AppLocale {
  en,
  ar;

  bool get isArabic => this == AppLocale.ar;

  Locale get locale => Locale(name);

  String get nativeLabel => switch (this) {
        AppLocale.en => 'English',
        AppLocale.ar => 'العربية',
      };

  static AppLocale fromName(String? name) {
    return AppLocale.values.firstWhere(
      (value) => value.name == name,
      orElse: () => AppLocale.en,
    );
  }
}

class AppLocalizations {
  AppLocalizations(this.locale);

  final AppLocale locale;

  bool get isArabic => locale.isArabic;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(AppLocale.en);
  }

  static const delegate = _AppLocalizationsDelegate();

  String get appName => _t('PDF Scanner', 'ماسح PDF');
  String get documentStudio => _t('Document studio', 'استوديو المستندات');
  String get versionLabel => _t('Private document studio · v1.0', 'استوديو مستندات خاص · الإصدار 1.0');

  String get home => _t('Home', 'الرئيسية');
  String get files => _t('Files', 'الملفات');
  String get tools => _t('Tools', 'الأدوات');
  String get settings => _t('Settings', 'الإعدادات');
  String get scan => _t('Scan', 'مسح');

  String get goodMorning => _t('Good morning', 'صباح الخير');
  String get goodAfternoon => _t('Good afternoon', 'مساء الخير');
  String get goodEvening => _t('Good evening', 'مساء الخير');

  String greeting(DateTime time) {
    final hour = time.hour;
    if (hour < 12) return goodMorning;
    if (hour < 18) return goodAfternoon;
    return goodEvening;
  }

  String get readyToCapture => _t('READY TO CAPTURE', 'جاهز للتصوير');
  String get heroTitle => _t('Turn paper into\nperfect PDF.', 'حوّل الورق إلى\nPDF مثالي.');
  String get heroSubtitle => _t(
        'Auto-detect edges, enhance clarity, and export in seconds.',
        'اكتشاف تلقائي للحواف، تحسين الوضوح، وتصدير في ثوانٍ.',
      );
  String get scanDocument => _t('Scan document', 'مسح مستند');
  String get cameraScan => _t('Camera scan', 'مسح بالكاميرا');
  String get imageToPdf => _t('Image to PDF', 'صورة إلى PDF');
  String get photosToPages => _t('Photos to pages', 'صور إلى صفحات');
  String get pdfTools => _t('PDF tools', 'أدوات PDF');
  String get mergeSplitMore => _t('Merge, split & more', 'دمج وتقسيم والمزيد');
  String get recentFiles => _t('Recent files', 'الملفات الأخيرة');
  String documentsCount(int count) => _t('$count documents', '$count مستند');
  String get quickActions => _t('Quick actions', 'إجراءات سريعة');
  String get seeAll => _t('See all', 'عرض الكل');
  String get noDocumentsYet => _t('No documents yet', 'لا توجد مستندات بعد');
  String get emptyDocsMessage => _t(
        'Scan a page or import photos to start your private studio.',
        'امسح صفحة أو استورد صوراً لتبدأ استوديو المستندات الخاص بك.',
      );
  String get storedSecurely => _t(
        'Stored securely on this device.',
        'محفوظة بأمان على هذا الجهاز.',
      );

  String get makeStudioYours => _t('Make the studio yours.', 'خصّص الاستوديو كما تريد.');
  String get darkStudio => _t('Dark studio', 'وضع داكن');
  String get lightStudio => _t('Light studio', 'وضع فاتح');
  String get darkStudioSub => _t('Clear midnight workspace', 'مساحة عمل داكنة وواضحة');
  String get lightStudioSub => _t('Bright paper workspace', 'مساحة عمل ورقية مضيئة');
  String get language => _t('Language', 'اللغة');
  String get languageSub => _t('Arabic & English', 'العربية والإنجليزية');
  String get localProcessing => _t('Local processing', 'معالجة محلية');
  String get filesNeverLeave => _t('Files never leave this device', 'الملفات لا تغادر هذا الجهاز');
  String get defaultQuality => _t('Default quality', 'الجودة الافتراضية');
  String get autoEnhance => _t('Auto enhance', 'تحسين تلقائي');
  String get autoEnhanceSub => _t(
        'Sharpen and clarify scans by default',
        'توضيح وتحسين المسح تلقائياً',
      );
  String get helpTips => _t('Help & tips', 'مساعدة ونصائح');
  String get learnEssentials => _t('Learn the essentials', 'تعلّم الأساسيات');
  String get clearLocalDocs => _t('Clear local documents', 'مسح المستندات المحلية');
  String get clearAllTitle => _t('Clear all documents?', 'مسح كل المستندات؟');
  String get clearAllBody => _t(
        'This permanently deletes locally stored PDFs from this device.',
        'سيتم حذف ملفات PDF المخزنة محلياً من هذا الجهاز نهائياً.',
      );
  String get cancel => _t('Cancel', 'إلغاء');
  String get clear => _t('Clear', 'مسح');
  String get chooseLanguage => _t('Choose language', 'اختر اللغة');

  String get qualityCompact => _t('Compact', 'مدمج');
  String get qualityBalanced => _t('Balanced', 'متوازن');
  String get qualityHigh => _t('High', 'عالي');
  String get qualityCompactSub => _t('Smaller files, faster sharing', 'ملفات أصغر ومشاركة أسرع');
  String get qualityBalancedSub => _t('Best everyday studio quality', 'أفضل جودة للاستخدام اليومي');
  String get qualityHighSub => _t('Maximum clarity for archives', 'أقصى وضوح للأرشفة');

  String qualityLabel(ScanQuality quality) => switch (quality) {
        ScanQuality.compact => qualityCompact,
        ScanQuality.balanced => qualityBalanced,
        ScanQuality.high => qualityHigh,
      };

  String qualitySubtitle(ScanQuality quality) => switch (quality) {
        ScanQuality.compact => qualityCompactSub,
        ScanQuality.balanced => qualityBalancedSub,
        ScanQuality.high => qualityHighSub,
      };

  String get toolsTitle => _t('PDF tools', 'أدوات PDF');
  String get toolsSubtitle => _t(
        'Everything you need, processed privately.',
        'كل ما تحتاجه، بمعالجة خاصة على الجهاز.',
      );
  String get mergePdfs => _t('Merge PDFs', 'دمج PDF');
  String get mergeSub => _t('Combine multiple documents', 'دمج عدة مستندات');
  String get splitPdf => _t('Split PDF', 'تقسيم PDF');
  String get splitSub => _t('Extract or remove pages', 'استخراج أو حذف صفحات');
  String get compressPdf => _t('Compress PDF', 'ضغط PDF');
  String get compressSub => _t('Make files easier to share', 'اجعل الملفات أسهل للمشاركة');
  String get privateWorkspace => _t('Private workspace', 'مساحة عمل خاصة');
  String get privateWorkspaceBody => _t(
        'Your files never leave this device. Every tool runs locally.',
        'ملفاتك لا تغادر الجهاز. كل الأدوات تعمل محلياً.',
      );

  String get favorites => _t('Favorites', 'المفضلة');
  String get searchDocuments => _t('Search documents', 'بحث في المستندات');
  String get importPdf => _t('Import PDF', 'استيراد PDF');
  String get searchHint => _t('Search by name', 'ابحث بالاسم');
  String get noResults => _t('No results', 'لا توجد نتائج');

  String get adjustScan => _t('Adjust scan', 'ضبط المسح');
  String get adjustScanSub => _t('Drag corners to refine the document.', 'اسحب الزوايا لضبط حدود المستند.');
  String get crop => _t('Crop', 'قص');
  String get rotate => _t('Rotate', 'تدوير');
  String get enhance => _t('Enhance', 'تحسين');
  String get previewScan => _t('Preview scan  >', 'معاينة المسح  >');
  String get polishingPage => _t('Polishing page…', 'جاري تحسين الصفحة…');
  String get enhancing => _t('Enhancing…', 'جاري التحسين…');

  String get preview => _t('Preview', 'معاينة');
  String get noPagesYet => _t('No pages yet', 'لا توجد صفحات بعد');
  String pageOf(int current, int total) => _t('Page $current of $total', 'صفحة $current من $total');
  String get noPagePreview => _t('No page to preview', 'لا توجد صفحة للمعاينة');
  String get captureToPolish => _t(
        'Capture a document to polish and export it.',
        'التقط مستنداً لتحسينه وتصديره.',
      );
  String get delete => _t('Delete', 'حذف');
  String get save => _t('Save', 'حفظ');
  String get share => _t('Share', 'مشاركة');
  String get workingLocally => _t('Working locally…', 'يعمل محلياً…');
  String get filterOriginal => _t('Original', 'أصلي');
  String get filterColor => _t('Color', 'ألوان');
  String get filterGrayscale => _t('Grayscale', 'رمادي');
  String get filterBw => _t('B&W', 'أبيض وأسود');

  String filterLabel(ScanFilter filter) => switch (filter) {
        ScanFilter.original => filterOriginal,
        ScanFilter.color => filterColor,
        ScanFilter.grayscale => filterGrayscale,
        ScanFilter.blackWhite => filterBw,
      };

  String get skip => _t('Skip', 'تخطي');
  String get continueLabel => _t('Continue', 'متابعة');
  String get enterStudio => _t('Enter your studio  >', 'ادخل استوديوك  >');

  String get onboard1Eyebrow => _t('PRIVATE BY DESIGN', 'خصوصية بالتصميم');
  String get onboard1Title => _t('Your documents stay here.', 'مستنداتك تبقى هنا.');
  String get onboard1Body => _t(
        'Every scan, merge, and export is processed on this device. Nothing is uploaded.',
        'كل عملية مسح ودمج وتصدير تتم على هذا الجهاز. لا يتم رفع أي شيء.',
      );
  String get onboard2Eyebrow => _t('STUDIO QUALITY', 'جودة احترافية');
  String get onboard2Title => _t('Turn paper into a perfect PDF.', 'حوّل الورق إلى PDF مثالي.');
  String get onboard2Body => _t(
        'Auto-detect edges, correct perspective, and polish pages with color, grayscale, or B&W.',
        'اكتشاف تلقائي للحواف، تصحيح المنظور، وتحسين الصفحات بالألوان أو الرمادي أو الأبيض والأسود.',
      );
  String get onboard3Eyebrow => _t('READY TO CAPTURE', 'جاهز للتصوير');
  String get onboard3Title => _t('A private document studio.', 'استوديو مستندات خاص.');
  String get onboard3Body => _t(
        'Scan multi-page files, import photos, then merge, split, compress, and share locally.',
        'امسح ملفات متعددة الصفحات، استورد صوراً، ثم ادمج وقسّم واضغط وشارك محلياً.',
      );

  String get capture => _t('Capture', 'التقاط');
  String get addPage => _t('Add page', 'إضافة صفحة');
  String get flash => _t('Flash', 'فلاش');
  String get gallery => _t('Gallery', 'المعرض');

  String get rename => _t('Rename', 'إعادة تسمية');
  String get favorite => _t('Favorite', 'مفضلة');
  String get unfavorite => _t('Remove favorite', 'إزالة من المفضلة');
  String get open => _t('Open', 'فتح');
  String get done => _t('Done', 'تم');
  String get nameDocument => _t('Document name', 'اسم المستند');

  String pageLabel(int count) => count == 1
      ? _t('1 page', 'صفحة واحدة')
      : _t('$count pages', '$count صفحات');

  String todayAt(String time) => _t('Today, $time', 'اليوم، $time');
  String get yesterday => _t('Yesterday', 'أمس');

  String get somethingWrong => _t('Something went wrong', 'حدث خطأ ما');
  String get permissionNeeded => _t(
        'Camera permission is needed to scan documents.',
        'يلزم إذن الكاميرا لمسح المستندات.',
      );
  String get openSettings => _t('Open settings', 'فتح الإعدادات');

  String get scanNamePrefix => _t('Scan', 'مسح');

  String _t(String en, String ar) => isArabic ? ar : en;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en' || locale.languageCode == 'ar';

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(AppLocale.fromName(locale.languageCode));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

TextStyle studioText({
  required BuildContext context,
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  double? letterSpacing,
}) {
  final arabic = AppLocalizations.of(context).isArabic;
  if (arabic) {
    return GoogleFonts.cairo(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
  return GoogleFonts.manrope(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

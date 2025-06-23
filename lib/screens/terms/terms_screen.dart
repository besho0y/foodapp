import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isArabic = Layoutcubit.get(context).isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).terms_and_conditions),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              isArabic ? '📜 الشروط والأحكام' : '📜 Terms & Conditions',
              '',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '1. المقدمة' : '1. Introduction',
              isArabic
                  ? 'مرحبًا بك في أكلة . تحكم هذه الشروط والأحكام استخدامك لتطبيقنا والخدمات المقدمة، التي تتضمن خدمات توصيل الطعام من المطابخ المنزلية المستقلة. باستخدامك لتطبيقنا، فإنك توافق على الالتزام بهذه الشروط.'
                  : 'Welcome to Akla. These Terms and Conditions govern your use of our mobile application and services, which provide delivery services for food prepared by independent home kitchens. By using our app, you agree to be bound by these terms.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '2. دورنا' : '2. Our Role',
              isArabic
                  ? 'يعد أكلة مجرد خدمة توصيل. نحن لا نقوم بإعداد أو طهي الطعام أو بيعه. نحن نعمل كمنصة لربط العملاء مع المطابخ المنزلية المسجلة وتوصيل الطعام نيابةً عنها. كما نقوم بجمع المدفوعات نيابةً عن المطابخ.'
                  : 'Akla acts solely as a delivery service. We do not prepare, cook, or sell food. We serve as a platform to connect customers with registered home kitchens and deliver food on their behalf. We also collect payments on behalf of the kitchens.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '3. أهلية المستخدم' : '3. User Eligibility',
              isArabic
                  ? 'لاستخدام خدماتنا، يجب عليك:\n\n• أن تكون في سن ١٥ عامًا أو أكثر.\n• تقديم معلومات دقيقة عند التسجيل.\n• الموافقة على هذه الشروط والأحكام وعلى سياسة الخصوصية الخاصة بنا.'
                  : 'To use our services, you must:\n\n• Be at least 15 years old.\n• Provide accurate information during registration.\n• Agree to these Terms & Conditions and our Privacy Policy.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '4. الطلبات والمدفوعات' : '4. Orders and Payments',
              isArabic
                  ? '• يمكن تقديم الطلبات من خلال تطبيقنا ويجب دفعها باستخدام وسائل الدفع المتاحة.\n• يتم تحديد أسعار الطعام من قبل المطابخ. نحن نقوم بجمع المدفوعات وتحويل الجزء المخصص للمطبخ.\n• يتم توضيح رسوم التوصيل قبل تأكيد الطلب.'
                  : '• Orders can be placed through our app and must be paid using the available payment methods.\n• All food prices are set by the kitchens. We collect payments and remit the kitchen\'s share.\n• Delivery fees are clearly indicated before order confirmation.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '5. سياسة التوصيل' : '5. Delivery Policy',
              isArabic
                  ? '• نحن نسعى لتوصيل الطعام في الوقت المحدد وبطريقة آمنة.\n• قد تحدث تأخيرات بسبب حركة المرور أو الطقس أو الطلب المرتفع.\n• نحن لسنا مسؤولين عن جودة الطعام أو مكوناته — هذه مسؤولية المطبخ.'
                  : '• We aim to deliver food in a timely and safe manner.\n• Delays may occur due to traffic, weather, or high demand.\n• We are not responsible for food quality, hygiene, or ingredients — these are the responsibility of the kitchen.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '6. الإلغاء والاسترداد' : '6. Cancellation & Refunds',
              isArabic
                  ? '• يمكن إلغاء الطلبات فقط خلال [ 2 دقيقة] من تقديمها إذا لم يبدأ المطبخ في التحضير.\n• سيتم النظر في طلبات الاسترداد على أساس كل حالة على حدة:\n  - الطلبات غير المسلمة.\n  - العناصر غير الصحيحة أو المفقودة (تُبلغ خلال 30 دقيقة من التوصيل).\n• لن يتم منح استرداد لأي قضايا تتعلق بالطعم أو مستوى التوابل أو التفضيلات الشخصية.'
                  : '• Orders can only be cancelled within [ 2 minutes] of placing them if the kitchen has not yet started preparation.\n• Refunds will be considered on a case-by-case basis for:\n  - Undelivered orders.\n  - Wrong or missing items (reported within 30 minutes of delivery).\n• No refunds will be given for taste, spice level, or personal preferences.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '7. مسؤولية المطبخ' : '7. Kitchen Responsibility',
              isArabic
                  ? '• يتم تحضير الطعام بواسطة مطابخ منزلية مستقلة.\n• المطابخ هي المسؤولة بالكامل عن الالتزام بمعايير النظافة واللوائح الصحية المحلية.\n• يجب توجيه أي شكاوى بشأن جودة الطعام إلى المطبخ.'
                  : '• All food is prepared by independent home kitchens.\n• Kitchens are solely responsible for meeting hygiene standards and local health regulations.\n• Any complaints regarding food quality must be directed to the kitchen.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '8. سلوك المستخدم' : '8. User Conduct',
              isArabic
                  ? 'يجب على المستخدمين عدم:\n• إساءة استخدام المنصة أو مضايقة موظفي التوصيل لدينا.\n• نشر مراجعات كاذبة أو انتحال شخصيات أخرى.\n• محاولة فك تشفير التطبيق أو التدخل في عمله.'
                  : 'Users must not:\n• Misuse the platform or harass our delivery personnel.\n• Post false reviews or impersonate others.\n• Attempt to reverse-engineer the app or interfere with its operation.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '9. المسؤولية' : '9. Liability',
              isArabic
                  ? 'نحن غير مسؤولين عن:\n• المشاكل الصحية المتعلقة بالطعام أو ردود الفعل التحسسية.\n• التأخيرات الخارجة عن إرادتنا.\n• أي نزاعات بين المستخدمين والمطابخ.'
                  : 'We are not liable for:\n• Food-related health issues or allergic reactions.\n• Delays beyond our control.\n• Any disputes between users and kitchens.',
              isArabic,
            ),
            _buildSection(
              context,
              isArabic ? '10. التعديلات على الشروط' : '10. Changes to Terms',
              isArabic
                  ? 'قد نقوم بتحديث هذه الشروط في أي وقت. يشكل الاستمرار في استخدام التطبيق قبولًا للشروط المعدلة.'
                  : 'We may update these terms at any time. Continued use of the app constitutes acceptance of the revised terms.',
              isArabic,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, String content, bool isArabic) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

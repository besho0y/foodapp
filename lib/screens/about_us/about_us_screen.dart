import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:foodapp/generated/l10n.dart';
import 'package:foodapp/layout/cubit.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isArabic = Layoutcubit.get(context).isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).about_us),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic
                  ? 'مرحبًا بك في أكلة — بوابتك للوجبات المنزلية الأصيلة!'
                  : 'Welcome to Akla — Your Gateway to authentic Home-Cooked meals!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 16.h),
            Text(
              isArabic
                  ? 'أكلة هو تطبيق توصيل متخصص في تقديم الطعام البيتي الطازج إليك مباشرة، من مطابخ منزلية محلية محترفة.'
                  : 'Akla is a food delivery platform specialized in bringing fresh, homemade meals straight to your door — prepared with love by talented local home kitchens.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16.h),
            Text(
              isArabic
                  ? 'نربطك بطباخين منزليين مستقلين يقدمون وجبات شهية محضّرة بوصفات تقليدية ومكونات عالية الجودة. دورنا بسيط لكنه جوهري: نحن نتولى مهمة التوصيل بكفاءة واهتمام، لنضمن أن طعامك يصل إليك ساخنًا وطازجًا.'
                  : 'We connect you with independent home chefs who prepare delicious, authentic food using traditional recipes and quality ingredients. Our role is simple yet essential: we handle the delivery with care and efficiency, ensuring your food arrives hot, fresh, and on time.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16.h),
            Text(
              isArabic
                  ? 'نحن لا نعد أو نبيع الطعام بأنفسنا، بل نتيح لأصحاب المطابخ المنزلية منصة رقمية لعرض أطباقهم، ونجمع المدفوعات نيابةً عنهم، ونتأكد من وصول الوجبة إليك بجودة عالية.'
                  : 'We do not cook or sell food ourselves. Instead, we empower small kitchens and home chefs by giving them a digital storefront, managing payments on their behalf, and ensuring their dishes reach you in the best condition.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 16.h),
            Text(
              isArabic
                  ? 'سواء كنت تبحث عن وجبة مريحة، أو أطباق محلية أصيلة، أو طعام صحي من البيت — أكلة يجلب لك نكهة البيت أينما كنت.'
                  : 'Whether you\'re craving comfort food, regional specialities, or healthy home meals — Akla delivers the taste of home, wherever you are.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'true_caller.dart';
import 'utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('en', 'US'),
          fallbackLocale: const Locale('en', 'US'),
          initialBinding: BindingsBuilder(() {
            Get.put(AuthController());
          }),
          getPages: [
            GetPage(
              name: AppRoutes.manualVerifyNumberScreen,
              page: () => const ManualVerifyNumberScreen(),
            ),
          ],
          home: const ManualVerifyNumberScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'true_caller.dart';
import 'utils.dart';
import 'map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // try {
    // await MobileAds.instance.initialize();
  // } catch (e) {
    // debugPrint("MobileAds initialization failed: $e");
  // }
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
          // initialBinding: BindingsBuilder(() {
          //   Get.put(AuthController());
          // }),
          getPages: [
            GetPage(
              name: '/map',
              page: () => const MapScreen(),
            ),
            GetPage(
              name: AppRoutes.manualVerifyNumberScreen,
              page: () => const ManualVerifyNumberScreen(),
            ),
          ],
          home: const MapScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

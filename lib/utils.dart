import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'login_with_truecaller': 'Login with Truecaller',
          'OR': 'OR',
          'proceed': 'Proceed',
          'enter_phone_number': 'Enter phone number',
          'please_enter_valid_phone_number': 'Please enter a valid phone number',
          'enter_otp': 'Enter OTP',
          'invalid_otp': 'Invalid OTP',
          'retry_again_after': 'Retry again after',
          'verification_timed_out_retry_again': 'Verification timed out. Retry again.',
          'no_internet_connection': 'No internet connection',
          'login_failed': 'Login failed',
          'truecaller_not_found': 'Truecaller not found',
        }
      };
}

class AppColors {
  static const Color outlineColor = Color(0xFFE0E0E0);
  static const Color blackColor = Colors.black;
  static const Color redColor = Colors.red;
  static const Color greenColor = Colors.green;
  static const Color greyColor = Colors.grey;
  static const Color blueColor = Colors.blue;
  static const Color primaryColor = Colors.blue;
  static const Color whiteColor = Colors.white;
}

class Appcolor extends AppColors {}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isActive;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? AppColors.primaryColor : AppColors.greyColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: isActive ? onTap : null,
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }
}

class CommonToast {
  static void error(String message) {
    Get.snackbar('Error', message, backgroundColor: Colors.red, colorText: Colors.white);
  }

  static void success(String message) {
    Get.snackbar('Success', message, backgroundColor: Colors.green, colorText: Colors.white);
  }
}

class AppLoader {
  static void show() {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
  }

  static void hide() {
    if (Get.isDialogOpen ?? false) Get.back();
  }
}

class InternetService {
  bool get isConnected => true; // Mock implementation
}

class TrueCallerHelper {
  Future<void> initialize() async {
    // Mock implementation
  }

  static Future<bool> isUsable() async {
    return true; // Mock implementation
  }

  static Future<void> getProfile({String? phoneNumber}) async {
    // Mock implementation
  }
}

class AppRoutes {
  static const String manualVerifyNumberScreen = '/manualVerifyNumber';
  static const String mainHomeScreen = '/home';
}

class ApiUrls {
  static const String loginUrl = 'https://api.example.com/login';
}

class CommonStorage {
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}

class StorageKeys {
  static const String token = 'token';
}

class UserModel {
  final String? email;
  final String? name;
  final String? phone;
  final String? countryName;
  final String? countryIsoCode;
  final bool? isAgent;

  UserModel({
    this.email,
    this.name,
    this.phone,
    this.countryName,
    this.countryIsoCode,
    this.isAgent,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
      countryName: json['countryName'],
      countryIsoCode: json['countryIsoCode'],
      isAgent: json['isAgent'],
    );
  }
}

class AuthService {
  UserModel? user;
  String? lastGoogleToken;

  void onLogin(UserModel userModel) {
    user = userModel;
  }

  Future<dynamic> signInWithGoogle() async {
    return null; // Mock implementation
  }
}

final AuthService authService = AuthService();

class ApiHelper {
  Future<void> post(
    String url, {
    Map<String, dynamic>? body,
    required Function(dynamic) onSuccess,
    required Function(dynamic) onError,
  }) async {
    debugPrint('Truecaller: $url, $body');
    // Mock implementation
    onSuccess({'data': {'token': 'mock_token', 'user': {'name': 'Mock User'}}});
  }
}

final ApiHelper apiHelper = ApiHelper();

class ResponsiveView {
  static bool isWeb(BuildContext context) => false;
}

class Validator {
  static bool validatePhoneNumber(String number, String isoCode) => true;
}

class ValidationMessages {
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Invalid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordInvalid = 'Password must be at least 6 characters';
}

class AppValidators {
  static bool isValidEmail(String email) => GetUtils.isEmail(email);
}

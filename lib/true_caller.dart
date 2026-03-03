import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';
import 'package:uuid/uuid.dart';
import 'utils.dart';

class ManualVerifyNumberScreen extends GetView<AuthController> {
  const ManualVerifyNumberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double fontSize = 18.0;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Obx(
            () =>
                controller.showProgressBar.value
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Obx(
                                () => Column(
                                  children: [
                                    Visibility(
                                      visible: controller.showInputNumberView(),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.outlineColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 20.w,
                                              ),
                                              child: InternationalPhoneNumberInput(
                                                onInputChanged: (
                                                  PhoneNumber number,
                                                ) {
                                                  controller
                                                      .onPhoneNumberChanged(
                                                        number.isoCode,
                                                        number.dialCode,
                                                      );
                                                  controller.validatePhone();
                                                },
                                                selectorConfig:
                                                    const SelectorConfig(
                                                      selectorType:
                                                          PhoneInputSelectorType
                                                              .DIALOG,
                                                    ),
                                                ignoreBlank: false,
                                                selectorTextStyle: TextStyle(
                                                  color: AppColors.blackColor,
                                                ),
                                                scrollPadding: EdgeInsets.only(
                                                  bottom: 120.h,
                                                ),
                                                formatInput: false,
                                                keyboardType:
                                                    TextInputType.phone,
                                                initialValue: PhoneNumber(
                                                  isoCode:
                                                      controller
                                                              .isoCode
                                                              .value
                                                              .isEmpty
                                                          ? 'IN'
                                                          : controller
                                                              .isoCode
                                                              .value,
                                                  dialCode:
                                                      controller
                                                              .dialCode
                                                              .value
                                                              .isEmpty
                                                          ? '+91'
                                                          : controller
                                                              .dialCode
                                                              .value,
                                                ),
                                                validator: (value) => null,
                                                textFieldController:
                                                    controller.phoneController,
                                                inputDecoration:
                                                    InputDecoration(
                                                      hintText:
                                                          'enter_phone_number'
                                                              .tr,
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      isDense: true,
                                                    ),
                                              ),
                                            ),
                                          ),
                                          if (controller
                                              .phoneError
                                              .value
                                              .isNotEmpty)
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 8.h,
                                                left: 4.w,
                                              ),
                                              child: Text(
                                                controller.phoneError.value,
                                                style: TextStyle(
                                                  color: AppColors.redColor,
                                                  fontSize: 12.sp,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Visibility(
                                      visible: controller.showInputOtpView(),
                                      child: TextField(
                                        controller: controller.otpController,
                                        maxLength: 6,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        style: TextStyle(
                                          color: AppColors.greenColor,
                                          fontSize: fontSize,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: "enter_otp".tr,
                                          labelStyle: TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: fontSize,
                                          ),
                                          hintText: "enter_otp".tr,
                                          errorText:
                                              controller.invalidOtp.value
                                                  ? "invalid_otp".tr
                                                  : null,
                                          hintStyle: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: AppColors.greyColor,
                                            fontSize: fontSize,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20.h),
                                    Visibility(
                                      visible: controller.showRetryTextView(),
                                      child:
                                          controller.ttl.value == 0
                                              ? TextButton(
                                                child: Text(
                                                  "verification_timed_out_retry_again"
                                                      .tr,
                                                  style: TextStyle(
                                                    decoration:
                                                        TextDecoration
                                                            .underline,
                                                    color: AppColors.blueColor,
                                                  ),
                                                ),
                                                onPressed:
                                                    () =>
                                                        controller
                                                            .tempResult
                                                            .value = null,
                                              )
                                              : Text(
                                                "${"retry_again_after".tr} ${controller.ttl.value}",
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => Visibility(
                              visible:
                                  controller.showInputNumberView() ||
                                  controller.showInputNameView() ||
                                  controller.showInputOtpView(),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 5.h,
                                ),
                                child: Column(
                                  children: [
                                    if (controller.isTruecallerAvailable.value && controller.showInputNumberView()) ...[
                                      PrimaryButton(
                                        text: 'login_with_truecaller'.tr,
                                        onTap: () => controller.signInWithTruecaller(),
                                      ),
                                      SizedBox(height: 10.h),
                                      Text('OR'.tr, style: TextStyle(color: AppColors.greyColor)),
                                      SizedBox(height: 10.h),
                                    ],
                                    PrimaryButton(
                                      isActive: controller.isPhoneValid.value,
                                      text: 'proceed'.tr,
                                      onTap: () => controller.onProceedClick(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
class AuthController extends GetxController {
  RxString isoCode = 'IN'.obs;
  RxString dialCode = '+91'.obs;
  RxBool isTruecallerAvailable = false.obs;
  Stream<TcSdkCallback>? stream;
  String? codeVerifier;

  @override
  void onInit() {
    if (Platform.isAndroid) {
      _initTruecaller();
    }
    super.onInit();
  }

  Future<void> _initTruecaller() async {
    debugPrint('Initializing Truecaller SDK...');
    try {
      // Initialize the SDK
      TcSdk.initializeSDK(sdkOption: TcSdkOptions.OPTION_VERIFY_ALL_USERS);
      
      // Check if SDK is usable
      isTruecallerAvailable.value = await TcSdk.isOAuthFlowUsable;
      debugPrint('Truecaller usable: ${isTruecallerAvailable.value}');

      stream = TcSdk.streamCallbackData;
      stream?.listen((TcSdkCallback event) {
        debugPrint('Truecaller event: ${event.result}');
        switch (event.result) {
          case TcSdkCallbackResult.success:
          case TcSdkCallbackResult.verifiedBefore:
          case TcSdkCallbackResult.verificationComplete:
            debugPrint('Auth Controller: Verification success path: ${event.result}');
            showProgressBar.value = true;
            onVerificationSuccess(event);
            break;
          case TcSdkCallbackResult.exception:
          case TcSdkCallbackResult.failure:
            handleVerificationCallback(event);
            break;
          case TcSdkCallbackResult.verification:
          case TcSdkCallbackResult.missedCallInitiated:
          case TcSdkCallbackResult.missedCallReceived:
          case TcSdkCallbackResult.otpInitiated:
          case TcSdkCallbackResult.otpReceived:
            _handleVerificationRequired(event);
            break;
          default:
            break;
        }
      });
    } catch (e) {
      debugPrint('Truecaller SDK Exception: $e');
    }
  }

  void _handleVerificationRequired(TcSdkCallback event) {
    switch (event.result) {
      case TcSdkCallbackResult.missedCallInitiated:
        debugPrint('Truecaller: Missed call initiated');
        showProgressBar.value = true; // Show loader when initiation starts
        tempResult.value = TcSdkCallbackResult.missedCallInitiated; // Track state
        break;
      case TcSdkCallbackResult.missedCallReceived:
        debugPrint('Truecaller: Missed call received, verifying...');
        showProgressBar.value = true; // Ensure loader is shown during auto-verification
        tempResult.value = TcSdkCallbackResult.missedCallReceived;
        // Auto-verify missed call to complete the flow
        TcSdk.verifyMissedCall(
          firstName: 'User',
          lastName: '',
        );
        break;
      case TcSdkCallbackResult.otpInitiated:
        debugPrint('Truecaller: OTP initiated');
        showProgressBar.value = true; // Show loader when initiation starts
        tempResult.value = TcSdkCallbackResult.otpInitiated;
        break;
      case TcSdkCallbackResult.otpReceived:
        debugPrint('Truecaller: OTP received');
        showProgressBar.value = true; // Ensure loader is shown during auto-verification
        tempResult.value = TcSdkCallbackResult.otpReceived;
        if (event.otp != null) {
          otpController.text = event.otp!;
          // Auto-verify OTP if received automatically
          TcSdk.verifyOtp(
            firstName: 'User',
            lastName: '',
            otp: event.otp!,
          );
        }
        break;
      case TcSdkCallbackResult.verification:
        debugPrint('Truecaller: Verification required');
        CommonToast.error('truecaller_not_found'.tr);
        Future.delayed(const Duration(seconds: 1), () {
          Get.toNamed(AppRoutes.manualVerifyNumberScreen);
        });
        break;
      default:
        break;
    }
  }

  Future<void> signInWithTruecaller() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!InternetService().isConnected) {
      CommonToast.error('no_internet_connection'.tr);
      return;
    }

    TcSdk.initializeSDK(sdkOption: TcSdkOptions.OPTION_VERIFY_ALL_USERS);
    TcSdk.isOAuthFlowUsable.then((isOAuthFlowUsable) {
      if (isOAuthFlowUsable) {
        TcSdk.setOAuthState(const Uuid().v1());
        TcSdk.setOAuthScopes(['profile', 'phone', 'openid', 'email']);
        TcSdk.generateRandomCodeVerifier.then((codeVerifier) {
          TcSdk.generateCodeChallenge(codeVerifier).then((codeChallenge) {
            if (codeChallenge != null) {
              this.codeVerifier = codeVerifier;
              TcSdk.setCodeChallenge(codeChallenge);
              TcSdk.getAuthorizationCode;
            } else {
              CommonToast.error("Device not supported");
              debugPrint("***Code challenge NULL***");
            }
          });
        });
      } else {
        Get.toNamed(AppRoutes.manualVerifyNumberScreen);
      }
    });
  }
  // Future<void> signInWithTruecaller() async {
  //   if (!InternetService().isConnected) {
  //     CommonToast.error('no_internet_connection'.tr);
  //     return;
  //   }

  //   final String phoneNumber = phoneController.text.trim();
  //   final bool isUsable = await TrueCallerHelper.isUsable();

  //   if (!isUsable && phoneNumber.isEmpty) {
  //     CommonToast.error('please_enter_phone_number'.tr);
  //     return;
  //   }

  //   AppLoader.show();
  //   await TrueCallerHelper.getProfile(
  //     phoneNumber: phoneNumber.isNotEmpty ? (dialCode.value + phoneNumber) : null,
  //   );
  // }

  void onVerificationSuccess(TcSdkCallback event) {
    _handleTruecallerSuccess(
      event.tcOAuthData,
      codeVerifier,
      event.profile,
      accessToken: event.accessToken,
      avatarUrl: event.profile?.avatarUrl,
    );
  }

  Future signInWithGoogle() async {
    try {
      if (!InternetService().isConnected) {
        CommonToast.error('no_internet_connection'.tr);
        return null;
      }

      AppLoader.show();

      final userCredential = await authService.signInWithGoogle();

      if (userCredential == null || userCredential.user == null) {
        AppLoader.hide();
        debugPrint('❌ Sign-in failed or cancelled');
        return null;
      }

      final user = userCredential.user!;
      final googleToken = authService.lastGoogleToken;

      debugPrint('✅ User: ${user.email}');
      debugPrint('🔑 Token: ${googleToken != null ? "Available" : "null"}');

      if (googleToken == null || googleToken.isEmpty) {
        AppLoader.hide();
        CommonToast.error('Failed to get authentication token');
        return null;
      }
    } catch (e) {
      AppLoader.hide();
      debugPrint('❌ Sign-in error: $e');
    }
  }

  Future<void> _handleTruecallerSuccess(
    TcOAuthData? oauthData,
    String? codeVerifier,
    dynamic profile, {
    String? accessToken,
    String? avatarUrl,
  }) async {
    try {
      debugPrint('✅ Truecaller Auth Code: ${oauthData?.authorizationCode}');
      debugPrint('✅ Truecaller Auth Code: $codeVerifier');
      debugPrint('✅ Truecaller Access Token: $accessToken');
      debugPrint('✅ Truecaller Avatar URL: $avatarUrl');
      debugPrint('✅ Truecaller Profile: ${profile?.phoneNumber}');

      // String? phoneNumber = profile?.phoneNumber;

      // if (profile is TruecallerUserProfile) {
      //   phoneNumber = profile.phoneNumber;
      // }

      // if (phoneNumber == null || phoneNumber.isEmpty) {
      //   phoneNumber = dialCode.value + phoneController.text;
      // }

      // // Ensure number starts with +
      // if (!phoneNumber.startsWith('+')) {
      //   phoneNumber = '+$phoneNumber';
      // }

      await apiHelper.post(
        ApiUrls.loginUrl,
        body: {
          if (oauthData?.authorizationCode != null)
            'authorizationCode': oauthData?.authorizationCode,
          if (codeVerifier != null) 'codeVerifier': codeVerifier,
          if (oauthData?.state != null) 'state': oauthData?.state,
          if (profile?.phoneNumber != null)
            'phone': profile?.phoneNumber
          else if (phoneController.text.isNotEmpty)
            'phone': dialCode.value + phoneController.text,
        },
        onSuccess: (res) async {
          showProgressBar.value = false;

          await CommonStorage.saveString(
            StorageKeys.token,
            res.data['data']['token'],
          );

          final userMap = res.data['data']['user'];
          if (userMap != null) {
            authService.onLogin(UserModel.fromJson(userMap));
          }

          Get.offAllNamed(AppRoutes.mainHomeScreen);
        },
        onError: (error) {
          showProgressBar.value = false;
          CommonToast.error(error.message);
        },
      );
    } catch (e) {
      showProgressBar.value = false;
      debugPrint('❌ Truecaller handle success error: $e');
    }
  }

  TextEditingController phoneController = TextEditingController();
  RxString phoneError = ''.obs;

  TextEditingController emailController = TextEditingController();
  RxString emailError = ''.obs;

  TextEditingController passwordController = TextEditingController();
  RxString passwordError = ''.obs;

  RxBool isPhoneValid = false.obs;
  RxBool isEmailValid = false.obs;

  RxBool isAgent = false.obs;

  // Manual Verification State
  Rx<TcSdkCallbackResult?> tempResult = Rx<TcSdkCallbackResult?>(null);
  RxBool invalidNumber = false.obs;
  RxBool invalidFName = false.obs;
  RxBool invalidOtp = false.obs;
  RxBool showProgressBar = false.obs;
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  Timer? _timer;
  RxnInt ttl = RxnInt();

  Future<void> validatePhoneWithLib(String phoneNumber) async {
    try {
      final bool isValid = Validator.validatePhoneNumber(
        phoneController.text,
        isoCode.value,
      );
      if (isValid != true) {
        phoneError.value = 'please_enter_valid_phone_number'.tr;
      } else {
        phoneError.value = '';
      }
    } catch (e) {
      phoneError.value = 'invalid_phone_number_format'.tr;
    }
  }

  validatePhone() {
    isPhoneValid.value =
        phoneController.text.isNotEmpty && phoneError.value.isEmpty;
  }

  onPhoneNumberChanged(isoCode1, dialCode1) {
    isoCode.value = isoCode1 ?? 'IN';
    dialCode.value = dialCode1 ?? '+91';

    validatePhoneWithLib(phoneController.text);
  }

  validateEmailAuth() {
    isEmailValid.value =
        emailController.text.isNotEmpty && emailError.value.isEmpty;
  }

  validateEmail() {
    if (emailController.text.isEmpty) {
      emailError.value = ValidationMessages.emailRequired.tr;
      return false;
    }
    if (!AppValidators.isValidEmail(emailController.text)) {
      emailError.value = ValidationMessages.emailInvalid.tr;
      return false;
    }
    emailError.value = '';
    return true;
  }

  validatePassword() {
    if (passwordController.text.isEmpty) {
      passwordError.value = ValidationMessages.passwordRequired.tr;
      return false;
    }
    passwordError.value = '';
    return true;
  }

  resetError() {
    emailError.value = '';
    passwordError.value = '';
    emailController.text = '';
    passwordController.text = '';
  }

  bool validateAgentCredentials() {
    bool isValid = true;

    if (emailController.text.isEmpty) {
      emailError.value = ValidationMessages.emailRequired.tr;
      isValid = false;
    } else if (!AppValidators.isValidEmail(emailController.text)) {
      emailError.value = ValidationMessages.emailInvalid.tr;
      isValid = false;
    } else {
      emailError.value = '';
    }

    if (passwordController.text.isEmpty) {
      passwordError.value = ValidationMessages.passwordRequired.tr;
      isValid = false;
    } else if (passwordController.text.length < 6) {
      passwordError.value = ValidationMessages.passwordInvalid.tr;
      isValid = false;
    } else {
      passwordError.value = '';
    }

    return isValid;
  }

  void toggleAgentMode() {
    FocusManager.instance.primaryFocus?.unfocus();
    isAgent.value = !isAgent.value;
    resetError();
  }

  Future<void> onTapAgentLogin() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!validateAgentCredentials()) {
      if (emailError.value.isNotEmpty) {
        CommonToast.error('please_enter_valid_email'.tr);
      } else if (passwordError.value.isNotEmpty) {
        CommonToast.error('please_enter_valid_password'.tr);
      }
      return;
    }

    await apiHelper.post(
      ApiUrls.loginUrl,
      body: {
        'email': emailController.text,
        'password': passwordController.text,
      },
      onSuccess: (response) async {
        debugPrint('response: $response');
        await CommonStorage.saveString(
          StorageKeys.token,
          response.data['data']['token'],
        );

        authService.onLogin(
          UserModel(
            email: emailController.text,
            name: response.data['data']['user']['name'],
            isAgent: true,
          ),
        );

        Get.offAllNamed(AppRoutes.mainHomeScreen);
        ResponsiveView.isWeb(Get.context!)
            ? Get.back()
            : Get.offAllNamed(AppRoutes.mainHomeScreen);
      },
      onError: (error) {
        CommonToast.error(error.message);
      },
    );
  }

  Future<void> onTapSignUp() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (phoneController.text.isEmpty) {
      CommonToast.error('please_enter_phone_number'.tr);
      return;
    }
    signUpApiCall();
  }

  void signUpApiCall({String? phone}) async {
    await apiHelper.post(
      ApiUrls.loginUrl,
      body: {'contact': phone ?? (dialCode.value + phoneController.text)},
      onSuccess: (response) async {
        await CommonStorage.saveString(
          StorageKeys.token,
          response.data['data']['token'],
        );
        authService.onLogin(
          UserModel(
            countryName: isoCode.value,
            countryIsoCode: dialCode.value,
            phone: phoneController.text,
          ),
        );
        ResponsiveView.isWeb(Get.context!)
            ? Get.back()
            : Get.offAllNamed(AppRoutes.mainHomeScreen);
      },
      onError: (error) {
        phoneController.text = '';
        CommonToast.error(error.message);
      },
    );
  }

  // Manual Verification Logic
  bool showInputNumberView() {
    return tempResult.value == null;
  }

  bool showInputNameView() {
    return tempResult.value != null &&
        (tempResult.value == TcSdkCallbackResult.missedCallReceived ||
            showInputOtpView());
  }

  bool showInputOtpView() {
    return tempResult.value != null &&
        ((tempResult.value == TcSdkCallbackResult.otpInitiated) ||
            (tempResult.value == TcSdkCallbackResult.otpReceived) ||
            (tempResult.value == TcSdkCallbackResult.imOtpInitiated) ||
            (tempResult.value == TcSdkCallbackResult.imOtpReceived));
  }

  bool showRetryTextView() {
    return ttl.value != null && !showInputNumberView();
  }

  void startCountdownTimer(int newTtl) {
    ttl.value = newTtl;
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (ttl.value! < 1) {
          timer.cancel();
          showProgressBar.value = false;
        } else {
          ttl.value = ttl.value! - 1;
        }
      },
    );
  }

  void handleVerificationCallback(TcSdkCallback callback) {
    debugPrint('Auth Controller: handleVerificationCallback received event: ${callback.result}');
    if (isPhoneValid.value) {
      if (callback.result != TcSdkCallbackResult.exception) {
        tempResult.value = callback.result;
      }
      showProgressBar.value = tempResult.value == TcSdkCallbackResult.missedCallInitiated;
      if (tempResult.value == TcSdkCallbackResult.otpReceived ||
          tempResult.value == TcSdkCallbackResult.imOtpReceived) {
        otpController.text = callback.otp!;
      }
    }

    switch (callback.result) {
      case TcSdkCallbackResult.missedCallInitiated:
        debugPrint('Auth Controller: Missed call initiated.');
        startCountdownTimer(double.parse(callback.ttl!).floor());
        CommonToast.success(
          "Missed call Initiated : ${callback.ttl}",
        );
        break;
      case TcSdkCallbackResult.missedCallReceived:
        debugPrint('Auth Controller: Missed call received.');
        CommonToast.success("Missed call Received");
        break;
      case TcSdkCallbackResult.otpInitiated:
        debugPrint('Auth Controller: OTP initiated.');
        startCountdownTimer(double.parse(callback.ttl!).floor());
        CommonToast.success(
          "OTP Initiated : ${callback.ttl}",
        );
        break;
      case TcSdkCallbackResult.otpReceived:
        debugPrint('Auth Controller: OTP received.');
        CommonToast.success("OTP Received : ${callback.otp}");
        break;
      case TcSdkCallbackResult.imOtpInitiated:
        debugPrint('Auth Controller: IM OTP initiated.');
        startCountdownTimer(double.parse(callback.ttl!).floor());
        CommonToast.success(
          "IM OTP Initiated : ${callback.ttl}",
        );
        break;
      case TcSdkCallbackResult.imOtpReceived:
        debugPrint('Auth Controller: IM OTP received.');
        CommonToast.success("IM OTP Received : ${callback.otp}");
        otpController.text = callback.otp!;
        break;
      case TcSdkCallbackResult.exception:
        debugPrint('Auth Controller: Verification exception: ${callback.exception!.message}');
        CommonToast.error(
          "try_again_after_some_time".tr,
        );
        break;
      case TcSdkCallbackResult.failure:
        debugPrint('Auth Controller: Verification failure: ${callback.error?.message}');
        CommonToast.error(
          "Failure : ${callback.error?.code ?? 'Unknown'} - ${callback.error?.message ?? ''}",
        );
        showProgressBar.value = false;
        break;
      default:
        debugPrint('Auth Controller: Unknown verification event: ${tempResult.value.toString()}');
        break;
    }
  }

  Future<void> onProceedClick() async {
    FocusManager.instance.primaryFocus?.unfocus();
    debugPrint('Auth Controller: onProceedClick initiated.');

    if (!isPhoneValid.value) {
      debugPrint('Auth Controller: Invalid phone number, aborting.');
      return;
    }
    if (showInputNumberView() && isPhoneValid.value) {
      debugPrint(
        'Auth Controller: Requesting verification for phoneNumber: ${dialCode.value + phoneController.text}',
      );
      try {
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.phone,
          // Permission.contacts, // Removed as per user request
          // Permission.callLog, // Handled by Permission.phone in some versions or not needed separately
        ].request();

        if (statuses[Permission.phone]!.isGranted) {
          debugPrint('Auth Controller: Requesting verification for phoneNumber: ${phoneController.text}');
          showProgressBar.value = true;
          await TcSdk.requestVerification(
            phoneNumber: phoneController.text,
            countryISO: isoCode.value,
          );
          // AppLoader is shown via stream events (missedCallInitiated, etc.)
        } else if (statuses[Permission.phone]!.isPermanentlyDenied) {
          debugPrint('Auth Controller: Phone permission permanently denied.');
          openAppSettings();
        } else {
          debugPrint('Auth Controller: Phone permission not granted.');
          CommonToast.error('please_grant_all_the_permissions_to_proceed'.tr);
        }
      } on PlatformException catch (exception) {
        debugPrint('Auth Controller: PlatformException during requestVerification: ${exception.message}');
        CommonToast.error(exception.message.toString());
      } catch (exception) {
        debugPrint('Auth Controller: Exception during requestVerification: $exception');
        CommonToast.error(exception.toString());
      }
    } else if (tempResult.value == TcSdkCallbackResult.missedCallReceived) {
      debugPrint('Auth Controller: Verifying missed call.');
      showProgressBar.value = true;
      TcSdk.verifyMissedCall(
        firstName: '',
        lastName: '',
      );
    } else if ((tempResult.value == TcSdkCallbackResult.otpInitiated ||
            tempResult.value == TcSdkCallbackResult.otpReceived ||
            tempResult.value == TcSdkCallbackResult.imOtpInitiated ||
            tempResult.value == TcSdkCallbackResult.imOtpReceived) &&
        validateOtp()) {
      debugPrint('Auth Controller: Verifying OTP.');
      showProgressBar.value = true;
      TcSdk.verifyOtp(
        firstName: '',
        lastName: '',
        otp: otpController.text,
      );
    }
  }

  bool validateOtp() {
    invalidOtp.value = otpController.text.length != 6;
    return !invalidOtp.value;
  }

  @override
  void onClose() {
    phoneController.dispose();
    fNameController.dispose();
    lNameController.dispose();
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thyna_core/controllers/main_controller.dart';
import 'package:thyna_core/utils/exceptions.dart';

class AuthController extends GetxController {
  static const String _tag = 'AuthController';
  final RxInt stackIndex = 0.obs;
  final RxBool sendToSignIn = false.obs;
  final RxBool hasSignInPageLoaded = false.obs;
  final MainController mainController = Get.find();

  InAppWebViewController? webViewController;
  final CookieManager cookieManager = CookieManager.instance();
  final InAppWebViewSettings settings = InAppWebViewSettings(
    incognito: true,
    transparentBackground: true,
    useShouldInterceptAjaxRequest: true,
    useShouldInterceptRequest: true,
  );

  bool _caughtAccessToken = false;
  @override
  void onInit() {
    hasSignInPageLoaded.listen((value) {
      if (value) {
        if (sendToSignIn.value) {
          stackIndex.value = 1;
        }
      }
    });
    super.onInit();
  }

  @override
  void onReady() async {
    await InAppWebViewController.clearAllCache();
    await _init();
    try {
      await _checkLogin();
    } on Exceptions catch (e) {
      Get.log("$_tag - USER sent to login screen ($e)");
      sendToSignIn.value = true;
    } catch (e, stack) {
      Get.log("[$_tag] Something went wrong");
      Get.log("$_tag - $e");
      Get.log("$_tag - $stack");
      stackIndex.value = 2;
    }
    super.onReady();
  }

  Future<void> _restartAuthFlow() async {
    try {
      stackIndex.value = 0;
      sendToSignIn.value = false;
      if (webViewController != null) {
        webViewController?.reload();
      }
      await _checkLogin();
    } on Exceptions catch (e) {
      Get.log("$_tag - USER sent to login screen ($e)");
      sendToSignIn.value = true;
    } catch (e, stack) {
      Get.log("Something went wrong");
      Get.log("$_tag - $e");
      Get.log("$_tag - $stack");
      stackIndex.value = 2;
    }
  }

  Future<void> _init() async {
    try {
      await dotenv.load(fileName: "assets/.env");
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
      // Authenticating the app itself to further secure the read/write operations
      await Supabase.instance.client.auth.signInWithPassword(
        email: dotenv.env['AUTH_EMAIL'],
        password: dotenv.env['AUTH_PASS'] ?? "",
      );
      if (!Platform.isWindows) {
        OneSignal.initialize(dotenv.env['ONESIGNAL_APP_ID']!);
        if (await OneSignal.Notifications.canRequest()) {
          OneSignal.Notifications.requestPermission(true);
        }
      }
    } catch (e, stack) {
      Get.log("_init: $e");
      Get.log("_init: $stack");
    }
  }

  /// Checks if the user is logged in by looking for a valid user ID in
  /// SharedPreferences. If the user ID is valid, it fetches the user's
  /// access token and refresh token from the database and assigns them
  /// to the [MainController.user] object. If the user ID is invalid or
  /// no user is found in the database, it throws an exception.
  ///
  /// Throws [Exceptions.userNotRegistered] if the user is not registered
  /// and [Exceptions.userNotFoundInDB] if the user is registered but not
  /// found in the database.
  Future<void> _checkLogin() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt("userID") ?? -1;
    if (userID != -1) {
      final userData = await mainController.supabase
          .from('Users')
          .select('access_token, refresh_token')
          .eq('id', userID);
      if (userData.isNotEmpty) {
        mainController.user.accessToken = userData.first['access_token'];
        mainController.user.refreshToken = userData.first['refresh_token'];
        await mainController.user.expaFetchUserData();
      } else {
        await prefs.remove('userID');
        throw Exceptions.userNotFoundInDB;
      }
    } else {
      throw Exceptions.userNotRegistered;
    }
  }

  void onProgressChanged(
      InAppWebViewController controller, int progress) async {
    final WebUri? currentURL = await controller.getUrl();

    if (currentURL != null) {
      if (currentURL.path == "/members/sign_in" && progress > 67) {
        Get.log("Should show the signin page now");
        hasSignInPageLoaded.value = true;
      }
    }
  }

  Future<AjaxRequestAction?> onAjaxReadyStateChange(
      InAppWebViewController webController, AjaxRequest ajaxRequest) async {
    Get.log("onAjaxReadyStateChange: ${ajaxRequest.url}");
    if (ajaxRequest.url!.path.contains('/oauth/token') &&
        ajaxRequest.responseText!.isNotEmpty) {
      final Map<String, dynamic> response =
          jsonDecode(ajaxRequest.responseText!);
      await webController.stopLoading();
      await CookieManager.instance().deleteAllCookies();
      await webController.platform.clearAllCache();
      await WebStorageManager.instance().deleteAllData();
      try {
        if (!_caughtAccessToken) {
          _caughtAccessToken = true;
          mainController.user.accessToken = response['access_token'];
          mainController.user.refreshToken = response['refresh_token'];
          await mainController.user.expaFetchUserData();
        }
      } catch (e, stack) {
        Get.log('[$_tag]: $e');
        Get.log('[$_tag]: $stack');
        stackIndex.value = 2;
      }
    }
    return AjaxRequestAction.PROCEED;
  }

  Future<void> onRefresh() async {
    await webViewController?.reload();
  }

  void onRetryButtonClick() {
    _restartAuthFlow();
  }
}

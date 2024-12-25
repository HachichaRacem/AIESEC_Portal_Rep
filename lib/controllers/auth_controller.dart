import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thyna_core/controllers/main_controller.dart';
import 'package:thyna_core/utils/auth_inappbrowser.dart';
import 'package:thyna_core/utils/auth_server.dart';
import 'package:thyna_core/utils/exceptions.dart';

class AuthController extends GetxController {
  static const String _tag = 'AuthController';

  final MainController mainController = Get.find();

  final RxInt authStatus = 0.obs;

  final InAppBrowser _browser = AuthInAppBrowser();
  final InAppBrowserClassSettings _settingsBrowser = InAppBrowserClassSettings(
    browserSettings: InAppBrowserSettings(
        allowGoBackWithBackButton: false, hideTitleBar: true, hideUrlBar: true),
  );
  final AuthServer _authServer = AuthServer();
  Isolate? _serverIsolate;
  @override
  void onReady() async {
    await _init();
    try {
      await _checkLogin();
    } on Exceptions catch (e) {
      _initServer();
      Get.log("[$_tag] - USER sent to the authentication screen ($e)");
      authStatus.value = 1;
    } catch (e, stack) {
      Get.log("[$_tag] - Something went wrong");
      Get.log("[$_tag] - $e");
      Get.log("[$_tag] - $stack");
      authStatus.value = 2;
    }
    super.onReady();
  }

  Future<void> _restartAuthFlow() async {
    try {
      authStatus.value = 0;
      await _checkLogin();
    } on Exceptions catch (e) {
      Get.log("[$_tag] - USER sent to the authentication screen ($e)");
      authStatus.value = 1;
    } catch (e, stack) {
      Get.log("[$_tag] - Something went wrong");
      Get.log("[$_tag] - $e");
      Get.log("[$_tag] - $stack");
      authStatus.value = 2;
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

  void _initServer() async {
    final ReceivePort receivePort = ReceivePort();
    final Map<String, dynamic> serverParams = {
      'env': {
        'REDIRECT_URI': dotenv.env['REDIRECT_URI']!,
        'CLIENT_ID': dotenv.env['CLIENT_ID']!,
        'CLIENT_SECRET': dotenv.env['CLIENT_SECRET']!,
      },
      'sendPort': receivePort.sendPort
    };
    _serverIsolate = await Isolate.spawn(_authServer.start, serverParams);
    receivePort.listen((value) {
      debugPrint("[MAIN THREAD - FROM SERVER]: $value");
    });
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
        Get.offAllNamed('/main');
      } else {
        await prefs.remove('userID');
        throw Exceptions.userNotFoundInDB;
      }
    } else {
      throw Exceptions.userNotRegistered;
    }
  }

  void onLoginBtnClick() {
    _browser.openUrlRequest(
        urlRequest: URLRequest(url: WebUri("http://localhost:8080")),
        settings: _settingsBrowser);
  }

  void onRetryButtonClick() {
    _restartAuthFlow();
  }

  @override
  Future<void> onClose() async {
    _serverIsolate?.kill(priority: Isolate.immediate);
    super.onClose();
  }
}

import 'dart:convert';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/auth_controller.dart';

class AuthInAppBrowser extends InAppBrowser {
  @override
  void onLoadStop(WebUri? url) async {
    if (url.toString().contains("?code=")) {
      await webViewController?.pause();
      await webViewController?.stopLoading();
      String? response = await webViewController?.evaluateJavascript(
          source: 'document.body.innerText');
      final AuthController authController = Get.find();
      if (response != null) {
        await hide();
        authController.authStatus.value = 0;
        final data = jsonDecode(response);
        authController.mainController.user.accessToken = data['access_token'];
        authController.mainController.user.refreshToken = data['refresh_token'];
        await authController.mainController.user.expaFetchUserData();
        Get.offAllNamed('/main');
      } else {
        Get.log('[onLoadStop]: No response');
        authController.authStatus.value = 2;
      }
    }
    super.onLoadStop(url);
  }
}

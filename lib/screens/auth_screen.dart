import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

// The windows inAppWebView implementation so far only allows to intercept requests (not responses apparently)
// Therefore you can only acquire the access token used in graphql requests (unless you analyse more the requests)
// However since you know the key related to the access and refresh token in the Chrome DevTool
// Search for it using the Storage API in the InAppWebView and/or the Cookies API in hope to get it.
// If found try to implement this in the mobile version since its faster and does not require to check if the access token
// is acquired and not and that value changes thingies used.

// Once done with acquiring and updating the access and refresh tokens to the DB, test the notifications by
// Adding a new row with the userID in the Notifications table and checking the logs

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return SafeArea(
      child: Obx(
        () => ColoredBox(
          color: const Color(0xFF037ef3),
          child: IndexedStack(
            index: controller.stackIndex.value,
            children: [
              Center(
                child: Image.asset(
                  "assets/loading.gif",
                  height: 125,
                  width: 125,
                ),
              ),
              RefreshIndicator.adaptive(
                onRefresh: controller.onRefresh,
                child: SingleChildScrollView(
                  child: Container(
                    height: Get.height,
                    color: Colors.white,
                    child: InAppWebView(
                      onWebViewCreated: (controller) =>
                          this.controller.webViewController ??= controller,
                      initialSettings: controller.settings,
                      onProgressChanged: controller.onProgressChanged,
                      initialUrlRequest: URLRequest(
                        url: WebUri('https://expa.aiesec.org'),
                      ),
                      onLoadStart: (webController, url) {
                        if (url!.path.contains('auth')) {
                          controller.stackIndex.value = 0;
                        }
                      },
                      onAjaxReadyStateChange: controller.onAjaxReadyStateChange,
                    ),
                  ),
                ),
              ),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Something went wrong",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: IconButton(
                            onPressed: controller.onRetryButtonClick,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                            ),
                            padding: EdgeInsets.zero),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

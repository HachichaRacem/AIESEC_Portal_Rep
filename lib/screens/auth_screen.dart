import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

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

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';

class AuthScreen extends GetView<AuthController> {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(AuthController());
    return Material(
      color: const Color(0xFF037ef3),
      child: Center(
        child: Obx(
          () => controller.authStatus.value == 0
              ? Image.asset(
                  "assets/loading.gif",
                  height: 125,
                  width: 125,
                )
              : controller.authStatus.value == 1
                  ? MaterialButton(
                      color: Get.theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      onPressed: controller.onLoginBtnClick,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 16,
                        children: [
                          Text("Login with EXPA"),
                          SvgPicture.asset(
                            'assets/expa_icon.svg',
                            height: 24,
                            width: 24,
                          ),
                        ],
                      ),
                    )
                  : Column(
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/home_controller.dart';
import 'package:thyna_core/widgets/cache_image.dart';

class HomeAppBar extends GetView<HomeController> {
  late final double _pictureRadius;
  HomeAppBar({super.key}) {
    Get.put(HomeController());
    _pictureRadius = Get.width < 400 ? 36 : 42;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Padding(
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: Get.mediaQuery.viewPadding.top + 24.0,
            bottom: 18),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CacheImage(
              imageURL: controller.mainController.user.profilePicture,
              height: _pictureRadius,
              width: _pictureRadius,
            ),
            SizedBox(width: Get.width > 400 ? 8 : 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "Hello ${controller.mainController.user.firstName},",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                      const Text(
                        "Welcome back",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

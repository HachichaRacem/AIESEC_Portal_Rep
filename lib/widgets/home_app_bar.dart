import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thyna_core/controllers/home_controller.dart';

class HomeAppBar extends GetView<HomeController> {
  late final Future<FileResponse> _pictureFuture;
  late final double _pictureRadius;
  HomeAppBar({super.key}) {
    Get.put(HomeController());
    _pictureFuture = DefaultCacheManager()
        .getImageFile(controller.mainController.user.profilePicture)
        .single;
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
            SizedBox(
              height: _pictureRadius,
              width: _pictureRadius,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: FutureBuilder<FileResponse>(
                  future: _pictureFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final FileInfo fileInfo =
                          snapshot.requireData as FileInfo;
                      if (!controller.mainController.user.hasSVGPicture) {
                        return Image.file(fileInfo.file);
                      } else {
                        return SvgPicture.file(fileInfo.file);
                      }
                    } else {
                      if (snapshot.hasError) {
                        Get.log(
                            "[HomeAppBar] Error loading SVG Picture : ${snapshot.error}");
                        Get.log(
                            "If this occurs, you might want to update _pictureFuture");
                      }
                      return Shimmer.fromColors(
                        baseColor: const Color(0xFFEBEBF4),
                        highlightColor: Get.theme.colorScheme.surface,
                        child: const ColoredBox(color: Colors.red),
                      );
                    }
                  },
                ),
              ),
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

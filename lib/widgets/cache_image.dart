import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CacheImage extends StatelessWidget {
  final String imageURL;

  final double width;
  final double height;

  late final Future<FileResponse> _imageFuture =
      DefaultCacheManager().getImageFile(imageURL).first;
  late final bool _isSVGPicture = imageURL.contains(".svg");

  CacheImage(
      {super.key, required this.imageURL, this.width = 42, this.height = 42});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: FutureBuilder<FileResponse>(
          future: _imageFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final FileInfo fileInfo = snapshot.requireData as FileInfo;
              if (!_isSVGPicture) {
                return Image.file(fileInfo.file);
              } else {
                return SvgPicture.file(fileInfo.file);
              }
            } else {
              if (snapshot.hasError) {
                Get.log(
                    "[CacheImage] Error loading Picture : ${snapshot.error}");
                Get.log(
                    "If this occurs, you might want to update _imageFuture");
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
    );
  }
}

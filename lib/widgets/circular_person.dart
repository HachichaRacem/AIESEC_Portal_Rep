import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thyna_core/widgets/person_sheet.dart';

class CircularPerson extends StatelessWidget {
  final Map personData;
  final bool hasSVGPicture;
  late final Future<FileResponse> _pictureFuture;

  CircularPerson(
      {super.key, required this.personData, required this.hasSVGPicture}) {
    _pictureFuture =
        DefaultCacheManager().getImageFile(personData['profile_photo']).single;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: () => Get.bottomSheet(PersonSheet(personData: personData),
            isScrollControlled: true, elevation: 0),
        child: Tooltip(
          message: "${personData['full_name']}".capitalizeAllWordsFirstLetter(),
          triggerMode: TooltipTriggerMode.longPress,
          child: Column(
            children: [
              SizedBox(
                height: 42,
                width: 42,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: FutureBuilder<FileResponse>(
                    future: _pictureFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final FileInfo fileInfo =
                            snapshot.requireData as FileInfo;
                        if (!hasSVGPicture) {
                          return Image.file(fileInfo.file);
                        } else {
                          return SvgPicture.file(fileInfo.file);
                        }
                      } else {
                        if (snapshot.hasError) {
                          Get.log(
                              "[CircularPerson] Error loading SVG Picture : ${snapshot.error}");
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
              const SizedBox(height: 6),
              Text(
                (personData['first_name'] as String).capitalizeFirst,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

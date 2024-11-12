import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thyna_core/controllers/main_controller.dart';

class PersonTile extends StatelessWidget {
  final Map personData;
  final VoidCallback? onViewDetailsClick;
  final VoidCallback? onAddManagerClick;

  late final String _personName;
  late final String _pictureURL;
  late final bool _hasSVGPicture;
  late final bool _hasManagers;
  late final bool _showAddManagerIcon;
  late final Future<FileResponse> _pictureFuture;

  PersonTile(
      {super.key,
      required this.personData,
      required this.onViewDetailsClick,
      this.onAddManagerClick}) {
    _personName =
        (personData['full_name'] as String).capitalizeAllWordsFirstLetter();

    _pictureURL = personData['profile_photo'];
    _hasSVGPicture = _pictureURL.contains('.svg');
    _hasManagers = (personData['managers'] as List).isNotEmpty;
    if (_hasManagers) {
      final List managers = personData['managers'] as List;
      final MainController mainController = Get.find();
      _showAddManagerIcon = !(managers.any((manager) =>
          '${manager['full_name']}'.toLowerCase() ==
          mainController.user.fullName.toLowerCase()));
    } else {
      _showAddManagerIcon = true;
    }
    _pictureFuture =
        DefaultCacheManager().getImageFile(personData['profile_photo']).single;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 36,
          width: 36,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: FutureBuilder<FileResponse>(
              future: _pictureFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final FileInfo fileInfo = snapshot.requireData as FileInfo;
                  if (!_hasSVGPicture) {
                    return Image.file(fileInfo.file);
                  } else {
                    return SvgPicture.file(fileInfo.file);
                  }
                } else {
                  if (snapshot.hasError) {
                    Get.log(
                        "[PersonTile] Error loading SVG Picture : ${snapshot.error}");
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
        Flexible(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _personName,
                      style: Get.textTheme.labelMedium!
                          .copyWith(color: Colors.black87),
                    ),
                    Text(
                      personData['id'],
                      style: Get.textTheme.labelSmall!.copyWith(
                        fontSize: 10,
                        color: Colors.black45,
                      ),
                    )
                  ],
                ),
                if (_hasManagers)
                  Flexible(
                      child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 6.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          personData['managers'].length,
                          (index) => Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Tooltip(
                              message:
                                  '${personData['managers'][index]['full_name']}'
                                      .capitalizeAllWordsFirstLetter(),
                              triggerMode: TooltipTriggerMode.longPress,
                              child: SizedBox(
                                height: 18,
                                width: 18,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: FutureBuilder<FileResponse>(
                                    future: DefaultCacheManager()
                                        .getImageFile(personData['managers']
                                            [index]['profile_photo'])
                                        .single,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        final FileInfo fileInfo =
                                            snapshot.requireData as FileInfo;
                                        final bool hasSVGPicture =
                                            personData['managers'][index]
                                                    ['profile_photo']
                                                .contains('.svg');
                                        if (!hasSVGPicture) {
                                          return Image.file(fileInfo.file);
                                        } else {
                                          return SvgPicture.file(fileInfo.file);
                                        }
                                      } else {
                                        return Shimmer.fromColors(
                                          baseColor: const Color(0xFFEBEBF4),
                                          highlightColor:
                                              Get.theme.colorScheme.surface,
                                          child: const ColoredBox(
                                              color: Colors.red),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ))
              ],
            ),
          ),
        ),
        Row(
          children: [
            TextButton(
              onPressed: onViewDetailsClick,
              child: Text(
                "View details",
                style: Get.textTheme.labelSmall!.copyWith(
                    color: Get.theme.colorScheme.primary, fontSize: 10),
              ),
            ),
            if (_showAddManagerIcon)
              Tooltip(
                message: 'Add yourself as manager to this person',
                triggerMode: TooltipTriggerMode.longPress,
                textStyle: Get.theme.textTheme.labelSmall!
                    .copyWith(color: Get.theme.colorScheme.surface),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    color: Colors.black54,
                    iconSize: 20,
                    onPressed: onAddManagerClick,
                    icon: const Icon(
                      Icons.person_add_alt_1_rounded,
                    ),
                  ),
                ),
              ),
          ],
        )
      ],
    );
  }
}

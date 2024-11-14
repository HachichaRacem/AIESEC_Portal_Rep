import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/main_controller.dart';
import 'package:thyna_core/widgets/cache_image.dart';

class PersonTile extends StatelessWidget {
  final Map personData;
  final VoidCallback? onViewDetailsClick;
  final VoidCallback? onAddManagerClick;

  late final String _personName;
  late final bool _hasManagers;
  late final bool _showAddManagerIcon;

  PersonTile(
      {super.key,
      required this.personData,
      required this.onViewDetailsClick,
      this.onAddManagerClick}) {
    _personName =
        (personData['full_name'] as String).capitalizeAllWordsFirstLetter();

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
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CacheImage(
          imageURL: personData['profile_photo'],
          width: 32,
          height: 32,
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
                              child: CacheImage(
                                  width: 18,
                                  height: 18,
                                  imageURL: personData['managers'][index]
                                      ['profile_photo']),
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

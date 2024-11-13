import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/widgets/cache_image.dart';
import 'package:thyna_core/widgets/person_sheet.dart';

class CircularPerson extends StatelessWidget {
  final Map personData;
  const CircularPerson({super.key, required this.personData});

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
              CacheImage(imageURL: personData['profile_photo']),
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

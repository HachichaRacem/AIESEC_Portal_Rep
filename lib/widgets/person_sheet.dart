import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thyna_core/controllers/home_controller.dart';
import 'package:thyna_core/widgets/person_about.dart';
import 'package:thyna_core/widgets/person_opportunities_applications.dart';

class PersonSheet extends GetView<HomeController> {
  final Map personData;

  late final Future<FileResponse> _pictureFuture;
  late final bool _hasSVGPicture;
  late final String _personName;
  late final bool _hasPhoneProvided;
  late final bool _hasCVProvided;
  late final bool _hasApplications;
  late final List _preferredProgs;
  late final String? _facultyName;

  PersonSheet({
    super.key,
    required this.personData,
  }) {
    _pictureFuture =
        DefaultCacheManager().getImageFile(personData['profile_photo']).single;
    _hasSVGPicture = personData['profile_photo'].contains(".svg");
    _personName =
        (personData['full_name'] as String).capitalizeAllWordsFirstLetter();
    _hasApplications =
        personData['opportunity_applications']['total_count'] > 0;
    _hasPhoneProvided = personData['contact_detail']['phone'] != null;
    _hasCVProvided = (personData['cvs'] as List).isNotEmpty;
    _preferredProgs = personData['person_profile']['selected_programmes'];
    _facultyName = personData['lc_alignment']?['keywords'];
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      maxChildSize: 0.65,
      initialChildSize: 0.65,
      minChildSize: 0.65,
      builder: (context, scrollController) => DecoratedBox(
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 46,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Get.theme.colorScheme.inverseSurface.withAlpha(160),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 74,
                  width: 74,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: FutureBuilder<FileResponse>(
                      future: _pictureFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final FileInfo fileInfo =
                              snapshot.requireData as FileInfo;
                          if (!_hasSVGPicture) {
                            return Image.file(fileInfo.file);
                          } else {
                            return SvgPicture.file(fileInfo.file);
                          }
                        } else {
                          if (snapshot.hasError) {
                            Get.log(
                                "Error loading profile photo in managed person sheet :");
                            Get.log("${snapshot.error}");
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
                Padding(
                  padding: const EdgeInsets.only(top: 6.0, bottom: 12),
                  child: Text(_personName),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Tooltip(
                      message:
                          'Phone number ${_hasPhoneProvided ? 'available' : 'not provided'}',
                      triggerMode: TooltipTriggerMode.longPress,
                      child: GestureDetector(
                        onTap: _hasPhoneProvided
                            ? () => controller.onPersonPhoneClick(
                                personData['contact_detail']['phone'])
                            : null,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _hasPhoneProvided
                                ? Get.theme.colorScheme.primary
                                : Get.theme.colorScheme.secondary,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Transform.flip(
                              flipX: !_hasPhoneProvided,
                              child: Icon(
                                _hasPhoneProvided
                                    ? Icons.phone_rounded
                                    : Icons.phone_disabled_rounded,
                                size: 18,
                                color: _hasPhoneProvided
                                    ? Get.theme.colorScheme.onPrimary
                                    : Get.theme.colorScheme.onSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                      child: Tooltip(
                        triggerMode: TooltipTriggerMode.longPress,
                        message: 'Email address available',
                        child: GestureDetector(
                          onTap: () => controller.onPersonEmailClick(
                              personData['secure_identity_email']),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Get.theme.colorScheme.primary,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.email_rounded,
                                size: 18,
                                color: Get.theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Tooltip(
                      message:
                          'CV ${_hasCVProvided ? 'available' : 'not provided'}',
                      triggerMode: TooltipTriggerMode.longPress,
                      child: GestureDetector(
                        onTap: _hasCVProvided
                            ? () => controller.onPersonCVClick(
                                (personData['cvs'] as List)[0]['url'],
                                _personName)
                            : null,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: _hasCVProvided
                                ? Get.theme.colorScheme.primary
                                : Get.theme.colorScheme.secondary,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              _hasCVProvided
                                  ? Icons.file_present_rounded
                                  : Icons.file_present_outlined,
                              size: 18,
                              color: _hasCVProvided
                                  ? Get.theme.colorScheme.onPrimary
                                  : Get.theme.colorScheme.onSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Flexible(
                child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    dividerHeight: 0,
                    labelStyle: Get.textTheme.bodySmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Get.theme.colorScheme.primary),
                    unselectedLabelStyle: Get.textTheme.bodySmall!.copyWith(
                      color: Get.theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    tabs: const [
                      Tab(
                        text: "About",
                      ),
                      Tab(
                        text: "Applications",
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        PersonAbout(
                          preferredProgs: _preferredProgs,
                          signedUpDate:
                              DateTime.parse(personData['created_at']),
                          gender: personData['gender'],
                          dateOfBirth: personData['dob'],
                          faculty: _facultyName,
                          referral: personData['referral_type'],
                        ),
                        PersonOpportunitiesApplications(
                          personData: personData,
                          hasApplications: _hasApplications,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

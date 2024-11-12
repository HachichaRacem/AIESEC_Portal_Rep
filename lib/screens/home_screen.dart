import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/home_controller.dart';
import 'package:thyna_core/widgets/circular_person.dart';
import 'package:thyna_core/widgets/home_analysis_widget.dart';
import 'package:thyna_core/widgets/person_application_tile.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Flexible(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 18),
                Flexible(
                  child: Obx(
                    () => DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF292929),
                      ),
                      child: controller.analysisChartStatus.value == 2
                          ? Center(
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
                                      padding: EdgeInsets.zero,
                                      onPressed:
                                          controller.analysisChartOnRetryClick,
                                      icon: const Icon(
                                        Icons.refresh_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : controller.analysisChartStatus.value == 1
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    top: 12.0,
                                    bottom: 12.0,
                                    right: 22,
                                    left: 12.0,
                                  ),
                                  child: HomeAnalysisWidget(),
                                )
                              : const Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      strokeCap: StrokeCap.round,
                                    ),
                                  ),
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    "Managed people",
                    style: Get.textTheme.titleMedium,
                  ),
                ),
                controller.mainController.user.managedPeople.isNotEmpty
                    ? Scrollbar(
                        radius: const Radius.circular(8.0),
                        controller: ScrollController(),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding:
                              const EdgeInsets.only(bottom: 12.0, top: 4.0),
                          child: Obx(
                            () => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: List.generate(
                                  controller
                                      .mainController.user.managedPeople.length,
                                  (index) => CircularPerson(
                                    personData: controller.mainController.user
                                        .managedPeople[index],
                                    hasSVGPicture: (controller.mainController
                                                .user.managedPeople[index]
                                            ['profile_photo'] as String)
                                        .contains('.svg'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Center(
                          child: Text(
                            "You do not manage anyone yet",
                            style: Get.theme.textTheme.labelMedium!
                                .copyWith(color: Colors.grey[600]),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: Text(
                    "Recent applications",
                    style: Get.textTheme.titleMedium,
                  ),
                ),
                Flexible(
                  child: controller
                          .mainController.user.recentApplications.isEmpty
                      ? Center(
                          child: Text(
                            "No applications yet",
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 13),
                          ),
                        )
                      : Scrollbar(
                          radius: const Radius.circular(8),
                          interactive: true,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            padding:
                                const EdgeInsets.only(bottom: 8.0, right: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: List.generate(
                                controller.mainController.user
                                    .recentApplications.length,
                                (index) {
                                  final Map applicationData = controller
                                      .mainController
                                      .user
                                      .recentApplications[index];
                                  final String personName =
                                      '${applicationData['person']['full_name']}'
                                          .capitalizeAllWordsFirstLetter();
                                  final String opportunityTitle =
                                      '${applicationData['opportunity']['title']}'
                                          .capitalizeAllWordsFirstLetter();
                                  final hostDetails =
                                      '${applicationData['opportunity']['host_lc']['name']} - ${applicationData['opportunity']['host_lc']['parent']['name']}'
                                          .capitalizeAllWordsFirstLetter();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    child: PersonApplicationTile(
                                      header: personName,
                                      title: opportunityTitle,
                                      label: hostDetails,
                                      pictureURL: applicationData['person']
                                          ['profile_photo'],
                                      status: applicationData['status'],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}



/**
 Replace with HomeAnalysisData if needed


 PageView(
  controller:
      controller.overviewCardsPageController,
  children: List.generate(
    controller.statuses.length,
    (index) => controller.overviewCardsStatus.value == 0
        ? Shimmer.fromColors(
            baseColor: const Color(0xFFEBEBF4),
            highlightColor:
                Get.theme.colorScheme.surface,
            child: const OverviewCard(
                status: "",
                month: "",
                talentValue: 0,
                teachingValue: 0))
        : OverviewCard(
            status: controller.statuses[index],
            month: controller.months[
                controller.currentMonth.month -
                    1],
            talentValue: controller.overviewCardsData['talent']![
                controller.statuses[index]
                    .toLowerCase()]!,
            teachingValue: controller
                    .overviewCardsData['teaching']![
                controller.statuses[index].toLowerCase()]!),
  ),
),

*/

/**

Page indicators below the overviewCards
 
 Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 12),
                  child: Center(
                    child: Obx(
                      () => controller.overviewCardsStatus.value == 0
                          ? Shimmer.fromColors(
                              baseColor: const Color(0xFFEBEBF4),
                              highlightColor: Get.theme.colorScheme.surface,
                              child: SmoothPageIndicator(
                                controller:
                                    controller.overviewCardsPageController,
                                count: controller.statuses.length,
                                effect:
                                    const WormEffect(dotHeight: 8, dotWidth: 8),
                              ),
                            )
                          : SmoothPageIndicator(
                              controller:
                                  controller.overviewCardsPageController,
                              count: controller.statuses.length,
                              effect: WormEffect(
                                  dotHeight: 8,
                                  dotWidth: 8,
                                  dotColor: Get.theme.colorScheme.surfaceDim,
                                  activeDotColor: const Color(0xff4b79a1)),
                            ),
                    ),
                  ),
                ),


 */
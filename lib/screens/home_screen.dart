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
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    "Performance review",
                    style: Get.textTheme.titleMedium,
                  ),
                ),
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
                const SizedBox(height: 14),
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
                    bottom: 10,
                  ),
                  child: Text(
                    "Recent applications",
                    style: Get.textTheme.titleMedium,
                  ),
                ),
                Flexible(
                  child:
                      controller.mainController.user.recentApplications.isEmpty
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
                                padding: const EdgeInsets.only(right: 8.0),
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
                                        padding:
                                            const EdgeInsets.only(bottom: 12.0),
                                        child: PersonApplicationTile(
                                          applicationData: applicationData,
                                          header: personName,
                                          title: opportunityTitle,
                                          label: hostDetails,
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

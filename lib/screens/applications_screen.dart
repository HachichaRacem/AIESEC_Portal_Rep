import 'package:another_stepper/another_stepper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/applications_controller.dart';
import 'package:thyna_core/widgets/person_application_tile.dart';

class ApplicationsScreen extends GetView<ApplicationsController> {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ApplicationsController());
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onFabClick,
        child: const Icon(Icons.filter_alt_rounded),
      ),
      body: Obx(
        () => controller.applicationsDataStatus.value == 0
            ? Center(
                child: Text(
                  "Use the filters to search for applications",
                  style: Get.theme.textTheme.labelMedium!.copyWith(
                    color: Colors.black54,
                  ),
                ),
              )
            : controller.applicationsDataStatus.value == 1
                ? const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeCap: StrokeCap.round,
                        strokeWidth: 3.0,
                      ),
                    ),
                  )
                : controller.applicationsDataStatus.value == 3
                    ? Center(
                        child: Text(
                          "Something went wrong",
                          style: Get.theme.textTheme.labelMedium!.copyWith(
                            color: Get.theme.colorScheme.error,
                          ),
                        ),
                      )
                    : controller.applicationsData['data'].isNotEmpty
                        ? SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                vertical: 3.0, horizontal: 6.0),
                            child: Column(
                              children: List.generate(
                                controller.applicationsData['paging']
                                    ['total_items'],
                                (index) {
                                  final Map applicationData = controller
                                      .applicationsData['data'][index];
                                  final String opportunityTitle =
                                      '${applicationData['opportunity']['title']}'
                                          .capitalizeAllWordsFirstLetter();
                                  final hostDetails =
                                      '${applicationData['opportunity']['host_lc']['name']} - ${applicationData['opportunity']['host_lc']['parent']['name']}'
                                          .capitalizeAllWordsFirstLetter();
                                  final String programmeShortNameDisplay =
                                      applicationData['opportunity']
                                              ['programmes'][0]
                                          ['short_name_display'];
                                  final String applicantName =
                                      '${applicationData['person']['full_name']}'
                                          .capitalizeAllWordsFirstLetter();
                                  final opportunityProgrammePictureURL =
                                      'https://aiesec-logos.s3.eu-west-1.amazonaws.com/${programmeShortNameDisplay.toUpperCase()}%20LOGO%20COLOR.png';
                                  final TextStyle stepperTitle =
                                      Get.theme.textTheme.labelSmall!.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 9);
                                  final TextStyle stepperSubtitle =
                                      Get.theme.textTheme.labelSmall!.copyWith(
                                    color: Colors.grey[500],
                                    fontSize: 8,
                                  );
                                  List<StepperData> stepperList = [
                                    StepperData(
                                      title: StepperText('Applied',
                                          textStyle: stepperTitle),
                                      subtitle: StepperText(
                                        '${applicationData['created_at']}'
                                            .split('T')[0],
                                        textStyle: stepperSubtitle,
                                      ),
                                    ),
                                  ];
                                  int activeIndex = 0;
                                  List<String> applicationTimeline = [];
                                  final statusList = [
                                    'matched',
                                    'approved',
                                    'realized',
                                    'finished',
                                    'completed'
                                  ];

                                  activeIndex = statusList
                                      .indexOf(applicationData['status']);

                                  if (activeIndex != -1) {
                                    applicationTimeline.addAll(
                                        statusList.sublist(0, activeIndex + 1));
                                    for (final status in applicationTimeline) {
                                      String date = '';
                                      if (status == 'finished') {
                                        date = applicationData[
                                            'experience_end_date'];
                                      } else if (status == 'completed') {
                                        date = applicationData['updated_at'];
                                      } else {
                                        Get.log('date_$status');
                                        date = applicationData['date_$status'];
                                      }
                                      stepperList.add(
                                        StepperData(
                                          title: StepperText(
                                              status.capitalizeFirst,
                                              textStyle: stepperTitle),
                                          subtitle: StepperText(
                                            date.split('T')[0],
                                            textStyle: stepperSubtitle,
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (applicationData['status'] == 'open') {
                                      activeIndex = 0;
                                    } else if (applicationData['status'] ==
                                        'rejected') {
                                      stepperList.add(
                                        StepperData(
                                          title: StepperText('Rejected',
                                              textStyle: stepperTitle),
                                          subtitle: StepperText(
                                            '${applicationData['matched_or_rejected_at']}'
                                                .split('T')[0],
                                            textStyle: stepperSubtitle,
                                          ),
                                        ),
                                      );

                                      activeIndex = 1;
                                    } else if (applicationData['status'] ==
                                        'approval_broken') {
                                      final sequence = [
                                        'matched',
                                        'approval_broken'
                                      ];
                                      for (final status in sequence) {
                                        stepperList.add(
                                          StepperData(
                                            title: StepperText(
                                                status
                                                    .replaceAll('_', ' ')
                                                    .capitalizeAllWordsFirstLetter(),
                                                textStyle: stepperTitle),
                                            subtitle: StepperText(
                                              '${applicationData['date_$status']}'
                                                  .split('T')[0],
                                              textStyle: stepperSubtitle,
                                            ),
                                          ),
                                        );
                                      }
                                      activeIndex = 2;
                                    } else if (applicationData['status'] ==
                                        'withdrawn') {
                                      stepperList.add(StepperData(
                                          title: StepperText('Withdrawn',
                                              textStyle: stepperTitle),
                                          subtitle: StepperText(
                                            '${applicationData['updated_at']}'
                                                .split('T')[0],
                                            textStyle: stepperSubtitle,
                                          )));
                                      activeIndex = 1;
                                    }
                                  }

                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 18.0),
                                    child: PersonApplicationTile(
                                      header: opportunityTitle,
                                      title: hostDetails,
                                      label: 'By $applicantName',
                                      pictureURL:
                                          opportunityProgrammePictureURL,
                                      pictureRadius: 36,
                                      expandableChild: [
                                        AnotherStepper(
                                            iconHeight: 14,
                                            iconWidth: 14,
                                            activeIndex: activeIndex + 1,
                                            stepperList: stepperList,
                                            stepperDirection: Axis.horizontal),
                                        if (applicationData[
                                                'rejection_reason'] !=
                                            null)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              applicationData[
                                                  'rejection_reason']['name'],
                                              overflow: TextOverflow.ellipsis,
                                              style: stepperSubtitle.copyWith(
                                                color: Get.theme.colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                          )
                                      ],
                                      expandable: true,
                                      status: applicationData['status'],
                                      showExtraActionsDots: true,
                                      popupItemsBuilder: (context) => [
                                        PopupMenuItem(
                                          onTap: () => controller
                                              .onShowPersonItemTap(index),
                                          value: 0,
                                          child: Text(
                                            "View Person",
                                            style:
                                                Get.theme.textTheme.labelSmall,
                                          ),
                                        ),
                                        PopupMenuItem(
                                          onTap: () => controller
                                              .onShowOpportunityItemTap(index),
                                          value: 1,
                                          child: Text(
                                            "View Opportunity",
                                            style:
                                                Get.theme.textTheme.labelSmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              "No results found, adjust your filters and try again",
                              style: Get.theme.textTheme.labelMedium!.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ),
      ),
    );
  }
}

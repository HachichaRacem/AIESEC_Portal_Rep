import 'package:another_stepper/another_stepper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/home_controller.dart';
import 'package:thyna_core/widgets/person_application_tile.dart';

class PersonOpportunitiesApplications extends GetView<HomeController> {
  late final bool _hasApplications;
  final Map personData;
  PersonOpportunitiesApplications(
      {super.key, required bool hasApplications, required this.personData}) {
    _hasApplications = hasApplications;
  }

  @override
  Widget build(BuildContext context) {
    return _hasApplications
        ? SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
            child: Column(
              children: List.generate(
                personData['opportunity_applications']['total_count'],
                (index) {
                  final Map applicationData =
                      personData['opportunity_applications']['nodes'][index];
                  final String opportunityTitle =
                      '${applicationData['opportunity']['title']}'
                          .capitalizeAllWordsFirstLetter();
                  final hostDetails =
                      '${applicationData['opportunity']['host_lc']['name']} - ${applicationData['opportunity']['host_lc']['parent']['name']}'
                          .capitalizeAllWordsFirstLetter();
                  final TextStyle stepperTitle = Get.theme.textTheme.labelSmall!
                      .copyWith(fontWeight: FontWeight.bold, fontSize: 9);
                  final TextStyle stepperSubtitle =
                      Get.theme.textTheme.labelSmall!.copyWith(
                    color: Colors.grey[500],
                    fontSize: 8,
                  );
                  List<StepperData> stepperList = [
                    StepperData(
                      title: StepperText('Applied', textStyle: stepperTitle),
                      subtitle: StepperText(
                        '${applicationData['created_at']}'.split('T')[0],
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

                  activeIndex = statusList.indexOf(applicationData['status']);

                  if (activeIndex != -1) {
                    applicationTimeline
                        .addAll(statusList.sublist(0, activeIndex + 1));
                    for (final status in applicationTimeline) {
                      String date = '';
                      if (status == 'finished') {
                        date = applicationData['experience_end_date'];
                      } else if (status == 'completed') {
                        date = applicationData['updated_at'];
                      } else {
                        date = applicationData['date_$status'];
                      }
                      stepperList.add(
                        StepperData(
                          title: StepperText(status.capitalizeFirst,
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
                    } else if (applicationData['status'] == 'rejected') {
                      stepperList.add(
                        StepperData(
                          title:
                              StepperText('Rejected', textStyle: stepperTitle),
                          subtitle: StepperText(
                            '${applicationData['matched_or_rejected_at']}'
                                .split('T')[0],
                            textStyle: stepperSubtitle,
                          ),
                        ),
                      );

                      activeIndex = 1;
                    } else if (applicationData['status'] == 'approval_broken') {
                      final sequence = ['matched', 'approval_broken'];
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
                    } else if (applicationData['status'] == 'withdrawn') {
                      stepperList.add(StepperData(
                          title:
                              StepperText('Withdrawn', textStyle: stepperTitle),
                          subtitle: StepperText(
                            '${applicationData['updated_at']}'.split('T')[0],
                            textStyle: stepperSubtitle,
                          )));
                      activeIndex = 1;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18.0),
                    child: PersonApplicationTile(
                      applicationData: applicationData,
                      header: opportunityTitle,
                      title: hostDetails,
                      pictureRadius: 36,
                      expandableChild: [
                        AnotherStepper(
                            iconHeight: 14,
                            iconWidth: 14,
                            activeIndex: activeIndex + 1,
                            stepperList: stepperList,
                            stepperDirection: Axis.horizontal),
                        if (applicationData['rejection_reason'] != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              applicationData['rejection_reason']['name'],
                              overflow: TextOverflow.ellipsis,
                              style: stepperSubtitle.copyWith(
                                color: Get.theme.colorScheme.onSurface,
                              ),
                            ),
                          )
                      ],
                      expandable: true,
                      onLongPress: controller.onPersonApplicationLongPress,
                    ),
                  );
                },
              ),
            ),
          )
        : Center(
            child: Text(
              "Has not applied yet",
              style: Get.theme.textTheme.labelMedium!.copyWith(
                color: Colors.grey[600],
              ),
            ),
          );
  }
}

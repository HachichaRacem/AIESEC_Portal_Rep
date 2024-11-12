import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/applications_controller.dart';

class ApplicationsFilterDialog extends GetView<ApplicationsController> {
  const ApplicationsFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Filters",
                style: Get.theme.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24.0, bottom: 6.0),
              child: Text(
                "Date Range",
                style: Get.theme.textTheme.labelLarge!
                    .copyWith(color: Colors.black87),
              ),
            ),
            Column(
              children: [
                Obx(
                  () => Wrap(
                    spacing: 12.0,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      controller.preSelectedDateRanges.length,
                      (index) => ChoiceChip(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color:
                                controller.selectedDateRangeIndex.value == index
                                    ? Get.theme.colorScheme.onPrimaryContainer
                                        .withAlpha(30)
                                    : const Color.fromARGB(25, 0, 0, 0),
                          ),
                        ),
                        labelStyle: Get.theme.textTheme.labelSmall!.copyWith(
                            color:
                                controller.selectedDateRangeIndex.value == index
                                    ? Get.theme.colorScheme.onPrimaryContainer
                                    : Colors.black54),
                        selected:
                            controller.selectedDateRangeIndex.value == index,
                        onSelected: (value) {
                          index == 0
                              ? controller.selectedDateRangeIndex.value = 0
                              : value
                                  ? controller.selectedDateRangeIndex.value =
                                      index
                                  : controller.selectedDateRangeIndex.value = 0;
                          controller.filtersCustomDateRange.value = '';
                        },
                        label: Text(controller.preSelectedDateRanges[index]),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () =>
                            controller.onFiltersCustomRangeClick(context),
                        child: Obx(() => Text(
                              controller.filtersCustomDateRange.value.isEmpty
                                  ? "Custom Range"
                                  : controller.filtersCustomDateRange.value,
                              style: Get.theme.textTheme.labelSmall,
                            )),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0, bottom: 6.0),
              child: Text(
                "Status",
                style: Get.theme.textTheme.labelLarge!
                    .copyWith(color: Colors.black87),
              ),
            ),
            Obx(
              () => Wrap(
                spacing: 12.0,
                alignment: WrapAlignment.center,
                children: List.generate(
                  controller.statuses.length,
                  (index) => ChoiceChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: controller.selectedStatusIndex.value == index
                            ? Get.theme.colorScheme.onPrimaryContainer
                                .withAlpha(30)
                            : const Color.fromARGB(25, 0, 0, 0),
                      ),
                    ),
                    labelStyle: Get.theme.textTheme.labelSmall!.copyWith(
                        color: controller.selectedStatusIndex.value == index
                            ? Get.theme.colorScheme.onPrimaryContainer
                            : Colors.black54),
                    selected: controller.selectedStatusIndex.value == index,
                    onSelected: (value) => value
                        ? controller.selectedStatusIndex.value = index
                        : controller.selectedStatusIndex.value = -1,
                    label: Text(controller.statuses[index]),
                  ),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: controller.onFiltersDialogClearBtnClick,
                      child: const Text("Clear"),
                    ),
                    ElevatedButton(
                      onPressed: controller.onFiltersDialogApplyBtnClick,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Get.theme.colorScheme.surfaceDim;
                            }
                            return Get.theme.colorScheme.primary;
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith(
                          (states) {
                            if (states.contains(WidgetState.disabled)) {
                              return Get.theme.colorScheme.onSurfaceVariant
                                  .withAlpha(150);
                            }
                            return Get.theme.colorScheme.onPrimary;
                          },
                        ),
                      ),
                      child: const Text("Apply"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

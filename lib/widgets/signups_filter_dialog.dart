import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/signups_controller.dart';

class SignupsFilterDialog extends GetView<SignupsController> {
  const SignupsFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                "Filters",
                style: Get.theme.textTheme.titleLarge,
              ),
            ),
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                                  color: controller
                                              .selectedDateRangeIndex.value ==
                                          index
                                      ? Get.theme.colorScheme.onPrimaryContainer
                                          .withAlpha(30)
                                      : const Color.fromARGB(25, 0, 0, 0),
                                ),
                              ),
                              labelStyle: Get.theme.textTheme.labelSmall!
                                  .copyWith(
                                      color: controller.selectedDateRangeIndex
                                                  .value ==
                                              index
                                          ? Get.theme.colorScheme
                                              .onPrimaryContainer
                                          : Colors.black54),
                              selected:
                                  controller.selectedDateRangeIndex.value ==
                                      index,
                              onSelected: (value) {
                                index == 0
                                    ? controller.selectedDateRangeIndex.value =
                                        0
                                    : value
                                        ? controller.selectedDateRangeIndex
                                            .value = index
                                        : controller
                                            .selectedDateRangeIndex.value = 0;
                                controller.filtersCustomDateRange.value = '';
                              },
                              label:
                                  Text(controller.preSelectedDateRanges[index]),
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
                                    controller.filtersCustomDateRange.value
                                            .isEmpty
                                        ? "Custom Range"
                                        : controller
                                            .filtersCustomDateRange.value,
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
                      "AIESECer",
                      style: Get.theme.textTheme.labelLarge!
                          .copyWith(color: Colors.black87),
                    ),
                  ),
                  Obx(
                    () => Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.aiesecerChoices.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 18, left: 8.0),
                          child: ChoiceChip(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                color: controller.isAiesecerIndex.value == index
                                    ? Get.theme.colorScheme.onPrimaryContainer
                                        .withAlpha(30)
                                    : const Color.fromARGB(25, 0, 0, 0),
                              ),
                            ),
                            labelStyle: Get
                                .theme.textTheme.labelSmall!
                                .copyWith(
                                    color: controller.isAiesecerIndex.value ==
                                            index
                                        ? Get.theme.colorScheme
                                            .onPrimaryContainer
                                        : Colors.black54),
                            selected: controller.isAiesecerIndex.value == index,
                            onSelected: (value) => value
                                ? controller.isAiesecerIndex.value = index
                                : controller.isAiesecerIndex.value = -1,
                            label: Text(controller.aiesecerChoices[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0, bottom: 6.0),
                    child: Text(
                      "Background",
                      style: Get.theme.textTheme.labelLarge!
                          .copyWith(color: Colors.black87),
                    ),
                  ),
                  Obx(
                    () => DropdownMenu(
                      hintText: "Select a background",
                      menuHeight: 250,
                      initialSelection:
                          controller.filtersBackgroundID.value == 0
                              ? null
                              : controller.filtersBackgroundID.value,
                      textStyle: Get.textTheme.bodySmall!
                          .copyWith(color: Get.theme.colorScheme.primary),
                      trailingIcon: Icon(
                        Icons.arrow_drop_down_rounded,
                        color: controller.filtersBackgroundID.value == 0
                            ? null
                            : Get.theme.colorScheme.primary,
                      ),
                      selectedTrailingIcon: Icon(
                        Icons.arrow_drop_up_rounded,
                        color: controller.filtersBackgroundID.value == 0
                            ? null
                            : Get.theme.colorScheme.primary,
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        constraints:
                            BoxConstraints.tight(const Size.fromHeight(40)),
                        hintStyle: Get.theme.textTheme.bodySmall!.copyWith(
                            color: Get.theme.colorScheme.onSurfaceVariant),
                        isDense: true,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        activeIndicatorBorder: BorderSide.none,
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: controller.filtersBackgroundID.value == 0
                                ? Colors.black54
                                : Get.theme.colorScheme.primary,
                            width: controller.filtersBackgroundID.value == 0
                                ? 1.0
                                : 2.0,
                          ),
                        ),
                      ),
                      menuStyle: const MenuStyle(alignment: Alignment.center),
                      onSelected: controller.onFiltersBackgroundChange,
                      dropdownMenuEntries: List.generate(
                        controller.mainController.backgrounds.length,
                        (index) => DropdownMenuEntry(
                          labelWidget: Text(
                            controller.mainController.backgrounds.keys
                                .elementAt(index),
                            style: Get.textTheme.bodySmall,
                          ),
                          value: controller.mainController.backgrounds.values
                              .elementAt(index),
                          label: controller.mainController.backgrounds.keys
                              .elementAt(index),
                        ),
                      ),
                    ),
                  ),
                ],
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

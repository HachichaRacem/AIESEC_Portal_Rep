import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/signups_controller.dart';

class SignupsScreen extends GetView<SignupsController> {
  const SignupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SignupsController());
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: Obx(() => FloatingActionButton(
            onPressed: controller.onFabClick,
            child: controller.signupsData.isEmpty
                ? const Icon(Icons.filter_alt_rounded)
                : const Icon(Icons.close_rounded),
          )),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Theme(
              data: ThemeData(
                textSelectionTheme: TextSelectionThemeData(
                  selectionColor: Colors.grey[300],
                  selectionHandleColor: Colors.grey[500],
                ),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Get.theme.colorScheme.surfaceContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Obx(() => Row(
                        children: [
                          Flexible(
                            child: TextField(
                              controller: controller.searchBarController,
                              textAlign: TextAlign.start,
                              textAlignVertical: TextAlignVertical.top,
                              cursorHeight: 16,
                              focusNode: controller.searchBarFocusNode,
                              onChanged: controller.onSearchBarValueChanged,
                              onSubmitted: controller.onSearchBarConfirm,
                              cursorRadius: const Radius.circular(50),
                              cursorColor: Colors.grey[600],
                              selectionControls:
                                  MaterialTextSelectionControls(),
                              style: Get.theme.textTheme.labelMedium!
                                  .copyWith(color: Colors.black87),
                              onTapOutside: (event) =>
                                  controller.searchBarFocusNode.unfocus(),
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                    borderSide: BorderSide.none),
                                hintText: "Search for a person",
                                hintStyle:
                                    Get.theme.textTheme.labelMedium!.copyWith(
                                  color: Colors.grey[600],
                                ),
                                icon: const Icon(Icons.search_rounded),
                                contentPadding:
                                    const EdgeInsets.only(left: 4, right: 6),
                              ),
                            ),
                          ),
                          if (controller.searchQuery.isNotEmpty)
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: IconButton(
                                onPressed: controller.onSearchBarClearClick,
                                icon: const Icon(Icons.close_rounded, size: 16),
                                color: Get.theme.colorScheme.error,
                                padding: EdgeInsets.zero,
                              ),
                            )
                        ],
                      )),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Obx(
                () => controller.signupsDataStatus.value == 0
                    ? Center(
                        child: Text(
                          "Use the filters or the search bar to find people",
                          style: Get.theme.textTheme.labelMedium!.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      )
                    : controller.signupsDataStatus.value == 1
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
                        : controller.signupsDataStatus.value == 3
                            ? Center(
                                child: Text(
                                  "Something went wrong",
                                  style:
                                      Get.theme.textTheme.labelMedium!.copyWith(
                                    color: Get.theme.colorScheme.error,
                                  ),
                                ),
                              )
                            : controller.signupsData.isNotEmpty
                                ? SingleChildScrollView(
                                    padding: const EdgeInsets.only(bottom: 60),
                                    child: Column(
                                      children: [
                                        ...controller.personTiles,
                                        Text(
                                          "A total of ${controller.signupsData.length} people found",
                                          style: Get.textTheme.labelSmall!
                                              .copyWith(
                                            color: Colors.black38,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      "No results found, adjust your filters and try again",
                                      style: Get.theme.textTheme.labelMedium!
                                          .copyWith(
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

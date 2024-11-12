import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/main_controller.dart';
import 'package:thyna_core/screens/applications_screen.dart';
import 'package:thyna_core/screens/home_screen.dart';
import 'package:thyna_core/screens/signups_screen.dart';
import 'package:thyna_core/widgets/home_app_bar.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize:
            Size(double.infinity, Get.mediaQuery.viewPadding.top + 56),
        child: HomeAppBar(),
      ),
      bottomNavigationBar: Obx(
        () => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (controller.showProgressIndicator.value)
              const LinearProgressIndicator(
                borderRadius: BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
            NavigationBar(
              backgroundColor: Get.theme.colorScheme.surface,
              selectedIndex: controller.bottomNavBarIndex.value,
              onDestinationSelected: controller.onNavigationDestinationTap,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                  selectedIcon: Icon(Icons.home_filled),
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  label: 'Sign ups',
                  selectedIcon: Icon(Icons.people_rounded),
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded),
                  label: 'Applications',
                  selectedIcon: Icon(Icons.work_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
      body: PageView(
        controller: controller.mainPageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [HomeScreen(), SignupsScreen(), ApplicationsScreen()],
      ),
    );
  }
}

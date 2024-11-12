import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ToastType { success, error, warning, info }

class ToastCards {
  static success({required String message, bool pulsateIcon = false}) {
    Get.showSnackbar(GetSnackBar(
      snackPosition: SnackPosition.top,
      barBlur: 1.0,
      shouldIconPulse: pulsateIcon,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      snackStyle: SnackStyle.floating,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      messageText: Text(
        message,
        style: Get.theme.textTheme.labelLarge!
            .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      borderRadius: 40,
      backgroundColor: Colors.green.withOpacity(0.95),
    ));
  }

  static info({required String message, bool pulsateIcon = false}) {
    Get.showSnackbar(GetSnackBar(
      snackPosition: SnackPosition.top,
      shouldIconPulse: pulsateIcon,
      icon: const Icon(Icons.info_rounded, color: Colors.white),
      snackStyle: SnackStyle.floating,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      messageText: Text(
        message,
        style: Get.theme.textTheme.labelLarge!
            .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      borderRadius: 40,
      backgroundColor: Colors.blue.withOpacity(0.95),
    ));
  }

  static warning({required String message, bool pulsateIcon = false}) {
    Get.showSnackbar(GetSnackBar(
      snackPosition: SnackPosition.top,
      shouldIconPulse: pulsateIcon,
      icon: const Icon(Icons.warning_rounded, color: Colors.white),
      snackStyle: SnackStyle.floating,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      messageText: Text(
        message,
        style: Get.theme.textTheme.labelLarge!
            .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      borderRadius: 40,
      backgroundColor: Colors.orange.withOpacity(0.95),
    ));
  }

  static error({required String message, bool pulsateIcon = false}) {
    Get.showSnackbar(GetSnackBar(
      snackPosition: SnackPosition.top,
      shouldIconPulse: pulsateIcon,
      icon: const Icon(Icons.cancel_rounded, color: Colors.white),
      snackStyle: SnackStyle.floating,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      messageText: Text(
        message,
        style: Get.theme.textTheme.labelLarge!
            .copyWith(color: Colors.white, fontWeight: FontWeight.w500),
      ),
      borderRadius: 40,
      backgroundColor: Colors.red.withOpacity(0.95),
    ));
  }
}

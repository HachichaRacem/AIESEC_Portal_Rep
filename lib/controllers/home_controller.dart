import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thyna_core/controllers/main_controller.dart';
import 'package:thyna_core/widgets/opportunity_managers_dialog.dart';
import 'package:thyna_core/widgets/toast_card.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final RxInt analysisChartStatus =
      0.obs; // 0 - loading, 1 - succeess, 2 - error

  final MainController mainController = Get.find();
  final Map<String, Map<String, Map>> analysisChartData = {};

  final DateTime currentMonth = DateTime.now();

  final List<String> shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  final List<String> statuses = [
    'Applied',
    'Accepted',
    'Approved',
    'Realized',
    'Finished',
    'Completed'
  ];

  @override
  void onInit() {
    _initAnalysisChart();
    super.onInit();
  }

  String _getDateRangeOfMonth({required int month, bool isEndOfDay = false}) {
    final DateTime now =
        DateTime(month == 1 ? currentMonth.year + 1 : currentMonth.year, month);
    final DateTime endOfMonthDate = DateTime(now.year, now.month + 1, 0);
    if (isEndOfDay) {
      return "${endOfMonthDate.year}-${endOfMonthDate.month.toString().padLeft(2, "0")}-${endOfMonthDate.day.toString().padLeft(2, "0")} 23:59:59";
    } else {
      return "${now.year}-${now.month.toString().padLeft(2, "0")}-01 00:00:00";
    }
  }

  void _extractMonthDataPerProduct(
      {required Map monthData,
      required String status,
      required Map monthDataPerProduct}) {
    final Map<String, Set<String>> applicants = {'talent': {}, 'teaching': {}};
    for (final talentApp in monthData['${status}_8']['data']) {
      applicants['talent']!.add(talentApp['person']['full_name']);
    }
    for (final teachingApp in monthData['${status}_9']['data']) {
      applicants['teaching']!.add(teachingApp['person']['full_name']);
    }
    monthDataPerProduct['talent']![status] = applicants['talent']!.length;
    monthDataPerProduct['teaching']![status] = applicants['teaching']!.length;
  }

  List<int> _getSemesterMonths() {
    final List<int> firstSemester = [2, 3, 4, 5, 6, 7];
    final List<int> secondSemester = [8, 9, 10, 11, 12, 1];
    if (firstSemester.contains(currentMonth.month)) {
      final currentMonthIndex = firstSemester.indexOf(currentMonth.month);
      return firstSemester.sublist(0, currentMonthIndex + 1);
    }
    final currentMonthIndex = secondSemester.indexOf(currentMonth.month);
    return secondSemester.sublist(0, currentMonthIndex + 1);
  }

  Future<Map> _getMonthAnalysisData(String startDate, String endDate) async {
    final headers = {
      'Authorization': mainController.user.accessToken,
      'Content-Type': 'application/json'
    };
    String query =
        '{applied_8:allOpportunityApplication(filters:{created_at:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[8]}pagination:{per_page:150}){data{status person{full_name}}}accepted_8:allOpportunityApplication(filters:{date_matched:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[8]}pagination:{per_page:150}){data{status person{full_name}}}approved_8:allOpportunityApplication(filters:{date_approved:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[8]}pagination:{per_page:150}){data{status person{full_name}}}realized_8:allOpportunityApplication(filters:{experience_start_date:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[8]status:"realized"}pagination:{per_page:150}){data{status person{full_name}}}finished_8:allOpportunityApplication(filters:{experience_end_date:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[8]status:"finished"}pagination:{per_page:150}){data{status person{full_name}}}completed_8:allOpportunityApplication(filters:{experience_end_date:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[8]status:"completed"}pagination:{per_page:150}){data{status person{full_name}}}applied_9:allOpportunityApplication(filters:{created_at:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[9]}pagination:{per_page:150}){data{status person{full_name}}}accepted_9:allOpportunityApplication(filters:{date_matched:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[9]}pagination:{per_page:150}){data{status person{full_name}}}approved_9:allOpportunityApplication(filters:{date_approved:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[9]}pagination:{per_page:150}){data{status person{full_name}}}realized_9:allOpportunityApplication(filters:{experience_start_date:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[9]status:"realized"}pagination:{per_page:150}){data{status person{full_name}}}finished_9:allOpportunityApplication(filters:{experience_end_date:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[9]status:"finished"}pagination:{per_page:150}){data{status person{full_name}}}completed_9:allOpportunityApplication(filters:{experience_end_date:{from:"$startDate",to:"$endDate"}person_committee:${mainController.user.lcID} programmes:[9]status:"completed"}pagination:{per_page:150}){data{status person{full_name}}}}';

    final payload = {
      'query': query,
    };
    final response = await mainController.dioClient.post(
      "/graphql",
      data: payload,
      options: Options(headers: headers),
    );
    return response.data['data'];
  }

  Future<void> _initAnalysisChart() async {
    final semesterMonths = _getSemesterMonths();
    analysisChartData.clear(); // For debugging purposes, might keep it
    try {
      for (final month in semesterMonths) {
        final Map<String, Map<String, int>> monthDataPerProduct = {
          'talent': {},
          'teaching': {}
        };
        final String startDate = _getDateRangeOfMonth(month: month);
        final String endDate =
            _getDateRangeOfMonth(month: month, isEndOfDay: true);
        final Map monthData = await _getMonthAnalysisData(startDate, endDate);

        for (final status in statuses) {
          _extractMonthDataPerProduct(
              monthData: monthData,
              status: status.toLowerCase(),
              monthDataPerProduct: monthDataPerProduct);
        }
        analysisChartData[shortMonths[month - 1]] = monthDataPerProduct;
      }
      analysisChartStatus.value = 1;
    } catch (e, stack) {
      analysisChartStatus.value = 2;
      Get.log("HomeController.initAnalysisChart : $e");
      Get.log("HomeController.initAnalysisChart : $stack");
    }
  }

  void analysisChartOnRetryClick() {
    analysisChartStatus.value = 0;
    _initAnalysisChart();
  }

  void onPersonPhoneClick(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ToastCards.warning(
          message:
              'Could not open default phone application\nPhone number will be copied to clipboard instead');
      try {
        await Clipboard.setData(ClipboardData(text: phone));
      } catch (e, stack) {
        ToastCards.error(message: 'Could not copy phone number to clipboard');
        Get.log("onPersonPhoneClick: $e");
        Get.log("onPersonPhoneClick: $stack");
      }
    }
  }

  Future<String> _getCVDownloadPath() async {
    Directory? downloadDirectory = Directory('/storage/emulated/0/Download');
    if (downloadDirectory.existsSync()) {
      return downloadDirectory.path;
    } else {
      downloadDirectory = await getDownloadsDirectory();
      if (downloadDirectory != null) {
        return downloadDirectory.path;
      }
      return "";
    }
  }

  void onPersonCVClick(String url, String personName) async {
    try {
      final String cvDownloadPath = await _getCVDownloadPath();
      if (cvDownloadPath.isNotEmpty) {
        final String fileName = '${personName.replaceAll(' ', '_')}_CV.pdf';
        File cvFile = File('$cvDownloadPath/$fileName');
        ToastCards.info(
            message: 'Downloading and opening CV..', pulsateIcon: true);
        if (!cvFile.existsSync()) {
          await mainController.dioClient.download(
              url, '$cvDownloadPath/$fileName',
              onReceiveProgress: (received, total) => Get.log(
                  "Downloading CV (${((received / total) * 100).toStringAsFixed(2)}%)"));
        }
        final openResults = await OpenFilex.open('$cvDownloadPath/$fileName');
        Get.log("openResults: ${openResults.message}");
        if (openResults.type == ResultType.permissionDenied) {
          ToastCards.error(message: 'Permission denied to open CV');
        }
      } else {
        Get.log("Could not acquire download path");
      }
    } catch (e) {
      Get.log("onPersonCVClick: $e");
    }
  }

  void onPersonEmailClick(String email) async {
    try {
      await Clipboard.setData(ClipboardData(text: email));
      ToastCards.success(message: 'Email copied to clipboard');
    } catch (e) {
      ToastCards.error(message: 'Failed to copy to clipboard');
      Get.log("onPersonEmailClick: $e");
    }
  }

  String _formatOpportunityLink(int oppId, String oppProgramme) {
    String url = 'https://www.aiesec.org/opportunity/';
    if (oppProgramme == 'GTa') {
      url += 'global-talent/$oppId';
    } else if (oppProgramme == 'GTe') {
      url += 'global-teacher/$oppId';
    }
    return url;
  }

  void _onShowOpportunityItemTap(int oppId, String oppProgramme) async {
    final String url = _formatOpportunityLink(oppId, oppProgramme);
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ToastCards.warning(
          message: 'Could not open browser, copying link instead...');
      await _onCopyLinkItemTap(oppId, oppProgramme);
    }
  }

  void _onViewManagersItemTap(List managers) async {
    await Get.dialog(OpportunityManagersDialog(
      managers: managers,
    ));
  }

  Future<void> _onCopyLinkItemTap(int oppId, String oppProgramme) async {
    final String url = _formatOpportunityLink(oppId, oppProgramme);
    try {
      await Clipboard.setData(ClipboardData(text: url));
      ToastCards.success(message: 'Link copied to clipboard.');
    } catch (e) {
      ToastCards.error(message: 'Could not copy link to clipboard.');
      Get.log("[HomeController] Copying Opportunity link returned error : $e");
    }
  }

  void onPersonApplicationLongPress(
      LongPressStartDetails details, Map applicationData) {
    final oppID = int.parse(applicationData['opportunity']['id']);
    final oppProgramme =
        applicationData['opportunity']['programmes'][0]['short_name_display'];

    final offset = details.globalPosition;
    final RelativeRect position = RelativeRect.fromLTRB(
        offset.dx, offset.dy, Get.width - offset.dx, Get.height - offset.dy);
    showMenu(context: Get.context!, position: position, items: [
      PopupMenuItem(
        height: 20,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
        child: Text("Copy link", style: Get.textTheme.bodySmall),
        onTap: () => _onCopyLinkItemTap(oppID, oppProgramme),
      ),
      PopupMenuItem(
        height: 20,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
        child: Text("Open opportunity", style: Get.textTheme.bodySmall),
        onTap: () => _onShowOpportunityItemTap(oppID, oppProgramme),
      ),
      PopupMenuItem(
        height: 20,
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
        child: Text("View managers", style: Get.textTheme.bodySmall),
        onTap: () =>
            _onViewManagersItemTap(applicationData['opportunity']['managers']),
      )
    ]);
  }
}

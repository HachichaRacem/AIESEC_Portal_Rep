import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/main_controller.dart';
import 'package:thyna_core/controllers/signups_controller.dart';
import 'package:thyna_core/widgets/applications_filter_dialog.dart';
import 'package:thyna_core/widgets/opportunity_managers_dialog.dart';
import 'package:thyna_core/widgets/toast_card.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationsController extends GetxController {
  final MainController _mainController = Get.find();

  RxInt applicationsDataStatus = RxInt(0);
  RxMap applicationsData = {}.obs;

  final List<String> _months = [
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
  final List<String> preSelectedDateRanges = [
    'Today',
    'Yesterday',
    'This Month',
    'Last Month'
  ];
  final RxInt selectedDateRangeIndex = RxInt(0);

  final RxString filtersCustomDateRange = ''.obs;
  String _filtersCustomDateRangeStart = '';
  String _filtersCustomDateRangeEnd = '';

  final List<String> statuses = [
    'Open',
    'Accepted',
    'Approved',
    'Realized',
    'Finished',
    'Completed',
    'Rejected',
    'Withdrawn'
  ];

  final RxInt selectedStatusIndex = RxInt(-1);

  void onFabClick() {
    Get.dialog(const ApplicationsFilterDialog());
  }

  Future<void> onFiltersCustomRangeClick(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? dateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: now,
      barrierDismissible: false,
      currentDate: now,
    );
    if (dateRange != null) {
      filtersCustomDateRange.value =
          "${_months[dateRange.start.month - 1]} ${dateRange.start.day} - ${_months[dateRange.end.month - 1]} ${dateRange.end.day}";
      selectedDateRangeIndex.value = -1;
      _filtersCustomDateRangeStart =
          '${dateRange.start.year}-${dateRange.start.month.toString().padLeft(2, '0')}-${dateRange.start.day.toString().padLeft(2, '0')} 00:00:00';
      _filtersCustomDateRangeEnd =
          '${dateRange.end.year}-${dateRange.end.month.toString().padLeft(2, '0')}-${dateRange.end.day.toString().padLeft(2, '0')} 23:59:59';
    } else {
      selectedDateRangeIndex.value = 0;
      filtersCustomDateRange.value = '';
    }
  }

  void onFiltersDialogClearBtnClick() {
    Get.close(closeDialog: true);
    filtersCustomDateRange.value = '';
    selectedStatusIndex.value = -1;
    selectedDateRangeIndex.value = 0;
  }

  Future<void> onFiltersDialogApplyBtnClick() async {
    final DateTime today = DateTime.now();
    if (filtersCustomDateRange.isEmpty) {
      switch (selectedDateRangeIndex.value) {
        case 1:
          final DateTime yesterday = today.subtract(const Duration(days: 1));
          _filtersCustomDateRangeStart =
              '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')} 00:00:00';
          _filtersCustomDateRangeEnd =
              '${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')} 23:59:59';
          break;
        case 2:
          _filtersCustomDateRangeStart =
              '${today.year}-${today.month.toString().padLeft(2, '0')}-01 00:00:00';
          _filtersCustomDateRangeEnd =
              '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')} 23:59:59';
          break;
        case 3:
          final DateTime lastMonth = DateTime(today.year, today.month, 0);
          _filtersCustomDateRangeStart =
              '${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}-01 00:00:00';
          _filtersCustomDateRangeEnd =
              '${lastMonth.year}-${lastMonth.month.toString().padLeft(2, '0')}-${lastMonth.day.toString().padLeft(2, '0')} 23:59:59';
          break;
        default:
          _filtersCustomDateRangeStart =
              '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')} 00:00:00';
          _filtersCustomDateRangeEnd =
              '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')} 23:59:59';
          break;
      }
    }
    Map<String, dynamic> filters = {
      'person_committee': _mainController.user.lcID,
      'programmes': _mainController.user.focusProducts,
      'created_at': {
        'from': '"$_filtersCustomDateRangeStart"',
        'to': '"$_filtersCustomDateRangeEnd"'
      }
    };
    if (selectedStatusIndex.value != -1) {
      filters.addAll({
        'status': '"${statuses[selectedStatusIndex.value]}"'.toLowerCase(),
      });
    }
    final headers = {
      'Authorization': _mainController.user.accessToken,
      'Content-Type': 'application/json'
    };
    final String query =
        '{allOpportunityApplication(filters:$filters per_page:500){data{status created_at date_matched date_approved date_realized experience_end_date date_approval_broken matched_or_rejected_at updated_at rejection_reason{name}person{id full_name profile_photo cvs{id url}contact_detail{email phone}secure_identity_email}opportunity{id title programmes{short_name_display} managers{full_name profile_photo current_positions{function{name}role{name}}contact_detail{country_code phone email facebook}} host_lc{id name parent{id name}}}}paging{total_items}}}';
    final payload = {
      'query': query,
    };
    applicationsDataStatus.value = 1;
    Get.close(closeDialog: true);
    try {
      final response = await _mainController.dioClient.post(
        "/graphql",
        data: payload,
        options: Options(headers: headers),
      );
      applicationsData.value =
          response.data['data']['allOpportunityApplication'];
      applicationsDataStatus.value = 2;
    } catch (e, stack) {
      applicationsDataStatus.value = 3;
      Get.log("onFiltersDialogApplyBtnClick (applications) : $e");
      Get.log("onFiltersDialogApplyBtnClick (applications): $stack");
    }
  }

  Future<void> onShowPersonItemTap(int applicationIndex) async {
    final SignupsController signupsController =
        Get.putOrFind(() => SignupsController());
    final String applicantName =
        applicationsData['data'][applicationIndex]['person']['full_name'];
    final String applicantID =
        applicationsData['data'][applicationIndex]['person']['id'];
    signupsController.searchQuery.value = applicantName;
    signupsController.searchBarController.text =
        applicantName.capitalizeAllWordsFirstLetter();
    signupsController.onSearchBarConfirm('',
        animateTile: true, personID: applicantID);
    _mainController.onNavigationDestinationTap(1);
  }

  void onShowOpportunityItemTap(int applicationIndex) async {
    final String oppId =
        applicationsData['data'][applicationIndex]['opportunity']['id'];
    final String oppProgramme = applicationsData['data'][applicationIndex]
        ['opportunity']['programmes'][0]['short_name_display'];
    String url = 'https://www.aiesec.org/opportunity/';
    if (oppProgramme == 'GTa') {
      url += 'global-talent/$oppId';
    } else if (oppProgramme == 'GTe') {
      url += 'global-teacher/$oppId';
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ToastCards.warning(
          message: 'Could not open browser, copying link instead...');
      try {
        await Clipboard.setData(ClipboardData(text: url));
        ToastCards.success(message: 'Link copied to clipboard.');
      } catch (e) {
        ToastCards.error(message: 'Could not copy link to clipboard.');
        Get.log("onShowOpportunityItemTap: $e");
      }
    }
  }

  String _formatOpportunityLink(String oppId, String oppProgramme) {
    String url = 'https://www.aiesec.org/opportunity/';
    if (oppProgramme == 'GTa') {
      url += 'global-talent/$oppId';
    } else if (oppProgramme == 'GTe') {
      url += 'global-teacher/$oppId';
    }
    return url;
  }

  void onCopyLinkItemTap(int applicationIndex) async {
    final String oppId =
        applicationsData['data'][applicationIndex]['opportunity']['id'];
    final String oppProgramme = applicationsData['data'][applicationIndex]
        ['opportunity']['programmes'][0]['short_name_display'];
    final String url = _formatOpportunityLink(oppId, oppProgramme);
    try {
      await Clipboard.setData(ClipboardData(text: url));
      ToastCards.success(message: 'Link copied to clipboard.');
    } catch (e) {
      ToastCards.error(message: 'Could not copy link to clipboard.');
      Get.log("[Applications Controller] : onCopyLinkItemTap -> $e");
    }
  }

  void onShowOpportunityManagers(int applicationIndex) async {
    await Get.dialog(OpportunityManagersDialog(
      managers: applicationsData['data'][applicationIndex]['opportunity']
          ['managers'],
    ));
  }
}

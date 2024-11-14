import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:thyna_core/controllers/main_controller.dart';
import 'package:thyna_core/widgets/person_sheet.dart';
import 'package:thyna_core/widgets/person_tile.dart';
import 'package:thyna_core/widgets/signups_filter_dialog.dart';
import 'package:thyna_core/widgets/toast_card.dart';

class SignupsController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // This controller is responsible for:
  //  - Keeping the filters variables
  //  - Show filters dialog on FAB click
  //  - Handles errors and fetching data for the signups
  //  - Handles the search feature

  final MainController mainController = Get.find();
  final RxInt signupsDataStatus =
      0.obs; // 0 - none, 1 - loading, 2 - success, 3 - error

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

  final FocusNode searchBarFocusNode = FocusNode();
  final TextEditingController searchBarController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxInt selectedDateRangeIndex = (0).obs;

  final List<String> aiesecerChoices = ['Yes', 'No'];
  final RxInt isAiesecerIndex = (-1).obs;
  final RxString filtersCustomDateRange = ''.obs;

  final RxInt filtersBackgroundID = 0.obs;

  final RxList signupsData = RxList.empty();
  List<Widget> personTiles = [];
  late final AnimationController foundTileAnimCtrl = AnimationController(
    vsync: this,
    lowerBound: 0.0,
    upperBound: 0.1,
    duration: const Duration(milliseconds: 300),
  )..addListener(() => foundTileScaleValue.value = foundTileAnimCtrl.value);
  final RxDouble foundTileScaleValue = 0.0.obs;

  final String _peopleDataQuery =
      'data{id referral_type created_at gender dob full_name first_name profile_photo cvs{id url}contact_detail{email phone} lc_alignment{keywords} person_profile{selected_programmes backgrounds{id name}} secure_identity_email opportunity_applications{total_count nodes{status created_at date_matched date_approved date_realized experience_end_date date_approval_broken matched_or_rejected_at updated_at rejection_reason{name}opportunity{id title programmes{short_name_display} managers{full_name profile_photo current_positions{function{name}role{name}}contact_detail{country_code phone email facebook}} host_lc{id name parent{id name}}}}}managers{id full_name profile_photo}}';

  String _filtersCustomDateRangeStart = '';
  String _filtersCustomDateRangeEnd = '';

  void onFabClick() {
    if (signupsData.isEmpty) {
      Get.dialog(const SignupsFilterDialog());
    } else {
      signupsData.clear();
      signupsDataStatus.value = 0;
    }
  }

  void onSearchBarValueChanged(String? value) {
    if (value != null) {
      searchQuery.value = value;
    }
  }

  void onSearchBarClearClick() {
    searchQuery.value = '';
    searchBarController.clear();
    searchBarFocusNode.requestFocus();
  }

  Future<void> onSearchBarConfirm(String? value,
      {bool animateTile = false, String personID = ''}) async {
    if (searchQuery.isNotEmpty) {
      final headers = {
        'Authorization': mainController.user.accessToken,
        'Content-Type': 'application/json'
      };
      final filters = {'q': '"${searchQuery.value.toLowerCase()}"'};
      final String query =
          '{people(filters:$filters,per_page: 500){$_peopleDataQuery}}';
      final payload = {
        'query': query,
      };
      signupsDataStatus.value = 1;
      try {
        final response = await mainController.dioClient.post(
          "/graphql",
          data: payload,
          options: Options(headers: headers),
        );
        signupsData.value = response.data['data']['people']['data'];
        generatePersonTiles();
        if (animateTile) {
          debugPrint("animateTile is true");
          if (personID.isNotEmpty) {
            for (int i = 0; i < personTiles.length; i++) {
              if (personTiles[i] is PersonTile) {
                final PersonTile personTile = personTiles[i] as PersonTile;
                if (personTile.personData['id'] == personID) {
                  debugPrint(
                      "Found the tile in the personTiles list (matched $personID), animating...");
                  personTiles[i] = Obx(
                    () => Transform.scale(
                        scale: 1 + foundTileScaleValue.value,
                        child: personTile),
                  );
                  break;
                }
              }
            }
            Future.delayed(
              Durations.short3,
              () => foundTileAnimCtrl.forward().then(
                    (_) => foundTileAnimCtrl.reverse(),
                  ),
            );
          }
        }
        signupsDataStatus.value = 2;
      } catch (e, stack) {
        signupsDataStatus.value = 3;
        Get.log("onSearchBarConfirm: $e");
        Get.log("onSearchBarConfirm: $stack");
      }
    }
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
      filtersCustomDateRange.value = '';
      selectedDateRangeIndex.value = 0;
    }
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
    Map<String, dynamic> filters = {'home_committee': mainController.user.lcID};
    if (_filtersCustomDateRangeStart.isNotEmpty &&
        _filtersCustomDateRangeEnd.isNotEmpty) {
      filters.addAll({
        'registered': {
          'from': '"$_filtersCustomDateRangeStart"',
          'to': '"$_filtersCustomDateRangeEnd"'
        }
      });
    }
    if (isAiesecerIndex.value != -1) {
      filters
          .addAll({'is_aiesecer': isAiesecerIndex.value == 0 ? true : false});
    }
    if (filtersBackgroundID.value != 0) {
      filters.addAll({
        'background_ids': [filtersBackgroundID.value]
      });
    }
    final headers = {
      'Authorization': mainController.user.accessToken,
      'Content-Type': 'application/json'
    };
    final String query =
        '{people(filters:$filters,per_page: 500){$_peopleDataQuery}}';
    final payload = {
      'query': query,
    };
    signupsDataStatus.value = 1;
    Get.close(closeDialog: true);
    try {
      final response = await mainController.dioClient.post(
        "/graphql",
        data: payload,
        options: Options(headers: headers),
      );
      signupsData.value = response.data['data']['people']['data'];
      generatePersonTiles();
      signupsDataStatus.value = 2;
    } catch (e, stack) {
      signupsDataStatus.value = 3;
      Get.log("onFiltersDialogApplyBtnClick : $e");
      Get.log("onFiltersDialogApplyBtnClick : $stack");
    }
  }

  void generatePersonTiles() {
    personTiles = List.generate(
      signupsData.length,
      (index) {
        List<int> managerIDs = [];
        for (final manager in signupsData[index]['managers']) {
          managerIDs.add(int.parse(manager['id']));
        }
        return PersonTile(
          personData: signupsData.elementAt(index),
          onViewDetailsClick: () => onPersonTileClick(index),
          onAddManagerClick: () => onAddManagerClick(
            int.parse(signupsData[index]['id']),
            managerIDs,
          ),
        );
      },
    );
  }

  void onPersonTileClick(int index) {
    Get.bottomSheet(PersonSheet(personData: signupsData[index]),
        isScrollControlled: true, elevation: 0);
  }

  void onFiltersDialogClearBtnClick() {
    Get.close(closeDialog: true);
    filtersCustomDateRange.value = '';
    isAiesecerIndex.value = -1;
    selectedDateRangeIndex.value = 0;
    filtersBackgroundID.value = 0;
  }

  void onFiltersBackgroundChange(int? value) {
    if (value != null) {
      if (value != filtersBackgroundID.value) {
        filtersBackgroundID.value = value;
      }
    }
  }

  Future<void> onAddManagerClick(int personID, List managerIDs) async {
    managerIDs.add(mainController.user.userID);
    final headers = {
      'Authorization': mainController.user.accessToken,
      'Content-Type': 'application/json'
    };
    final String query =
        'mutation{updatePerson(id:$personID,person:{manager_ids:$managerIDs}){id created_at referral_type gender dob full_name first_name profile_photo cvs{id url} lc_alignment{keywords} contact_detail{email phone}secure_identity_email opportunity_applications{total_count nodes{status created_at date_matched date_approved date_realized experience_end_date date_approval_broken matched_or_rejected_at updated_at rejection_reason{name} opportunity{title programmes{short_name_display}host_lc{id name parent{id name}}}}}}}';
    final payload = {
      'query': query,
    };
    try {
      mainController.showProgressIndicator.value = true;
      final response = await mainController.dioClient.post(
        "/graphql",
        data: payload,
        options: Options(headers: headers),
      );
      mainController.user.managedPeople
          .add(response.data['data']['updatePerson']);
      // To refresh the screen and show the updated list
      if (searchQuery.isNotEmpty) {
        // If used the search bar to begin with
        onSearchBarConfirm('');
      } else {
        onFiltersDialogApplyBtnClick();
      }
      ToastCards.success(message: 'Assigned you as a manager successfully');
    } catch (e, stack) {
      ToastCards.error(message: 'Failed to assign you as a manager');
      Get.log("onAddManagerClick : $e");
      Get.log("onAddManagerClick : $stack");
    } finally {
      mainController.showProgressIndicator.value = false;
    }
  }
}

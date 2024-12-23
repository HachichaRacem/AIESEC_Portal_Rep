import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thyna_core/controllers/main_controller.dart';

class ExpaUser {
  String firstName = "";
  String fullName = "";
  String accessToken = "";
  String refreshToken = "";
  String lcName = "";
  String position = "";
  String profilePicture = "";
  bool hasSVGPicture = false;

  int lcID = -1;
  int userID = -1;

  RxList managedPeople = RxList.empty();
  List focusProducts = [];
  List recentApplications = [];

  StreamSubscription<List<Map<String, dynamic>>>?
      _windowsNotificationsSubscription;

  void updateFromJson(Map json) {
    firstName = (json['currentPerson']['first_name'] as String).capitalizeFirst;
    fullName = json['currentPerson']['full_name'];
    lcID = int.parse(json['currentPerson']['home_lc']['id']);
    lcName = json['currentPerson']['home_lc']['name'];
    userID = int.parse(json['currentPerson']['id']);
    position = json['currentPerson']['current_positions'][0]['title'];
    focusProducts =
        json['currentPerson']['current_positions'][0]['focus_products'];

    profilePicture = json['currentPerson']['profile_photo'];
    hasSVGPicture = profilePicture.contains(".svg");

    managedPeople.value = json['people']['data'];
    recentApplications = json['allOpportunityApplication']['data'];
  }

  Future<void> expaFetchUserData() async {
    final MainController mainController = Get.find();
    final DateTime now = DateTime.now();
    final DateTime endOfMonthDate = DateTime(now.year, now.month + 1, 0);
    final String startDate =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01 00:00:00';
    final String endDate =
        '${endOfMonthDate.year}-${endOfMonthDate.month.toString().padLeft(2, '0')}-${endOfMonthDate.day.toString().padLeft(2, '0')} 23:59:59';

    final headers = {
      'Authorization': accessToken,
      'Content-Type': 'application/json'
    };
    final String query =
        '{currentPerson{id full_name first_name profile_photo current_positions{title focus_products}home_lc{id name parent{id name}}}people(my:true){data{full_name referral_type created_at gender dob first_name profile_photo cvs{id url} person_profile{selected_programmes} lc_alignment{keywords} contact_detail{email phone}secure_identity_email opportunity_applications{total_count nodes{status created_at date_matched date_approved date_realized experience_end_date date_approval_broken matched_or_rejected_at updated_at rejection_reason{name} opportunity{id title programmes{short_name_display} managers{full_name profile_photo current_positions{function{name}role{name}}contact_detail{country_code phone email facebook}} host_lc{id name parent{id name}}}}}}}allOpportunityApplication(filters:{created_at:{from:"$startDate",to:"$endDate"}programmes:[8,9]person_committee:1277}per_page:8){data{status created_at opportunity{id programme{id} programmes{short_name_display} managers{full_name profile_photo current_positions{function{name}role{name}}contact_detail{country_code phone email facebook}} host_lc{name parent{name}}title}person{full_name profile_photo}}}}';
    final payload = {
      'query': query,
    };
    final response = await mainController.dioClient
        .post("/graphql", data: payload, options: Options(headers: headers));
    if (response.statusCode == 200) {
      updateFromJson(response.data['data']);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt("userID", userID);
      await _saveUserToDB();
      if (!Platform.isWindows) {
        await OneSignal.login('$userID');
      } else {
        await _initWindowsNotifications();
      }
      Get.offAllNamed('/main');
    }
  }

  Future<void> _initWindowsNotifications() async {
    Get.log("[USER L84]: userID = $userID");
    await _windowsNotificationsSubscription?.cancel();
    _windowsNotificationsSubscription = Supabase.instance.client
        .from('Notifications')
        .stream(primaryKey: ['id']).listen((event) {
      if (event.isEmpty) return;
      for (final notification in event) {
        if (notification['target_user'] == '$userID') {
          if (!notification['sent_to_user']) {
            // Send notification
            Get.log("Received a desktop notification : $event");
          }
        }
      }
    });
  }

  Future<void> _saveUserToDB() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String strCurrVersion = packageInfo.version;
    final MainController mainController = Get.find();
    await mainController.supabase.from("Users").upsert({
      'id': userID,
      'full_name': fullName,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'lc_id': lcID,
      'position': position,
      'department_id': focusProducts[0],
      'last_active': DateTime.now().toString(),
      'app_version': strCurrVersion,
    }, onConflict: 'id');
  }
}

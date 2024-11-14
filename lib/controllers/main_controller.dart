import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:thyna_core/utils/expa_user.dart';

class MainController extends GetxController {
  static const String _tag = 'MainController';
  ExpaUser user = ExpaUser();
  Dio dioClient = Dio(
    BaseOptions(baseUrl: "https://gis-api.aiesec.org"),
  );
  late final SupabaseClient supabase = Supabase.instance.client;

  final RxInt bottomNavBarIndex = 0.obs;
  final PageController mainPageController = PageController();
  final RxBool showProgressIndicator = false.obs;

  // Constants
  final Map<String, int> backgrounds = {
    "Accounting": 10224,
    "Aerospace engineering": 10225,
    "Agriculture": 10226,
    "Anthropology": 11275,
    "Archeology": 10227,
    "Architecture": 10228,
    "Arts": 10229,
    "Assurance": 11276,
    "Audit": 11277,
    "Automotive engineering": 10230,
    "Banking": 10231,
    "Bioengineering": 11278,
    "Biology": 10232,
    "Biomedical Science": 11279,
    "Business administration": 10233,
    "Chemical engineering": 10234,
    "Chemistry": 10235,
    "Civil engineering": 10236,
    "Communication & journalism": 10237,
    "Computer engineering": 10238,
    "Computer sciences": 10239,
    "Design": 11280,
    "Earth Sciences": 11281,
    "Ecology": 11282,
    "Economics": 10240,
    "Education": 10241,
    "Electrical engineering": 10242,
    "Electronics engineering": 10243,
    "Entrepreneurship": 11283,
    "Environmental engineering": 10244,
    "Finance": 10245,
    "Food Engineering": 22303,
    "Food Science": 22304,
    "Geography": 10246,
    "Graphic design": 10247,
    "Health Science": 11284,
    "History": 11285,
    "Human Resources": 11286,
    "Industrial Design": 11287,
    "Industrial engineering": 10248,
    "International relations": 10249,
    "International Trade": 11288,
    "Languages": 11289,
    "Law": 10250,
    "Linguistics": 10251,
    "Literature": 10252,
    "Logistics": 11290,
    "Marketing": 10253,
    "Material engineering": 10254,
    "Mathematics": 10255,
    "Mechanical engineering": 10256,
    "Media Arts": 11291,
    "Medicine": 10257,
    "Military sciences": 10258,
    "Music": 11292,
    "Nanotechnology": 10259,
    "Nursing": 11293,
    "Nutrition": 21248,
    "Other": 10271,
    "Petroleum Engineering": 11294,
    "Philosophy": 10260,
    "Physics": 10261,
    "Political science": 10262,
    "Psychology": 10263,
    "Public administration": 10264,
    "Public relations": 10265,
    "Religion": 10266,
    "Sales": 21677,
    "Social Work": 11295,
    "Sociology": 10267,
    "Software development and programming": 10268,
    "Sports": 11296,
    "Statistics": 11297,
    "Sustainability": 22072,
    "Systems and Computing Engineering": 11298,
    "Telecommunication Engineering": 10269,
    "Theatre": 11299,
    "Tourism & hotel management": 10270,
    "Veterinarian": 21247
  };

  @override
  void onInit() {
    dioClient.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.response != null) {
          Get.log(
              '[$_tag - Dio Interceptor]: Error from : ${error.response?.realUri.toString()}');
          Get.log(
              '[$_tag - Dio Interceptor]: Status code : ${error.response?.statusCode}');
          Get.log(
              '[$_tag - Dio Interceptor]: Error response : ${error.response?.data}');
          Get.log(
              '[$_tag - Dio Interceptor]: Error message : ${error.message}');
          // Unauthorized/Expired token
          if (error.response?.statusCode == 401) {
            Get.log(
                '[$_tag]: HTTP Request to ${error.response?.realUri.toString()} has returned 401');
            // Case of random request
            if (error.response?.realUri.authority == 'gis-api.aiesec.org' ||
                error.response?.realUri.authority ==
                    'analytics.api.aiesec.org') {
              try {
                Get.log('[$_tag]: Refreshing Token...');
                final refreshReq = await dioClient.post(
                  'https://auth.aiesec.org/oauth/token',
                  queryParameters: {
                    'grant_type': 'refresh_token',
                    'refresh_token': user.refreshToken
                  },
                  options: Options(
                    headers: {
                      'Authorization': 'Basic ${dotenv.env['REFRESH_KEY']}'
                    },
                  ),
                );
                if (refreshReq.statusCode == 200) {
                  Get.log('[$_tag]: Refresh Token request returned 200');
                  final bool isGraphQl =
                      error.response?.realUri.path == '/graphql';
                  final queryParams = error.requestOptions.queryParameters;
                  final requestHeaders = error.requestOptions.headers;
                  final requestData = error.requestOptions.data;

                  final String oldAccessToken = isGraphQl
                      ? requestHeaders['Authorization']
                      : queryParams['access_token'];

                  final String newAccessToken = refreshReq.data['access_token'];
                  final String newRefreshToken =
                      refreshReq.data['refresh_token'];

                  isGraphQl
                      ? requestHeaders['Authorization'] = newAccessToken
                      : queryParams['access_token'] = newAccessToken;
                  Get.log('[$_tag]: Re-attempting the original request...');
                  final result =
                      await dioClient.request(error.requestOptions.path,
                          options: Options(
                            method: error.requestOptions.method,
                            headers: requestHeaders,
                          ),
                          queryParameters: isGraphQl ? null : queryParams,
                          data: isGraphQl ? requestData : null);
                  if (result.statusCode == 200) {
                    Get.log(
                        '[$_tag]: Re-attempting the original request returned 200');
                    user.accessToken = newAccessToken;
                    user.refreshToken = newRefreshToken;
                    await Supabase.instance.client.from('Users').update({
                      'access_token': newAccessToken,
                      'refresh_token': newRefreshToken
                    }).eq('access_token', oldAccessToken);
                    Get.log(
                        '[$_tag]: Successfully refreshed the token and updated the database');
                    return handler.resolve(result);
                  }
                }
              } catch (e) {
                Get.log('[$_tag]: Refreshing the access token returned $e');
              }
            }
            // Unauthorized account
          } else if (error.response?.statusCode == 406) {
            await (await SharedPreferences.getInstance()).remove('userID');
            Get.offAllNamed('/auth');
            return handler.reject(error);
          }
        } else {
          Get.log('[$_tag - Dio Interceptor]: $error');
        }
        return handler.reject(error);
      },
    ));
    super.onInit();
  }

  void onNavigationDestinationTap(int index) {
    if (bottomNavBarIndex.value != index) {
      bottomNavBarIndex.value = index;
      mainPageController.animateToPage(index,
          duration: const Duration(milliseconds: 200),
          curve: Curves.fastEaseInToSlowEaseOut);
    }
  }
}

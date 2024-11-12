import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonAbout extends StatelessWidget {
  late final List _preferredProgs;
  late final DateTime _signedUpDate;
  late final String? _gender;
  late final String? _dateOfBirth;
  late final String? _faculty;
  late final String? _referral;

  final TextStyle _titleStyle = Get.theme.textTheme.bodySmall!
      .copyWith(color: Get.theme.colorScheme.onSurfaceVariant);
  final TextStyle? _labelStyle = Get.theme.textTheme.bodySmall;

  PersonAbout(
      {super.key,
      required List preferredProgs,
      required DateTime signedUpDate,
      required String? gender,
      required String? dateOfBirth,
      required String? faculty,
      required String? referral}) {
    _gender = gender;
    _dateOfBirth = dateOfBirth;
    _preferredProgs = preferredProgs;
    _signedUpDate = signedUpDate;
    _faculty = faculty;
    _referral = referral;
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Signed up on", style: _titleStyle),
              Text(
                _signedUpDate.toLocal().toString().split(" ")[0],
                style: _labelStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Gender", style: _titleStyle),
              Text(_gender == null ? "Not provided" : _gender.capitalizeFirst,
                  style: _labelStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Date Of Birth", style: _titleStyle),
              Text(_dateOfBirth ?? "Not provided", style: _labelStyle),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Faculty", style: _titleStyle),
              Text(
                _faculty ?? "Not provided",
                style: _labelStyle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Interested in", style: _titleStyle),
              if (_preferredProgs.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    _preferredProgs.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(
                          left: _preferredProgs.length == 1 ? 0.0 : 6.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _preferredProgs[index] == 8
                              ? const Color(0xFF0CB9C1)
                              : _preferredProgs[index] == 9
                                  ? const Color(0xFFF48924)
                                  : const Color(0xFFF85A40),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6.0, vertical: 2.0),
                          child: Text(
                            _preferredProgs[index] == 8
                                ? "GTa"
                                : _preferredProgs[index] == 9
                                    ? "GTe"
                                    : "GV",
                            style: Get.theme.textTheme.bodySmall!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                Text("Not provided", style: Get.textTheme.bodySmall),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Referral", style: _titleStyle),
              Text(
                _referral ?? "Not provided",
                style: _labelStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:thyna_core/widgets/cache_image.dart';
import 'package:thyna_core/widgets/toast_card.dart';
import 'package:url_launcher/url_launcher.dart';

class OpportunityManagersDialog extends StatelessWidget {
  final List managers;
  const OpportunityManagersDialog({super.key, required this.managers});

  ListTile _generateManagerTile(int index) {
    final String managerFullName =
        '${managers[index]['full_name']}'.capitalizeAllWordsFirstLetter();
    final String managerPosition = _getManagerPosition(index);

    final String managerPicture = managers[index]['profile_photo'];

    final String? managerPhone = managers[index]['contact_detail']['phone'];

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      title: SelectableText(
        managerFullName,
      ),
      subtitle: Text(
        managerPosition,
        style: Get.textTheme.bodySmall!.copyWith(
          color: Colors.black54,
          fontSize: 10,
        ),
      ),
      leading: CacheImage(imageURL: managerPicture),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: managerPhone != null
                ? '${managers[index]['contact_detail']['country_code'] ?? ''} $managerPhone'
                : 'Phone not provided',
            icon: Icon(
              managerPhone != null
                  ? Icons.send_rounded
                  : Icons.cancel_schedule_send_rounded,
              color:
                  managerPhone != null ? Get.theme.colorScheme.primary : null,
            ),
            onPressed: managerPhone != null
                ? () => _onManagerSendClick(managers[index]['contact_detail'])
                : null,
          ),
        ],
      ),
    );
  }

  String _getManagerPosition(int index) {
    if (managers[index]['current_positions'].isEmpty) {
      return 'Position not provided';
    } else {
      return '${managers[index]['current_positions'][0]['role']['name']} ${'${managers[index]['current_positions'][0]['function']['name']}'.split('-')[0]}';
    }
  }

  Future<void> _onManagerSendClick(Map contactInfo) async {
    final String? countryCode = contactInfo['country_code'];
    if (countryCode == null) {
      ToastCards.warning(
          message:
              'No country code were found, copying to clipboard instead..');
      try {
        await Clipboard.setData(ClipboardData(text: contactInfo['phone']));
      } catch (e) {
        ToastCards.error(
            message:
                'Could not copy to clipboard, you can try long pressing the button to see the number');
      }
    } else {
      final String countryCode = '${contactInfo['country_code']}'.substring(1);
      countryCode.replaceAll('0', '');
      final String url = 'https://wa.me/$countryCode${contactInfo['phone']}';
      try {
        await launchUrl(Uri.parse(url));
      } catch (e) {
        ToastCards.error(
            message:
                'Could not open WhatsApp, you can try long pressing the button to see the number');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text("Managers", style: Get.textTheme.titleLarge),
            ),
            ConstrainedBox(
              constraints: BoxConstraints.loose(const Size.fromHeight(400)),
              child: Padding(
                padding: const EdgeInsets.only(right: 2.0),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                        managers.length,
                        _generateManagerTile,
                      ),
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

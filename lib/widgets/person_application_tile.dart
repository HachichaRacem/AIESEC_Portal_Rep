import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

// This thing should be refactored to accept the whole data :')

class PersonApplicationTile extends StatelessWidget {
  final String header;
  final String title;
  final String label;
  final double pictureRadius;
  final Map applicationData;
  final bool expandable;
  final bool showExtraActionsDots;
  final List<PopupMenuEntry<int>> Function(BuildContext)? popupItemsBuilder;

  final List<Widget> expandableChild;

  final Function(LongPressStartDetails, Map)? onLongPress;

  late final String status;

  late final Color _statusColor;

  late final Future<FileResponse> _pictureFuture;

  late final bool _isPictureSVG;
  late final bool _showHeader;
  late final bool _showTitle;
  late final bool _showLabel;

  PersonApplicationTile({
    super.key,
    required this.applicationData,
    this.header = '',
    this.title = '',
    this.label = '',
    this.pictureRadius = 42.0,
    this.expandable = false,
    this.showExtraActionsDots = false,
    this.popupItemsBuilder,
    this.expandableChild = const [],
    this.onLongPress,
  }) {
    status = applicationData['status'];
    final String programmeShortNameDisplay =
        applicationData['opportunity']['programmes'][0]['short_name_display'];
    final String pictureURL =
        'https://aiesec-logos.s3.eu-west-1.amazonaws.com/${programmeShortNameDisplay.toUpperCase()}%20LOGO%20COLOR.png';

    switch (status) {
      case 'open':
        _statusColor = const Color(0xFF037EF3);
        break;
      case 'accepted':
        _statusColor = const Color(0xFF00c16e);
        break;
      case 'approved':
        _statusColor = const Color(0xFFffc845);
        break;
      case 'rejected':
        _statusColor = const Color(0xFFF85A40);
        break;
      case 'completed':
        _statusColor = const Color(0xFF7552CC);
        break;
      case 'approval_broken':
        _statusColor = const Color(0xFFF48924);
        break;
      default:
        _statusColor = const Color(0xFF52565E);
    }
    _pictureFuture = DefaultCacheManager().getImageFile(pictureURL).single;
    _isPictureSVG = pictureURL.contains('.svg');

    _showHeader = header.isNotEmpty;
    _showTitle = title.isNotEmpty;
    _showLabel = label.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onLongPressStart: onLongPress != null
                ? (details) => onLongPress!(details, applicationData)
                : null,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.only(left: 16.0),
              showTrailingIcon: expandable,
              enabled: expandable,
              shape: const ContinuousRectangleBorder(side: BorderSide.none),
              dense: true,
              controlAffinity:
                  expandable ? ListTileControlAffinity.leading : null,
              title: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: pictureRadius,
                    width: pictureRadius,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: FutureBuilder<FileResponse>(
                        future: _pictureFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final FileInfo fileInfo =
                                snapshot.requireData as FileInfo;
                            if (!_isPictureSVG) {
                              return Image.file(fileInfo.file);
                            } else {
                              return SvgPicture.file(fileInfo.file);
                            }
                          } else {
                            return Shimmer.fromColors(
                              baseColor: const Color(0xFFEBEBF4),
                              highlightColor: Get.theme.colorScheme.surface,
                              child: const ColoredBox(color: Colors.red),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_showHeader)
                                Flexible(
                                  child: Text(header,
                                      style: Get.theme.textTheme.labelMedium,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              if (_showTitle)
                                Text(
                                  title,
                                  overflow: TextOverflow.ellipsis,
                                  style: Get.theme.textTheme.labelSmall!
                                      .copyWith(
                                          color: Colors.grey[600], fontSize: 9),
                                ),
                              if (_showLabel)
                                Text(
                                  label,
                                  overflow: TextOverflow.ellipsis,
                                  style: Get.theme.textTheme.labelSmall!
                                      .copyWith(
                                          color: Colors.grey[600], fontSize: 8),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 12.0, right: 6.0),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: _statusColor.withAlpha(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 3.0, horizontal: 6.0),
                              child: Text(
                                status.contains('_')
                                    ? status.replaceAll('_', ' ')
                                    : status,
                                style: Get.theme.textTheme.labelSmall!
                                    .copyWith(color: _statusColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              childrenPadding: const EdgeInsets.all(12.0),
              children: expandableChild,
            ),
          ),
        ),
        if (showExtraActionsDots)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: SizedBox(
              height: 20,
              width: 20,
              child: PopupMenuButton(
                menuPadding: const EdgeInsets.symmetric(vertical: 4.0),
                iconSize: 20,
                position: PopupMenuPosition.under,
                padding: EdgeInsets.zero,
                itemBuilder: popupItemsBuilder ?? (context) => [],
              ),
            ),
          )
      ],
    );
  }
}

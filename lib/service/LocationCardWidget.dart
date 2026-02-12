import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:snap_journey/model/TagStyle.dart';
import 'package:auto_size_text/auto_size_text.dart';

class LocationCardWidget extends StatelessWidget {
  final String locationText;
  final TagStyle style;
  final String? weatherInfo;
  final String? coordinates;
  final DateTime? timestamp;

  const LocationCardWidget({
    super.key,
    required this.locationText,
    required this.style,
    this.weatherInfo,
    this.coordinates,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return _buildCard();
  }

  Widget _buildCard() {
    Widget cardContent = _buildCardContent();

    if (style.styleType == TagStyleType.glassy && style.blurRadius != null) {
      cardContent = ClipRRect(
        borderRadius: BorderRadius.circular(style.borderRadius.toDouble()),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: style.blurRadius!,
            sigmaY: style.blurRadius!,
          ),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }

  Widget _buildCardContent() {
    return Card(
      elevation: style.elevation,
      color: _getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: style.borderRadius == 0
            ? BorderRadius.zero
            : BorderRadius.circular(style.borderRadius.toDouble()),
      ),
      child: Container(
        width: double.infinity,
        decoration: _getContainerDecoration(),
        padding: EdgeInsets.symmetric(
          horizontal: (style.paddingHorizontal * 2.8).w,
          vertical: (style.paddingVertical * 2.8).h,
        ),
        child: _buildLayout(),
      ),
    );
  }

  Color _getCardColor() {
    if (style.layoutType == TagLayoutType.lineFade) {
      return Colors.transparent;
    }
    if (style.styleType == TagStyleType.transparent ||
        style.styleType == TagStyleType.glassy) {
      return Colors.white.withOpacity(style.opacity * 0.5);
    }
    return Colors.white.withOpacity(style.opacity);
  }

  BoxDecoration? _getContainerDecoration() {
    if (style.hasGradient) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(style.borderRadius.toDouble()),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(style.opacity),
            Colors.white.withOpacity(style.opacity * 0.7),
          ],
        ),
      );
    }

    if (style.overlayColor != null) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(style.borderRadius.toDouble()),
        color: _parseColor(style.overlayColor!),
      );
    }

    return null;
  }

  Color _parseColor(String colorString) {
    if (colorString.startsWith('rgba')) {
      final regex = RegExp(r'rgba\((\d+),\s*(\d+),\s*(\d+),\s*([0-9.]+)\)');
      final match = regex.firstMatch(colorString);
      if (match != null) {
        final r = int.parse(match.group(1)!);
        final g = int.parse(match.group(2)!);
        final b = int.parse(match.group(3)!);
        final a = double.parse(match.group(4)!);
        return Color.fromRGBO(r, g, b, a);
      }
    }
    return Colors.white.withOpacity(0.8);
  }

  Widget _buildLayout() {
    switch (style.layoutType) {
      case TagLayoutType.minimal:
        return _buildMinimalLayout();
      case TagLayoutType.compact:
        return _buildCompactLayout();
      case TagLayoutType.detailed:
        return _buildDetailedLayout();
      case TagLayoutType.weather:
        return _buildWeatherLayout();
      case TagLayoutType.coordinates:
        return _buildCoordinatesLayout();
      case TagLayoutType.lineFade:
        return _buildLineFadeLayout();
      case TagLayoutType.timeFocused:
        return _buildTimeFocusedLayout();
      case TagLayoutType.dateFocused:
        return _buildDateFocusedLayout();
      case TagLayoutType.standard:
      default:
        return _buildStandardLayout();
    }
  }

  Widget _buildTimeFocusedLayout() {
    return Center(
      child: AutoSizeText(
        _formatTime(timestamp ?? DateTime.now()),
        style: TextStyle(
          fontSize: (style.titleFontSize * 2.8 * 2).sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          fontFamily: style.fontFamily,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDateFocusedLayout() {
    return Center(
      child: AutoSizeText(
        _formatDate(timestamp ?? DateTime.now()),
        style: TextStyle(
          fontSize: (style.titleFontSize * 2.8 * 1.5).sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: style.fontFamily,
          height: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLineFadeLayout() {
    final parts = locationText.split('\n')[0].split(',');
    final name = parts.isNotEmpty ? parts[0].trim() : '';
    final city = parts.length > 1 ? parts[1].trim() : '';

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: 18.h, // 6 * 2.8
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 72.w), // 24 * 2.8
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  name,
                  style: TextStyle(
                    fontSize: (style.titleFontSize * 2.8).sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    fontFamily: style.fontFamily,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (city.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  AutoSizeText(
                    city,
                    style: TextStyle(
                      fontSize: (style.subtitleFontSize * 2.8).sp,
                      color: Colors.black54,
                      fontFamily: style.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Container(
              height: 18.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style.showDateTime && timestamp != null) ...[
          AutoSizeText(
            _formatDateTime(timestamp!),
            style: TextStyle(
              fontSize: (style.subtitleFontSize * 2.8).sp,
              color: Colors.black87,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 24.h),
        ],
        Flexible(
          child: AutoSizeText(
            locationText,
            style: TextStyle(
              fontSize: (style.titleFontSize * 2.8).sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: style.fontFamily,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style.showIcon)
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.red,
                size: (style.iconSize * 2.8).r,
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: AutoSizeText(
                  locationText,
                  style: TextStyle(
                    fontSize: (style.titleFontSize * 2.8).sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: style.fontFamily,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        if (style.showDateTime && timestamp != null) ...[
          SizedBox(height: 24.h),
          AutoSizeText(
            _formatDateTime(timestamp!),
            style: TextStyle(
              fontSize: (style.subtitleFontSize * 2.8).sp,
              color: Colors.black54,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (style.showCoordinates && coordinates != null) ...[
          SizedBox(height: 18.h),
          AutoSizeText(
            coordinates!,
            style: TextStyle(
              fontSize: (style.subtitleFontSize * 2.8).sp,
              color: Colors.black54,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildStandardLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style.showIcon)
          Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: (style.iconSize * 2.8).r,
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: AutoSizeText(
                    _getLocationName(locationText),
                    style: TextStyle(
                      fontSize: (style.titleFontSize * 2.8).sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: style.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (style.showWeather && weatherInfo != null)
                  _buildWeatherWidget(),
              ],
            ),
          ),

        Flexible(
          child: AutoSizeText(
            locationText,
            style: TextStyle(
              fontSize: (style.fontSize * 2.8).sp,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              fontFamily: style.fontFamily,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (style.showDateTime && timestamp != null) ...[
          SizedBox(height: 24.h),
          AutoSizeText(
            _formatDateTime(timestamp!),
            style: TextStyle(
              fontSize: (style.subtitleFontSize * 2.8).sp,
              color: Colors.black54,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        if (style.showCoordinates && coordinates != null) ...[
          SizedBox(height: 18.h),
          AutoSizeText(
            coordinates!,
            style: TextStyle(
              fontSize: (style.subtitleFontSize * 2.8).sp,
              color: Colors.black54,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (style.showIcon) ...[
              Icon(
                Icons.location_on,
                color: Colors.red,
                size: (style.iconSize * 2.8).r,
              ),
              SizedBox(width: 24.w),
            ],
            Expanded(
              child: AutoSizeText(
                _getLocationName(locationText),
                style: TextStyle(
                  fontSize: (style.titleFontSize * 2.8).sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: style.fontFamily,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (style.showWeather && weatherInfo != null) _buildWeatherWidget(),
          ],
        ),

        SizedBox(height: 24.h),

        Flexible(
          child: AutoSizeText(
            locationText,
            style: TextStyle(
              fontSize: (style.fontSize * 2.8).sp,
              color: Colors.black87,
              fontWeight: FontWeight.w400,
              fontFamily: style.fontFamily,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (style.showDateTime && timestamp != null) ...[
          SizedBox(height: 24.h),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: ((style.iconSize - 2) * 2.8).r,
                color: Colors.black54,
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: AutoSizeText(
                  _formatDateTime(timestamp!),
                  style: TextStyle(
                    fontSize: (style.subtitleFontSize * 2.8).sp,
                    color: Colors.black54,
                    fontFamily: style.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],

        if (style.showCoordinates && coordinates != null) ...[
          SizedBox(height: 18.h),
          Row(
            children: [
              Icon(
                Icons.my_location,
                size: ((style.iconSize - 2) * 2.8).r,
                color: Colors.black54,
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: AutoSizeText(
                  coordinates!,
                  style: TextStyle(
                    fontSize: (style.subtitleFontSize * 2.8).sp,
                    color: Colors.black54,
                    fontFamily: style.fontFamily,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildWeatherLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (style.showWeather && weatherInfo != null) ...[
              _buildWeatherWidget(),
              SizedBox(width: 36.w),
            ],
            if (style.showIcon) ...[
              Icon(
                Icons.location_on,
                color: Colors.red,
                size: (style.iconSize * 2.8).r,
              ),
              SizedBox(width: 24.w),
            ],
            Expanded(
              child: AutoSizeText(
                _getLocationName(locationText),
                style: TextStyle(
                  fontSize: (style.titleFontSize * 2.8).sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: style.fontFamily,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        if (style.showDateTime && timestamp != null)
          AutoSizeText(
            _formatDateTime(timestamp!),
            style: TextStyle(
              fontSize: (style.fontSize * 2.8).sp,
              color: Colors.black87,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

        if (style.showCoordinates && coordinates != null) ...[
          SizedBox(height: 18.h),
          AutoSizeText(
            coordinates!,
            style: TextStyle(
              fontSize: (style.subtitleFontSize * 2.8).sp,
              color: Colors.black54,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildCoordinatesLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (style.showIcon)
          Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Row(
              children: [
                Icon(
                  Icons.my_location,
                  color: Colors.blue,
                  size: (style.iconSize * 2.8).r,
                ),
                SizedBox(width: 24.w),
                Expanded(
                  child: AutoSizeText(
                    'GPS Coordinates',
                    style: TextStyle(
                      fontSize: (style.titleFontSize * 2.8).sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      fontFamily: style.fontFamily,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

        Flexible(
          child: AutoSizeText(
            locationText,
            style: TextStyle(
              fontSize: (style.fontSize * 2.8).sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontFamily: style.fontFamily,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        if (style.showCoordinates && coordinates != null) ...[
          SizedBox(height: 24.h),
          AutoSizeText(
            coordinates!,
            style: TextStyle(
              fontSize: (style.titleFontSize * 2.8).sp,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        if (style.showDateTime && timestamp != null) ...[
          SizedBox(height: 18.h),
          AutoSizeText(
            _formatDateTime(timestamp!),
            style: TextStyle(
              fontSize: (style.subtitleFontSize * 2.8).sp,
              color: Colors.black54,
              fontFamily: style.fontFamily,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildWeatherWidget() {
    if (weatherInfo == null) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wb_sunny, color: Colors.orange, size: 48.w),

        SizedBox(width: 18.w),
        AutoSizeText(
          weatherInfo!,
          style: TextStyle(
            fontSize: (style.subtitleFontSize * 2.8).sp,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontFamily: style.fontFamily,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $period';
  }

  String _getLocationName(String fullLocation) {
    final parts = fullLocation.split(',');
    return parts.first.trim();
  }
}

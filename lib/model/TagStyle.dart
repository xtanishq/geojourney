enum TagLayoutType {
  standard,
  compact,
  detailed,
  minimal,
  weather,
  coordinates,
  lineFade,
  timeFocused,
  dateFocused,
}

enum TagStyleType {
  classic,
  modern,
  glassy,
  material,
  rounded,
  sharp,
  overlay,
  transparent,
}

enum TagCategory { location, filters }

class TagStyle {
  final int id;
  final String name;
  final String description;
  final TagLayoutType layoutType;
  final TagStyleType styleType;

  // Visual properties
  final double borderRadius;
  final double elevation;
  final double opacity;
  final double paddingHorizontal;
  final double paddingVertical;
  final double fontSize;
  final double iconSize;

  // Layout properties
  final bool showIcon;
  final bool showWeather;
  final bool showCoordinates;
  final bool showDateTime;
  final bool showLocationPin;
  final bool isPremium;

  // Style properties
  final String? backgroundImage;
  final String? overlayColor;
  final double? blurRadius;
  final bool hasGradient;

  // Typography
  final String fontFamily;
  final double titleFontSize;
  final double subtitleFontSize;

  final TagCategory category;

  final double? tagWidth;
  final double? tagHeight;

  TagStyle({
    required this.id,
    required this.name,
    required this.description,
    required this.layoutType,
    required this.styleType,
    required this.borderRadius,
    required this.elevation,
    required this.opacity,
    required this.paddingHorizontal,
    required this.paddingVertical,
    required this.fontSize,
    required this.iconSize,
    this.showIcon = true,
    this.showWeather = false,
    this.showCoordinates = false,
    this.showDateTime = true,
    this.showLocationPin = true,
    this.isPremium = false,
    this.backgroundImage,
    this.overlayColor,
    this.blurRadius,
    this.hasGradient = false,
    this.fontFamily = 'Medium',
    required this.titleFontSize,
    required this.subtitleFontSize,
    required this.category,
    this.tagWidth,
    this.tagHeight,
  });

  factory TagStyle.fromJson(Map<String, dynamic> json) {
    return TagStyle(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      layoutType: TagLayoutType.values.firstWhere(
        (e) => e.toString().split('.').last == json['layoutType'],
        orElse: () => TagLayoutType.standard,
      ),
      styleType: TagStyleType.values.firstWhere(
        (e) => e.toString().split('.').last == json['styleType'],
        orElse: () => TagStyleType.classic,
      ),
      borderRadius: json['borderRadius']?.toDouble() ?? 8.0,
      elevation: json['elevation']?.toDouble() ?? 4.0,
      opacity: json['opacity']?.toDouble() ?? 0.8,
      paddingHorizontal: json['paddingHorizontal']?.toDouble() ?? 12.0,
      paddingVertical: json['paddingVertical']?.toDouble() ?? 12.0,
      fontSize: json['fontSize']?.toDouble() ?? 11.0,
      iconSize: json['iconSize']?.toDouble() ?? 16.0,
      showIcon: json['showIcon'] ?? true,
      showWeather: json['showWeather'] ?? false,
      showCoordinates: json['showCoordinates'] ?? false,
      showDateTime: json['showDateTime'] ?? true,
      showLocationPin: json['showLocationPin'] ?? true,
      isPremium: json['isPremium'] ?? false,
      backgroundImage: json['backgroundImage'],
      overlayColor: json['overlayColor'],
      blurRadius: json['blurRadius']?.toDouble(),
      hasGradient: json['hasGradient'] ?? false,
      fontFamily: json['fontFamily'] ?? 'Roboto',
      titleFontSize: json['titleFontSize']?.toDouble() ?? 14.0,
      subtitleFontSize: json['subtitleFontSize']?.toDouble() ?? 11.0,
      category: TagCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => TagCategory.location,
      ),
      tagWidth: json['tagWidth']?.toDouble(),
      tagHeight: json['tagHeight']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'layoutType': layoutType.toString().split('.').last,
      'styleType': styleType.toString().split('.').last,
      'borderRadius': borderRadius,
      'elevation': elevation,
      'opacity': opacity,
      'paddingHorizontal': paddingHorizontal,
      'paddingVertical': paddingVertical,
      'fontSize': fontSize,
      'iconSize': iconSize,
      'showIcon': showIcon,
      'showWeather': showWeather,
      'showCoordinates': showCoordinates,
      'showDateTime': showDateTime,
      'showLocationPin': showLocationPin,
      'isPremium': isPremium,
      'backgroundImage': backgroundImage,
      'overlayColor': overlayColor,
      'blurRadius': blurRadius,
      'hasGradient': hasGradient,
      'fontFamily': fontFamily,
      'titleFontSize': titleFontSize,
      'subtitleFontSize': subtitleFontSize,
      'category': category.toString().split('.').last,
      'tagWidth': tagWidth,
      'tagHeight': tagHeight,
    };
  }
}

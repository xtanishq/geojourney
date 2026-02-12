import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

// --- Updated App Branding ---
const appName = "GeoJourney: AI GPS Journal"; // Updated Name for SEO
const appbackgroundColor = Color(0xff); // Warm Off-White (Vibey & Clean)
const appColor = Color(0xff001F54); // Terracotta (Primary Action Color)
const gradient = Color(0xffF5EFE6); // Soft Sand (For depth)

// --- Premium Card & AutoSizeText Colors ---
const Color cardDarkColor = Color(0xFFFFFFFF); // Clean white cards
const textColor = Color(0xFF2D2D2D); // Charcoal (Better readability)
const btnbg = Color(0xffE2725B); // Primary Button
const textcolor = Color(0xff2D2D2D);
const cardtextcolor = Color(0xff6D6D6D); // Muted secondary text
// const primarycolor = Color(0xffF8FAFC);
const primarycolor = Color(0xff001F54);
const primarycolor2 = Color(0xff007AFF); // Soft Amber (For Sunset Gradient)
const pressColor = Color(0xFF1E3A8A);     // Pressed (Royal Blue)
const unPressColor = Color(0xFF003B8E);  // Unpressed (Bright Navy)

const dialogBgColor = Color(0xFF0B1220); // Almost black-blue
const dialogButtonTextColor = Colors.white;

const backgroundColor = Color(0xFFF8FAFC); // Clean light background

const appFontFamily = 'Medium';
const rateID = '6755062953';
const privacyPolicyUrl = 'https://jagrutiraval.blogspot.com/2025/10/privacy-policy.html';
const termsOfUseUrl = 'https://jagrutiraval.blogspot.com/2025/10/terms-of-use.html';

String uuid1 = 'GeoJourney: AI GPS Diary';

const fontFamilyRegular = 'Regular';
const fontFamilySemiBold = 'SemiBold';
const fontFamilyMedium = 'Medium';
const fontFamilyBold = 'Bold';


bool isconnected = false;
String devicename = '';
// Device? device;
bool? istaped;
String? languagecode;
String? countrycode;
bool? isdone;
String? languagename;



// --- Elite Visuals: Button & Indicators ---
// const unPressIndicatorColor = Color(0xffE2725B);
// LinearGradient unPressLinearGradiant = LinearGradient(
//   colors: [primarycolor, primarycolor2], // Sunset Gradient
//   begin: Alignment.topLeft,
//   end: Alignment.bottomRight,
// );
const unPressLinearGradiant = LinearGradient(
  colors: [
    Color(0xFF001F54), // Navy base
    Color(0xFF003B8E), // Bright navy
    Color(0xFF0EA5E9), // Cyan highlight
  ],
);


// High-end glassmorphism effect for pressed states
// LinearGradient pressLinearGradiant = LinearGradient(
//   colors: [primarycolor.withOpacity(0.7), primarycolor2.withOpacity(0.7)],
// );
const pressLinearGradiant = LinearGradient(
  colors: [
    Color(0xFF0A2A66), // Deep blue
    Color(0xFF1E3A8A), // Royal blue
    Color(0xFF38BDF8), // Soft cyan accent
  ],
);


const iosIndicator = Center(
  child: CupertinoActivityIndicator(radius: 15, color: appColor),
);

// Toast matches the new brand color
appToast(String msg) => Fluttertoast.showToast(
  msg: msg,
  backgroundColor: appColor,
  textColor: Colors.white,
);

void showToast({required String msg}) {
  Fluttertoast.showToast(
    msg: msg,
    backgroundColor: textColor,
    textColor: Colors.white,
  );
}
abstract class AppFontWeight {
  static const light = FontWeight.w300;
  static const medium = FontWeight.w500;
  static const bold = FontWeight.w700;
}
abstract class AppTextColor {
  static const primary = Color(0xFF001F54);   // Navy
  static const secondary = Color(0xFF64748B); // Slate
  static const muted = Color(0xFF94A3B8);
  static const inverse = Colors.white;
  static const error = Color(0xFFDC2626);
}
abstract class AppTextStyle {
  static TextStyle _style({
    required FontWeight weight,
    double size = 14,
    Color? color,
    double height = 1.35,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontWeight: weight,
      fontSize: size,
      color: color ?? AppTextColor.primary,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // LIGHT
  static TextStyle light({
    double size = 14,
    Color? color,
  }) =>
      _style(
        weight: AppFontWeight.light,
        size: size,
        color: color,
      );

  // MEDIUM
  static TextStyle medium({
    double size = 14,
    Color? color,
  }) =>
      _style(
        weight: AppFontWeight.medium,
        size: size,
        color: color,
      );

  // BOLD
  static TextStyle bold({
    double size = 14,
    Color? color,
  }) =>
      _style(
        weight: AppFontWeight.bold,
        size: size,
        color: color,
      );
}


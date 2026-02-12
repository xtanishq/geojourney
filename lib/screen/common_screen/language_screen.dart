import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';
import 'onboarding_screen.dart';
import 'package:auto_size_text/auto_size_text.dart';

class LanguageScreen extends StatefulWidget {
  final String isFrom;
  LanguageScreen({super.key, required this.isFrom});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int? selectedIndex;
  // Custom Cool Colors
  final Color primaryBlue = const Color(0xFF001F54);
  final Color backgroundGrey = const Color(0xFFF8FAFC);
  final Color textDark = const Color(0xFF1E293B);
  // int? selectedddindex;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  _loadCurrentLanguage() {
    // Aapke existing logic ke hisaab se initial index set karein
    for (int i = 0; i < list.length; i++) {
      if (list[i]['languagecode'] == languagecode) {
        setState(() {
          selectedIndex = i;
        });
      }
    }
  }
  setlanguage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('languagecode', list[selectedIndex!]['languagecode']);
    pref.setString('countrycode', list[selectedIndex!]['countrycode']);
    pref.setString('languagename', list[selectedIndex!]['name']);
    pref.setBool('istaped', true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGrey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundGrey,
        leading: widget.isFrom == 'setting'
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: textDark, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: AutoSizeText(
              "Choose Language".tr,
          style: TextStyle(
            color: textDark,
            fontSize: 60.sp,
            fontFamily: "semibold"
          ),
        ),
        actions: [
          if (selectedIndex != null)
            TextButton(
              onPressed: () => _handleDone(),
              child: AutoSizeText(
                "Done".tr,
                style: TextStyle(
                  color: primaryBlue,
                  fontFamily: "medium",
                  fontSize: 55.sp,
                ),
              ),
            ),
          SizedBox(width: 10.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 30.w),
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 100),
                        margin: EdgeInsets.symmetric(vertical: 8.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: 35.w,
                          vertical: 35.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(29.r),
                          border: Border.all(
                            color: isSelected ? primaryBlue : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? primaryBlue.withOpacity(0.1)
                                  : Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Language Flag/Icon
                            Container(
                              height: 125.h,
                              width: 125.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: AssetImage(
                                    list[index]['languageselect'],
                                  ), // Using your existing asset
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 15.w),
                            // Language Name
                            Expanded(
                              child: AutoSizeText(
                                list[index]['name'],
                                style: TextStyle(
                                  color: textDark,
                                  fontSize: 50.sp,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            // Custom Radio Circle
                            Container(
                              height: 42.h,
                              width: 42.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? primaryBlue
                                      : Colors.grey.shade300,
                                  width: isSelected ? 7 : 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleDone() async {
    // Aapka existing save aur navigation logic yahan aayega
    loadlanguage(selectedIndex!);
    setlanguage();
    if (widget.isFrom == 'splash') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const OnBoardingScreen(fromHome: false),
        ),
      );
    } else {
      Navigator.of(context).pop(true);
    }
  }

  loadlanguage(int index) {
    print('hiiiiiii');
    if (istaped == true) {
      print("_)(*&");
      print(languagecode);
      print(countrycode);
      languagecode = list[index]['languagecode'];
      countrycode = list[index]['countrycode'];
      var locale = Locale(languagecode!, countrycode!);
      Get.updateLocale(locale);
    } else {
      print("789456");
      print('${list[index]['languagecode']}');
      print('${list[index]['countrycode']}');
      var locale = Locale(
        '${list[index]['languagecode']}',
        '${list[index]['countrycode']}',
      );
      Get.updateLocale(locale);
    }
  }


  checkforselect(int index) {
    print("yess");
    for (var i = 0; i < list.length; i++) {
      if (list[i]['notselect'] == false) {
        setState(() {
          list[i]['notselect'] = !list[i]['notselect'];
          //   list[index]['notselect'] =! list[index]['notselect'];
        });
        break;
      }
    }
    setState(() {
      print('false');
      list[index]['notselect'] = !list[index]['notselect'];
      print(
        "===============>>>>>>${list[index]['notselect']} ${list[index]['name']}",
      );
    });
  }

  List<Map<String, dynamic>> list = [
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/ENGLISH.png',
      'name': 'English (Default)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/english_selected language.png',
      'languageunselect':
          'assets/language_screen/english_selected language-1.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'en',
      'countrycode': 'US',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/HINDI.png',
      'name': 'Hindi (हिंदी)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/hindi_select.png',
      'languageunselect': 'assets/language_screen/hindi_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'hi',
      'countrycode': 'IN',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/Chinese.png',
      'name': 'Chinese (中国人)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/chinese_select.png',
      'languageunselect': 'assets/language_screen/chinese_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'zh',
      'countrycode': 'CN',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/Dutch.png',
      'name': 'Dutch (Nederlands)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/dutch_select.png',
      'languageunselect': 'assets/language_screen/dutch_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'nl',
      'countrycode': 'BE',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/FRENCH.png',
      'name': 'French (française)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/french_select.png',
      'languageunselect': 'assets/language_screen/french_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'fr',
      'countrycode': 'CA',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/GERMAN.png',
      'name': 'German (Deutsch)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/german_select.png',
      'languageunselect': 'assets/language_screen/german_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'de',
      'countrycode': 'CH',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/INDONESIAN.png',
      'name': 'Indonesia (bahasa Indonesia)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/indonesian_select.png',
      'languageunselect': 'assets/language_screen/indonesian_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'id',
      'countrycode': 'ID',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/Italian.png',
      'name': 'Italian (Italiana)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/Italian_select.png',
      'languageunselect': 'assets/language_screen/Italian_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'it',
      'countrycode': 'IT',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/JAPANESE.png',
      'name': 'Japanese (日本)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/japanese_select.png',
      'languageunselect': 'assets/language_screen/japanese_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'ja',
      'countrycode': 'JP',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/KOREAN.png',
      'name': 'Korean (한국인)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/korean_select.png',
      'languageunselect': 'assets/language_screen/korean_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'ko',
      'countrycode': 'KR',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/Malaysian.png',
      'name': 'Malaysian (rakyat Malaysia)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/malay_select.png',
      'languageunselect': 'assets/language_screen/malay_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'ms',
      'countrycode': 'IN',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/PORTUGUESE.png',
      'name': 'Portuguese (Português)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/portuguese_select.png',
      'languageunselect': 'assets/language_screen/portuguese_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'pt',
      'countrycode': 'PT',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/PUNJABI.png',
      'name': 'Punjabi (ਪੰਜਾਬੀ)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/punjabi_select.png',
      'languageunselect': 'assets/language_screen/punjabi_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'pa',
      'countrycode': 'IN',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/RUSSIAN.png',
      'name': 'Russian (русский)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/russian_select.png',
      'languageunselect': 'assets/language_screen/russian_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'ru',
      'countrycode': 'RU',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/Spanish.png',
      'name': 'Spanish (española)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/spanish_select.png',
      'languageunselect': 'assets/language_screen/spanish_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'es',
      'countrycode': 'ES',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/Thai.png',
      'name': 'Thai (แบบไทย)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/thai_select.png',
      'languageunselect': 'assets/language_screen/thai_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'th',
      'countrycode': 'TH',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/Turkish.png',
      'name': 'turkish (Türkçe)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/turkish_select.png',
      'languageunselect': 'assets/language_screen/turkish_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'tr',
      'countrycode': 'TR',
    },
    {
      //'bg': 'lib/assets/languagescreenasset/language_list_bg.png',
      'path': 'assets/language/Vietnamese.png',
      'name': 'Vietnamese (Tiếng Việt)',
      'nonselect': 'assets/language_screen/unselected_language_bg.png',
      'selected': 'assets/language_screen/selected_language_bg.png',
      'languageselect': 'assets/language_screen/vietnamese_select.png',
      'languageunselect': 'assets/language_screen/vietnamese_unselect.png',
      'iconselect': 'assets/language_screen/select.png',
      'iconunselect': 'assets/language_screen/unselect.png',
      'notselect': true,
      'languagecode': 'vi',
      'countrycode': 'VN',
    },
  ];
}

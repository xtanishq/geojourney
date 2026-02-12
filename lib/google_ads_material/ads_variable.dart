import 'package:get/get_rx/src/rx_types/rx_types.dart';

class AdsVariable {
  static RxBool isPurchase = false.obs;
  static RxInt credits = 0.obs;

  static String googleApiKey = "";

  static List<Map<String, String>> morningPrompts = [];
  static List<Map<String, String>> middayPrompts = [];
  static List<Map<String, String>> eveningPrompts = [];
  static Map<String, String> memoryTemplate = {};


  static int cameraFreeTrial = 20;
  static int notesFreeTrial = 20;
  static int tagFreeTrial = 20;

  static int weekCredit = 30;
  static int yearCredit = 100;

  static String isPremiumClose = '1';
  static String show_week_price = '1';

  static String showSubmitRating = "1";
  static String show_close_delay = '0';
  static String show_rate_intro = '0';
  static String without_subscription = '0';

  static String fullscreen_on_in_splash_screen = '1';

  static int inAppFlag = 0;
  static String in_app_screen_ad_continue_ads_online = '1';

  static int mapFlag = 0;
  static String map_screen_ad_continue_ads_online = '1';

  static int timelineFlag = 0;
  static String timeline_config_screen_ad_continue_ads_online = '1';

  static int memoriesFlag = 0;
  static String memories_screen_ad_continue_ads_online = '1';

  static int editFlag = 0;
  static String edit_screen_ad_continue_ads_online = '1';

  static int tagStyleFlag = 0;
  static String tagStyle_screen_ad_continue_ads_online = '1';

  // ca-app-pub-3940256099942544/1033173712
  static String fullscreen_preload_high = '11';
  static String fullscreen_preload_normal = '11';
  static String fullscreen_splash_screen_high = '11';
  static String fullscreen_splash_screen_normal = '11';
  static String fullscreen_in_app_screen = '11';
  static String fullscreen_map_screen = '11';
  static String fullscreen_timeline_screen = '11';
  static String fullscreen_memories_screen = '11';
  static String fullscreen_edit_screen = '11';
  static String fullscreen_tagStyle_screen = '11';

  // ca-app-pub-3940256099942544/9214589741
  static String banner_memories_screen = '11';
  static String banner_img_preview_screen = '11';
  static String banner_vid_preview_screen = '11';
  static String banner_tagStyle_screen = '11';
  static String banner_map_screen = '11';

  //ca-app-pub-3940256099942544/2247696110

  static String native_intro_screen = '11';
  static String big_native_intro_screen = '11';

  static String appopen = '11';

  static String nativeBGColor = 'F0F0F0';
  static String headerTextColor = '000000';
  static String bodyTextColor = '828282';
  static String btnBgStartColor = '4381FF';
  static String btnBgEndColor = '2B67FE';
  static String btnTextColor = 'FFFFFF';
  static String btnAdBgColor = '3775FF';
  static String btnAdTextColor = 'FFFFFF';

  static String facebookId = '11';
  static String facebookToken = '11';
}

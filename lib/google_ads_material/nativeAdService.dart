import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdLoadState { loading, failed, loaded }

class NativeAdService extends GetxController {

  Rx<NativeAd?> smallNativeAd = Rx<NativeAd?>(null);
  Rx<NativeAd?> bigNativeAd = Rx<NativeAd?>(null);

  Rx<AdLoadState> smallAdLoadState = AdLoadState.failed.obs;
  Rx<AdLoadState> bigAdLoadState = AdLoadState.loading.obs;

  void loadSmallAd(String id) {
    print('=============================calling===========================');
    if (id != '11') {
      try{
        smallAdLoadState.value = AdLoadState.loading;
        smallNativeAd.value?.dispose();
        smallNativeAd.value = NativeAd(
          adUnitId: id,
          factoryId: 'small',
          listener: NativeAdListener(
            onAdLoaded: (ad) {
              print('=============================onAdLoaded===========================');
              smallAdLoadState.value = AdLoadState.loaded;
            },
            onAdFailedToLoad: (ad, error) {
              print('=============================onAdFailedToLoad===========================');
              smallAdLoadState.value = AdLoadState.failed;
              smallNativeAd.value?.dispose();
            },
          ),
          request: const AdRequest(),
        );
        smallNativeAd.value!.load();
      }catch(e){
        smallAdLoadState.value = AdLoadState.failed;
      }
    } else {
      smallAdLoadState.value = AdLoadState.failed;
    }
  }

  void loadBigAd(String id) {
    print('=============================calling===========================');
    if (id != '11') {
      try{
        bigAdLoadState.value = AdLoadState.loading;
        bigNativeAd.value?.dispose();
        bigNativeAd.value = NativeAd(
          adUnitId: id,
          factoryId: 'big',
          listener: NativeAdListener(
            onAdLoaded: (ad) {
              print('=============================onAdLoaded===========================');
              bigAdLoadState.value = AdLoadState.loaded;
            },
            onAdFailedToLoad: (ad, error) {
              print('=============================onAdFailedToLoad===========================');
              bigAdLoadState.value = AdLoadState.failed;
              bigNativeAd.value?.dispose();
            },
          ),
          request: const AdRequest(),
        );
        bigNativeAd.value!.load();
      }catch(e){
        bigAdLoadState.value = AdLoadState.failed;
      }
    } else {
      bigAdLoadState.value = AdLoadState.failed;
    }
  }

  void disposeNativeAd() {
    smallAdLoadState.value = AdLoadState.failed;
    bigAdLoadState.value = AdLoadState.failed;
    smallNativeAd.value?.dispose();
    bigNativeAd.value?.dispose();
  }
}

// class AdService {
//   static NativeAd? smallAd;
//   static NativeAd? bigAd;
//
//   static ValueNotifier<bool> smallAdLoaded = ValueNotifier(false);
//   static ValueNotifier<bool> bigAdLoaded = ValueNotifier(false);
//
//   static void loadSmallAd(String adUnitId) {
//     smallAd?.dispose();
//     smallAd = NativeAd(
//       adUnitId: adUnitId,
//       factoryId: 'small',
//       listener: NativeAdListener(
//         onAdLoaded: (_) => smallAdLoaded.value = true,
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           smallAdLoaded.value = false;
//         },
//       ),
//       request: const AdRequest(),
//     )..load();
//   }
//
//   static void loadBigAd(String adUnitId) {
//     bigAd?.dispose();
//     bigAd = NativeAd(
//       adUnitId: adUnitId,
//       factoryId: 'big',
//       listener: NativeAdListener(
//         onAdLoaded: (_) => bigAdLoaded.value = true,
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           bigAdLoaded.value = false;
//         },
//       ),
//       request: const AdRequest(),
//     )..load();
//   }
//
//   static void disposeAds() {
//     smallAd?.dispose();
//     bigAd?.dispose();
//   }
// }

// class NativeAdService {
//   static NativeAd? nativeAd;
//   static ValueNotifier<bool> loaded = ValueNotifier<bool>(false);
//   static ValueNotifier<bool> failed = ValueNotifier<bool>(false);
//
//   static Future<void> loadNativeAd(String id) {
//     print('=============================calling===========================');
//     loaded.value = false;
//     failed.value = false;
//
//     final Completer<void> completer = Completer<void>();
//
//     nativeAd = NativeAd(
//       adUnitId: id,
//       factoryId: 'small',
//       listener: NativeAdListener(onAdLoaded: (ad) {
//         print(id);
//         print(
//             '=============================onAdLoaded===========================');
//         loaded.value = true;
//         failed.value = false;
//         completer.complete();
//       }, onAdFailedToLoad: (ad, error) {
//         print(
//             '=============================onAdFailedToLoad===========================');
//         failed.value = true;
//         loaded.value = false;
//         nativeAd!.dispose();
//         completer.complete();
//       }),
//       request: const AdRequest(),
//     );
//     nativeAd!.load();
//     return completer.future;
//   }
//
//   void disposeNativeAd() {
//     nativeAd?.dispose();
//   }
// }

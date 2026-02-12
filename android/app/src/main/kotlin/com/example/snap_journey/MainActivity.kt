package com.stonekross.smarttrace

import android.graphics.Color
import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin.NativeAdFactory
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
//        GeneratedPluginRegistrant.registerWith(flutterEngine)
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "smallNativeAds", NativeAdFactorySmall(layoutInflater))
        GoogleMobileAdsPlugin.registerNativeAdFactory(flutterEngine, "fullNativeAds", NativeAdFactoryBig(layoutInflater))

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "nativeChannel").setMethodCallHandler { call, result ->
            if (call.method == "colorValue") {
                val colors = call.arguments as Map<String, String>
                AdsColorManager.setColors(colors)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "small")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "big")
    }
}

object AdsColorManager {
    var nativeAdTagTextColor: Int = Color.WHITE
    var textColorTitle: Int = Color.WHITE
    var nativeTextColorBody: Int = Color.GRAY
    var nativeButtonColorStartColor: Int = Color.BLUE
    var nativeButtonColorEndColor: Int = Color.GREEN
    var nativeButtonTextColor: Int = Color.WHITE
    var nativeAdTagBgStartColor: Int = Color.BLUE
    var nativeAdTagBgEndColor: Int = Color.GREEN
    var nativeAdBgColor: Int = Color.BLACK

    fun setColors(colors: Map<String, String>) {
        nativeAdTagTextColor = Color.parseColor(colors["Fun_headerTextColor"])
        textColorTitle = Color.parseColor(colors["Fun_headerTextColor"])
        nativeTextColorBody = Color.parseColor(colors["Fun_bodyTextColor"])
        nativeButtonColorStartColor = Color.parseColor(colors["Fun_btnBgColorStart"])
        nativeButtonColorEndColor = Color.parseColor(colors["Fun_btnBgColorEnd"])
        nativeButtonTextColor = Color.parseColor(colors["Fun_btnTextColor"])
        nativeAdTagBgStartColor = Color.parseColor(colors["Fun_btnBgColorStart"])
        nativeAdTagBgEndColor = Color.parseColor(colors["Fun_btnBgColorEnd"])
        nativeAdBgColor = Color.parseColor(colors["Fun_nativeBGColor"])
    }
}


class NativeAdFactorySmall(private val layoutInflater: LayoutInflater) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd?, customOptions: MutableMap<String, Any>?): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.small_template, null) as NativeAdView
        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.bodyView = adView.findViewById(R.id.ad_body)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        adView.iconView = adView.findViewById(R.id.ad_app_icon)
        adView.starRatingView = adView.findViewById(R.id.ad_stars)

        // Apply colors from AdsColorManager
//        (adView.headlineView as TextView).setTextColor(AdsColorManager.textColorTitle)
//        (adView.bodyView as TextView).setTextColor(AdsColorManager.nativeTextColorBody)
//        (adView.callToActionView as Button).apply {
//            setTextColor(AdsColorManager.nativeButtonTextColor)
//            setBackgroundColor(AdsColorManager.nativeButtonColorStartColor)
//        }
//        adView.setBackgroundColor(AdsColorManager.nativeAdBgColor)


        if (nativeAd?.headline != null) {
            (adView.headlineView as TextView).text = nativeAd.headline
        }
        if (nativeAd?.body != null) {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        } else {
            adView.bodyView?.visibility = View.INVISIBLE
        }
        if (nativeAd?.callToAction != null) {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        } else {
            adView.callToActionView?.visibility = View.INVISIBLE
        }
        if (nativeAd?.icon != null) {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon?.drawable)
            adView.iconView?.visibility = View.VISIBLE
        } else {
            adView.iconView?.visibility = View.GONE
        }
        if (nativeAd?.starRating != null) {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        } else {
            adView.starRatingView?.visibility = View.INVISIBLE
        }

        nativeAd?.let {
            adView.setNativeAd(it)
        }

        return adView
    }
}

class NativeAdFactoryBig(private val layoutInflater: LayoutInflater) : NativeAdFactory {
    override fun createNativeAd(nativeAd: NativeAd?, customOptions: MutableMap<String, Any>?): NativeAdView {
        val adView = layoutInflater.inflate(R.layout.big_template, null) as NativeAdView
        adView.mediaView = adView.findViewById(R.id.native_ad_media)

        adView.headlineView = adView.findViewById(R.id.ad_headline)
        adView.bodyView = adView.findViewById(R.id.ad_body)
        adView.callToActionView = adView.findViewById(R.id.ad_call_to_action)
        adView.iconView = adView.findViewById(R.id.ad_app_icon)
        adView.starRatingView = adView.findViewById(R.id.ad_stars)
        (adView.headlineView as TextView).text = nativeAd?.headline
        adView.mediaView?.mediaContent = nativeAd?.mediaContent

        if (nativeAd?.body == null) {
            adView.bodyView?.visibility = View.INVISIBLE
        } else {
            adView.bodyView?.visibility = View.VISIBLE
            (adView.bodyView as TextView).text = nativeAd.body
        }

        if (nativeAd?.callToAction == null) {
            adView.callToActionView?.visibility = View.INVISIBLE
        } else {
            adView.callToActionView?.visibility = View.VISIBLE
            (adView.callToActionView as Button).text = nativeAd.callToAction
        }

        if (nativeAd?.icon == null) {
            adView.iconView?.visibility = View.GONE
        } else {
            (adView.iconView as ImageView).setImageDrawable(nativeAd.icon!!.drawable)
            adView.iconView?.visibility = View.VISIBLE
        }

        if (nativeAd?.starRating == null) {
            adView.starRatingView?.visibility = View.INVISIBLE
        } else {
            (adView.starRatingView as RatingBar).rating = nativeAd.starRating!!.toFloat()
            adView.starRatingView?.visibility = View.VISIBLE
        }

        nativeAd?.let {
            adView.setNativeAd(it)
        }

        return adView
    }
}


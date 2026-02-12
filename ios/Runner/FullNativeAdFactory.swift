// TODO: Import google_mobile_ads
import google_mobile_ads
import CoreGraphics


// TODO: Implement ListTileNativeAdFactory
class FullNativeAdFactory : FLTNativeAdFactory {

    func imageOfStars(from starRating: NSDecimalNumber?) -> UIImage? {
        guard let rating = starRating?.doubleValue else {
            return nil
        }
        if rating >= 5 {
            return UIImage(named: "stars_5")
        } else if rating >= 4.5 {
            return UIImage(named: "stars_4_5")
        } else if rating >= 4 {
            return UIImage(named: "stars_4")
        } else if rating >= 3.5 {
            return UIImage(named: "stars_3_5")
        } else {
            return UIImage(named: "stars_3_5")
        }
    }
    
    func createNativeAd(_ nativeAd: GADNativeAd,
                        customOptions: [AnyHashable : Any]? = nil) -> GADNativeAdView? {
        let nibView = Bundle.main.loadNibNamed("FullNativeAdsView", owner: nil, options: nil)!.first
        let nativeAdView = nibView as! GADNativeAdView
        if let labelAdViewIndex = ((nibView as? UIView)?.subviews)?.firstIndex(where: {($0 as? UILabel)?.text == "Ad"}),
           let labelAd = (((nibView as? UIView)?.subviews)?[labelAdViewIndex] as? UILabel) {
            labelAd.backgroundColor = UIColor(rgb: btnAdBgColor ?? "A14AF7")
            labelAd.textColor = UIColor(rgb: btnAdTextColor ?? "FFFFFF")
        }
        
        nativeAdView.layer.cornerRadius = 10879
        nativeAdView.layer.cornerRadius = 10879
        nativeAdView.callToActionView?.layer.cornerRadius = 10
        
        nativeAdView.backgroundColor = UIColor(rgb: nativeBGColor ?? "101010")
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.headlineView as? UILabel)?.textColor = UIColor(rgb: headerTextColor ?? "FFFFFF")
        nativeAdView.headlineView?.isHidden = nativeAd.headline == nil
           
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        (nativeAdView.bodyView as? UILabel)?.textColor = UIColor(rgb: bodyTextColor ?? "828282")
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        if let callToActionBtn = nativeAdView.callToActionView as? UIButton {
                // Create gradient layer for button background
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = callToActionBtn.bounds
                gradientLayer.colors = [
                    UIColor(rgb: btnBgStartColor ?? "A14AF7").cgColor,
//                     UIColor(rgb: btnBgMidColor ?? "A9F491").cgColor,
                    UIColor(rgb: btnBgEndColor ?? "A14AF7").cgColor,
                ]
                gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
                gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
                callToActionBtn.layoutIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    gradientLayer.frame = callToActionBtn.bounds
                }
                // Insert gradient layer below existing layers (if any)
                callToActionBtn.layer.insertSublayer(gradientLayer, at: 0)
                callToActionBtn.clipsToBounds = true
            
                // Set other button properties
//                callToActionBtn.backgroundColor = UIColor(rgb: btnBgColor ?? "000000")
                callToActionBtn.setTitle(nativeAd.callToAction, for: .normal)
                callToActionBtn.setTitleColor(UIColor(rgb: btnTextColor ?? "FFFFFF"), for:.normal)
            callToActionBtn.isHidden = nativeAd.callToAction == nil
            }

        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView!.isHidden = nativeAd.icon == nil
        
        (nativeAdView.starRatingView as? UIImageView)?.image = imageOfStars(
            from: nativeAd.starRating)
        nativeAdView.starRatingView?.isHidden = nativeAd.starRating == nil
        nativeAdView.starRatingView?.layoutIfNeeded()
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
      

        nativeAdView.nativeAd = nativeAd

        return nativeAdView
    }
}

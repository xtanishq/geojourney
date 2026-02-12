import UIKit
import Flutter
import google_mobile_ads
import FirebaseCore
import FacebookCore
import UserNotifications
import GoogleMaps

 var btnBgStartColor: String!
 var btnBgMidColor: String!
 var btnBgEndColor: String!
 var headerTextColor:String!
 var bodyTextColor:String!
 var btnTextColor:String!
 var nativeBGColor:String!
 var btnAdBgColor:String!
 var btnAdTextColor:String!

@UIApplicationMain

@objc class AppDelegate: FlutterAppDelegate  {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

//         FaceBook Integration with Firebase Config
        FirebaseApp.configure()

    GMSServices.provideAPIKey("AIzaSyDgNqMX-R6aVmSXpqYXSfwlKzaneTGVCP4")

        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let batteryChannel = FlutterMethodChannel(name: "nativeChannel",
                                                  binaryMessenger: controller.binaryMessenger)


        batteryChannel.setMethodCallHandler({
            [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
            guard let self = self else { return }
            // Note: this method is invoked on the UI thread.
            guard call.method == "setToast" else {
                result(FlutterMethodNotImplemented)
                return
            }

            // Fetch colors code from firebase remote config
            let myresult = call.arguments as? [String: Any]
            let isPurchase = myresult?["isPurchase"] as? String
            let value1 = myresult?["facebookId"] as? String
            let value2 = myresult?["facebookToken"] as? String

            btnBgStartColor = myresult?["btnBgStartColor"] as? String
            btnBgMidColor = myresult?["btnBgMidColor"] as? String
            btnBgEndColor = myresult?["btnBgEndColor"] as? String
            headerTextColor = myresult?["headerTextColor"] as? String
            bodyTextColor = myresult?["bodyTextColor"] as? String
            btnTextColor = myresult?["btnTextColor"] as? String
            nativeBGColor = myresult?["nativeBGColor"] as? String
            btnAdBgColor = myresult?["btnAdBgColor"] as? String
            btnAdTextColor = myresult?["btnAdTextColor"] as? String

//             comment below code before submission
            DispatchQueue.main.async {

//                 if isPurchase == "false" {
//                     // delegate for notification :
//                     UNUserNotificationCenter.current().delegate = self
//
//
//                     // calling for notification:
//                     UNUserNotificationCenter.current().getNotificationSettings { settings in
//                         switch settings.authorizationStatus {
//                         case .notDetermined:
//                             self.requestAuthorization()
//                         case .authorized, .provisional:
//                             self.sendNotification()
//                         default:
//                             break // Do nothing
//                         }
//                     }
//                 }

                // Uncomment this line to show toast messages for testing facebook ads.
                // self.showToast(controller: controller, message: "fb_appid: \(value1) fb_token: \(value2)", seconds: 2)
            }

            Settings.appID = value1!
            Settings.clientToken = value2!
            Settings.isAutoLogAppEventsEnabled = true
        })


        let notificationChannel = FlutterMethodChannel(name: "notificationChannel",
                                                        binaryMessenger: controller.binaryMessenger)


              notificationChannel.setMethodCallHandler({
                        [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
                        guard let self = self else { return }
                        // Note: this method is invoked on the UI thread.
                        guard call.method == "setNotification" else {
                            result(FlutterMethodNotImplemented)
                            return
                        }

                        let myresult = call.arguments as? [String: Any]
                        let isPurchase = myresult?["isPurchase"] as? String
                        DispatchQueue.main.async {

                            if isPurchase == "false" {
                                // delegate for notification :
                                UNUserNotificationCenter.current().delegate = self


                                // calling for notification:
                                UNUserNotificationCenter.current().getNotificationSettings { settings in
                                    switch settings.authorizationStatus {
                                    case .notDetermined:
                                        self.requestAuthorization()
                                    case .authorized, .provisional:
                                        self.sendNotification()
                                    default:
                                        break // Do nothing
                                    }
                                }
                            }

                            // Uncomment this line to show toast messages for testing facebook //notification home screen.
        //                     self.showToast(controller: controller, message: "Notification Setup", seconds: 2)
                        }
                    })


        // Native ads Big and Small :
        GeneratedPluginRegistrant.register(with: self)
        let listTileBig = FullNativeAdFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self, factoryId: "big", nativeAdFactory: listTileBig)
        let listTileSmall = SmallNativeAdFactory()
        FLTGoogleMobileAdsPlugin.registerNativeAdFactory(
            self, factoryId: "small", nativeAdFactory: listTileSmall)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)


    }

    // method for notification :
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            if granted {
                print("Yes")
            } else {
                print("No")
            }
        }
    }

//     method for notification :
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Snap Journey : Where we meet"
        content.body = ""
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 11
        dateComponents.minute = 00
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(identifier: "testNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func showToast(controller: UIViewController, message : String, seconds: Double){
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = .black

        alert.view.alpha = 0.5

        alert.view.layer.cornerRadius = 15
        controller.present(alert, animated: true)

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds){
            alert.dismiss(animated: true)
        }
    }
}

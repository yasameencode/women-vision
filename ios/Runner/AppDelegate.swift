import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import AVFoundation // استيراد مكتبة الصوت

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  private let methodChannelName = "com.yourapp.channel/universal_links" // اسم القناة للتواصل مع Flutter

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // تهيئة Firebase
    FirebaseApp.configure()

    // إعداد الإشعارات
    if #available(iOS 10.0, *) {
      let notificationCenter = UNUserNotificationCenter.current()
      notificationCenter.delegate = self
      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
      notificationCenter.requestAuthorization(options: authOptions) { granted, error in
        if let error = error {
          print("Notification authorization error: \(error.localizedDescription)")
        }
      }
    }
    application.registerForRemoteNotifications()

    // تعيين Delegate لـ Messaging
    Messaging.messaging().delegate = self

    // إعداد جلسة الصوت
    configureAudioSession()

    GeneratedPluginRegistrant.register(with: self) // تسجيل جميع المكونات الإضافية

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // معالجة التسجيل للإشعارات البعيدة
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    print("APNs token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
  }

  override func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register for remote notifications: \(error.localizedDescription)")
  }

  // معالجة رمز تسجيل FCM
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    guard let fcmToken = fcmToken else { return }
    print("FCM registration token: \(fcmToken)")
    
    // إرسال الرمز إلى الخادم إذا لزم الأمر
    NotificationCenter.default.post(
      name: Notification.Name("FCMToken"),
      object: nil,
      userInfo: ["token": fcmToken]
    )
  }

  /// معالجة الروابط الشاملة (Universal Links)
  override func application(_ application: UIApplication,
                            continue userActivity: NSUserActivity,
                            restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else {
      return false
    }

    // معالجة الرابط الشامل
    print("Received Universal Link: \(url.absoluteString)")

    // تمرير الرابط إلى Flutter
    handleUniversalLink(url: url)

    return true
  }

  /// معالجة Custom URL Scheme
  override func application(_ app: UIApplication,
                            open url: URL,
                            options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    print("Received Custom URL Scheme: \(url.absoluteString)")

    // تمرير الرابط إلى Flutter
    handleCustomScheme(url: url)

    return true
  }

  /// منطق التعامل مع Universal Links
  private func handleUniversalLink(url: URL) {
    if url.path.starts(with: "/callback.php") {
      if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
        if let code = queryItems.first(where: { $0.name == "code" })?.value {
          print("Code received from Universal Link: \(code)")
          sendCodeToFlutter(code: code) // إرسال الكود إلى Flutter
        }
      }
    }
  }

  /// منطق التعامل مع Custom URL Scheme
  private func handleCustomScheme(url: URL) {
    if url.host == "callback" {
      if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
        if let code = queryItems.first(where: { $0.name == "code" })?.value {
          print("Code received from Custom URL Scheme: \(code)")
          sendCodeToFlutter(code: code) // إرسال الكود إلى Flutter
        }
      }
    }
  }

  /// إرسال الكود إلى Flutter عبر MethodChannel
  private func sendCodeToFlutter(code: String) {
    if let controller = window?.rootViewController as? FlutterViewController {
      let methodChannel = FlutterMethodChannel(
        name: methodChannelName,
        binaryMessenger: controller.binaryMessenger
      )
      methodChannel.invokeMethod("onReceivedCode", arguments: code)
    }
  }

  /// إعداد جلسة الصوت لتسجيل وتشغيل الصوت
  private func configureAudioSession() {
    do {
      let audioSession = AVAudioSession.sharedInstance()

      // قم بضبط فئة الصوت مع خصائص إضافية
      try audioSession.setCategory(
        AVAudioSession.Category.playAndRecord,
        mode: AVAudioSession.Mode.voiceChat, // تجربة الوضع voiceChat للتوافق مع الميكروفون
        options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay]
      )
      print("Audio session category and mode set.")

      // تنشيط الجلسة
      try audioSession.setActive(true, options: [])
      print("Audio session successfully activated.")

    } catch let error as NSError {
      print("Failed to configure AVAudioSession. Error: \(error.localizedDescription)")
    }
  }
}
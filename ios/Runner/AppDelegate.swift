import UIKit
import Flutter
import Firebase
import FirebaseMessaging
import AVFoundation
import SafariServices

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate, SFSafariViewControllerDelegate {
    private let methodChannelName = "com.yourapp.channel/universal_links"
    var safariViewController: SFSafariViewController?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()

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
        Messaging.messaging().delegate = self
        
        configureAudioSession()

        if let controller = window?.rootViewController as? FlutterViewController {
            let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: controller.binaryMessenger)

            methodChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
                if call.method == "openSafariView",
                   let args = call.arguments as? [String: Any],
                   let urlString = args["url"] as? String,
                   let url = URL(string: urlString) {
                    self.openSafariView(url: url)
                    result(nil)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func openSafariView(url: URL) {
        if let controller = window?.rootViewController {
            let safariVC = SFSafariViewController(url: url)
            safariVC.delegate = self // تعيين `AppDelegate` كمفوض
            safariViewController = safariVC
            controller.present(safariVC, animated: true, completion: nil)
        }
    }

    private func closeSafariView() {
        if let safariVC = safariViewController {
            safariVC.dismiss(animated: true, completion: nil)
            safariViewController = nil
        }
    }

    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    override func application(_ application: UIApplication,
                              continue userActivity: NSUserActivity,
                              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL else {
            return false
        }

        print("Received Universal Link: \(url.absoluteString)")
        handleUniversalLink(url: url)
        return true
    }

    override func application(_ app: UIApplication,
                              open url: URL,
                              options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        print("Received Custom URL Scheme: \(url.absoluteString)")
        handleCustomScheme(url: url)
        return true
    }

    private func handleUniversalLink(url: URL) {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            print("No query items found in the Universal Link.")
            return
        }

        if let code = queryItems.first(where: { $0.name == "code" })?.value {
            print("Code received from Universal Link: \(code)")
            sendCodeToFlutter(code: code)
            DispatchQueue.main.async {
                self.closeSafariView()
            }
        } else {
            print("No code parameter found in the Universal Link.")
        }
    }

    private func handleCustomScheme(url: URL) {
        guard let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else {
            print("No query items found in the Custom URL Scheme.")
            return
        }

        if let code = queryItems.first(where: { $0.name == "code" })?.value {
            print("Code received from Custom URL Scheme: \(code)")
            sendCodeToFlutter(code: code)
            DispatchQueue.main.async {
                self.closeSafariView()
            }
        } else {
            print("No code parameter found in the Custom URL Scheme.")
        }
    }

    private func sendCodeToFlutter(code: String) {
        if let controller = window?.rootViewController as? FlutterViewController {
            let methodChannel = FlutterMethodChannel(name: methodChannelName, binaryMessenger: controller.binaryMessenger)
            methodChannel.invokeMethod("onReceivedCode", arguments: code)
        }
    }

    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                AVAudioSession.Category.playAndRecord,
                mode: AVAudioSession.Mode.voiceChat,
                options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay]
            )
            print("Audio session category and mode set.")
            try audioSession.setActive(true, options: [])
            print("Audio session successfully activated.")
        } catch let error as NSError {
            print("Failed to configure AVAudioSession. Error: \(error.localizedDescription)")
        }
    }
}


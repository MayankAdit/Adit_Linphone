import UIKit
import Flutter
import adit_lin_plugin
import PushKit
import CallKit
import os
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    //private let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
    
    //private var sharedProvider: CXProvider!
    
    var deviceToken: Foundation.Data?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
//        self.registerForPushNotifications()
//        self.voipRegistration()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    
    // Register for VoIP notifications
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [ .voIP]
    }
    
    // Push notification setting
    func getNotificationSettings() {
        UNUserNotificationCenter.current().delegate = self
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        } else {
            let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // Register push notification
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                guard let _ = self else {return}
                guard granted else { return }
                self?.getNotificationSettings()
            }
    }
}


//MARK: - PKPushRegistryDelegate
@available(iOS 13.0, *)
extension AppDelegate : PKPushRegistryDelegate, CXProviderDelegate {
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
        UIPasteboard.general.string = deviceToken
        print("pushRegistry -> deviceToken :\(deviceToken)")
    }
        
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType:")
    }
    
    // Handle incoming pushes
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
         print(payload.dictionaryPayload)
        
        let payloadDict = payload.dictionaryPayload["aps"] as? [String:Any] ?? [:]
        let message = payloadDict["alert"] as! String

        
        if UIApplication.shared.applicationState == UIApplication.State.inactive {
            let content = UNMutableNotificationContent()
            content.title = "VoIPDemo"
            content.body = message
            content.badge = 0
            content.sound = UNNotificationSound.default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "VoIPDemoIdentifier", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
        
        DispatchQueue.main.async {
            completion()
        }
        
        let config = CXProviderConfiguration(localizedName: "My App")
               config.ringtoneSound = "ringtone.caf"
               config.includesCallsInRecents = false;
               config.supportsVideo = true;
               let provider = CXProvider(configuration: config)
               provider.setDelegate(self, queue: nil)
               let update = CXCallUpdate()
               update.remoteHandle = CXHandle(type: .generic, value: "Pete Za")
               update.hasVideo = true
               provider.reportNewIncomingCall(with: UUID(), update: update, completion: { error in })
        
        
    }
    
    func providerDidReset(_ provider: CXProvider) {
       }

       func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
           action.fulfill()
       }

       func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
           action.fulfill()
       }
}



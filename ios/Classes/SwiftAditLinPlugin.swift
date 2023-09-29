import Flutter
import UIKit
import linphone
import SwiftUI
//import PushKit
//import UserNotifications

public class SwiftAditLinPlugin: NSObject, FlutterPlugin {
    
    var linphoneConnect: LinphoneConnect!
    private var channel: FlutterMethodChannel? = nil
    
    @objc public private(set) static var sharedInstance: SwiftAditLinPlugin!
    
    init(with registrar: FlutterPluginRegistrar) {
        super.init()
        linphoneConnect = LinphoneConnect(registery: registrar)
//        registerForPushNotifications()
//        voipRegistration()
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
//        if(sharedInstance == nil){
//            sharedInstance = SwiftAditLinPlugin(with: registrar)
//        } else {
//            let channel = FlutterMethodChannel(name: aditLinPlugin, binaryMessenger: registrar.messenger())
//            let instance = SwiftAditLinPlugin(with: registrar)
//            instance.channel = channel
//            registrar.addMethodCallDelegate(instance, channel: channel)
//        }
        let channel = FlutterMethodChannel(name: aditLinPlugin, binaryMessenger: registrar.messenger())
        sharedInstance = SwiftAditLinPlugin(with: registrar)
        sharedInstance.channel = channel
        registrar.addMethodCallDelegate(sharedInstance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String : Any] else {return}
        let userName = args[username] as? String
        let password = args[passwd] as? String
        let domain = args[domain] as? String
        let transportType = args[transportType] as? String
        let methodType = args[methodType] as? String
        let phone = args[phone] as? String
        let sipExtention = args[sipExtention] as? String
        linphoneConnect.username = userName ?? ""
        linphoneConnect.passwd = password ?? ""
        linphoneConnect.domain = domain ?? ""
        linphoneConnect.transportType = transportType ?? ""
        linphoneConnect.channel = SwiftAditLinPlugin.sharedInstance.channel
        linphoneConnect.methodType = methodType ?? ""
        linphoneConnect.phone = phone ?? ""
        linphoneConnect.sipExtention = sipExtention ?? ""
        
        if(methodType == isLoginChannel){
            linphoneConnect.login()
        }
        linphoneConnect.remoteAddress = "sip:\(linphoneConnect.phone)\(linphoneConnect.sipExtention)"//@pjsip5.adit.com" //@pjsipbeta1.adit.com"
        
        if methodType == isOutgoingChannel {
            linphoneConnect.outgoingCall()
        } else if methodType == isHungUpChannel {
            linphoneConnect.mProviderDelegate.stopCall()
            linphoneConnect.terminateCall()
        } else if methodType == isMuteCallChannel {
            linphoneConnect.muteCall()
        } else if methodType == isUnMuteCallChannel {
            linphoneConnect.unmuteCall()
        } else if methodType == isHoldAndUnhold {
            linphoneConnect.pauseOrResume()
        } else if methodType == isSpeakerChannel {
            linphoneConnect.toggleSpeaker()
        } else if methodType == isUnregistration {
            linphoneConnect.unregister()
        } else if methodType == isDelete {
            linphoneConnect.delete()
        }
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    @objc public func showCallkitIncoming(_ data: String, callName: String, fromPushKit: Bool, completion: @escaping () -> Void) {
        linphoneConnect.incomingCallName = callName
        linphoneConnect.mProviderDelegate.incomingCall(callID: data) {
            completion()
        }
    }
    
    // Register for VoIP notifications
//    func voipRegistration() {
//        let mainQueue = DispatchQueue.main
//        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
//        voipRegistry.delegate = self
//        voipRegistry.desiredPushTypes = [PKPushType.voIP]
//    }
//
//    // Push notification setting
//    func getNotificationSettings() {
//        if #available(iOS 10.0, *) {
//            UNUserNotificationCenter.current().getNotificationSettings { settings in
//                UNUserNotificationCenter.current().delegate = self
//                guard settings.authorizationStatus == .authorized else { return }
//                DispatchQueue.main.async {
//                    UIApplication.shared.registerForRemoteNotifications()
//                }
//            }
//        } else {
//            let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
//            UIApplication.shared.registerUserNotificationSettings(settings)
//            UIApplication.shared.registerForRemoteNotifications()
//        }
//    }
//
//    // Register push notification
//    func registerForPushNotifications() {
//        UNUserNotificationCenter.current()
//            .requestAuthorization(options: [.alert, .sound, .badge]) {
//                [weak self] granted, error in
//                guard let _ = self else {return}
//                guard granted else { return }
//                self?.getNotificationSettings()
//            }
//    }
    
}


//MARK: - PKPushRegistryDelegate
//extension SwiftAditLinPlugin : PKPushRegistryDelegate {
//
//    // Handle updated push credentials
//    public func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
//        print(credentials.token)
//        let deviceToken = credentials.token.map { String(format: "%02x", $0) }.joined()
//        print("pushRegistry -> deviceToken :\(deviceToken)")
//    }
//
//    public func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
//        print("pushRegistry:didInvalidatePushTokenForType:")
//    }
//
//    // Handle incoming pushes
//    public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
//        print(payload.dictionaryPayload)
//        guard type == .voIP else { return }
//        let callId = payload.dictionaryPayload["id"] as? String ?? ""
//        if UIApplication.shared.applicationState == UIApplication.State.active {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//                print("application mode------> active")
//                self.linphoneConnect.mProviderDelegate.incomingCall(callID: callId, completion: {
//
//                })
//            }
//        } else if UIApplication.shared.applicationState == UIApplication.State.inactive {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//                print("application mode------> inactive")
//                self.linphoneConnect.mProviderDelegate.incomingCall(callID: callId, completion: {
//
//                })
//            }
//        } else {
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
//                print("application mode------> background")
//                self.linphoneConnect.mProviderDelegate.incomingCall(callID: callId, completion: {
//
//                })
//            }
//        }
//
//        DispatchQueue.main.async {
//            completion()
//        }
//    }
//}
////
//////
//////// MARK:- UNUserNotificationCenterDelegate
//extension SwiftAditLinPlugin : UNUserNotificationCenterDelegate {
//
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        let userInfo = response.notification.request.content.userInfo
//        print("didReceive ======", userInfo)
//        completionHandler()
//    }
//
//    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        let userInfo = notification.request.content.userInfo
//        print("willPresent ======", userInfo)
//        completionHandler([.alert, .sound, .badge])
//    }
//}

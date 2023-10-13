import Flutter
import UIKit
import linphone
import SwiftUI

public class SwiftAditLinPlugin: NSObject, FlutterPlugin {
    
    var linphoneConnect: LinphoneConnect!
    private var channel: FlutterMethodChannel? = nil
    
    @objc public private(set) static var sharedInstance: SwiftAditLinPlugin!
    
    static var eventSink: FlutterEventSink?
    
    init(with registrar: FlutterPluginRegistrar) {
        super.init()
        linphoneConnect = LinphoneConnect(registery: registrar)
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
        let eventChannelCallBack = FlutterEventChannel(name: aditcallbackEvent, binaryMessenger: registrar.messenger())
        eventChannelCallBack.setStreamHandler(sharedInstance)
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
        let callerId = args[callerID] as? String
        print("get caller id --------", callerId)
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
            linphoneConnect.outgoingCall(result: result)
        } else if methodType == isHungUpChannel {
           // linphoneConnect.mProviderDelegate.stopCall()
            linphoneConnect.hangup(result: result, callerID: callerId ?? "")
        } else if methodType == isMuteCallChannel {
            linphoneConnect.toggleMic(result: result)
        } else if methodType == isHoldAndUnhold {
            linphoneConnect.pauseOrResume()
        } else if methodType == isSpeakerChannel {
            linphoneConnect.toggleSpeaker(result: result)
        } else if methodType == isUnregistration {
            linphoneConnect.unregister(result: result)
        } else if methodType == isDelete {
            linphoneConnect.delete()
        } else if methodType == isAcceptCallChannel {
            linphoneConnect.acceptCall(result: result, callerID: callerId ?? "")
        } else if methodType == isPausedChannel {
            linphoneConnect.pause(result: result)
        } else if methodType == isResumChannel {
            linphoneConnect.resume(result: result)
        } else if methodType == isRejectCall {
            linphoneConnect.reject(result: result)
        } else if methodType == isTransfer {
            linphoneConnect.transfer(recipient: linphoneConnect.phone, result: result)
        }
        result("iOS " + UIDevice.current.systemVersion)
    }
    
    @objc public func showCallkitIncoming(_ data: String, callName: String, fromPushKit: Bool, completion: @escaping () -> Void) {
        linphoneConnect.incomingCallName = callName
//        linphoneConnect.mProviderDelegate.incomingCall(callID: data) {
//            completion()
//        }
    }
}

extension SwiftAditLinPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        SwiftAditLinPlugin.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        SwiftAditLinPlugin.eventSink = nil
        return nil
    }
}

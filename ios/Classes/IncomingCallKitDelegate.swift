//
//  IncomingCallKitDelegate.swift
//  adit_lin_plugin
//
//  Created by Adit Mac1 on 20/07/23.
//

import Foundation
import CallKit
import linphonesw
import AVFoundation
import AVKit

class IncomingCallKitDelegate : NSObject
{
    private var provider: CXProvider
    let mCallController = CXCallController()
    var linphoneConnect : LinphoneConnect!
    
    var incomingCallUUID : UUID!
    var audioSessionCall = AVAudioSession.sharedInstance()
    var isMuted = false
    
    ///MARK :  - Callkit init
    init(context: LinphoneConnect)
    {
        linphoneConnect = context
        let providerConfiguration = CXProviderConfiguration(localizedName: Bundle.main.infoDictionary!["CFBundleName"] as! String)
        providerConfiguration.supportedHandleTypes = [.generic]
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        provider = CXProvider(configuration: providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    ///MARK:  - Report to CallKit a call is incoming
    func incomingCall(callID: String, completion: @escaping () -> Void)
    {
        if callID.isEmpty { return }
        incomingCallUUID = UUID(uuidString: callID)
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type:.generic, value: linphoneConnect.incomingCallName)
        update.hasVideo = false
        linphoneConnect.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        provider.reportNewIncomingCall(with: incomingCallUUID, update: update, completion: { error in
            if let error = error {
                debugPrint("Error reporting incoming call: \(error.localizedDescription)")
            } else {
                completion()
            }
        })
    }
    
    ///MARK:  - 45 second timer
    @objc func updateCounter() {
        linphoneConnect.counter += 1
        if(linphoneConnect.counter >= 45){
            if(!linphoneConnect.isCallRunning){
                stopCall()
                //linphoneConnect.hangup()
                linphoneConnect.counter = 0
            }
            linphoneConnect.timer?.invalidate()
        }
    }
    
    ///MARK:  - Stop callkit call
    func stopCall()
    {
        if incomingCallUUID == nil {
            if(!linphoneConnect.isCallRunning){
                linphoneConnect.timer?.invalidate()
                linphoneConnect.counter = 0
            }
        } else {
            let endCallAction = CXEndCallAction(call: incomingCallUUID)
            let transaction = CXTransaction(action: endCallAction)
            if(!linphoneConnect.isCallRunning){
                linphoneConnect.timer?.invalidate()
                linphoneConnect.counter = 0
            }
            requestTransaction(transaction)
        }
    }
    
    ///MARK:  - Start outgoing call in callkit
    func startOutgoingCall(handle: String) {
        incomingCallUUID = UUID()
        let handle = CXHandle(type: .generic, value: handle)
        let startCallAction = CXStartCallAction(call: incomingCallUUID, handle: handle)
        startCallAction.isVideo = false
        startCallAction.fulfill()
        let transaction = CXTransaction(action: startCallAction)
        requestTransaction(transaction)
    }
    
    func reportOutgoingCallStartedConnecting(uuid:UUID) {
        provider.reportOutgoingCall(with: uuid, startedConnectingAt: nil)
    }
    
    func reportOutgoingCallConnected(uuid:UUID) {
        provider.reportOutgoingCall(with: uuid, connectedAt: nil)
    }
        
    func toggleSpeaker(isEnabled: Bool) {
        do {
            if isEnabled {
                try audioSessionCall.overrideOutputAudioPort(.speaker)
                if(linphoneConnect.mCall?.dir == .Incoming){
                    linphoneConnect.callbackChannel?.invokeMethod(isOnSpeakerChannel, arguments: nil)
                } else {
                    linphoneConnect.channel?.invokeMethod(isOnSpeakerChannel, arguments: nil)
                }
            } else {
                try audioSessionCall.overrideOutputAudioPort(.none)
                if(linphoneConnect.mCall?.dir == .Incoming){
                    linphoneConnect.callbackChannel?.invokeMethod(isOffSpeakerChannel, arguments: nil)
                } else {
                    linphoneConnect.channel?.invokeMethod(isOffSpeakerChannel, arguments: nil)
                }
            }
        } catch {
            print("Error setting audio route: \(error.localizedDescription)")
        }
       // linphoneConnect.toggleSpeaker()
    }
}

///MARK: - callkit delegete method
// In this extension, we implement the action we want to be done when CallKit is notified of something.
// This can happen through the CallKit GUI in the app, or directly in the code (see, incomingCall(), stopCall() functions above)
extension IncomingCallKitDelegate: CXProviderDelegate {
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        if (linphoneConnect.mCall?.state != .End && linphoneConnect.mCall?.state != .Released)  {
            if(!linphoneConnect.isCallRunning){
               // linphoneConnect.reject()
            } else {
               // linphoneConnect.hangup()
            }
        }
        linphoneConnect.isCallRunning = false
        linphoneConnect.isCallIncoming = false
        let endCallAction = CXEndCallAction(call: incomingCallUUID)
        let transaction = CXTransaction(action: endCallAction)
        requestTransaction(transaction)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        if(!linphoneConnect.isCallRunning){
            linphoneConnect.mCore.configureAudioSession()
            //linphoneConnect.acceptCall()
            linphoneConnect.callbackChannel?.invokeMethod(isAcceptCallChannel, arguments: nil)
            linphoneConnect.isCallRunning = true
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        linphoneConnect.pauseOrResume()
        linphoneConnect.isCallRunning = true
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        do {
            try linphoneConnect.mCore.start()
            linphoneConnect.isCallRunning = true
            linphoneConnect.callbackChannel?.invokeMethod(isStartCallChannel, arguments: nil)
        } catch {
            debugPrint(error)
        }
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        linphoneConnect.isCallRunning = true
        let isMuted = action.isMuted
        if isMuted {
           // linphoneConnect.muteCall()
        } else {
           // linphoneConnect.unmuteCall()
        }
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {}
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        //linphoneConnect.reject()
        linphoneConnect.isCallRunning = false
        stopCall()
        action.fulfill()
    }
    func providerDidReset(_ provider: CXProvider) {}
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        linphoneConnect.mCore.activateAudioSession(actived: true)
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        linphoneConnect.mCore.activateAudioSession(actived: false)
    }
    
    func muteCall(callUUID: UUID) {
        let muteAction = CXSetMutedCallAction(call: callUUID, muted: true)
        let transaction = CXTransaction(action: muteAction)
        //requestTransaction(transaction)
    }
    
    func unmuteCall(callUUID: UUID) {
        let unmuteAction = CXSetMutedCallAction(call: callUUID, muted: false)
        let transaction = CXTransaction(action: unmuteAction)
       // requestTransaction(transaction)
    }
    
    private func requestTransaction(_ transaction: CXTransaction) {
        mCallController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error.localizedDescription)")
            } else {
                print("Transaction request successful")
            }
        }
    }
}



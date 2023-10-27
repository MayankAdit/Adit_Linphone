//
//  LinphoneConnect.swift
//  adit_lin_plugin
//
//  Created by Adit Mac1 on 19/07/23.
//

import linphonesw
import AVFoundation

class LinphoneConnect
{
    var eventSink: FlutterEventSink?
    var mCore: Core!
    var coreVersion: String = Core.getVersion
    var channel: FlutterMethodChannel? = nil
    
    /*------------ Login tutorial related variables -------*/
    var mCoreDelegate : CoreDelegate!
    var mAccount: Account?
    var username : String = ""
    var passwd : String = ""
    var domain : String = ""
    var loggedIn: Bool = false
    var transportType : String = ""
    var methodType = ""
    var phone = ""
    var sipExtention = ""
    
    // Incoming call related variables
    var callMsg : String = ""
    var isCallIncoming : Bool = false
    var isCallRunning : Bool = false
    var remoteAddress : String = "Nobody yet"
    var isSpeakerEnabled : Bool = false
        
    /*------------ Callkit tutorial related variables ---------------*/
    var incomingCallName = "Incoming call example"
    var mCall : Call?
   // var mProviderDelegate : IncomingCallKitDelegate!
    var callbackChannel: FlutterMethodChannel!
    var counter = 0
    var timer: Timer?
    
    private var timeStartStreamingRunning: Int64 = 0
    private var isPause: Bool = false
    
    
    init(registery: FlutterPluginRegistrar)
    {
        LoggingService.Instance.logLevel = LogLevel.Debug
        let factory = Factory.Instance
        let configDir = factory.getConfigDir(context: nil)
        try? mCore = factory.createCore(configPath: "\(configDir)/MyConfig", factoryConfigPath: "", systemContext: nil)
        
       // mCore.callkitEnabled = true
       // mCore.pushNotificationEnabled = true
      //  mProviderDelegate = IncomingCallKitDelegate(context: self)
        
        mCore.genericComfortNoiseEnabled = true
        mCore.echoCancellationEnabled = true
        mCore.micEnabled = true
      
        mCore.adaptiveRateControlEnabled = true
        mCore.ipv6Enabled = true
        
        let natPolicy = try? mCore.createNatPolicy()
        natPolicy?.stunServer = "stun.linphone.org"
        natPolicy?.iceEnabled = true
        natPolicy?.stunEnabled = true
        natPolicy?.turnEnabled = false
        natPolicy?.upnpEnabled = true
        natPolicy?.resolveStunServer()
        natPolicy?.udpTurnTransportEnabled = true
        mCore.natPolicy = natPolicy
        
        // Comment this code becuase when we accept call then it will auto disconnect after 2 second so i commnet this line of code (22/09/2023) `Mayank Mangukiya`
        //mCore.setAudioPortRange(minPort: 7200, maxPort: 7299)
        
        mCore.ipv6Enabled = true
                        
        /// pending
        mCore.pushNotificationConfig?.voipToken = ""
         
        mCore.iterate()
        try? mCore.start()

        mCoreDelegate = CoreDelegateStub( onCallStateChanged: { [self] (core: Core, call: Call, state: Call.State, message: String) in
            callbackChannel = FlutterMethodChannel(name: aditcallback, binaryMessenger: registery.messenger())
                        
            NSLog("Call state is \(state) callid : \( call.callLog?.callId ?? "")   message \(message), calls log\(core.calls)")
            self.sendEvent(eventName: "callEvent", body: ["body": callsArray(calls: core.calls)])
//            if(call.dir == .Incoming){
//                callbackChannel.invokeMethod(isCallEventChannel, arguments: callData)
//            }else {
//                channel?.invokeMethod(isCallEventChannel, arguments: callData)
//            }
            incomingCallName = call.callLog?.fromAddress?.displayName ?? ""
            self.callMsg = message
            switch state {
            case .OutgoingInit:
               // mProviderDelegate.startOutgoingCall(handle: remoteAddress)
                break;
            case .OutgoingProgress:
                self.sendEvent(eventName: EventRing, body: callObject(callObject: call))
                break;
            case .OutgoingRinging:
                break;
            case .Connected:
                self.isCallRunning = true
                if(call.dir == .Incoming){
                    self.isCallIncoming = false
                    timer?.invalidate()
                    counter = 0
                }
                self.sendEvent(eventName: EventUp, body: callObject(callObject: call))
                break;
            case .StreamsRunning:
                if(!self.isPause) {
                    self.timeStartStreamingRunning = Int64(Date().timeIntervalSince1970 * 1000)
                }
                self.isPause = false
                self.sendEvent(eventName: EventUp, body: callObject(callObject: call))
                break;
            case .Paused:
                self.isPause = true
                self.sendEvent(eventName: EventPaused, body: callObject(callObject: call))
                break;
            case .Resuming:
                self.sendEvent(eventName: EventResuming, body: callObject(callObject: call))
                break;
            case .PausedByRemote:
                break;
            case .Updating:
                break;
            case .UpdatedByRemote:
                break;
            case .PushIncomingReceived:
                self.mCall = call
                self.isCallIncoming = true
                break;
            case .IncomingReceived:
                if (!self.isCallIncoming) {
                    self.mCall = call
                    self.isCallIncoming = true
                   // self.mProviderDelegate.incomingCall(callID: call.callLog?.callId ?? "") {}
                    self.sendEvent(eventName: EventRing, body: callObject(callObject: call))
                }
                self.remoteAddress = call.remoteAddress!.asStringUriOnly()
                break;
            case .Released:
                if(call.dir == .Outgoing){
                    self.isCallRunning = false
                }
                if(self.isMissed(callLog: call.callLog)) {
                    NSLog("Missed")
                    self.sendEvent(eventName: EventMissed, body: callObject(callObject: call))
                } else {
                    NSLog("Released")
                }
                break;
            case .End:
                if(call.dir == .Incoming){
                    if (self.isCallRunning) {
                   ////  MARK: - We are managing from callkit
                       // self.mProviderDelegate.stopCall()
//                        self.hangup(result: { r in
//                        }, callerID: mCore.currentCall?.callLog?.callId ?? "")
                    }else {
                        if(call.callLog?.status == .Aborted){
                            //self.mProviderDelegate.stopCall()
//                            self.hangup(result: { r in
//                            }, callerID: mCore.currentCall?.callLog?.callId ?? "")
                        }
                    }
                } else {
                    if (self.isCallRunning) {
//                        self.hangup(result: { r in
//                        }, callerID: mCore.currentCall?.callLog?.callId ?? "")
                       // self.mProviderDelegate.stopCall()
                    }
                }
                self.remoteAddress = "Nobody yet"
                let duration = self.timeStartStreamingRunning == 0 ? 0 : Int64(Date().timeIntervalSince1970 * 1000) - self.timeStartStreamingRunning
                NSLog("duration", duration)
                self.sendEvent(eventName: EventHangup, body: callObject(callObject: call))
                self.timeStartStreamingRunning = 0
                break;
            case .Error:
                self.hangup(result: { r in
                }, callerID: mCore.currentCall?.callLog?.callId ?? "")
                self.sendEvent(eventName: EventError, body: callObject(callObject: call))
                //self.mProviderDelegate.stopCall()
                break;
            default:
                break;
            }
        }, onAudioDeviceChanged: { (core: Core, device: AudioDevice) in
        }, onAudioDevicesListUpdated: { (core: Core) in
        }, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
            NSLog("New registration state is \(state) for user id \( String(describing: account.params?.identityAddress?.asString()))\n")
            //self.channel?.invokeMethod(isRegistrationState, arguments: "\(state)")
            self.sendEvent(eventName: EventAccountRegistrationStateChanged, body: ["registrationState": self.getRegistrationState(state: state), "message": message])
            if (state == .Ok){
                self.loggedIn = true
            } else if (state == .Cleared){
                self.loggedIn = false
            } else if (state == .Failed){
                self.loggedIn = false
            }
        })
        //mCore.removeDelegate(delegate: mCoreDelegate)
        mCore.addDelegate(delegate: mCoreDelegate)
    }
    
      
    func callObject(callObject: Call) -> [String: Any] {
        var callData = [String : Any]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let currentDateTime = Date()
        let formattedDateTime = dateFormatter.string(from: currentDateTime)
        print("Current Date and Time: \(formattedDateTime)")
        callData = ["callId": callObject.callLog?.callId ?? "", "callStatus": getCallStatus(status: callObject.callLog!.status), "number": callObject.remoteAddress?.username ?? "", "timer": callObject.duration, "isHold": callObject.state == .Paused || callObject.state == .Pausing ? true : false, "isMute": !mCore.micEnabled, "isActive": true, "isIncoming": callObject.dir == .Incoming ? true : false, "isConnected": callObject.state == .Connected || callObject.state == .StreamsRunning ? true : false, "isProgress": callObject.state == .OutgoingProgress || callObject.state == .IncomingReceived ? true : false, "startTime": formattedDateTime, "callState": getCallState(call: callObject.state)] as [String : Any]
        print("state call -------", callData)
        
        return callData
    }
    
    func convertIntoJSONString(arrayObject: [Any]) -> String? {

            do {
                let jsonData: Data = try JSONSerialization.data(withJSONObject: arrayObject, options: [])
                if  let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                    return jsonString as String
                }
                
            } catch let error as NSError {
                print("Array convertIntoJSON - \(error.description)")
            }
            return nil
        }
    
    func callsArray(calls: [Call]) -> String {
        var callData = [String : Any]()
        var tempCallData = [[String: Any]]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let currentDateTime = Date()
        let formattedDateTime = dateFormatter.string(from: currentDateTime)
        print("Current Date and Time: \(formattedDateTime)")
        for i in 0..<calls.count {
            var data = calls[i]
            callData = ["callId": data.callLog?.callId ?? "", "callStatus": getCallStatus(status: data.callLog!.status), "number": data.remoteAddress?.username ?? "", "timer": data.duration, "isHold": data.state == .Paused || data.state == .Pausing ? true : false, "isMute": !mCore.micEnabled, "isActive": true, "isIncoming": data.dir == .Incoming ? true : false, "isConnected": data.state == .Connected || data.state == .StreamsRunning ? true : false, "isProgress": data.state == .OutgoingProgress || data.state == .IncomingReceived ? true : false, "startTime": formattedDateTime, "callState": getCallState(call: data.state)] as [String : Any]
            tempCallData.append(callData)
        }
        print("state call -------", callData)
        var str = convertIntoJSONString(arrayObject: tempCallData)
        print("call convert string -------", str)
        return str ?? ""
    }
    
    //// MARK:  - Login
    ///
    func login() {
        do {
            var transport : TransportType
            if (transportType == "TLS") { transport = TransportType.Tls }
            else if (transportType == "TCP") { transport = TransportType.Tcp }
            else { transport = TransportType.Udp }
            let authInfo = try Factory.Instance.createAuthInfo(username: username, userid: "", passwd: passwd, ha1: "", realm: "", domain: domain)
            let accountParams = try mCore.createAccountParams()
            let identity = try Factory.Instance.createAddress(addr: String("sip:" + username + "@" + domain))
            try! accountParams.setIdentityaddress(newValue: identity)
            let address = try Factory.Instance.createAddress(addr: String("sip:" + domain))
            try address.setTransport(newValue: transport)
            try accountParams.setServeraddress(newValue: address)
            //accountParams.expires = 60
            accountParams.registerEnabled = true
            accountParams.pushNotificationAllowed = false
           // accountParams.pushNotificationConfig?.provider = "apns.dev"
            mCore.setUserAgent(name: "LinPhone iOS", version: "0.0.1")
            mCore.configureAudioSession()
            mAccount = try mCore.createAccount(params: accountParams)
            mCore.addAuthInfo(info: authInfo)
            try mCore.addAccount(account: mAccount!)
            mCore.defaultAccount = mAccount
        } catch { NSLog(error.localizedDescription) }
    }
    
    //// MARK:  - Unregister
    
    func unregister(result: FlutterResult)
    {
        if let account = mCore.defaultAccount {
            let params = account.params
            let clonedParams = params?.clone()
            clonedParams?.registerEnabled = false
            account.params = clonedParams
            mCore.clearProxyConfig()
            delete()
            result(true)
        } else {
            NSLog("Sip account not found")
            result(false)
        }
    }
    
    ////MARK:  - Delete
    
    func delete() {
        if let account = mCore.defaultAccount {
            mCore.removeAccount(account: account)
            mCore.clearAccounts()
            mCore.clearAllAuthInfo()
        }
    }
    
    private func createParams(eventName: String, body: [String: Any]?) -> [String:Any] {
        if body == nil {
            return [
                "event": eventName
            ] as [String: Any]
        } else {
            return [
                "event": eventName,
                "body": body!
            ] as [String: Any]
        }
    }
    
    private func sendEvent(eventName: String, body: [String: Any]?) {
        let data = createParams(eventName: eventName, body: body)
        SwiftAditLinPlugin.eventSink?(data)
    }
    
    ///MARK:  - Terminate Ringing Call
    
//    func terminateRingingCall() {
//        do {
//            if (mCore.callsNb == 0) { return }
//            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
//            if let call = coreCall {
//                try call.terminate()
//            }
//            if(mCall?.dir == .Incoming){
//                callbackChannel?.invokeMethod(isRingingCallTerminate, arguments: nil)
//            } else {
//                channel?.invokeMethod(isRingingCallTerminate, arguments: nil)
//            }
//
//        } catch { NSLog(error.localizedDescription) }
//    }
    
    func reject(result: FlutterResult) {
        do {
            let coreCall = mCore.currentCall
            if(coreCall == nil) {
                return result(false)
            }
            try coreCall!.terminate()
            result(true)
        } catch {
            NSLog(error.localizedDescription)
            result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
        }
    }
    
    ///MARK:  - Terminate Call
    
    func hangup(result: FlutterResult, callerID: String) {
//        do {
//            try mCore.currentCall?.terminate()
//        } catch { NSLog(error.localizedDescription) }
        var getCall = mCore.getCallByCallid(callId: callerID)
        print("get hangup Call -------- ", getCall)
        if(getCall != nil){
            do {
                try getCall!.terminate()
                result(true)
            } catch {
                NSLog(error.localizedDescription)
                result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
            }
        } else {
            do {
                if (mCore.callsNb == 0) {
                    return result(false)
                }
                let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
                if(coreCall == nil) {
                    return result(false)
                }
                try coreCall!.terminate()
                result(true)
            } catch {
                NSLog(error.localizedDescription)
                result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
            }
        }
    }
    
    ///MARK:  -  Call accept
    
    func acceptCall(result: FlutterResult, callerID: String) {
//        do {
//            try mCore.currentCall?.accept()
//        } catch { NSLog(error.localizedDescription) }
        var getCall = mCore.getCallByCallid(callId: callerID)
        print("get accept Call -------- ", getCall)
        if(getCall != nil){
            do {
                try getCall!.accept()
                result(true)
            } catch {
                NSLog(error.localizedDescription)
                result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
            }
        } else {
            do {
                let coreCall = mCore.currentCall
                if(coreCall == nil) {
                    return result(false)
                }
                try coreCall!.accept()
                result(true)
            } catch {
                NSLog(error.localizedDescription)
                result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
            }
        }
//        do {
//            let coreCall = mCore.currentCall
//            if(coreCall == nil) {
//                return result(false)
//            }
//            try coreCall!.accept()
//            result(true)
//        } catch {
//            NSLog(error.localizedDescription)
//            result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
//        }
    }
    
    func toggleMic(result: FlutterResult) {
        let coreCall = mCore.currentCall
        if(coreCall == nil) {
            return result(FlutterError(code: "404", message: "Current call not found", details: nil))
        }
        mCore.micEnabled = !mCore.micEnabled
        result(mCore.micEnabled)
    }
    
    ///MARK:  -  Speaker On and Off
    func toggleSpeaker(result: FlutterResult) {
        let currentAudioDevice = mCore.currentCall?.outputAudioDevice
        let speakerEnabled = currentAudioDevice?.type == AudioDeviceType.Speaker
        for audioDevice in mCore.audioDevices {
            if (speakerEnabled && audioDevice.type == AudioDeviceType.Microphone) {
                mCore.currentCall?.outputAudioDevice = audioDevice
                isSpeakerEnabled = false
//                if(mCall?.dir == .Incoming){
//                    callbackChannel?.invokeMethod(isOffSpeakerChannel, arguments: nil)
//                } else {
//                    channel?.invokeMethod(isOffSpeakerChannel, arguments: nil)
//                }
                return result(false)
            } else if (!speakerEnabled && audioDevice.type == AudioDeviceType.Speaker) {
                mCore.currentCall?.outputAudioDevice = audioDevice
                isSpeakerEnabled = true
//                if(mCall?.dir == .Incoming){
//                    callbackChannel?.invokeMethod(isOnSpeakerChannel, arguments: nil)
//                } else {
//                    channel?.invokeMethod(isOnSpeakerChannel, arguments: nil)
//                }
                return result(true)
            }
        }
    }
    
    ///MARK:  - Outgoing call
    func outgoingCall(result: FlutterResult) {
        do {
            let remoteAddress1 = try Factory.Instance.createAddress(addr: remoteAddress)
            let params = try mCore.createCallParams(call: nil)
            params.mediaEncryption = .None
            let _ = mCore.inviteAddressWithParams(addr: remoteAddress1, params: params)
            result(true)
        } catch {
            NSLog(error.localizedDescription)
            result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
        }
    }
    
    ///MARK:  - call hold and unhold
    func pauseOrResume() {
        do {
            if (mCore.callsNb == 0) { return }
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            if let call = coreCall {
                if (call.state != Call.State.Paused && call.state != Call.State.Pausing) {
                    try call.pause()
                    if(mCall?.dir == .Incoming){
                        callbackChannel?.invokeMethod(isPausedChannel, arguments: nil)
                    } else {
                        channel?.invokeMethod(isPausedChannel, arguments: nil)
                    }
                } else if (call.state != Call.State.Resuming) {
                    try call.resume()
                    if(mCall?.dir == .Incoming){
                        callbackChannel?.invokeMethod(isResumChannel, arguments: nil)
                    } else {
                        channel?.invokeMethod(isResumChannel, arguments: nil)
                    }
                }
            }
        } catch { NSLog(error.localizedDescription) }
    }
    
    func pause(result: FlutterResult) {
        do {
            if (mCore.callsNb == 0) {
                return result(false)
            }
            
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            
            if(coreCall == nil) {
                return result(false)
            }
            // Pause a call
            try coreCall!.pause()
            result(true)
        } catch {
            NSLog(error.localizedDescription)
            result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
        }
    }
    
    func resume(result: FlutterResult) {
        do {
            if (mCore.callsNb == 0) {
                return result(false)
            }
            
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            
            if(coreCall == nil) {
                result(false)
            }
            // Resume a call
            try coreCall!.resume()
            result(true)
        } catch {
            NSLog(error.localizedDescription)
            result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
        }
    }
    
    func transfer(recipient: String, result: FlutterResult) {
        do {
            if (mCore.callsNb == 0) { return }
            
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            
            let domain: String? = mCore.defaultAccount?.params?.domain
            
            if (domain == nil) {
                NSLog("Can't create sip uri")
                return result(false)
            }
            
            let address = mCore.interpretUrl(url: String("sip:\(recipient)@\(domain!)"))
            if(address == nil) {
                NSLog("Can't create address")
                return result(false)
            }
            
            if(coreCall == nil) {
                NSLog("Current call not found")
                result(false)
            }
            
            // Transfer a call
            try coreCall!.transferTo(referTo: address!)
            NSLog("Transfer successful")
            result(true)
        } catch {
            NSLog(error.localizedDescription)
            result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
        }
    }
    
    //// send DTMF
    ///
    func sendDTMF(dtmf: String, result: FlutterResult) {
        do {
            let coreCall = mCore.currentCall
            if(coreCall == nil) {
                NSLog("Current call not found")
                return result(false)
            }
            
            // Send IVR
            try coreCall!.sendDtmf(dtmf: dtmf.utf8CString[0])
            NSLog("Send DTMF successful")
            result(true)
            // result("Send DTMF successful")
        } catch {
            NSLog(error.localizedDescription)
            result(FlutterError(code: "500", message: error.localizedDescription, details: nil))
        }
    }
    
    private func isMissed(callLog: CallLog?) -> Bool {
        return (callLog?.dir == Call.Dir.Incoming && callLog?.status == Call.Status.Missed)
    }
    
    func getCallState(){
        
    }
    
    func getCallState(call: Call.State) -> String {
        var callState = ""
        switch call {
        case .Idle:
            callState = "CALL_INITIATION"
            break;
        case .IncomingReceived:
            callState = "PROGRESS"
            break;
        case .PushIncomingReceived:
            break;
        case .OutgoingInit:
            break;
        case .OutgoingProgress:
            callState = "PROGRESS"
            break;
        case .OutgoingRinging:
            break;
        case .OutgoingEarlyMedia:
            break;
        case .Connected:
            callState = "ACCEPTED"
            break;
        case .StreamsRunning:
            callState = "CONFIRMED"
            break;
        case .Pausing:
            break;
        case .Paused:
            break;
        case .Resuming:
            break;
        case .Referred:
            break;
        case .Error:
            break;
        case .End:
            callState = "ENDED"
            break;
        case .PausedByRemote:
            break;
        case .UpdatedByRemote:
            break;
        case .IncomingEarlyMedia:
            break;
        case .Updating:
            break;
        case .Released:
            break;
        case .EarlyUpdatedByRemote:
            break;
        case .EarlyUpdating:
            break;
        default:
            break;
        }
        return callState
    }
    
    func getCallStatus(status: Call.Status) -> String {
        var callStatus = ""
        switch status {
        case .Success:
            callStatus = "Success"
            break;
        case .Aborted:
            callStatus = "Aborted"
            break;
        case .Missed:
            callStatus = "Missed"
            break;
        case .Declined:
            callStatus = "Declined"
            break;
        case .EarlyAborted:
            callStatus = "EarlyAborted"
            break;
        case .AcceptedElsewhere:
            callStatus = "AcceptedElsewhere"
            break;
        case .DeclinedElsewhere:
            callStatus = "DeclinedElsewhere"
            break;
        default:
            break;
        }
        return callStatus
    }
    
    func getRegistrationState(state: RegistrationState) -> String {
        var registrationState = ""
        switch state {
        case .None:
            registrationState = "None"
            break;
        case .Progress:
            registrationState = "Progress"
            break;
        case .Ok:
            registrationState = "Ok"
            break;
        case .Failed:
            registrationState = "Failed"
            break;
        case .Cleared:
            registrationState = "Cleared"
            break;
        case .Refreshing:
            registrationState = "Refreshing"
            break;
        default:
            break;
        }
        return registrationState
    }
}


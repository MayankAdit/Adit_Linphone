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
    var mProviderDelegate : IncomingCallKitDelegate!
    var callbackChannel: FlutterMethodChannel!
    var counter = 0
    var timer: Timer?
    
    init(registery: FlutterPluginRegistrar)
    {
        LoggingService.Instance.logLevel = LogLevel.Debug
        let factory = Factory.Instance
        let configDir = factory.getConfigDir(context: nil)
        try? mCore = factory.createCore(configPath: "\(configDir)/MyConfig", factoryConfigPath: "", systemContext: nil)
        
        mCore.callkitEnabled = true
        mCore.pushNotificationEnabled = true
        mProviderDelegate = IncomingCallKitDelegate(context: self)
        
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
            let callData = ["callId": call.callLog?.callId ?? "", "callerName": call.callLog?.fromAddress?.displayName ?? "", "state": "\(state)", "duration": call.callLog?.duration ?? 0, "direction": "\(call.dir)"]
            NSLog("Call state is \(state) callid : \( call.callLog?.callId ?? "")   message \(message)")
            if(call.dir == .Incoming){
                callbackChannel.invokeMethod(isCallEventChannel, arguments: callData)
            }else {
                channel?.invokeMethod(isCallEventChannel, arguments: callData)
            }
            incomingCallName = call.callLog?.fromAddress?.displayName ?? ""
            self.callMsg = message
            switch state {
            case .OutgoingInit:
                mProviderDelegate.startOutgoingCall(handle: remoteAddress)
                break;
            case .OutgoingProgress:
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
                break;
            case .StreamsRunning:
                break;
            case .Paused:
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
                    self.mProviderDelegate.incomingCall(callID: call.callLog?.callId ?? "") {}
                }
                self.remoteAddress = call.remoteAddress!.asStringUriOnly()
                break;
            case .Released:
                if(call.dir == .Outgoing){
                    self.isCallRunning = false
                }
                break;
            case .End:
                if(call.dir == .Incoming){
                    if (self.isCallRunning) {
                        self.mProviderDelegate.stopCall()
                        self.terminateCall()
                    }else {
                        if(call.callLog?.status == .Aborted){
                            self.mProviderDelegate.stopCall()
                            self.terminateCall()
                        }
                    }
                } else {
                    if (self.isCallRunning) {
                        self.terminateCall()
                        self.mProviderDelegate.stopCall()
                    }
                }
                self.remoteAddress = "Nobody yet"
                break;
            case .Error:
                self.terminateCall()
                self.mProviderDelegate.stopCall()
                break;
            default:
                break;
            }
        }, onAudioDeviceChanged: { (core: Core, device: AudioDevice) in
        }, onAudioDevicesListUpdated: { (core: Core) in
        }, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
            NSLog("New registration state is \(state) for user id \( String(describing: account.params?.identityAddress?.asString()))\n")
            self.channel?.invokeMethod(isRegistrationState, arguments: "\(state)")
            if (state == .Ok){
                self.loggedIn = true
            } else if (state == .Cleared){
                self.loggedIn = false
            } else if (state == .Failed){
                self.loggedIn = false
            }
        })
        mCore.addDelegate(delegate: mCoreDelegate)
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
            accountParams.registerEnabled = true
            accountParams.pushNotificationAllowed = true
            accountParams.pushNotificationConfig?.provider = "apns.dev"
            mCore.configureAudioSession()
            mAccount = try mCore.createAccount(params: accountParams)
            mCore.addAuthInfo(info: authInfo)
            try mCore.addAccount(account: mAccount!)
            mCore.defaultAccount = mAccount
        } catch { NSLog(error.localizedDescription) }
    }
    
    //// MARK:  - Unregister
    
    func unregister()
    {
        if let account = mCore.defaultAccount {
            let params = account.params
            let clonedParams = params?.clone()
            clonedParams?.registerEnabled = false
            account.params = clonedParams
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
    
    ///MARK:  - Terminate Ringing Call
    
    func terminateRingingCall() {
        do {
            if (mCore.callsNb == 0) { return }
            let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
            if let call = coreCall {
                try call.terminate()
            }
            if(mCall?.dir == .Incoming){
                callbackChannel?.invokeMethod(isRingingCallTerminate, arguments: nil)
            } else {
                channel?.invokeMethod(isRingingCallTerminate, arguments: nil)
            }
            
        } catch { NSLog(error.localizedDescription) }
    }
    
    ///MARK:  - Terminate Call
    
    func terminateCall() {
        do {
            try mCore.currentCall?.terminate()
        } catch { NSLog(error.localizedDescription) }
    }
    
    ///MARK:  -  Call accept
    
    func acceptCall() {
        do {
            try mCore.currentCall?.accept()
        } catch { NSLog(error.localizedDescription) }
    }
    
    ///MARK:  -  Mute the current active call
    func muteCall() {
        mCore.micEnabled = false
        if(mCall?.dir == .Incoming){
            callbackChannel?.invokeMethod(isMuteCallChannel, arguments: nil)
        } else {
            channel?.invokeMethod(isMuteCallChannel, arguments: nil)
        }
    }
    
    ///MARK:  - Unmute the current active call
    func unmuteCall() {
        mCore.micEnabled = true
        if(mCall?.dir == .Incoming){
            callbackChannel?.invokeMethod(isUnMuteCallChannel, arguments: nil)
        } else {
            channel?.invokeMethod(isUnMuteCallChannel, arguments: nil)
        }
    }
    
    ///MARK:  -  Speaker On and Off
    func toggleSpeaker() {
        let currentAudioDevice = mCore.currentCall?.outputAudioDevice
        let speakerEnabled = currentAudioDevice?.type == AudioDeviceType.Speaker
        for audioDevice in mCore.audioDevices {
            if (speakerEnabled && audioDevice.type == AudioDeviceType.Microphone) {
                mCore.currentCall?.outputAudioDevice = audioDevice
                isSpeakerEnabled = false
                if(mCall?.dir == .Incoming){
                    callbackChannel?.invokeMethod(isOffSpeakerChannel, arguments: nil)
                } else {
                    channel?.invokeMethod(isOffSpeakerChannel, arguments: nil)
                }
                return
            } else if (!speakerEnabled && audioDevice.type == AudioDeviceType.Speaker) {
                mCore.currentCall?.outputAudioDevice = audioDevice
                isSpeakerEnabled = true
                if(mCall?.dir == .Incoming){
                    callbackChannel?.invokeMethod(isOnSpeakerChannel, arguments: nil)
                } else {
                    channel?.invokeMethod(isOnSpeakerChannel, arguments: nil)
                }
                return
            }
        }
    }
    
    ///MARK:  - Outgoing call
    func outgoingCall() {
        do {
            let remoteAddress1 = try Factory.Instance.createAddress(addr: remoteAddress)
            let params = try mCore.createCallParams(call: nil)
            params.mediaEncryption = .None
            let _ = mCore.inviteAddressWithParams(addr: remoteAddress1, params: params)
        } catch { NSLog(error.localizedDescription) }
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
    
    //// send DTMF
    ///
    func sendDTMF(dtmf: String){
        do {
            if let cString = dtmf.cString(using: .utf8) {
              //  try mCore.currentCall?.sendDtmf(dtmf: cString)
            } else {
                print("Error converting DTMF tone to C-style string")
            }
        } catch { NSLog(error.localizedDescription) }
    }
}




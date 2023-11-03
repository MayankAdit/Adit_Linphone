package com.example.adit_lin_plugin.sip_manager

import SipConfiguration
import android.content.Context
import android.media.AudioAttributes
import android.util.Log
import com.example.adit_lin_plugin.AditLinPlugin
import com.example.adit_lin_plugin.utils.*
import io.flutter.plugin.common.MethodChannel.Result
import org.linphone.core.*
import java.text.SimpleDateFormat
import java.util.*


internal class SipManager private constructor(context: Context) {

    private var timeStartStreamingRunning: Long = 0
    private var isPause = false
    private var mCore: Core
    private val coreListener = object : CoreListenerStub() {

        override fun onAccountRegistrationStateChanged(
            core: Core,
            account: Account,
            state: RegistrationState?,
            message: String
        ) {
            sendEvent(
                EventAccountRegistrationStateChanged,
                "registrationState1" to (state?.name ?: ""),
                "message" to message
            )
        }

        // override fun onAudioDeviceChanged(core: Core, audioDevice: AudioDevice) {
        // val currentAudioDeviceType = core.currentCall?.outputAudioDevice?.type
        // if(currentAudioDeviceType != AudioDevice.Type.Speaker && currentAudioDeviceType != AudioDevice.Type.Earpiece) {
        // return
        // }
        // sendEvent("AudioDevicesChanged", createParams("audioOutputType" to currentAudioDeviceType.name))
        // }

        override fun onCallStateChanged(
            core: Core,
            call: Call,
            state: Call.State?,
            message: String
        ) {
            val extension: String = core.defaultAccount?.contactAddress?.username ?: ""
            val phoneNumber: String = call.remoteAddress.username ?: ""
            val callId: String = call.callLog.callId ?: ""
            val isHold: Boolean = call.state == Call.State.Paused
            val isMute: Boolean = call.microphoneMuted
            val isIncomingCall: Boolean = call.dir == Call.Dir.Incoming
            val isConnected: Boolean = call.state == Call.State.StreamsRunning
            val inProgress: Boolean =
                call.state == Call.State.OutgoingInit || call.state == Call.State.IncomingReceived
            val startTime: String = convertLongToTime(timeStartStreamingRunning)
            val callStatus: String = getCallState(call.state)


            when (state) {

                Call.State.IncomingReceived -> {
                    Log.d(TAG, "IncomingReceived")

                    sendEvent(
                        EventRing,
                        "callId" to callId,
                        "number" to phoneNumber,
                        "timer" to 0,
                        "isHold" to isHold,
                        "isMute" to isMute,
                        "isActive" to true,
                        "isIncoming" to isIncomingCall,
                        "isConnected" to isConnected,
                        "isProgress" to inProgress,
                        "startTime" to startTime,
                        "callState" to callStatus

                    )
                }
                Call.State.OutgoingInit -> {
                    // First state an outgoing call will go through
                    Log.d(TAG, "OutgoingInit")
                }
                Call.State.OutgoingProgress -> {
                    // First state an outgoing call will go through
                    Log.d(TAG, "OutgoingProgress")

                    sendEvent(
                        EventRing,
                        "callId" to callId,
                        "number" to phoneNumber,
                        "timer" to 0,
                        "isHold" to isHold,
                        "isMute" to isMute,
                        "isActive" to true,
                        "isIncoming" to isIncomingCall,
                        "isConnected" to isConnected,
                        "isProgress" to inProgress,
                        "startTime" to startTime,
                        "callState" to callStatus

                    )
                }
                Call.State.OutgoingRinging -> {
                    // Once remote accepts, ringing will commence (180 response)
                    Log.d(TAG, "OutgoingRinging")
                }
                Call.State.Connected -> {
                    Log.d(TAG, "Connected")
                }
                Call.State.StreamsRunning -> {
                    // This state indicates the call is active.
                    // You may reach this state multiple times, for example after a pause/resume
                    // or after the ICE negotiation completes
                    // Wait for the call to be connected before allowing a call update
                    Log.d(TAG, "StreamsRunning")
                    if (!isPause) {
                        timeStartStreamingRunning = System.currentTimeMillis()
                    }
                    isPause = false


                    sendEvent(
                        EventUp,
                        "callId" to callId,
                        "number" to phoneNumber,
                        "timer" to 0,
                        "isHold" to isHold,
                        "isMute" to isMute,
                        "isActive" to true,
                        "isIncoming" to isIncomingCall,
                        "isConnected" to isConnected,
                        "isProgress" to inProgress,
                        "startTime" to startTime,
                        "callState" to callStatus

                    )


                }
                Call.State.Paused -> {
                    Log.d(TAG, "Paused")
                    isPause = true
                    // sendEvent(EventPaused)

                    sendEvent(
                        EventPaused,
                        "callId" to callId,
                        "number" to phoneNumber,
                        "timer" to 0,
                        "isHold" to isHold,
                        "isMute" to isMute,
                        "isActive" to true,
                        "isIncoming" to isIncomingCall,
                        "isConnected" to isConnected,
                        "isProgress" to inProgress,
                        "startTime" to startTime,
                        "callState" to callStatus

                    )
                }
                Call.State.Resuming -> {
                    Log.d(TAG, "Resuming")
                    //sendEvent(EventResuming)

                    sendEvent(
                        EventResuming,
                        "callId" to callId,
                        "number" to phoneNumber,
                        "timer" to 0,
                        "isHold" to isHold,
                        "isMute" to isMute,
                        "isActive" to true,
                        "isIncoming" to isIncomingCall,
                        "isConnected" to isConnected,
                        "isProgress" to inProgress,
                        "startTime" to startTime,
                        "callState" to callStatus

                    )
                }
                Call.State.PausedByRemote -> {
                    Log.d(TAG, "PausedByRemote")

                }
                Call.State.Updating -> {
                    // When we request a call update, for example when toggling video
                    Log.d(TAG, "Updating")
                }
                Call.State.UpdatedByRemote -> {
                    Log.d(TAG, "UpdatedByRemote")
                }
                Call.State.Released -> {
                    if (isMissed(call.callLog)) {
                        Log.d(TAG, "Missed")
                        val callee = call.remoteAddress.username ?: ""
                        val totalMissed = core.missedCallsCount.toString()
                        sendEvent(
                            EventMissed,
                            "phoneNumber" to callee,
                            "totalMissed" to totalMissed
                        )
                    } else {
                        Log.d(TAG, "Released")
                        // val data = createParams(EventReleased)
                        // FlutterVoip24hSdkPlugin.eventSink?.success(data)
                    }
                }
                Call.State.End -> {
                    Log.d(TAG, "End")
                    val duration =
                        if (timeStartStreamingRunning == 0L) 0 else System.currentTimeMillis() - timeStartStreamingRunning
                    //sendEvent(EventHangup, "duration" to duration)
                    timeStartStreamingRunning = 0

                    sendEvent(
                        EventHangup,
                        "callId" to callId,
                        "number" to phoneNumber,
                        "timer" to 0,
                        "isHold" to isHold,
                        "isMute" to isMute,
                        "isActive" to true,
                        "isIncoming" to isIncomingCall,
                        "isConnected" to isConnected,
                        "isProgress" to inProgress,
                        "startTime" to startTime,
                        "callState" to callStatus

                    )
                }
                Call.State.Error -> {
                    Log.d(TAG, "Error")
                    // sendEvent(EventError, "message" to message)

                    sendEvent(
                        EventError,
                        "callId" to callId,
                        "number" to phoneNumber,
                        "timer" to 0,
                        "isHold" to isHold,
                        "isMute" to isMute,
                        "isActive" to true,
                        "isIncoming" to isIncomingCall,
                        "isConnected" to isConnected,
                        "isProgress" to inProgress,
                        "startTime" to startTime,
                        "callState" to callStatus

                    )
                }
                else -> {
                    // Log.d(TAG, "Nothing " + state?.name.toString())
                }
            }
        }
    }

    fun convertLongToTime(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("HH:mm:ss")
        return format.format(date)
    }

    fun getCallState(state: Call.State): String {
        var callStatus = ""
        when (state) {
            Call.State.Idle -> {
                callStatus = "CALL_INITIATION"
            }
            Call.State.IncomingReceived -> {
                callStatus = "PROGRESS"
            }
            Call.State.PushIncomingReceived -> ""
            Call.State.OutgoingInit -> ""
            Call.State.OutgoingProgress -> {
                callStatus = "PROGRESS"
            }
            Call.State.OutgoingRinging -> ""
            Call.State.OutgoingEarlyMedia -> ""
            Call.State.Connected -> {
                callStatus = "ACCEPTED"
            }
            Call.State.StreamsRunning -> {
                callStatus = "CONFIRMED"
            }
            Call.State.Pausing -> ""
            Call.State.Paused -> ""
            Call.State.Resuming -> ""
            Call.State.Referred -> ""
            Call.State.Error -> ""
            Call.State.End -> {
                callStatus = "ENDED"
            }
            Call.State.PausedByRemote -> ""
            Call.State.UpdatedByRemote -> ""
            Call.State.IncomingEarlyMedia -> ""
            Call.State.Updating -> ""
            Call.State.Released -> ""
            Call.State.EarlyUpdatedByRemote -> ""
            Call.State.EarlyUpdating -> ""
            else -> {
                ""
            }
        }

        return callStatus;


    }


    private fun sendEvent(event: String, vararg params: Pair<String, Any>) {
        val data = createParams(event, *params)
        AditLinPlugin.eventSink?.success(data)
    }

    init {
        val factory = Factory.instance()
        mCore = factory.createCore(null, null, context)
    }

    fun initSipModule(sipConfiguration: SipConfiguration) {
        //mCore.isKeepAliveEnabled = sipConfiguration.isKeepAlive //= sipConfiguration.isKeepAlive
        mCore.start()
        mCore.removeListener(coreListener)
        mCore.addListener(coreListener)
        initSipAccount(
            sipConfiguration.extension,
            sipConfiguration.password,
            sipConfiguration.domain,
            sipConfiguration.port
        )
    }

    private fun initSipAccount(
        ext: String,
        password: String,
        domain: String,
        port: Int
    ) {
        // To configure a SIP account, we need an Account object and an AuthInfo object
        // The first one is how to connect to the proxy server, the second one stores the credentials

        // The auth info can be created from the Factory as it's only a data class
        // userID is set to null as it's the same as the username in our case
        // ha1 is set to null as we are using the clear text password. Upon first register, the hash will be computed automatically.
        // The realm will be determined automatically from the first register, as well as the algorithm
        val authInfo =
            Factory.instance().createAuthInfo(ext, null, password, null, null, domain, null)

        // Account object replaces deprecated ProxyConfig object
        // Account object is configured through an AccountParams object that we can obtain from the Core
        val accountParams = mCore.createAccountParams()


        var natPolicy = mCore.createNatPolicy()
        natPolicy?.stunServer = "stun.linphone.org"
        natPolicy?.isIceEnabled = true
        natPolicy?.isStunEnabled = true
        natPolicy?.isTurnEnabled = false
        natPolicy?.isUpnpEnabled = true
        natPolicy?.resolveStunServer()
        natPolicy?.isUdpTurnTransportEnabled = true
        mCore.natPolicy = natPolicy
        mCore.isIpv6Enabled = true

        if (mCore.hasBuiltinEchoCanceller()) {
            Log.d(TAG, "Device has built in echo canceler, disabling software echo canceler");
            mCore.isEchoCancellationEnabled = false
        } else {
            mCore.isEchoCancellationEnabled = true
        }
        mCore.isGenericComfortNoiseEnabled = true
        mCore.isMicEnabled = true
        mCore.isAdaptiveRateControlEnabled = true


        // A SIP account is identified by an identity address that we can construct from the username and domain
        val identity = Factory.instance().createAddress("sip:$ext@$domain")
        accountParams.identityAddress = identity
        // We also need to configure where the proxy server is located
        val address = Factory.instance().createAddress("sip:$domain")
        // We use the Address object to easily set the transport protocol
        address?.transport = TransportType.Udp
        //address?.port = port
        accountParams.serverAddress = address
        // And we ensure the account will start the registration process
        accountParams.isRegisterEnabled = true

        // Now that our AccountParams is configured, we can create the Account object
        val account = mCore.createAccount(accountParams)
        // Now let's add our objects to the Core
        mCore.addAuthInfo(authInfo)
        mCore.addAccount(account)
        // mCore.mediastreamerFactory.setDeviceInfo();
        //mCore.sessionExpiresEnabled
        AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)

        // Also set the newly added account as default
        mCore.defaultAccount = account
    }

    fun answer(result: Result) {
        Log.d(TAG, "Try to accept call")
        try {
            val currentCall = mCore.currentCall
            if (currentCall == null) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }


            if (mCore.hasBuiltinEchoCanceller()) {
                Log.d(TAG, "Device has built in echo canceler, disabling software echo canceler");
                currentCall.isEchoCancellationEnabled = false
            } else {
                currentCall.isEchoCancellationEnabled = true
            }


            AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_MEDIA)
            currentCall.accept()
            currentCall.microphoneMuted = false




            // result.success("Answer successful")
            result.success(true)
        } catch (e: Exception) {
            // Log.d(TAG, e.message.toString())
            result.error("500", e.message.toString(), null)
        }
    }

    fun reject(result: Result) {
        Log.d(TAG, "Try to accept call")
        try {
            val currentCall = mCore.currentCall
            if (currentCall == null) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }


            currentCall.terminate()
            Log.d(TAG, "Reject successful")
            result.success(true)
            // result.success("Reject successful")
        } catch (e: Exception) {
            // Log.d(TAG, e.message.toString())
            result.error("500", e.message.toString(), null)
        }
    }

    fun call(recipient: String, result: Result) {
        Log.d(TAG, "Try to call")
        // As for everything we need to get the SIP URI of the remote and convert it to an Address
        val domain = mCore.defaultAccount?.params?.domain
        if (domain == null) {
            Log.d(TAG, "Can't create sip uri")
            // result.error("404", "Can't create sip uri", null)
            return result.success(false)
        }
        val remoteAddress = Factory.instance().createAddress("sip:$recipient@$domain")
        if (remoteAddress == null) {
            Log.d(TAG, "Invalid SIP URI")
            // result.error("404", "Invalid SIP URI", null)
            return result.success(false)
        } else {
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            val params = mCore.createCallParams(null)
            if (params == null) {
                Log.d(TAG, "Something went wrong")
                return result.success(false)
            }

            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            // If we wanted to start the call with video directly
            //params.enableVideo(true)

            // Finally we start the call
            mCore.inviteAddressWithParams(remoteAddress, params)
            // result.success("Call successful")
            Log.d(TAG, "Call successful")
            result.success(true)
        }
    }

    fun hangup(result: Result) {
        Log.d(TAG, "Trying to hang up")
        try {
            if (mCore.callsNb == 0) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            val coreCall = mCore.currentCall ?: mCore.calls.firstOrNull()
            if (coreCall == null) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            coreCall.terminate()
            Log.d(TAG, "Hangup successful")
            result.success(true)
            // result.success("Hangup successful")
        } catch (e: Exception) {
            Log.d(TAG, e.message.toString())
            result.error("500", e.message.toString(), null)
        }
    }

    fun pause(result: Result) {
        Log.d(TAG, "Try to pause")
        try {
            if (mCore.callsNb == 0) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            val coreCall = mCore.currentCall ?: mCore.calls.firstOrNull()
            if (coreCall == null) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            coreCall.pause()
            Log.d(TAG, "Pause successful")
            result.success(true)
            // result.success("Pause successful")
        } catch (e: Exception) {
            Log.d(TAG, e.message.toString())
            result.error("500", e.message.toString(), null)
        }
    }

    fun resume(result: Result) {
        Log.d(TAG, "Try to resume")
        try {
            if (mCore.callsNb == 0) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            val coreCall = mCore.currentCall ?: mCore.calls.firstOrNull()

            if (coreCall == null) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            coreCall.resume()
            Log.d(TAG, "Resume successful")
            result.success(true)
            // result.success("Resume successful")
        } catch (e: Exception) {
            Log.d(TAG, e.message.toString())
            result.error("500", e.message.toString(), null)
        }
    }

    fun transfer(recipient: String, result: Result) {
        Log.d(TAG, "Try to transfer")
        try {
            if (mCore.callsNb == 0) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            val domain = mCore.defaultAccount?.params?.domain
            // Log.d(TAG, "Domain: $domain")
            if (domain == null) {
                Log.d(TAG, "Can't create sip uri")
                // result.error("404", "Can't create sip uri", null)
                return result.success(false)
            }
            val address = mCore.interpretUrl("sip:$recipient@$domain") ?: return
            val coreCall = mCore.currentCall ?: mCore.calls.firstOrNull()
            if (coreCall == null) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            coreCall.transferTo(address)
            Log.d(TAG, "Transfer successful")
            result.success(true)
            // result.success("Transfer successful")
        } catch (e: Exception) {
            Log.d(TAG, e.message.toString())
            result.error("500", e.message.toString(), null)
        }
    }

    fun sendDTMF(dtmf: String, result: Result) {
        try {
            val coreCall = mCore.currentCall
            if (coreCall == null) {
                Log.d(TAG, "Current call not found")
                return result.success(false)
            }
            coreCall.sendDtmf(dtmf.first())
            Log.d(TAG, "Send DTMF successful")
            result.success(true)
            // result.success("Send DTMF successful")
        } catch (e: Exception) {
            Log.d(TAG, e.message.toString())
            result.error("500", e.message.toString(), null)
        }
    }

    fun toggleSpeaker(result: Result) {
        val coreCall =
            mCore.currentCall ?: return result.error("404", "Current call not found", null)
        val currentAudioDevice = coreCall.outputAudioDevice
        val speakerEnabled = currentAudioDevice?.type == AudioDevice.Type.Speaker

        for (audioDevice in mCore.audioDevices) {
            if (speakerEnabled && audioDevice.type == AudioDevice.Type.Earpiece) {
                coreCall.outputAudioDevice = audioDevice
                return result.success(false)
            } else if (!speakerEnabled && audioDevice.type == AudioDevice.Type.Speaker) {
                coreCall.outputAudioDevice = audioDevice
                return result.success(true)
            }
        }

    }

    fun toggleMic(result: Result) {
        if (mCore.currentCall == null) {
            return result.error("404", "Current call not found", null)
        } else {
            print("toggleMic")
        }

        mCore.isMicEnabled = !mCore.isMicEnabled
        result.success(mCore.isMicEnabled)
    }

    fun refreshSipAccount(result: Result) {
        mCore.refreshRegisters()
        result.success(true)
    }

    fun unregisterSipAccount(result: Result) {
        // Here we will disable the registration of our Account
        val account = mCore.defaultAccount
        if (account == null) {
            Log.d(TAG, "Sip account not found")
            return result.success(false)
            // return result.error("404", "Sip account not found", null)
        }
        val params = account.params
        // Returned params object is const, so to make changes we first need to clone it
        val clonedParams = params.clone()
        // Now let's make our changes
        clonedParams.isRegisterEnabled = false
        // And apply them
        account.params = clonedParams
        mCore.clearProxyConfig()
        deleteSipAccount()
        result.success(true)
    }

    private fun deleteSipAccount() {
        // To completely remove an Account
        val account = mCore.defaultAccount
        account ?: return
        mCore.removeAccount(account)
        // To remove all accounts use
        mCore.clearAccounts()
        // Same for auth info
        mCore.clearAllAuthInfo()
    }

    fun getCallId(result: Result) {
        mCore.currentCall?.callLog?.callId?.let {
            result.success(it)
        } ?: kotlin.run {
            result.error("404", "Call ID not found", null)
        }
    }

    fun getMissedCalls(result: Result) {
        result.success(mCore.missedCallsCount)
    }

    fun getSipRegistrationState(result: Result) {
        mCore.defaultAccount?.state?.name?.let {
            result.success(it)
        } ?: kotlin.run {
            result.error("404", "Register state not found", null)
        }
    }

    fun isMicEnabled(result: Result) {
        result.success(mCore.isMicEnabled)
    }

    fun isSpeakerEnabled(result: Result) {
        val currentAudioDevice = mCore.currentCall?.outputAudioDevice
        val speakerEnabled = currentAudioDevice?.type == AudioDevice.Type.Speaker
        result.success(speakerEnabled)
    }

    // fun removeListener() {
    // mCore.removeListener(coreListener)
    // }

    private fun isMissed(callLog: CallLog?): Boolean {
        return (callLog?.dir == Call.Dir.Incoming && callLog.status == Call.Status.Missed)
    }

    private fun createParams(
        event: String,
        vararg params: Pair<String, Any>
    ): Map<String, Any> {
        return mapOf("event" to event, "body" to params.toMap())
    }

    companion object {

        private const val TAG = "SipManager"
        private var INSTANCE: SipManager? = null

        fun getInstance(context: Context): SipManager {
            return INSTANCE ?: synchronized(SipManager::class.java) {
                INSTANCE ?: SipManager(context).also {
                    INSTANCE = it
                }
            }
        }
    }
}
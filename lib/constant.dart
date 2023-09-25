class AppTexts {
  static const String aditLinPlugin = "adit_lin_plugin";
  static const String isLoginChannel = "isLoginChannel";
  static const String isRegistrationState = "isRegistrationState";
  static const String isOutgoingChannel = "isOutgoingChannel";
  static const String isCallEventChannel = "isCallEventChannel";
  static const String isRingingCallTerminate = "isRingingCallTerminate";
  static const String isAcceptCallChannel = "isAcceptCallChannel";
  static const String isHoldAndUnhold = "isHoldAndUnhold";
  static const String isStartCallChannel = "isStartCallChannel";
  static const String isMuteCallChannel = "isMuteCallChannel";
  static const String isUnMuteCallChannel = "isUnMuteCallChannel";
  static const String isHungUpChannel = "isHungUpChannel";
  static const String isSpeakerChannel = "isSpeakerChannel";
  static const String isOnSpeakerChannel = "isOnSpeakerChannel";
  static const String isOffSpeakerChannel = "isOffSpeakerChannel";
  static const String isAlreadyLogin = "isAlreadyLogin";
  static const String isPausedChannel = "isPausedChannel";
  static const String isResumChannel = "isResumChannel";

  /// Initial state for registrations.
  static const String none = "None";

  /// Registration is in progress.
  static const String progress = "Progress";

  /// Registration is successful.
  static const String ok = "Ok";

  /// Unregistration succeeded.
  static const String cleared = "Cleared";

  /// Registration failed.
  static const String failed = "Failed";

  /// Initial state.
  static const String idle = "Idle";

  /// Incoming call received.
  static const String incomingReceived = "IncomingReceived";

  /// PushIncoming call received.
  static const String pushIncomingReceived = "PushIncomingReceived";

  /// Outgoing call initialized.
  static const String outgoingInit = "OutgoingInit";

  /// Outgoing call in progress.
  static const String outgoingProgress = "OutgoingProgress";

  /// Outgoing call ringing.
  static const String outgoingRinging = "OutgoingRinging";

  /// Outgoing call early media.
  static const String outgoingEarlyMedia = "OutgoingEarlyMedia";

  /// Connected.
  static const String connected = "Connected";

  /// Streams running.
  static const String streamsRunning = "StreamsRunning";

  /// Pausing.
  static const String pausing = "Pausing";

  /// Paused.
  static const String paused = "Paused";

  /// Resuming.
  static const String resuming = "Resuming";

  /// Referred.
  static const String referred = "Referred";

  /// Error.
  static const String error = "Error";

  /// Call end.
  static const String end = "End";

  /// Paused by remote.
  static const String pausedByRemote = "PausedByRemote";

  /// The call's parameters are updated for example when video is asked by remote.
  static const String updatedByRemote = "UpdatedByRemote";

  /// We are proposing early media to an incoming call.
  static const String incomingEarlyMedia = "IncomingEarlyMedia";

  /// We have initiated a call update.
  static const String updating = "Updating";

  /// The call object is now released.
  static const String released = "Released";

  /// The call is updated by remote while not yet answered (SIP UPDATE in early
  /// dialog received)
  static const String earlyUpdatedByRemote = "EarlyUpdatedByRemote";

  /// We are updating the call while not yet answered (SIP UPDATE in early dialog
  /// sent)
  static const String earlyUpdating = "EarlyUpdating";
}

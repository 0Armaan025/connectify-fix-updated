import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(VoiceCallView());

// Fill in the app ID obtained from the Agora Console
const appId = "798f4dfa077544069c03c0a2e75e76e3";
// Fill in the temporary token generated from Agora Console
const token =
    "007eJxTYJCXOdWsMf/4Lo5o14rt961tlly8/G/zZZ+MvydMN4v/+SKowGBuaZFmkpKWaGBubmpiYmBmmWxgnGyQaJRqbppqbpZqPGVNWXpDICNDqbUcKyMDBIL4PAzJiTk58ckZiXl5qTkMDAC6jyNp";
// Fill in the channel name you used to generate the token
const channel = "call_channel";

// Application class
class VoiceCallView extends StatefulWidget {
  const VoiceCallView({Key? key}) : super(key: key);

  @override
  _VoiceCallViewState createState() => _VoiceCallViewState();
}

// Application state class
class _VoiceCallViewState extends State<VoiceCallView> {
  int? _remoteUid; // The UID of the remote user
  bool _localUserJoined =
      false; // Indicates whether the local user has joined the channel
  late RtcEngine _engine; // The RtcEngine instances

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    // Get microphone and camera permissions
    await [Permission.microphone, Permission.camera].request();

    // Create RtcEngine instance
    _engine = await createAgoraRtcEngine();

    // Initialize RtcEngine and set the channel profile to live broadcasting
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    // Add an event handler
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        // Occurs when the local user joins the channel successfully
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint(
              'local user ' + connection.localUid.toString() + ' joined');
          setState(() {
            _localUserJoined = true;
          });
        },
        // Occurs when a remote user join the channel
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        // Occurs when a remote user leaves the channel
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );
    // Enable the video module
    await _engine.enableVideo();
    // Enable local video preview
    await _engine.startPreview();
    // Join a channel using a temporary token and channel name
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      options: const ChannelMediaOptions(
          // Automatically subscribe to all video streams
          autoSubscribeVideo: true,
          // Automatically subscribe to all audio streams
          autoSubscribeAudio: true,
          // Publish camera video
          publishCameraTrack: true,
          // Publish microphone audio
          publishMicrophoneTrack: true,
          // Set user role to clientRoleBroadcaster (broadcaster) or clientRoleAudience (audience)
          clientRoleType: ClientRoleType.clientRoleBroadcaster),
      uid:
          0, // When you set uid to 0, a user name is randomly generated by the engine
    );
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  Future<void> _dispose() async {
    // Leave the channel
    await _engine.leaveChannel();
    // Release resources
    await _engine.release();
  }

  // Build the UI to display local and remote videos
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agora Video Call'),
        ),
        body: Stack(
          children: [
            Center(
              child: _remoteVideo(),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 100,
                height: 150,
                child: Center(
                  child: _localUserJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: _engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget to display remote video
  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: channel),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }
}
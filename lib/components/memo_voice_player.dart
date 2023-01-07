import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

const s3BaseUrl = "https://explify.s3.amazonaws.com/";

Mixpanel _mixpanel;

Future<void> _initMixpanel() async {
  _mixpanel = await MixpanelManager.init();
}

class MemoPlayerWidget extends StatefulWidget {
  final String url;

  MemoPlayerWidget({
    this.url,
  });

  @override
  _MemoPlayerWidgetState createState() => _MemoPlayerWidgetState();
}

class _MemoPlayerWidgetState extends State<MemoPlayerWidget> {
  @override
  void initState() {
    super.initState();
    _init();
    _initMixpanel();
  }

  final AudioPlayer _player = AudioPlayer();
  String localUrl;

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  @override
  void dispose() {
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ControlButtons(_player, widget.url);
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatefulWidget {
  final AudioPlayer player;
  final String url;

  ControlButtons(this.player, this.url);

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  @override
  Widget build(BuildContext context) {
    bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return StreamBuilder<PlayerState>(
      stream: widget.player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            // margin: EdgeInsets.all(14.0),
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.grey[200],
              strokeWidth: 3,
            ),
          );
        } else if (playing != true) {
          return IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.play_arrow),
            iconSize: 40,
            color: Colors.white,
            onPressed: () async {
              //if ios - set player to play from net, else get file from cache
              if (isIOS) {
                final audioSource =
                    LockCachingAudioSource(Uri.parse(s3BaseUrl + widget.url));
                widget.player.setAudioSource(audioSource);
              } else {
                final file = await DefaultCacheManager()
                    .getSingleFile(s3BaseUrl + widget.url);

                widget.player.setFilePath(file.path);
              }
              widget.player.play();
              _mixpanel.track("Play pressed");
            },
          );
        } else if (processingState != ProcessingState.completed) {
          return IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.pause),
            color: Colors.white,
            iconSize: 40,
            onPressed: () {
              widget.player.pause();
            },
          );
        } else {
          return IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(Icons.play_arrow),
            iconSize: 40,
            color: Colors.white,
            onPressed: () => widget.player.seek(Duration.zero),
          );
        }
      },
    );
  }
}

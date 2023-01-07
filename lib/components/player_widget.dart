import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../just_audio/common.dart';
import 'package:rxdart/rxdart.dart';
import 'package:unsplash_client/unsplash_client.dart';
import '../analytics.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

const s3BaseUrl = "https://explify.s3.amazonaws.com/";

Mixpanel _mixpanel;

Future<void> _initMixpanel() async {
  _mixpanel = await MixpanelManager.init();
}

class AudioTag {
  final String title;
  final String blockId;
  final String type;
  final String page;
  final String text;
  AudioTag(this.title, this.page, this.blockId, this.type, this.text);
}

class PlayerWidget extends StatefulWidget {
  final int index;
  final Map<String, dynamic> post;
  bool expanded = false;

  PlayerWidget({
    this.post,
    this.index,
    this.expanded,
  });

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  final AudioPlayer _player = AudioPlayer();
  final client = UnsplashClient(
    settings: ClientSettings(
        credentials: AppCredentials(
      accessKey: 'nYPzKjS6ExBKz9vKsJPoHQHjpiBklLzALcs2MCMu3uw',
      secretKey: 'cEXosTTff8JiQD0cDoR-QtpBIHhSKCd0s6kSG53vB4Y',
    )),
  );
  String photoUrl;
  List<AudioSource> playlist;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
    _initMixpanel();
  }

  Future<void> _init() async {
    playlist = [];
    widget.post["text"].forEach((block) {
      playlist.add(AudioSource.uri(
          Uri.parse(s3BaseUrl +
              widget.post["userUid"] +
              "/" +
              widget.post["pageId"] +
              "-" +
              block["id"].toString() +
              "-source" +
              ".mp3"),
          tag: AudioTag(widget.post["title"], widget.post["page"].toString(),
              block["id"].toString(), "source", block["text"])));
      playlist.add(AudioSource.uri(
          Uri.parse(s3BaseUrl +
              widget.post["userUid"] +
              "/" +
              widget.post["pageId"] +
              "-" +
              block["id"].toString() +
              "-simplified" +
              ".mp3"),
          tag: AudioTag(widget.post["title"], widget.post["page"].toString(),
              block["id"].toString(), "simplified", block["text"])));
    });

    final _playlist = ConcatenatingAudioSource(children: playlist);

    // print(playlist);

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });

    // Try to load audio from a source and catch any errors.
    try {
      // print("https://explify.s3.amazonaws.com/" +
      //     widget.post["pageId"] +
      //     "-" +
      //     widget.index.toString() +
      //     "-" +
      //     ".mp3");
      // await _player.setAudioSource(AudioSource.uri(Uri.parse(playlist[0]["url"])));
      _player.setAudioSource(_playlist);
      // _player.play(); //play on start
      final photos = await client.search
          .photos(widget.post["title"], page: widget.index, perPage: 1)
          .goAndGet();
      //random(count: 1).goAndGet();
      print("photos");
      print(photos);
      setState(() {
        photoUrl = photos.results.first.urls.small.toString();
        // photoUrl = photos.first.urls.small.toString();
      });
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    // Release decoders and buffers back to the operating system making them
    // available for other apps to use.
    _player.dispose();
    client.close();
    super.dispose();
  }

  /// Collects the data useful for displaying in a seek bar, using a handy
  /// feature of rx_dart to combine the 3 streams of interest into one.
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFdddbc7)),
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFCFCCAD)),
      home: Scaffold(
        body: widget.expanded
            ? Column(
                children: [
                  Container(
                      height: 150,
                      width: double.infinity,
                      child: photoUrl != null
                          ? Image.network(photoUrl, fit: BoxFit.cover)
                          : Container(
                              height: 150,
                              // width: 400,
                            )),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Center(
                        //     child: Padding(
                        //   padding: const EdgeInsets.only(bottom: 8.0),
                        //   child: StreamBuilder<SequenceState>(
                        //     stream: _player.sequenceStateStream,
                        //     builder: (context, snapshot) {
                        //       final state = snapshot.data;
                        //       if (state == null || state?.sequence.isEmpty ??
                        //           true) return SizedBox();
                        //       final tag = state.currentSource.tag;
                        //       return Padding(
                        //         padding:
                        //             const EdgeInsets.only(left: 12, right: 12),
                        //         child: Column(
                        //             crossAxisAlignment:
                        //                 CrossAxisAlignment.center,
                        //             children: [
                        //               Text(tag.title + ", page " + tag.page,
                        //                   overflow: TextOverflow.fade,
                        //                   maxLines: 1,
                        //                   style: TextStyle(
                        //                       fontWeight: FontWeight.bold)),
                        //               Text(
                        //                 tag.type == "simplified"
                        //                     ? "Simplified: " + tag.text
                        //                     : tag.text,
                        //                 maxLines: 1,
                        //                 overflow: TextOverflow.ellipsis,
                        //               ),
                        //             ]),
                        //       );
                        //     },
                        //   ),
                        // )),
                        // Display play/pause button and volume/speed sliders.
                        ControlButtons(_player, widget.expanded),
                        // Display seek bar. Using StreamBuilder, this widget rebuilds
                        // each time the position, buffered position or duration changes.
                        StreamBuilder<PositionData>(
                          stream: _positionDataStream,
                          builder: (context, snapshot) {
                            final positionData = snapshot.data;
                            return SeekBar(
                              duration: positionData?.duration ?? Duration.zero,
                              position: positionData?.position ?? Duration.zero,
                              bufferedPosition:
                                  positionData?.bufferedPosition ??
                                      Duration.zero,
                              onChangeEnd: _player.seek,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Container(
                height: 60,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Center(
                    //     child: Padding(
                    //   padding: const EdgeInsets.only(bottom: 0),
                    //   child: Text("Page " +
                    //       widget.post["page"] +
                    //       ". " +
                    //       widget.post["title"].trim() +
                    //       "."),
                    // )),
                    // Display play/pause button and volume/speed sliders.
                    Container(
                        height: 60,
                        width: 100,
                        child: photoUrl != null
                            ? Image.network(photoUrl, fit: BoxFit.cover)
                            : Container(
                                height: 60,
                                width: 100,
                              )),
                    StreamBuilder<SequenceState>(
                      stream: _player.sequenceStateStream,
                      builder: (context, snapshot) {
                        final state = snapshot.data;
                        if (state == null || state?.sequence.isEmpty ?? true)
                          return SizedBox();
                        final tag = state.currentSource.tag;
                        return Container(
                          width: MediaQuery.of(context).size.width - 150,
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            tag.type == "simplified"
                                ? "Simplified: " + tag.text
                                : tag.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                    Spacer(),
                    ControlButtons(_player, widget.expanded),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Displays the play/pause button and volume/speed sliders.
class ControlButtons extends StatefulWidget {
  final AudioPlayer player;
  bool expanded;

  ControlButtons(this.player, this.expanded);

  @override
  _ControlButtonsState createState() => _ControlButtonsState();
}

class _ControlButtonsState extends State<ControlButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Opens volume slider dialog
        widget.expanded
            ? IconButton(
                icon: Icon(Icons.volume_up),
                onPressed: () {
                  showSliderDialog(
                    context: context,
                    title: "Adjust volume",
                    divisions: 10,
                    min: 0.0,
                    max: 1.0,
                    value: widget.player.volume,
                    stream: widget.player.volumeStream,
                    onChanged: widget.player.setVolume,
                  );
                },
              )
            : Container(),

        /// This StreamBuilder rebuilds whenever the player state changes, which
        /// includes the playing/paused state and also the
        /// loading/buffering/ready state. Depending on the state we show the
        /// appropriate button or loading indicator.

        widget.expanded
            ? StreamBuilder<SequenceState>(
                stream: widget.player.sequenceStateStream,
                builder: (context, snapshot) => IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: widget.player.hasPrevious
                      ? widget.player.seekToPrevious
                      : null,
                ),
              )
            : SizedBox(),

        StreamBuilder<PlayerState>(
          stream: widget.player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: EdgeInsets.all(8.0),
                width: widget.expanded ? 64 : 32,
                height: widget.expanded ? 64 : 32,
                child: CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: Icon(Icons.play_arrow),
                iconSize: widget.expanded ? 64 : 32,
                color: Colors.grey[800],
                onPressed: () {
                  widget.player.play();
                  _mixpanel.track("Play pressed");
                },
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: Icon(Icons.pause),
                iconSize: widget.expanded ? 64 : 32,
                onPressed: () {
                  widget.player.pause();
                  // _mixpanel.track("Pause pressed");
                },
              );
            } else {
              return IconButton(
                icon: Icon(Icons.replay),
                iconSize: widget.expanded ? 64 : 32,
                onPressed: () => widget.player.seek(Duration.zero),
              );
            }
          },
        ),
        widget.expanded
            ? StreamBuilder<SequenceState>(
                stream: widget.player.sequenceStateStream,
                builder: (context, snapshot) => IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: widget.player.hasNext
                      ? () {
                          widget.player.seekToNext();
                          _mixpanel.track("Next track pressed");
                        }
                      : null,
                ),
              )
            : SizedBox(),
        // Opens speed slider dialog
        widget.expanded
            ? StreamBuilder<double>(
                stream: widget.player.speedStream,
                builder: (context, snapshot) => IconButton(
                  icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    _mixpanel.track(
                      "Player speed changed",
                    );
                    showSliderDialog(
                      context: context,
                      title: "Adjust speed",
                      divisions: 10,
                      min: 0.5,
                      max: 1.5,
                      value: widget.player.speed,
                      stream: widget.player.speedStream,
                      onChanged: widget.player.setSpeed,
                    );
                  },
                ),
              )
            : Container(),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/foundation.dart';

class MusicApp extends StatefulWidget {
  const MusicApp({super.key, required this.title});
  final String title;
  @override
  State<MusicApp> createState() => _MusicAppState();
}

class _MusicAppState extends State<MusicApp> {
  //define on audio plugin

  //define on audio plugin
  //  Interface and Main method for use on_audio_query
  final OnAudioQuery _audioQuery = OnAudioQuery();

  //An object to manage playing audio from a URL, a locale file or an asset.(just_audio)
  final AudioPlayer _player = AudioPlayer();

  List<SongModel> songs =
      []; //[SongModel] that contains all [Song] Information.(audio_query)
  String currentSongTitle = '';
  int currentIndex = 0;

  bool isPlayerViewVisible = false;

  //define a method to set the player view visibility
  void _changePlayerViewVisibility() {
    setState(() {
      isPlayerViewVisible = !isPlayerViewVisible;
    });
  }

  //duration state stream
  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _player.positionStream,
          _player.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));

  //request permission from initStateMethod
  @override
  void initState() {
    super.initState();
    requestStoragePermission();

    //update the current playing song index listener
    // _player.currentIndexStream ==> A stream broadcasting the current item.(Audio player)
    _player.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }
    });
  }

  //dispose the player when done.
  //(Called when this object is removed from the tree permanently.)
  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void requestStoragePermission() async {
    //only if the platform is not web, coz web have no permissions
    if (!kIsWeb) {
      bool permissionStatus = await _audioQuery.permissionsStatus();
      if (!permissionStatus) {
        await _audioQuery.permissionsRequest();
      }

      //ensure build method is called
      setState(() {});
    }
  }

  //create playlist
  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  //update playing song details
  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTitle = songs[index].title;
        currentIndex = index;
      }
    });
  }

  // int count = 1;
  @override
  Widget build(BuildContext context) {
    //if play mode on 

     if (isPlayerViewVisible) {
      return Scaffold(
        backgroundColor: Colors.pink.withOpacity(0.4),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 56.0, right: 20.0, left: 20.0),
            // decoration: BoxDecoration(color: bgColor),
            child: Column(
              children: <Widget>[
                //exit button and the song title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                      child: InkWell(
                        onTap:
                            _changePlayerViewVisibility, //hides the player view
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          // decoration: getDecoration(
                              // BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      child: Text(
                        currentSongTitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),

                //artwork container
                Container(
                  width: 300,
                  height: 300,
                  // decoration: getDecoration(
                      // BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                  margin: const EdgeInsets.only(top: 30, bottom: 30),
                  child: QueryArtworkWidget(
                    id: songs[currentIndex].id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(200.0),
                  ),
                ),

                //slider , position and duration widgets
                Column(
                  children: [
                    //slider bar container
                    Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 4.0),
                      // decoration: getRectDecoration(BorderRadius.circular(20.0),
                          // const Offset(2, 2), 2.0, 0.0),

                      //slider bar duration state stream
                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress =
                              durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;

                          return ProgressBar(
                            progress: progress,
                            total: total,
                            barHeight: 20.0,
                            // baseBarColor: bgColor,
                            progressBarColor: const Color(0xEE9E9E9E),
                            thumbColor: Colors.white60.withBlue(99),
                            timeLabelTextStyle: const TextStyle(
                              fontSize: 0,
                            ),
                            onSeek: (duration) {
                              _player.seek(duration);
                            },
                          );
                        },
                      ),
                    ),

                    //position /progress and total text
                    StreamBuilder<DurationState>(
                      stream: _durationStateStream,
                      builder: (context, snapshot) {
                        final durationState = snapshot.data;
                        final progress =
                            durationState?.position ?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                              child: Text(
                                progress.toString().split(".")[0],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                total.toString().split(".")[0],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),

                //prev, play/pause & seek next control buttons
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //skip to previous
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            if (_player.hasPrevious) {
                              _player.seekToPrevious();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            // decoration: getDecoration(
                                // BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: const Icon(
                              Icons.skip_previous,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      //play pause
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            if (_player.playing) {
                              _player.pause();
                            } else {
                              if (_player.currentIndex != null) {
                                _player.play();
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            margin:
                                const EdgeInsets.only(right: 20.0, left: 20.0),
                            // decoration: getDecoration(
                                // BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: StreamBuilder<bool>(
                              stream: _player.playingStream,
                              builder: (context, snapshot) {
                                bool? playingState = snapshot.data;
                                if (playingState != null && playingState) {
                                  return const Icon(
                                    Icons.pause,
                                    size: 30,
                                    color: Colors.white70,
                                  );
                                }
                                return const Icon(
                                  Icons.play_arrow,
                                  size: 30,
                                  color: Colors.white70,
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      //skip to next
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            if (_player.hasNext) {
                              _player.seekToNext();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            // decoration: getDecoration(
                                // BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: const Icon(
                              Icons.skip_next,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                //go to playlist, shuffle , repeat all and repeat one control buttons
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      //go to playlist btn
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            _changePlayerViewVisibility();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            // decoration: getDecoration(
                                // BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: const Icon(
                              Icons.list_alt,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      //shuffle playlist
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            _player.setShuffleModeEnabled(true);
                            // toast(context, "Shuffling enabled");
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            margin:
                                const EdgeInsets.only(right: 30.0, left: 30.0),
                            // decoration: getDecoration(
                                // BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: const Icon(
                              Icons.shuffle,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),

                      //repeat mode
                      Flexible(
                        child: InkWell(
                          onTap: () {
                            _player.loopMode == LoopMode.one
                                ? _player.setLoopMode(LoopMode.all)
                                : _player.setLoopMode(LoopMode.one);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10.0),
                            // decoration: getDecoration(
                                // BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: StreamBuilder<LoopMode>(
                              stream: _player.loopModeStream,
                              builder: (context, snapshot) {
                                final loopMode = snapshot.data;
                                if (LoopMode.one == loopMode) {
                                  return const Icon(
                                    Icons.repeat_one,
                                    color: Colors.white70,
                                  );
                                }
                                return const Icon(
                                  Icons.repeat,
                                  color: Colors.white70,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }



    //If currently not play anything
    return Scaffold(
      backgroundColor: Colors.purple.withOpacity(0.5),
      appBar: AppBar(title: Text("Music App")),
      body: FutureBuilder<List<SongModel>>(
          //default values
          future: _audioQuery.querySongs(
            orderType: OrderType.ASC_OR_SMALLER,
            uriType: UriType.EXTERNAL,
            ignoreCase: true,
          ),
          builder: (context, item) {
            //loading content indicator
            if (item.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            //no songs found
            if (item.data!.isEmpty) {
              return const Center(
                child: Text("No Songs Found"),
              );
            }

            // You can use [item.data!] direct or you can create a list of songs as
            // List<SongModel> songs = item.data!;
            //showing the songs

            //add songs to the song list
            songs.clear();
            songs = item.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              // child: Text("Music App"),
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: item.data!.length,
                itemBuilder: (context, index) {
                  return Container(
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListTile(
                        tileColor: Colors.blueAccent,
                        title: Text(
                          item.data![index].title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        subtitle: Text(
                          item.data![index].displayName,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        leading: QueryArtworkWidget(
                          id: item.data![index].id,
                          type: ArtworkType.AUDIO,
                        ),
                        // leading: Icon(Icons.music_note,
                        //     color: Colors.purple, size: 32),
                        trailing: Icon(Icons.play_arrow,
                            color: Colors.purple, size: 25),

                      onTap: () async {
                        //show the player view
                        _changePlayerViewVisibility();
                        await _player.setAudioSource(createPlaylist(item.data!),
                          initialIndex: index);
                      await _player.play();
                      }      
                      ),
                      
                      );
                },
              ),
            );
          }),
    );
  }
}

class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}

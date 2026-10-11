# import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// 1. बैकग्राउंड ऑडियो हैंडलर
class StreamifyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final _player = AudioPlayer();

  StreamifyAudioHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.pause,
        MediaControl.play,
        MediaControl.stop,
      ],
      systemActions: const {
        MediaAction.seek,
      },
      androidCompactActionIndices: const [0, 1],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}

late AudioHandler audioHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // बैकग्राउंड ऑडियो सर्विस चालू करना
  audioHandler = await AudioService.init(
    builder: () => StreamifyAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.streamify.app.audio',
      androidNotificationChannelName: 'Streamify Background Audio',
      androidNotificationOngoing: true,
    ),
  );

  runApp(const StreamifyApp());
}

class StreamifyApp extends StatelessWidget {
  const StreamifyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF030712),
        primaryColor: const Color(0xFF22C55E),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool isAudioMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // स्क्रीन बंद/चालू होने का ऑटो-डिटेक्टर
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      setState(() {
        isAudioMode = true; // स्क्रीन बंद होने पर ऑटो ऑडियो मोड
      });
    } else if (state == AppLifecycleState.resumed) {
      setState(() {
        isAudioMode = false; // स्क्रीन ऑन होने पर वीडियो मोड
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F19),
        elevation: 0,
        title: Row(
          children: const [
            Icon(Icons.play_circle_filled, color: Color(0xFF22C55E), size: 28),
            SizedBox(width: 8),
            Text('Streamify', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  isAudioMode = !isAudioMode;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isAudioMode ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isAudioMode ? Colors.green : Colors.red, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      isAudioMode ? Icons.music_note : Icons.videocam,
                      size: 16,
                      color: isAudioMode ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isAudioMode ? 'Audio Mode' : 'Video Mode',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAudioMode ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isAudioMode ? 260 : 220,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey.shade800),
            ),
            child: isAudioMode
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF22C55E),
                        ),
                        child: const Icon(Icons.music_note, size: 45, color: Colors.black),
                      ),
                      const SizedBox(height: 16),
                      const Text('Playing Audio Stream (Spotify Style)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      const Text('Screen Off / Data Saver Active', style: TextStyle(fontSize: 12, color: Colors.green)),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.play_circle_outline, size: 60, color: Colors.redAccent),
                      SizedBox(height: 12),
                      Text('HD Video Playing (YouTube Style)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 4),
                      Text('Screen off to switch to audio automatically', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.skip_previous, size: 32), onPressed: () {}),
              const SizedBox(width: 24),
              Container(
                decoration: BoxDecoration(
                  color: isAudioMode ? Colors.green : Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.play_arrow, size: 36, color: Colors.black),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 24),
              IconButton(icon: const Icon(Icons.skip_next, size: 32), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const StreamifyApp());
}

class StreamifyApp extends StatelessWidget {
  const StreamifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streamify',
      theme: ThemeData(
        primarySwatch: Colors.green,
        brightness: Brightness.dark,
      ),
      home: const StreamifyHomeScreen(),
    );
  }
}

class StreamifyHomeScreen extends StatefulWidget {
  const StreamifyHomeScreen({super.key});

  @override
  State<StreamifyHomeScreen> createState() => _StreamifyHomeScreenState();
}

class _StreamifyHomeScreenState extends State<StreamifyHomeScreen> {
  bool isAudioMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Streamify (Hybrid Player)'),
        actions: [
          Row(
            children: [
              const Text('Audio Mode', style: TextStyle(fontSize: 12)),
              Switch(
                value: isAudioMode,
                onChanged: (value) {
                  setState(() {
                    isAudioMode = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: isAudioMode ? 100.0 : 300.0,
            color: Colors.black87,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAudioMode ? Icons.audiotrack : Icons.videocam,
                    size: 48,
                    color: isAudioMode ? Colors.green : Colors.redAccent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isAudioMode ? "Audio-Only Mode (Data Saver Active)" : "Video Mode Active",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Search or select media to stream...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[900],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 32),
                  onPressed: () {},
                ),
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
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 32),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

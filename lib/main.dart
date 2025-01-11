import 'package:flutter/material.dart';
import 'main_menu.dart';
import 'package:audioplayers/audioplayers.dart';


String globalSelectedTrack = 'tracks/track1.m4a'; // Default track


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Play the background music
  await BackgroundMusicPlayer.playBackgroundMusic();

  runApp(const App());

  
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrdWorld',
      home: MainMenu(),
    );
  }
}

class BackgroundMusicPlayer {

  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  // String globalSelectedTrack = 'tracks/track1.m4a'; // Default track

  // Initialize and play the background music
  static Future<void> playBackgroundMusic() async {
    try {
      await _audioPlayer.setSource(AssetSource(globalSelectedTrack)); // Use global track
      await _audioPlayer.setReleaseMode(ReleaseMode.loop); // Loop playback
      await _audioPlayer.resume(); // Start playback
    } catch (e) {
      print('Error playing background music: $e');
    }
  }

  // Stop the background music
  static Future<void> stopBackgroundMusic() async {
    await _audioPlayer.stop();
  }

  // Update and play the new track
  static Future<void> updateTrack(String newTrack) async {
    globalSelectedTrack = newTrack; // Update the global variable
    await stopBackgroundMusic(); // Stop current playback
    await playBackgroundMusic(); // Play the new track
  }
}

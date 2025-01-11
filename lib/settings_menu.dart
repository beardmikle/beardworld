import 'package:brdgame/button_style_main.dart';
import 'package:flutter/material.dart';
import 'main_menu.dart';
import 'main.dart'; // Import for BackgroundMusicPlayer and globalSelectedTrack

class SettingsMenu extends StatefulWidget {
  const SettingsMenu({super.key});

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  String? _selectedTrack =
      globalSelectedTrack == 'tracks/track1.m4a' ? 'Track 1' : 'Track 2';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background_main_menu.png',
            fit: BoxFit.cover,
          ),
          // Audio Settings
          Positioned(
            top: 300.0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 200.0,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.green, width: 4.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Audio',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // RadioListTile for Track 1
                      RadioListTile<String>(
                        title: const Text(
                          'Track 1',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'Track 1',
                        groupValue: _selectedTrack,
                        onChanged: (value) async {
                          setState(() {
                            _selectedTrack = value;
                          });
                          await BackgroundMusicPlayer.updateTrack(
                              'tracks/track1.m4a');
                        },
                        activeColor: Colors.yellow,
                      ),
                      // RadioListTile for Track 2
                      RadioListTile<String>(
                        title: const Text(
                          'Track 2',
                          style: TextStyle(color: Colors.white),
                        ),
                        value: 'Track 2',
                        groupValue: _selectedTrack,
                        onChanged: (value) async {
                          setState(() {
                            _selectedTrack = value;
                          });
                          await BackgroundMusicPlayer.updateTrack(
                              'tracks/track2.m4a');
                        },
                        activeColor: Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Back to Menu Button
          Positioned(
            bottom: 80.0,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 150.0,
                child: StyledButton(
                  text: "<- Menu",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainMenu()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

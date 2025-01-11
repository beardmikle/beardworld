import 'package:flutter/material.dart';
import 'main_game_page.dart';
import 'settings_menu.dart';
import 'button_style_main.dart';
import 'main.dart'; // Import for BackgroundMusicPlayer

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool _isMusicPlaying = false; // Music is off by default

  @override
  void initState() {
    super.initState();
    // Ensure music is off when the app starts
    BackgroundMusicPlayer.stopBackgroundMusic();
  }

  // Toggle background music
  Future<void> _toggleMusic() async {
    if (_isMusicPlaying) {
      await BackgroundMusicPlayer.stopBackgroundMusic();
    } else {
      await BackgroundMusicPlayer.playBackgroundMusic();
    }
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
  }

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
          // Music toggle button
          Positioned(
            top: 60.0,
            right: 20.0,
            child: GestureDetector(
              onTap: _toggleMusic, // Call the toggle method on tap
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3.0),
                child: Icon(
                  _isMusicPlaying
                      ? Icons.volume_up_rounded // Music on icon
                      : Icons.volume_off_rounded, // Music off icon
                  color: Colors.white, // Icon color
                  size: 34.0, // Icon size
                ),
              ),
            ),
          ),
          // Menu content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with gradient mask
                ShaderMask(
                  shaderCallback: (rect) {
                    return const RadialGradient(
                      center: Alignment.center,
                      radius: 0.8,
                      colors: [
                        Colors.white,
                        Colors.transparent,
                      ],
                      stops: [0.6, 1.0],
                    ).createShader(rect);
                  },
                  blendMode: BlendMode.dstIn,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 300,
                    height: 300,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 20.0),
                // "New Game" button
                SizedBox(
                  width: 150.0,
                  child: StyledButton(
                    text: "New Game",
                    onPressed: () {
                      Navigator.push(
                        context,
                        _createRoute(const MainGamePage()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10.0),
                // "Settings" button
                SizedBox(
                  width: 150.0,
                  child: StyledButton(
                    text: "Settings",
                    onPressed: () {
                      Navigator.push(
                        context,
                        _createRoute(const SettingsMenu()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

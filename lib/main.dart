import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(BagelsGame());
}

class BagelsGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bagels Game',
      theme: ThemeData.dark(), // Dark theme
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String secretNumber = '';
  TextEditingController guessController = TextEditingController();
  String message = 'Enter a 3-digit number';
  int attempts = 0;
  int bestScore = 0;

  @override
  void initState() {
    super.initState();
    generateSecretNumber();
    loadBestScore();
  }

  void generateSecretNumber() {
    List<int> digits = List.generate(10, (i) => i);
    digits.shuffle();
    secretNumber = digits.take(3).join();
    attempts = 0; // Reset attempts for new game
  }

  void checkGuess() {
    String guess = guessController.text;
    if (guess.length != 3 || guess.contains(RegExp(r'[^0-9]'))) {
      setState(() {
        message = '⚠️ Enter a valid 3-digit number!';
      });
      return;
    }

    attempts++;

    if (guess == secretNumber) {
      setState(() {
        message = '🎉 Correct! You got it in $attempts tries!';
      });

      saveBestScore();
      return;
    }

    List<String> clues = [];
    for (int i = 0; i < 3; i++) {
      if (guess[i] == secretNumber[i]) {
        clues.add('🟢 Fermi');
      } else if (secretNumber.contains(guess[i])) {
        clues.add('🟡 Pico');
      }
    }

    setState(() {
      message = clues.isEmpty ? '🔴 Bagels' : clues.join(', ');
    });
  }

  void restartGame() {
    setState(() {
      generateSecretNumber();
      message = 'Enter a 3-digit number';
      guessController.clear();
    });
  }

  Future<void> saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    if (bestScore == 0 || attempts < bestScore) {
      setState(() {
        bestScore = attempts;
      });
      prefs.setInt('bestScore', bestScore);
    }
  }

  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      bestScore = prefs.getInt('bestScore') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueGrey.shade900, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bagels Game',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  message,
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextField(
                  controller: guessController,
                  keyboardType: TextInputType.number,
                  maxLength: 3,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    hintText: '123',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: checkGuess,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    backgroundColor: Colors.tealAccent[700],
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Guess'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: restartGame,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                    backgroundColor: Colors.redAccent[700],
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Restart Game'),
                ),
                SizedBox(height: 30),
                Text(
                  'Attempts: $attempts',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Best Score: ${bestScore > 0 ? bestScore : "N/A"}',
                  style: TextStyle(fontSize: 18, color: Colors.greenAccent),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

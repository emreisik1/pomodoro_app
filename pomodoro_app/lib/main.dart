import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const PomodoroScreen(),
    );
  }
}

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  _PomodoroScreenState createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  static const int pomodoroDuration = 25 * 60; // 25 dakika (1500 saniye)
  int remainingSeconds = pomodoroDuration;
  Timer? _timer;
  bool isRunning = false;
  int coins = 0;
  int elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadCoins();
  }

  // SharedPreferences'tan coin bilgisini yükle
  Future<void> _loadCoins() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
    });
  }

  // Coin miktarını kaydet
  Future<void> _saveCoins() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
  }

  void startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
          elapsedSeconds++;
        });
      } else {
        _finishPomodoro();
      }
    });
    setState(() {
      isRunning = true;
    });
  }

  void stopTimer() {
    _timer?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();
    setState(() {
      remainingSeconds = pomodoroDuration;
      elapsedSeconds = 0;
      isRunning = false;
    });
  }

  void _finishPomodoro() {
    _timer?.cancel();
    int earnedCoins = elapsedSeconds ~/ 60; // Tamamlanan dakikalar kadar coin ver
    setState(() {
      coins += earnedCoins;
      isRunning = false;
      remainingSeconds = pomodoroDuration;
      elapsedSeconds = 0;
    });
    _saveCoins(); // Coin bilgisini kaydet
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pomodoro Timer"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.yellow, size: 30),
                const SizedBox(width: 5),
                Text(
                  "$coins",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatTime(remainingSeconds),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: isRunning ? stopTimer : startTimer,
                child: Text(isRunning ? "Duraklat" : "Başlat"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: resetTimer,
                child: const Text("Sıfırla"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _finishPomodoro,
                child: const Text("Bitir"),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text(
            "Coin: $coins", // Coin miktarını göster
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

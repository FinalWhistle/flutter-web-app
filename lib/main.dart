import 'package:flutter/material.dart';
import 'loading.dart'; // Import LoadingWidget
import 'game_info.dart'; // Ensure GameInfo is properly imported

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinalWhistle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool dataLoaded = false;

  /// Fetch data in the background
  Future<void> fetchDataInBackground() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    setState(() {
      dataLoaded = true;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataInBackground(); // Start fetching data immediately
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      loadingMessage: "Initializing FinalWhistle...",
      onLoadingComplete: () {
        if (dataLoaded) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          // Ensure minimum loading delay of 3 seconds
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ),
            );
          });
        }
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Column(
        children: [
          Expanded(child: GameInfo(sportName: "All")), // Load default sport
        ],
      ),
    );
  }
}
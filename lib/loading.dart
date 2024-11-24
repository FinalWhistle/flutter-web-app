import 'package:flutter/material.dart';

class LoadingWidget extends StatefulWidget {
  final String loadingMessage;
  final VoidCallback onLoadingComplete;

  const LoadingWidget({
    super.key,
    this.loadingMessage = "We're just gathering your scores...",
    required this.onLoadingComplete,
  });

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize glowing animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Automatically navigate to the next page after 3 seconds
    Future.delayed(const Duration(seconds: 3), widget.onLoadingComplete);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // White background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Logo
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'lib/assets/finalwhistle-line-logo-1.png', // Replace with your logo path
                width: 400, // Increased logo size
              ),
            ),
            const SizedBox(height: 40),
            // Loading Message
            Text(
              widget.loadingMessage,
              style: const TextStyle(
                fontSize: 22, // Increased font size
                fontWeight: FontWeight.bold,
                color: Color(0xFF003471),
              ),
            ),
            const SizedBox(height: 30),
            // Modern Spinner
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003471)),
              strokeWidth: 4.0, // Slightly thicker stroke for better visibility
            ),
          ],
        ),
      ),
    );
  }
}
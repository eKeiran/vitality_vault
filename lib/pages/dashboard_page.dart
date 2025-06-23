import 'package:flutter/material.dart';

class AnalysisDashboard extends StatefulWidget {
  final String userId;
  final String sessionId;

  const AnalysisDashboard({
    super.key,
    required this.userId,
    required this.sessionId,
  });

  @override
  State<AnalysisDashboard> createState() => _AnalysisDashboardState();
}

class _AnalysisDashboardState extends State<AnalysisDashboard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  String _status = "Initializing analysis...";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _simulateAnalysis();
  }

  void _simulateAnalysis() async {
    final messages = [
      "Preparing your health data...",
      "Identifying key biomarkers...",
      "Generating visualizations...",
      "Finalizing insights..."
    ];
    
    for (var message in messages) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() => _status = message);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Color(0xFFf5f5f5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vitality Vault Logo/Title
            ScaleTransition(
              scale: _animation,
              child: Text(
                'Vitality Vault',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
            SizedBox(height: 40),
            
            // Animated DNA Icon
            Icon(
              Icons.psychology_rounded,
              size: 80,
              color: primary,
            ),
            SizedBox(height: 40),
            
            // Status Text
            Text(
              _status,
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            SizedBox(height: 20),
            
            // Progress Bar
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,
              child: LinearProgressIndicator(
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:vitality_vault/theme/app_theme.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  final List<bool> _hoverStates = [false, false, false];
  bool _isButtonHovered = false;
  bool _isSectionVisible = false;
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize animation controller for button bounce
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Trigger section visibility animation after a delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isSectionVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary; // Google Blue
    final secondaryColor = Theme.of(context).colorScheme.secondary; // Google Green
    final accentColor = Theme.of(context).colorScheme.tertiary; // Google Yellow
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isSmallMobile = screenSize.width < 400;

    return Scaffold(
      body: Column(
        children: [
          // Main Content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + (isMobile ? 10 : 20),
                left: isMobile ? 12 : 40,
                right: isMobile ? 12 : 40,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Hero Section
                  Flexible(
                    flex: isMobile ? 3 : 4,
                    child: isMobile
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: isSmallMobile ? 120 : 150,
                                child: Lottie.asset(
                                  'animations/heart_intro.json',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTextContent(
                                  primaryColor, secondaryColor, accentColor, isDark, isMobile, isSmallMobile),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 40),
                                  child: SizedBox(
                                    height: 350,
                                    child: Lottie.asset(
                                      'animations/heart_intro.json',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 3,
                                child: _buildTextContent(
                                    primaryColor, secondaryColor, accentColor, isDark, isMobile, isSmallMobile),
                              ),
                            ],
                          ),
                  ),

                  // Features Section
                  Flexible(
                    flex: isMobile ? 4 : 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start, // Shift section upwards
                      children: [
                        const SizedBox(height: 4), // Further reduced from 8
                        Text(
                          'How It Works',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallMobile ? 21 : (isMobile ? 23.1 : 25.2),
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedOpacity(
                          opacity: _isSectionVisible ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeInOut,
                          child: Wrap(
                            spacing: isMobile ? 20 : 32,
                            runSpacing: isMobile ? 20 : 32,
                            alignment: WrapAlignment.center,
                            children: List.generate(3, (index) {
                              final cardColors = [primaryColor, secondaryColor, accentColor];
                              final glowColors = [
                                primaryColor.withOpacity(0.4),
                                secondaryColor.withOpacity(0.4),
                                accentColor.withOpacity(0.4),
                              ];
                              return MouseRegion(
                                onEnter: (_) => setState(() => _hoverStates[index] = true),
                                onExit: (_) => setState(() => _hoverStates[index] = false),
                                child: Transform.scale(
                                  scale: _hoverStates[index] ? 1.05 : 1.0,
                                  child: Container(
                                    width: isSmallMobile
                                        ? screenSize.width * 0.8925
                                        : (isMobile ? 273 : 231),
                                    height: isMobile ? 157.5 : 189,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _hoverStates[index]
                                            ? glowColors[index]
                                            : glowColors[index].withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                      boxShadow: _hoverStates[index]
                                          ? [
                                              BoxShadow(
                                                color: glowColors[index],
                                                blurRadius: 12,
                                                spreadRadius: 2,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: Card(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      color: cardColors[index].withOpacity(isDark ? 0.3 : 0.2),
                                      child: Padding(
                                        padding: EdgeInsets.all(isMobile ? 12 : 16),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              [
                                                Icons.upload_file,
                                                Icons.auto_awesome,
                                                Icons.trending_up,
                                              ][index],
                                              size: isMobile ? 33.6 : 37.8,
                                              color: cardColors[index],
                                            ),
                                            SizedBox(height: isMobile ? 8 : 10),
                                            Text(
                                              [
                                                'Upload Reports',
                                                'AI Analysis',
                                                'Trend Tracking',
                                              ][index],
                                              style: GoogleFonts.poppins(
                                                fontSize: isSmallMobile
                                                    ? 16.8
                                                    : (isMobile ? 16.8 : 17.85),
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).textTheme.headlineMedium?.color,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: isMobile ? 4 : 6),
                                            Text(
                                              [
                                                'Secure medical report uploads',
                                                'AI-powered health insights',
                                                'Historical pattern visualization',
                                              ][index],
                                              style: GoogleFonts.poppins(
                                                fontSize: isSmallMobile
                                                    ? 12.6
                                                    : (isMobile ? 12.6 : 13.65),
                                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Footer
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: isMobile ? 12 : 16,
              horizontal: isMobile ? 16 : 24,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
              border: Border(
                top: BorderSide(
                  color: isDark ? primaryColor.withOpacity(0.3) : primaryColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Built with Agentic AI using Google\'s Agent Development Toolkit',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallMobile ? 12 : (isMobile ? 13 : 14),
                    fontStyle: FontStyle.italic,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '© ${DateTime.now().year} Vitality Vault. All rights reserved.',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallMobile ? 10 : (isMobile ? 11 : 12),
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContent(
      Color primaryColor, Color secondaryColor, Color accentColor, bool isDark, bool isMobile, bool isSmallMobile) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vitality Vault',
          style: GoogleFonts.poppins(
            fontSize: isSmallMobile ? 24 : (isMobile ? 26 : 36),
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        Text(
          'Health Tracker',
          style: GoogleFonts.poppins(
            fontSize: isSmallMobile ? 18 : (isMobile ? 20 : 26),
            fontWeight: FontWeight.w600,
            color: secondaryColor,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Text(
          'Chronic illness management with\nagentic AI insights and trend analysis',
          style: GoogleFonts.poppins(
            fontSize: isSmallMobile ? 12 : (isMobile ? 13 : 14),
            height: 1.5,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        MouseRegion(
          onEnter: (_) {
            setState(() => _isButtonHovered = true);
            _animationController.forward();
          },
          onExit: (_) {
            setState(() => _isButtonHovered = false);
            _animationController.reverse();
          },
          child: ScaleTransition(
            scale: _buttonScaleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSmallMobile ? 150 : (isMobile ? 160 : 180),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: _isButtonHovered
                    ? LinearGradient(
                        colors: [primaryColor, secondaryColor.withOpacity(0.8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : LinearGradient(
                        colors: [primaryColor, primaryColor],
                      ),
                boxShadow: _isButtonHovered
                    ? [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pushNamed(context, '/signin');
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 10 : 12,
                    ),
                    child: Center(
                      child: Text(
                        'Get Started →',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:vitality_vault/providers/theme_provider.dart';
import 'package:vitality_vault/theme/app_theme.dart';

class AppNavbar extends StatelessWidget {
  const AppNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive values
    final isSmallScreen = screenWidth < 600;
    final titleFontSize = isSmallScreen ? 16.0 : 20.0;
    final buttonFontSize = isSmallScreen ? 14.0 : 16.0;
    final buttonPadding = isSmallScreen
        ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    final iconSize = isSmallScreen ? 20.0 : 24.0;

    return AppBar(
      title: Row(
        children: [
          Icon(Icons.health_and_safety, color: primaryColor, size: iconSize),
          const SizedBox(width: 8),
          Text(
            'Vitality Vault',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: titleFontSize,
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
        ],
      ),
      centerTitle: false,
      elevation: 1,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  colors: AppTheme.darkGradient.colors,
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                )
              : LinearGradient(
                  colors: AppTheme.lightGradient.colors,
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            size: iconSize,
            color: Theme.of(context).colorScheme.tertiary, // Google Yellow
          ),
          onPressed: () {
            themeProvider.toggleTheme(!themeProvider.isDarkMode);
          },
        ),
        if (!isSmallScreen) ...[
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/signin'),
            style: Theme.of(context).elevatedButtonTheme.style,
            child: Text(
              'Sign In',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: buttonFontSize,
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/signup'),
            style: Theme.of(context).outlinedButtonTheme.style,
            child: Text(
              'Sign Up',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: buttonFontSize,
                color: Theme.of(context).colorScheme.secondary, // Google Green
              ),
            ),
          ),
        ] else ...[
          PopupMenuButton<String>(
            icon: Icon(Icons.menu, size: iconSize, color: Theme.of(context).colorScheme.tertiary),
            onSelected: (value) {
              if (value == 'signin') {
                Navigator.pushNamed(context, '/signin');
              } else if (value == 'signup') {
                Navigator.pushNamed(context, '/signup');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'signin',
                child: Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'signup',
                child: Text(
                  'Sign Up',
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }
}
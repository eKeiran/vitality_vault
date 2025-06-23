import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitality_vault/theme/app_theme.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
// Add this import at the top
import 'package:provider/provider.dart';
import 'package:vitality_vault/providers/user_provider.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Form state
  final List<String> _selectedConditions = [];
  String _age = '';
  String? _assignedBirth;
  String? _genderIdentity;
  String _customGender = '';
  final TextEditingController _customConditionController =
      TextEditingController();

  // UI state
  int _currentStep = 0;
  bool _isTyping = true;
  bool _isLoading = false;
  bool _showCustomCondition = false;
  final _ageController = TextEditingController();
  double _opacity = 0.0;

  // Inclusive gender options
  final List<String> assignedAtBirthOptions = [
    'AFAB (Assigned Female at Birth)',
    'AMAB (Assigned Male at Birth)',
    'Intersex',
    'Prefer not to say'
  ];

  final List<String> genderIdentityOptions = [
    'Woman',
    'Man',
    'Non-binary',
    'Genderqueer',
    'Genderfluid',
    'Agender',
    'Two-Spirit',
    'Other',
    'Prefer not to say'
  ];

  // Expanded health conditions
  final List<String> conditionOptions = [
    'Diabetes',
    'Hypertension',
    'Heart Disease',
    'Autoimmune Disorder',
    'Thyroid Condition',
    'Mental Health Condition',
    'Chronic Pain',
    'Respiratory Condition',
    'Arthritis',
    'Digestive Disorder',
    'Neurological Condition',
    'Cancer History',
    'Metabolic Disorder',
    'Blood Disorder',
    'None currently'
  ];

  @override
  void initState() {
    super.initState();
    // Start fade-in animation
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });
  }

  @override
  void dispose() {
    _ageController.dispose();
    _customConditionController.dispose();
    super.dispose();
  }

  void _addCustomCondition() {
    if (_customConditionController.text.isNotEmpty) {
      setState(() {
        _selectedConditions.add(_customConditionController.text);
        _customConditionController.clear();
        _showCustomCondition = false;
      });
    }
  }

// In your _OnboardingPageState class, update the _submitData method:
  Future<void> _submitData() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = _auth.currentUser;

      if (user != null) {
        final profileData = {
          'user_id': user.uid,
          'profile': {
            'conditions': _selectedConditions,
            'age': _age.isNotEmpty ? int.parse(_age) : null,
            'gender': {
              'assigned_at_birth': _assignedBirth,
              'identity': _genderIdentity,
              'custom': _customGender.isNotEmpty ? _customGender : null,
            },
          },
          'preferences': {
            'completed_onboarding': true,
            'onboarding_date': FieldValue.serverTimestamp(),
          }
        };

        await userProvider.updateProfile(profileData);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/uploads');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving data: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Update the skip method similarly:
  void _skipOnboarding() async {
    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = _auth.currentUser;

      if (user != null) {
        await userProvider.updateProfile({
          'preferences': {
            'completed_onboarding': true,
            'onboarding_date': FieldValue.serverTimestamp(),
            'skipped': true,
          }
        });

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildWelcomeMessage() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _auth.currentUser;
    final displayName = user?.displayName ?? 'Guest';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 150,
          child: Lottie.asset(
            'animations/health-kernel.json',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1000),
          child: Text(
            'Welcome, $displayName!',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.googleBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1000),
          child: Text(
            "I'm Agent Kernel, your AI health companion. I'm a digital cousin of Baymax.\n\n"
            "I'll unlock insights from your lab reports and help you keep track of your health.\n\n"
            "I'd love for us to get to know each other better! Let’s start with a few basics about you!",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color:
                  isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionsStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Are there any health conditions\nyou\'re looking to monitor?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: AppTheme.googleBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...conditionOptions.map((condition) {
              final isSelected = _selectedConditions.contains(condition);
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      if (condition == 'None currently') {
                        _selectedConditions.clear();
                      } else if (_selectedConditions
                          .contains('None currently')) {
                        _selectedConditions.remove('None currently');
                      }
                      _selectedConditions.add(condition);
                    } else {
                      _selectedConditions.remove(condition);
                    }
                  });
                },
                selectedColor: AppTheme.googleYellow.withOpacity(0.3),
                checkmarkColor: AppTheme.googleBlue,
                backgroundColor: isDark
                    ? AppTheme.darkCard.withOpacity(0.7)
                    : AppTheme.lightCard.withOpacity(0.7),
                labelStyle: GoogleFonts.poppins(
                  color: isSelected ? AppTheme.googleBlue : null,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppTheme.googleBlue.withOpacity(0.2),
                  ),
                ),
              );
            }),
            if (!_showCustomCondition)
              ActionChip(
                label: const Text('+ Add custom condition'),
                onPressed: () => setState(() => _showCustomCondition = true),
                backgroundColor: AppTheme.googleGreen.withOpacity(0.2),
                labelStyle: GoogleFonts.poppins(
                  color: AppTheme.googleGreen,
                  fontWeight: FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            if (_showCustomCondition)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _customConditionController,
                      decoration: InputDecoration(
                        hintText: 'Enter condition',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppTheme.googleBlue.withOpacity(0.3),
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppTheme.darkCard.withOpacity(0.7)
                            : AppTheme.lightCard.withOpacity(0.7),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.check, color: AppTheme.googleGreen),
                    onPressed: _addCustomCondition,
                  ),
                ],
              ),
          ],
        ),
        if (_selectedConditions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Wrap(
              spacing: 8,
              children: _selectedConditions.map((condition) {
                return Chip(
                  label: Text(condition),
                  onDeleted: () {
                    setState(() => _selectedConditions.remove(condition));
                  },
                  deleteIconColor: AppTheme.googleRed,
                  backgroundColor: isDark
                      ? AppTheme.darkCard.withOpacity(0.7)
                      : AppTheme.lightCard.withOpacity(0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: AppTheme.googleBlue.withOpacity(0.2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAgeStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'How old are you?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: AppTheme.googleBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          child: TextField(
            controller: _ageController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter your age',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.googleBlue.withOpacity(0.3),
                ),
              ),
              filled: true,
              fillColor: isDark
                  ? AppTheme.darkCard.withOpacity(0.7)
                  : AppTheme.lightCard.withOpacity(0.7),
            ),
            onChanged: (value) => _age = value,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '(Optional, between 13-120)',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: isDark
                ? AppTheme.darkTextSecondary
                : AppTheme.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderStep() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'How do you identify?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            color: AppTheme.googleBlue,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          value: _assignedBirth,
          hint: const Text('Assigned at birth (optional)'),
          items: assignedAtBirthOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) => setState(() => _assignedBirth = value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.googleBlue.withOpacity(0.3),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? AppTheme.darkCard.withOpacity(0.7)
                : AppTheme.lightCard.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _genderIdentity,
          hint: const Text('Gender identity (optional)'),
          items: genderIdentityOptions.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) => setState(() => _genderIdentity = value),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.googleBlue.withOpacity(0.3),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? AppTheme.darkCard.withOpacity(0.7)
                : AppTheme.lightCard.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Or describe in your own words (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppTheme.googleBlue.withOpacity(0.3),
              ),
            ),
            filled: true,
            fillColor: isDark
                ? AppTheme.darkCard.withOpacity(0.7)
                : AppTheme.lightCard.withOpacity(0.7),
          ),
          onChanged: (value) => _customGender = value,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      _buildWelcomeMessage(),
      _buildConditionsStep(),
      _buildAgeStep(),
      _buildGenderStep(),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppTheme.darkGradient : AppTheme.lightGradient,
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          AppTheme.googleBlue.withOpacity(0.2),
                          AppTheme.googleGreen.withOpacity(0.2),
                          AppTheme.googleYellow.withOpacity(0.2),
                          AppTheme.googleRed.withOpacity(0.2),
                        ]
                      : [
                          AppTheme.googleBlue.withOpacity(0.15),
                          AppTheme.googleGreen.withOpacity(0.15),
                          AppTheme.googleYellow.withOpacity(0.15),
                          AppTheme.googleRed.withOpacity(0.15),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? AppTheme.googleBlue.withOpacity(0.3)
                      : AppTheme.googleBlue.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppTheme.googleBlue.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: steps[_currentStep],
                  ),
                  const SizedBox(height: 32),
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(steps.length, (index) {
                      return Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentStep >= index
                              ? AppTheme.googleGreen
                              : isDark
                                  ? AppTheme.darkTextSecondary.withOpacity(0.3)
                                  : AppTheme.lightTextSecondary
                                      .withOpacity(0.3),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _currentStep > 0
                            ? () {
                                setState(() => _currentStep--);
                              }
                            : null,
                        child: Text(
                          'Back',
                          style: GoogleFonts.poppins(
                            color: AppTheme.googleBlue.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: _skipOnboarding,
                            child: Text(
                              'Skip',
                              style: GoogleFonts.poppins(
                                color: AppTheme.googleRed,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.googleBlue,
                                  AppTheme.googleGreen,
                                ],
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentStep < steps.length - 1) {
                                  setState(() => _currentStep++);
                                } else {
                                  _submitData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _currentStep < steps.length - 1
                                          ? 'Continue'
                                          : 'Complete Setup',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

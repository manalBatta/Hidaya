import 'package:flutter/material.dart';
import 'package:frontend/constants/colors.dart';
import 'package:frontend/widgets/SignInPage.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Match SignInPage background gradient
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.islamicGreen50,
              const Color(0xFFF4F0E7),
              AppColors.islamicGold500.withAlpha((255 * 0.2).toInt()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((255 * 0.85).toInt()),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.islamicGreen200),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.islamicGreen500.withAlpha(
                          (255 * 0.3).toInt(),
                        ),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with icon and text
                      Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.islamicGreen500,
                                  AppColors.islamicGreen600,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.islamicGreen600.withAlpha(
                                    128,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.nights_stay_outlined,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hidaya',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.islamicGreen800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'هداية - Guidance in Faith',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.islamicGreen600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Account type selector (DropdownButton)
                      const Text(
                        'Account Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.islamicGreen700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.islamicGreen200,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppColors.islamicGreen500,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        value: 'Volunteer',
                        items: const [
                          DropdownMenuItem(
                            value: 'Volunteer',
                            child: Text('Volunteer'),
                          ),
                          DropdownMenuItem(value: 'User', child: Text('User')),
                        ],
                        onChanged: (value) {},
                        style: TextStyle(
                          color: AppColors.islamicGreen800,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Text input fields: Full Name, Username, Email, Password, Confirm Password
                      const _RegisterTextField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                      ),
                      const SizedBox(height: 16),
                      const _RegisterTextField(
                        label: 'Username',
                        hint: 'Enter your username',
                      ),
                      const SizedBox(height: 16),
                      const _RegisterTextField(
                        label: 'Email Address',
                        hint: 'Enter your email',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      const _RegisterTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        obscureText: true,
                      ),
                      const SizedBox(height: 16),
                      const _RegisterTextField(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        obscureText: true,
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: AppColors.islamicGreen500,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          shadowColor: AppColors.islamicGreen600.withAlpha(
                            (255 * 0.7).toInt(),
                          ),
                          elevation: 8,
                        ),
                        onPressed: () {
                          // Handle submit
                        },
                        child: const Text('Create Volunteer Account'),
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Already have an account? Sign In',
                          style: TextStyle(
                            color: AppColors.islamicGreen600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Footer Quran quote
                      Column(
                        children: [
                          Text(
                            '"And it is He who sends down rain from heaven, and We produce thereby the vegetation of every kind."',
                            style: TextStyle(
                              color: AppColors.islamicGreen600,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '- Quran 6:99', //Surah Al-An'am, Ayah 99
                            style: TextStyle(
                              color: AppColors.islamicGreen500,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterTextField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _RegisterTextField({
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.islamicGreen700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.islamicGreen200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.islamicGreen500,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
          ),
          style: const TextStyle(
            color: AppColors.islamicGreen800,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

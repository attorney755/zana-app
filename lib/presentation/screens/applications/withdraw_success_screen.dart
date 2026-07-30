import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';

class WithdrawSuccessScreen extends StatelessWidget {
  final String opportunityTitle;
  final String providerName;

  const WithdrawSuccessScreen({
    super.key,
    required this.opportunityTitle,
    required this.providerName,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;
        final bgClr = isDark ? const Color(0xFF121212) : Colors.white;
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

        return Scaffold(
          backgroundColor: bgClr,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Amber / Orange Circular Info Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.exit_to_app_rounded,
                      size: 64,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Headline
                  Text(
                    'We are sorry to see you go',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'Your application for $opportunityTitle from $providerName has been successfully withdrawn.',
                    style: TextStyle(
                      fontSize: 15,
                      color: subtextColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Bottom Action Buttons
                  Column(
                    children: [
                      // Explore More Opportunities Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.explore_rounded, size: 20),
                          label: const Text(
                            'Explore More Opportunities',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            context.go('/explore');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Back to Opportunities Button
                      TextButton.icon(
                        icon: Icon(Icons.arrow_back_rounded, size: 18, color: subtextColor),
                        label: Text(
                          'Back to Opportunities',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subtextColor),
                        ),
                        onPressed: () {
                          context.go('/home');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

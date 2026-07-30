import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_provider.dart';

class ApplicationSuccessScreen extends StatelessWidget {
  final String opportunityTitle;
  final String providerName;

  const ApplicationSuccessScreen({
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
        final cardBg = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB);
        final textColor = isDark ? Colors.white : AppColors.textPrimary;
        final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
        final borderClr = isDark ? Colors.white24 : const Color(0xFFE5E7EB);

        return Scaffold(
          backgroundColor: bgClr,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Green Success Circle Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 72,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Headline
                  Text(
                    'Thank you for applying!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Role Details & Provider Sentence
                  Text(
                    'Thank you for applying for $opportunityTitle from $providerName!',
                    style: TextStyle(
                      fontSize: 15,
                      color: subtextColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Track Application Box Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: borderClr, width: 1.2),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'You can track your application status here:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.assignment_turned_in_rounded, size: 20),
                            label: const Text('Track Application'),
                            onPressed: () {
                              context.go('/applications');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Bottom Action Buttons
                  Column(
                    children: [
                      // Explore More Opportunities Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.explore_rounded, size: 20, color: AppColors.primary),
                          label: const Text(
                            'Explore More Opportunities',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          onPressed: () {
                            context.go('/explore');
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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

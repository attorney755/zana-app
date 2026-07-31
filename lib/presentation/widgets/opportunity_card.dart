import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class OpportunityCard extends StatelessWidget {
  final String id;
  final String category; // 'Scholarship', 'Internship', 'Fellowship', 'Grant', 'Workshop'
  final String title;
  final String subtitle;
  final String deadlineText;
  final bool isUrgent;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;

  const OpportunityCard({
    super.key,
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.deadlineText,
    this.isUrgent = false,
    this.isSaved = false,
    this.onTap,
    this.onBookmarkTap,
  });

  Color _getBadgeBgColor(bool isDark) {
    if (isDark) {
      switch (category.toLowerCase()) {
        case 'scholarship':
          return const Color(0xFF1E3A8A);
        case 'internship':
          return const Color(0xFF064E3B);
        case 'fellowship':
          return const Color(0xFF7C2D12);
        case 'grant':
          return const Color(0xFF78350F);
        case 'workshop':
          return const Color(0xFF581C87);
        default:
          return const Color(0xFF374151);
      }
    }
    switch (category.toLowerCase()) {
      case 'scholarship':
        return const Color(0xFFEEF2FF);
      case 'internship':
        return const Color(0xFFECFDF5);
      case 'fellowship':
        return const Color(0xFFFFF7ED);
      case 'grant':
        return const Color(0xFFFEF3C7);
      case 'workshop':
        return const Color(0xFFF3E8FF);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getBadgeTextColor(bool isDark) {
    if (isDark) {
      switch (category.toLowerCase()) {
        case 'scholarship':
          return const Color(0xFF93C5FD);
        case 'internship':
          return const Color(0xFF6EE7B7);
        case 'fellowship':
          return const Color(0xFFFDBA74);
        case 'grant':
          return const Color(0xFFFDE047);
        case 'workshop':
          return const Color(0xFFC084FC);
        default:
          return const Color(0xFFE5E7EB);
      }
    }
    switch (category.toLowerCase()) {
      case 'scholarship':
        return const Color(0xFF4F46E5);
      case 'internship':
        return const Color(0xFF059669);
      case 'fellowship':
        return const Color(0xFFEA580C);
      case 'grant':
        return const Color(0xFFD97706);
      case 'workshop':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF374151);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleClr = isDark ? Colors.white : AppColors.textPrimary;
    final subClr = isDark ? Colors.white70 : AppColors.textSecondary;
    final borderClr = isDark ? Colors.white24 : const Color(0xFFE5E7EB);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderClr, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Category Badge, Deadline & Bookmark Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: _getBadgeBgColor(isDark),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _getBadgeTextColor(isDark),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: isUrgent ? AppColors.deadlineText : subClr,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        deadlineText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isUrgent ? AppColors.deadlineText : subClr,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (onBookmarkTap != null) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: onBookmarkTap,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Icon(
                            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: isSaved ? AppColors.primary : subClr,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleClr,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: subClr,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

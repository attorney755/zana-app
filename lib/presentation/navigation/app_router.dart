import 'package:go_router/go_router.dart';
import '../screens/applications/application_success_screen.dart';
import '../screens/applications/applications_screen.dart';
import '../screens/applications/withdraw_success_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/onboarding/onboarding_step1_screen.dart';
import '../screens/onboarding/onboarding_step2_screen.dart';
import '../screens/onboarding/onboarding_step3_screen.dart';
import '../screens/opportunities/apply_screen.dart';
import '../screens/opportunity_detail/opportunity_detail_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/startup/analytics_screen.dart';
import '../screens/startup/applicant_detail_screen.dart';
import '../screens/startup/edit_post_screen.dart';
import '../screens/startup/founder_messages_screen.dart';
import '../screens/startup/my_posts_screen.dart';
import '../screens/startup/post_details_screen.dart';
import '../screens/startup/post_opportunity_screen.dart';
import '../screens/startup/startup_applicants_screen.dart';
import '../screens/startup/startup_feed_screen.dart';
import '../screens/startup/startup_profile_screen.dart';
import '../screens/startup/startup_settings_screen.dart';
import '../../data/models/application_model.dart';
import '../../data/models/opportunity_model.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => SplashScreen(
          onGetStarted: () {
            context.go('/login');
          },
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          onLoginSuccess: () => context.go('/home'),
          onNavigateToSignUp: () => context.push('/signup'),
          onNavigateToForgotPassword: () => context.push('/forgot-password'),
        ),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => SignUpScreen(
          onSignUpSuccess: () => context.go('/onboarding/step1'),
          onNavigateToLogin: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => ForgotPasswordScreen(
          onBackToLogin: () => context.pop(),
        ),
      ),
      GoRoute(
        path: '/onboarding/step1',
        builder: (context, state) => OnboardingStep1Screen(
          onBack: () => context.go('/login'),
          onSkip: () => context.go('/home'),
          onContinue: (country) => context.go('/onboarding/step2'),
        ),
      ),
      GoRoute(
        path: '/onboarding/step2',
        builder: (context, state) => OnboardingStep2Screen(
          onBack: () => context.go('/onboarding/step1'),
          onSkip: () => context.go('/home'),
          onContinue: (interests) => context.go('/onboarding/step3'),
        ),
      ),
      GoRoute(
        path: '/onboarding/step3',
        builder: (context, state) => OnboardingStep3Screen(
          onBack: () => context.go('/onboarding/step2'),
          onSkip: () => context.go('/home'),
          onGetStarted: (level) => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomeScreen(
          onNotificationTap: () => context.push('/notifications'),
          onOpportunityTap: (id) => context.push('/opportunity-detail/$id'),
          onCategoryTap: (category) => context.push('/explore?category=$category'),
          onNavTap: (index) {
            if (index == 1) context.go('/explore');
            if (index == 2) context.go('/applications');
            if (index == 3) context.go('/profile');
          },
        ),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) {
          final cat = state.uri.queryParameters['category'];
          return ExploreScreen(
            initialCategoryFilter: cat,
            onOpportunityTap: (id) => context.push('/opportunity-detail/$id'),
            onNavTap: (index) {
              if (index == 0) context.go('/home');
              if (index == 2) context.go('/applications');
              if (index == 3) context.go('/profile');
            },
          );
        },
      ),
      GoRoute(
        path: '/applications',
        builder: (context, state) => ApplicationsScreen(
          onOpportunityTap: (id) => context.push('/opportunity-detail/$id'),
          onNavTap: (index) {
            if (index == 0) context.go('/home');
            if (index == 1) context.go('/explore');
            if (index == 3) context.go('/profile');
          },
        ),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => ProfileScreen(
          onEditProfileTap: () async => await context.push('/edit-profile'),
          onSettingsTap: () => context.push('/settings'),
          onLogoutSuccess: () => context.go('/login'),
          onNavTap: (index) {
            if (index == 0) context.go('/home');
            if (index == 1) context.go('/explore');
            if (index == 2) context.go('/applications');
            if (index == 4) context.push('/settings');
          },
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => SettingsScreen(
          onBack: () => context.pop(),
          onEditProfileTap: () => context.push('/edit-profile'),
        ),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => EditProfileScreen(
          onBack: () => context.pop(true),
          onSaveChanges: () => context.pop(true),
        ),
      ),
      GoRoute(
        path: '/opportunity-detail/:id',
        builder: (context, state) {
          final oppId = state.pathParameters['id'];
          final oppExtra = state.extra as OpportunityModel?;
          return OpportunityDetailScreen(
            opportunityId: oppId,
            opportunity: oppExtra,
            onBack: () => context.pop(),
            onNavigateToApplications: () => context.go('/applications'),
          );
        },
      ),
      GoRoute(
        path: '/opportunity-detail',
        builder: (context, state) {
          final oppExtra = state.extra as OpportunityModel?;
          return OpportunityDetailScreen(
            opportunity: oppExtra,
            onBack: () => context.pop(),
            onNavigateToApplications: () => context.go('/applications'),
          );
        },
      ),
      GoRoute(
        path: '/apply',
        builder: (context, state) {
          final opp = state.extra as OpportunityModel? ??
              OpportunityModel(
                id: 'sample_opp_1',
                category: 'Scholarship',
                title: 'MasterCard Foundation Scholars Program',
                provider: 'MasterCard Foundation',
                subtitle: 'Full funding · Masters · Rwanda',
                description:
                    'Full tuition, accommodation, stipend, and mentorship for African students pursuing a Masters degree at partner universities',
                eligibility: 'African students · Masters level · GPA 3.0+',
                eligibleCountries: ['Rwanda', 'Kenya', 'Ghana', 'Uganda', 'Tanzania'],
                deadline: DateTime.now().add(const Duration(days: 12)),
                applicationUrl: 'https://mastercardfdn.org',
              );
          return ApplyScreen(opportunity: opp);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => NotificationsScreen(
          onNavTap: (index) {
            if (index == 0) context.go('/home');
            if (index == 1) context.go('/explore');
            if (index == 2) context.go('/applications');
            if (index == 3) context.go('/profile');
          },
        ),
      ),
      GoRoute(
        path: '/application-success',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'this role';
          final provider = state.uri.queryParameters['provider'] ?? 'the provider';
          return ApplicationSuccessScreen(
            opportunityTitle: title,
            providerName: provider,
          );
        },
      ),
      GoRoute(
        path: '/withdraw-success',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'this role';
          final provider = state.uri.queryParameters['provider'] ?? 'the provider';
          return WithdrawSuccessScreen(
            opportunityTitle: title,
            providerName: provider,
          );
        },
      ),

      // --- STARTUP / FOUNDER ROUTES ---
      GoRoute(
        path: '/startup/feed',
        builder: (context, state) => StartupFeedScreen(
          onNavTap: (index) {
            if (index == 1) context.go('/startup/my-posts');
            if (index == 2) context.go('/startup/applicants');
            if (index == 3) context.go('/startup/profile');
          },
        ),
      ),
      GoRoute(
        path: '/startup/post-opportunity',
        builder: (context, state) => PostOpportunityScreen(
          onNavTap: (index) {
            if (index == 0) context.go('/startup/feed');
            if (index == 1) context.go('/startup/my-posts');
            if (index == 2) context.go('/startup/applicants');
            if (index == 3) context.go('/startup/profile');
          },
        ),
      ),
      GoRoute(
        path: '/startup/my-posts',
        builder: (context, state) => MyPostsScreen(
          onNavTap: (index) {
            if (index == 0) context.go('/startup/feed');
            if (index == 2) context.go('/startup/applicants');
            if (index == 3) context.go('/startup/profile');
          },
        ),
      ),
      GoRoute(
        path: '/startup/post-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? state.uri.queryParameters['id'] ?? '';
          return PostDetailsScreen(opportunityId: id);
        },
      ),
      GoRoute(
        path: '/startup/post-details',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          return PostDetailsScreen(opportunityId: id);
        },
      ),
      GoRoute(
        path: '/startup/edit-post/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? state.uri.queryParameters['id'] ?? '';
          return EditPostScreen(opportunityId: id);
        },
      ),
      GoRoute(
        path: '/startup/edit-post',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          return EditPostScreen(opportunityId: id);
        },
      ),
      GoRoute(
        path: '/startup/analytics',
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/startup/applicants',
        builder: (context, state) => StartupApplicantsScreen(
          onNavTap: (index) {
            if (index == 0) context.go('/startup/feed');
            if (index == 1) context.go('/startup/my-posts');
            if (index == 3) context.go('/startup/profile');
          },
        ),
      ),
      GoRoute(
        path: '/startup/profile',
        builder: (context, state) => StartupProfileScreen(
          onNavTap: (index) {
            if (index == 0) context.go('/startup/feed');
            if (index == 1) context.go('/startup/my-posts');
            if (index == 2) context.go('/startup/applicants');
          },
        ),
      ),
      GoRoute(
        path: '/startup/settings',
        builder: (context, state) => const StartupSettingsScreen(),
      ),
      GoRoute(
        path: '/startup/applicant-details',
        builder: (context, state) {
          final app = state.extra as ApplicationModel? ??
              ApplicationModel(
                id: 'sample_app_1',
                opportunityId: 'sample_opp_1',
                opportunityTitle: 'Testing Opportunity',
                companyName: 'Zana Partner',
                applicantUid: 'student_123',
                coverLetter: 'I am highly passionate about this role and ready to join immediately.',
                availability: 'Immediate',
                status: 'Applied',
                appliedAt: DateTime.now(),
              );
          return ApplicantDetailScreen(application: app);
        },
      ),
      GoRoute(
        path: '/startup/messages',
        builder: (context, state) => const FounderMessagesScreen(),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_language_provider.dart';
import '../../../core/localization/app_translations.dart';
import '../../../core/utils/auth_error_formatter.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';
import '../../../data/services/firestore_service.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onSignUpSuccess;
  final VoidCallback? onNavigateToLogin;

  const SignUpScreen({
    super.key,
    this.onSignUpSuccess,
    this.onNavigateToLogin,
  });

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  String _accountType = 'student'; // 'student' or 'founder'
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false; // Terms & Conditions checkbox
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
    _companyNameController.addListener(_onCompanyNameChanged);
    _emailController.addListener(_onCompanyNameChanged);
  }

  void _onPasswordChanged() {
    setState(() {});
  }

  void _onCompanyNameChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  int _getPasswordStrength(String password) {
    if (password.length < 6) return 1;
    bool hasLetters = password.contains(RegExp(r'[a-zA-Z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (password.length >= 8 && hasLetters && hasDigits && hasSpecial) {
      return 3;
    } else if (password.length >= 6 && ((hasLetters && hasDigits) || (hasLetters && hasSpecial))) {
      return 2;
    }
    return 1;
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFFF59E0B);
      case 3:
        return const Color(0xFF10B981);
      default:
        return const Color(0xFFE2E8F0);
    }
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 1:
        return AppTranslations.tr('weak');
      case 2:
        return AppTranslations.tr('fair');
      case 3:
        return AppTranslations.tr('strong');
      default:
        return '';
    }
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the Terms & Conditions to proceed.';
      });
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = AppTranslations.tr('passwords_do_not_match');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await _authService.signUpWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (cred.user != null) {
        final newUser = UserModel(
          uid: cred.user!.uid,
          email: _emailController.text.trim(),
          fullName: _nameController.text.trim(),
          accountType: _accountType,
          companyName: _accountType == 'founder' ? _companyNameController.text.trim() : null,
          createdAt: DateTime.now(),
        );

        await _firestoreService.createUserProfile(newUser);

        if (mounted) {
          if (_accountType == 'founder') {
            context.go('/startup/feed');
          } else {
            widget.onSignUpSuccess?.call();
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = parseAuthErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    if (!_agreeToTerms) {
      setState(() {
        _errorMessage = 'Please agree to the Terms & Conditions to proceed.';
      });
      return;
    }

    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      final cred = await _authService.signInWithGoogle();
      if (cred != null && cred.user != null) {
        final existingProfile = await _firestoreService.getUserProfile(cred.user!.uid);

        if (existingProfile == null) {
          final newUser = UserModel(
            uid: cred.user!.uid,
            email: cred.user!.email ?? '',
            fullName: cred.user!.displayName ?? 'User',
            accountType: _accountType,
            companyName: _accountType == 'founder' ? _companyNameController.text.trim() : null,
            createdAt: DateTime.now(),
          );
          await _firestoreService.createUserProfile(newUser);
        }

        if (mounted) {
          if (_accountType == 'founder') {
            context.go('/startup/feed');
          } else {
            widget.onSignUpSuccess?.call();
          }
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = parseAuthErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Widget _buildLanguageDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: ['en', 'fr', 'sw', 'rw'].contains(appLanguageNotifier.value.languageCode) ? appLanguageNotifier.value.languageCode : 'en',
          isDense: true,
          icon: const Icon(Icons.language_rounded, size: 16, color: Color(0xFF2563EB)),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('🇺🇸 EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DropdownMenuItem(value: 'fr', child: Text('🇫🇷 FR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DropdownMenuItem(value: 'sw', child: Text('🇹ℤ SW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
            DropdownMenuItem(value: 'rw', child: Text('🇷🇼 RW', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          ],
          onChanged: (val) {
            if (val != null) {
              appLanguageNotifier.setLocale(Locale(val));
            }
          },
        ),
      ),
    );
  }

  Widget _buildAccountTypeCard({
    required String type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _accountType == type;
    return GestureDetector(
      onTap: () => setState(() => _accountType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF475569),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final password = _passwordController.text;
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _getPasswordStrength(password);
    final color = _getStrengthColor(strength);
    final text = _getStrengthText(strength);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: strength >= 1 ? color : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: strength >= 2 ? color : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: strength >= 3 ? color : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${AppTranslations.tr('password_strength')}: $text',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordMatchIndicator() {
    final confirm = _confirmPasswordController.text;
    if (confirm.isEmpty) return const SizedBox.shrink();

    final isMatch = confirm == _passwordController.text;
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: Row(
        children: [
          Icon(
            isMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: isMatch ? const Color(0xFF10B981) : const Color(0xFFEF4444),
          ),
          const SizedBox(width: 6),
          Text(
            isMatch ? 'Passwords match' : 'Passwords do not match',
            style: TextStyle(
              fontSize: 12,
              color: isMatch ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFounder = _accountType == 'founder';

    return ValueListenableBuilder<Locale>(
      valueListenable: appLanguageNotifier,
      builder: (context, locale, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top Half-Background Blue Header (Reference Design 3)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 50, bottom: 28, left: 20, right: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1D4ED8), Color(0xFF2563EB)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: _buildLanguageDropdown(),
                      ),
                      const SizedBox(height: 10),

                      // White App Logo Box
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          size: 36,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'ZANA',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Join Zana · Your opportunities, one tap away',
                        style: TextStyle(fontSize: 13, color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Form Body
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.tr('create_account'),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppTranslations.tr('signup_subtitle'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Banner if any
                        if (_errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Account Type Selector
                        const Text(
                          'I am a',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildAccountTypeCard(
                                type: 'student',
                                label: AppTranslations.tr('student_seeker'),
                                icon: Icons.school_outlined,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildAccountTypeCard(
                                type: 'founder',
                                label: AppTranslations.tr('founder_partner'),
                                icon: Icons.business_center_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Full Name Field
                        const Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter your full name';
                            return null;
                          },
                          decoration: _inputDecoration('e.g. Ishimwe Kevin'),
                        ),
                        const SizedBox(height: 18),

                        // Legal Business Name Field (ONLY FOR FOUNDERS)
                        if (isFounder) ...[
                          const Text(
                            'Legal Business Name',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _companyNameController,
                            validator: (val) {
                              if (isFounder && (val == null || val.trim().isEmpty)) {
                                return 'Please enter your legal business name';
                              }
                              return null;
                            },
                            decoration: _inputDecoration('e.g. Zana Tech Ltd'),
                          ),
                          const SizedBox(height: 18),
                        ],

                        // Email Field
                        Text(
                          isFounder ? 'Business Email' : AppTranslations.tr('email_address'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Please enter your email';
                            if (!val.contains('@')) return 'Enter a valid email address';
                            return null;
                          },
                          decoration: _inputDecoration(isFounder ? 'name@company.com' : AppTranslations.tr('email_hint')),
                        ),

                        // Red Note under Business Email (ONLY FOR FOUNDERS)
                        if (isFounder && _emailController.text.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Note: We will need to verify your business email. Please make sure the email is correct.',
                                    style: TextStyle(
                                      color: Color(0xFFDC2626),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),

                        // Password Field
                        Text(
                          AppTranslations.tr('password'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please enter a password';
                            if (val.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                          decoration: _inputDecoration(
                            AppTranslations.tr('password_hint'),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        _buildPasswordStrengthIndicator(),
                        const SizedBox(height: 18),

                        // Confirm Password Field
                        Text(
                          AppTranslations.tr('confirm_password'),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Please confirm your password';
                            if (val != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                          decoration: _inputDecoration(
                            AppTranslations.tr('confirm_password_hint'),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: const Color(0xFF94A3B8),
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        _buildPasswordMatchIndicator(),
                        const SizedBox(height: 18),

                        // Terms & Conditions Checkbox (As Requested!)
                        Row(
                          children: [
                            SizedBox(
                              height: 24,
                              width: 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                onChanged: (val) {
                                  if (val != null) setState(() => _agreeToTerms = val);
                                },
                                activeColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  text: 'I agree to the ',
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                                  children: const [
                                    TextSpan(
                                      text: 'Terms & Conditions',
                                      style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: ' & '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Primary Create Account Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_isLoading || _isGoogleLoading) ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  )
                                : Text(
                                    AppTranslations.tr('create_account'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // "Or" Divider
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              child: Text(
                                AppTranslations.tr('or'),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Google Social Auth Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignUp,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 0,
                            ),
                            child: _isGoogleLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(color: Color(0xFF2563EB), strokeWidth: 2.5),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Center(
                                          child: Text('G', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        AppTranslations.tr('sign_up_google'),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Login Footer Link
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppTranslations.tr('already_have_account'),
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: widget.onNavigateToLogin,
                                child: Text(
                                  AppTranslations.tr('log_in'),
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.8),
      ),
    );
  }
}

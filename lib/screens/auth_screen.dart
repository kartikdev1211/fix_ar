import 'package:fix_ar/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── VALUE NOTIFIERS (reactive state without setState)
final ValueNotifier<bool> isLoginMode = ValueNotifier(true);
final ValueNotifier<bool> isPasswordVisible = ValueNotifier(false);
final ValueNotifier<bool> isConfirmVisible = ValueNotifier(false);
final ValueNotifier<bool> isLoading = ValueNotifier(false);
final ValueNotifier<String?> errorMessage = ValueNotifier(null);

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {

  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  final _nameController     = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    isLoginMode.value       = true;
    isPasswordVisible.value = false;
    isConfirmVisible.value  = false;
    isLoading.value         = false;
    errorMessage.value      = null;

    _animController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  void _toggleMode() {
    isLoginMode.value = !isLoginMode.value;
    isPasswordVisible.value = false;
    isConfirmVisible.value  = false;
    errorMessage.value      = null;
    _emailController.clear();
    _passwordController.clear();
    _confirmController.clear();
    _nameController.clear();
    _animController.reset();
    _animController.forward();
  }

  Future<void> _submit() async {
    final email    = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name     = _nameController.text.trim();
    final confirm  = _confirmController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please fill in all fields.'; return;
    }
    if (!isLoginMode.value) {
      if (name.isEmpty) { errorMessage.value = 'Please enter your name.'; return; }
      if (password != confirm) { errorMessage.value = 'Passwords do not match.'; return; }
      if (password.length < 6) { errorMessage.value = 'Password must be at least 6 characters.'; return; }
    }

    errorMessage.value = null;
    isLoading.value    = true;
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _nameController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -60, left: -60,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.teal.withOpacity(0.1), Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.blue.withOpacity(0.1), Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      _buildLogo(),
                      const SizedBox(height: 36),
                      ValueListenableBuilder<bool>(
                        valueListenable: isLoginMode,
                        builder: (_, isLogin, __) => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isLogin ? 'Welcome back.' : 'Create account.',
                              style: GoogleFonts.syne(
                                fontSize: 28, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isLogin ? 'Sign in to continue fixing.' : 'Join FixAR and start repairing.',
                              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.white40),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      ValueListenableBuilder<bool>(
                        valueListenable: isLoginMode,
                        builder: (_, isLogin, __) => Column(
                          children: [
                            if (!isLogin) ...[
                              _InputField(
                                controller: _nameController,
                                label: 'Full name', hint: 'Kartik Kumar',
                                icon: Icons.person_outline_rounded,
                              ),
                              const SizedBox(height: 14),
                            ],
                            _InputField(
                              controller: _emailController,
                              label: 'Email address', hint: 'you@fixar.app',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            ValueListenableBuilder<bool>(
                              valueListenable: isPasswordVisible,
                              builder: (_, visible, __) => _InputField(
                                controller: _passwordController,
                                label: 'Password', hint: '••••••••',
                                icon: Icons.lock_outline_rounded,
                                isPassword: true, isVisible: visible,
                                onToggleVisibility: () => isPasswordVisible.value = !visible,
                              ),
                            ),
                            if (!isLogin) ...[
                              const SizedBox(height: 14),
                              ValueListenableBuilder<bool>(
                                valueListenable: isConfirmVisible,
                                builder: (_, visible, __) => _InputField(
                                  controller: _confirmController,
                                  label: 'Confirm password', hint: '••••••••',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true, isVisible: visible,
                                  onToggleVisibility: () => isConfirmVisible.value = !visible,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isLoginMode,
                        builder: (_, isLogin, __) => isLogin
                            ? Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              onTap: () {},
                              child: Text('Forgot password?',
                                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.teal)),
                            ),
                          ),
                        )
                            : const SizedBox(height: 10),
                      ),
                      const SizedBox(height: 24),
                      ValueListenableBuilder<String?>(
                        valueListenable: errorMessage,
                        builder: (_, error, __) => error != null
                            ? Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            color: AppColors.danger.withOpacity(0.08),
                            border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(error,
                                  style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.danger))),
                            ],
                          ),
                        )
                            : const SizedBox.shrink(),
                      ),
                      ValueListenableBuilder<bool>(
                        valueListenable: isLoading,
                        builder: (_, loading, __) => ValueListenableBuilder<bool>(
                          valueListenable: isLoginMode,
                          builder: (_, isLogin, __) => GestureDetector(
                            onTap: loading ? null : _submit,
                            child: Container(
                              width: double.infinity, height: 54,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.xl),
                                gradient: loading ? null : AppGradients.brand,
                                color: loading ? AppColors.white6 : null,
                              ),
                              child: Center(
                                child: loading
                                    ? SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.teal, strokeWidth: 2,
                                  ),
                                )
                                    : Text(
                                  isLogin ? 'Sign In' : 'Create Account',
                                  style: GoogleFonts.syne(
                                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(children: [
                        Expanded(child: Divider(color: AppColors.white8)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.white25)),
                        ),
                        Expanded(child: Divider(color: AppColors.white8)),
                      ]),
                      const SizedBox(height: 20),
                      _GoogleButton(),
                      const SizedBox(height: 28),
                      ValueListenableBuilder<bool>(
                        valueListenable: isLoginMode,
                        builder: (_, isLogin, __) => Center(
                          child: GestureDetector(
                            onTap: _toggleMode,
                            child: RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: isLogin ? "Don't have an account? " : 'Already have an account? ',
                                  style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.white35),
                                ),
                                TextSpan(
                                  text: isLogin ? 'Sign Up' : 'Sign In',
                                  style: GoogleFonts.syne(
                                    fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal,
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppGradients.brandDiagonal,
          ),
          child: const Icon(Icons.build_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(children: [
            TextSpan(text: 'Fix', style: GoogleFonts.syne(
              fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white,
            )),
            TextSpan(text: 'AR', style: GoogleFonts.syne(
              fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.teal,
            )),
          ]),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label, hint;
  final IconData icon;
  final bool isPassword, isVisible;
  final VoidCallback? onToggleVisibility;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller, required this.label, required this.hint, required this.icon,
    this.isPassword = false, this.isVisible = false,
    this.onToggleVisibility, this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.white50,
        )),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.white4,
            border: Border.all(color: AppColors.white8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, color: AppColors.white25, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: isPassword && !isVisible,
                  keyboardType: keyboardType,
                  style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.dmSans(fontSize: 14, color: AppColors.white20),
                    border: InputBorder.none, isDense: true,
                  ),
                ),
              ),
              if (isPassword && onToggleVisibility != null)
                GestureDetector(
                  onTap: onToggleVisibility,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(
                      isVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                      color: AppColors.white25, size: 18,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        color: AppColors.white4,
        border: Border.all(color: AppColors.white8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20, height: 20,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
            child: const Center(
              child: Text('G', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.googleBlue,
              )),
            ),
          ),
          const SizedBox(width: 10),
          Text('Continue with Google', style: GoogleFonts.dmSans(
            fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.white60,
          )),
        ],
      ),
    );
  }
}
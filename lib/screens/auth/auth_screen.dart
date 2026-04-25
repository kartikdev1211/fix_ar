import 'package:fix_ar/screens/auth/bloc/auth_bloc.dart';
import 'package:fix_ar/screens/auth/bloc/auth_event.dart';
import 'package:fix_ar/screens/auth/bloc/auth_state.dart';
import 'package:fix_ar/widgets/app_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fix_ar/constants/constant.dart';
import 'package:fix_ar/widgets/app_widgets.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _nameController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmVisible = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);

    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  void _submit(AuthState state) {
    final bloc = context.read<AuthBloc>();

    if (state.isLogin) {
      bloc.add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    } else {
      bloc.add(
        SignUpRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          confirmPassword: _confirmController.text.trim(),
        ),
      );
    }
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned(
              top: -60,
              left: -60,
              child: AppGlowBackground(color: AppColors.teal, size: 300),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: AppGlowBackground(color: AppColors.blue, size: 280),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 48),
                            _buildLogo(),
                            const SizedBox(height: 36),

                            /// Title
                            Text(
                              state.isLogin
                                  ? 'Welcome back.'
                                  : 'Create account.',
                              style: GoogleFonts.syne(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 32),

                            /// Name (Signup)
                            if (!state.isLogin)
                              InputField(
                                controller: _nameController,
                                label: 'Full name',
                                hint: 'Kartik Kumar',
                                icon: Icons.person_outline_rounded,
                              ),

                            const SizedBox(height: 14),

                            InputField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'you@fixar.app',
                              icon: Icons.email_outlined,
                            ),

                            const SizedBox(height: 14),

                            InputField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••',
                              icon: Icons.lock_outline,
                              isPassword: true,
                              isVisible: isPasswordVisible,
                              onToggleVisibility: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),

                            if (!state.isLogin) ...[
                              const SizedBox(height: 14),
                              InputField(
                                controller: _confirmController,
                                label: 'Confirm',
                                hint: '••••••',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                isVisible: isConfirmVisible,
                                onToggleVisibility: () {
                                  setState(() {
                                    isConfirmVisible = !isConfirmVisible;
                                  });
                                },
                              ),
                            ],

                            const SizedBox(height: 20),

                            /// Error
                            if (state.error != null)
                              Text(
                                state.error!,
                                style: const TextStyle(color: Colors.red),
                              ),

                            const SizedBox(height: 20),

                            /// Button
                            AppGradientButton(
                              label: state.isLogin
                                  ? 'Sign In'
                                  : 'Create Account',
                              isLoading: state.isLoading,
                              onTap: () => _submit(state),
                            ),

                            const SizedBox(height: 20),

                            /// Toggle
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  context.read<AuthBloc>().add(
                                    ToggleAuthMode(),
                                  );
                                },
                                child: Text(
                                  state.isLogin
                                      ? "Don't have an account? Sign Up"
                                      : "Already have an account? Sign In",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: const [
        Icon(Icons.build, color: Colors.white),
        SizedBox(width: 10),
        Text(
          'FixAR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
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
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.white4,
        border: Border.all(color: AppColors.white8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Center(
              child: Text(
                'G',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.googleBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Continue with Google',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.white60,
            ),
          ),
        ],
      ),
    );
  }
}

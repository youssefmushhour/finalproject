import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';
import 'register_screen.dart';
import '../../main_layout/ui/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(text: "Masrou", style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, color: AppColors.deepBlue, fontFamily: 'Cairo')),
                              TextSpan(text: "fy", style: TextStyle(fontSize: 35, fontWeight: FontWeight.w900, color: AppColors.emeraldGreen, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.deepBlue, fontFamily: 'Cairo')),
                    const SizedBox(height: 8),
                    const Text("Login to manage your expenses", style: TextStyle(fontSize: 15, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                    const SizedBox(height: 40),
                    CustomTextField(
                      hintText: "Email Address",
                      prefixIcon: Icons.email_outlined,
                      controller: emailController,
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: "Password",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: passwordController,
                      validator: (value) => value!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: state is AuthLoading ? "Processing..." : "Login",
                      onPressed: state is AuthLoading 
                      ? () {} 
                      : () {
                          if (formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                              LoginRequested(emailController.text.trim(), passwordController.text.trim()),
                            );
                          }
                        },
                    ),
                    const SizedBox(height: 20),
                    const Center(child: Text("Or", style: TextStyle(color: AppColors.textSecondary))),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: OutlinedButton.icon(
                        onPressed: state is AuthLoading 
                        ? () {} 
                        : () => context.read<AuthBloc>().add(GoogleSignInRequested()),
                        icon: Image.network(
                          'https://cdn1.iconfinder.com/data/icons/google-s-logo/150/Google_Icons-09-512.png', 
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 30, color: Colors.red),
                        ),
                        label: const Text("Google", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          backgroundColor: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("No account?", style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo')),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text("Sign Up", style: TextStyle(color: AppColors.emeraldGreen, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../logic/auth_bloc.dart';
import '../logic/auth_event.dart';
import '../logic/auth_state.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account Created! Please login now."),
              backgroundColor: AppColors.emeraldGreen,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 22, color: AppColors.deepBlue),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(text: "Masrou", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.deepBlue, fontFamily: 'Cairo')),
                              TextSpan(text: "fy", style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.emeraldGreen, fontFamily: 'Cairo')),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.deepBlue, fontFamily: 'Cairo')),
                    const SizedBox(height: 8),
                    const Text("Start managing your expenses with friends", style: TextStyle(fontSize: 16, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                    const SizedBox(height: 40),
                    CustomTextField(
                      hintText: "Full Name",
                      prefixIcon: Icons.person_outline,
                      controller: nameController,
                      validator: (value) => value!.isEmpty ? "Name is required" : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: "Email Address",
                      prefixIcon: Icons.email_outlined,
                      controller: emailController,
                      validator: (value) => value!.isEmpty ? "Email is required" : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      hintText: "Password",
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: passwordController,
                      validator: (value) => value!.length < 6 ? "Min 6 characters" : null,
                    ),
                    const SizedBox(height: 40),
                    CustomButton(
                      text: state is AuthLoading ? "Processing..." : "Sign Up",
                      onPressed: state is AuthLoading
                          ? () {}
                          : () {
                              if (formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                context.read<AuthBloc>().add(
                                      RegisterRequested(
                                        name: nameController.text.trim(),
                                        email: emailController.text.trim(),
                                        password: passwordController.text.trim(),
                                      ),
                                    );
                              }
                            },
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: AppColors.textSecondary, fontFamily: 'Cairo')),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Login", style: TextStyle(color: AppColors.emeraldGreen, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
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
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../Core/Utils/App Colors.dart'; // Adjust path as needed
import '../../../../core/Utils/Shared Methods.dart'; // Adjust path as needed
import '../../Login/presenation/view/login_view.dart'; // Adjust path for LoginView
import '../manger/forget_password_cubit.dart';
import '../manger/forget_password_state.dart'; // Adjust path as needed

class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  _ForgetPasswordViewState createState() => _ForgetPasswordViewState();
}

class _ForgetPasswordViewState extends State<ForgetPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  void _showSnackBar(BuildContext context, String message, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (context) => ForgetPasswordCubit(auth: FirebaseAuth.instance),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    const ForgetPasswordBackground(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: size.height * 0.35),
                            const FadeInText(
                              text: 'Reset Password',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              delay: 500,
                            ),
                            const SizedBox(height: 4),
                            const FadeInText(
                              textAlign: TextAlign.start,
                              text: 'Enter your email to receive a reset link',
                              style: TextStyle(fontSize: 14, color: Colors.black54),
                              delay: 700,
                            ),
                            const SizedBox(height: 24),
                            _buildTextField(),
                            const SizedBox(height: 24),
                            BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
                              listener: (context, state) {
                                if (state is ForgetPasswordSuccess) {
                                  _showSnackBar(context, state.message, true);
                                  Future.delayed(const Duration(seconds: 2), () {
                                    navigateTo(context, const LoginView());
                                  });
                                } else if (state is ForgetPasswordFailure) {
                                  _showSnackBar(context, state.errorMessage, false);
                                }
                              },
                              builder: (context, state) {
                                return AnimatedButton(
                                  text: 'SEND RESET LINK',
                                  isLoading: state is ForgetPasswordLoading,
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ?? false) {
                                      context.read<ForgetPasswordCubit>().resetPassword(
                                        _emailController.text.trim(),
                                      );
                                    }
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildBackToLogin(context),
                          ],
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
    );
  }

  Widget _buildTextField() {
    return Form(
      key: _formKey,
      child: CustomTextField(
        label: 'Enter your Email',
        icon: Icons.email,
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(errorText: 'Email is required'),
          FormBuilderValidators.email(
            errorText: 'Please enter a valid email address',
            regex: RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
          ),
        ]),
      ),
    );
  }

  Widget _buildBackToLogin(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Remembered your password?",
          style: TextStyle(fontSize: 12, color: Colors.black),
        ),
        TextButton(
          onPressed: () => navigateTo(context, const LoginView()),
          child: Text(
            "Log in",
            style: TextStyle(
              fontSize: 12,
              color: AppColorsData.primaryColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Text Field
class CustomTextField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    required this.label,
    this.icon,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: AppColorsData.primaryColor) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColorsData.primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      validator: validator,
    );
  }
}

// Background Components
class ForgetPasswordWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColorsData.primaryColor
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.lineTo(0, size.height * 0.26);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.36,
      size.width * 0.5,
      size.height * 0.26,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.15,
      size.width,
      size.height * 0.19,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ForgetPasswordBackground extends StatelessWidget {
  const ForgetPasswordBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(color: Colors.white),
            child: CustomPaint(painter: ForgetPasswordWavePainter()),
          ),
        ),
        Positioned(
          top: 155,
          right: 20,
          child: SizedBox(
            width: 130,
            height: 130,
            child: buildLogo(),
          ),
        ),
      ],
    );
  }
}

// Animation Components
class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final int delay;
  final TextAlign? textAlign;

  const FadeInText({
    super.key,
    required this.text,
    required this.style,
    required this.delay,
    this.textAlign = TextAlign.center,
  });

  @override
  State<FadeInText> createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.delay),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: SizedBox(
        width: double.infinity,
        child: Text(
          widget.text,
          style: widget.style,
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final int animationDuration;

  const AnimatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width,
    this.height,
    this.backgroundColor,
    this.textColor,
    this.animationDuration = 200,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animationDuration),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading) _controller.forward();
      },
      onTapUp: (_) {
        if (!widget.isLoading) {
          _controller.reverse();
          widget.onPressed();
        }
      },
      onTapCancel: () {
        if (!widget.isLoading) _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.width ?? double.infinity,
              height: widget.height ?? 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.backgroundColor ?? AppColorsData.primaryColor,
                  foregroundColor: widget.textColor ?? Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.textColor ?? Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget buildLogo() {
  return Container(
    width: 170,
    height: 170,
    child: Center(
      child: Image.asset(
        "assets/images/logo.png",
        width: 170 * 0.7,
        height: 170 * 0.7,
      ),
    ),
  );
}
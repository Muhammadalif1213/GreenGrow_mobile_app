import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_bloc.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_event.dart';
import 'package:greengrow_app/presentation/blocs/auth/auth_state.dart';
import 'package:greengrow_app/presentation/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:greengrow_app/core/providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // Always set to farmer role (2)
  final int _farmerRoleId = 2;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              username: _usernameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              fullName: _fullNameController.text,
              phoneNumber: _phoneNumberController.text.isNotEmpty ? _phoneNumberController.text : null,
              roleId: _farmerRoleId, // Always use farmer role ID
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.withOpacity(0.8),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is AuthSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state is Authenticated) {
            // Update FCM token ke backend setelah register
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);
            await authProvider.loadUserProfile();
            authProvider.updateFcmTokenToBackend();
            // Setelah register berhasil, arahkan ke halaman login
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        child: Stack(
          children: [
            // Background Image dengan Blur Effect
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  // Ganti dengan path gambar Anda
                  image: AssetImage('assets/images/login.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Blur Effect untuk Background
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
              child: Container(
                color: Colors.black.withOpacity(0.2),
              ),
            ),
            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Hapus IconButton back di sini
                        const Expanded(
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance untuk centering
                      ],
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          // Logo atau Icon App
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.1),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.agriculture,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Glassmorphism Container
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                padding: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Create Farmer Account',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Join our farming community',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 32),

                                      // Username Field
                                      _buildGlassTextField(
                                        controller: _usernameController,
                                        labelText: 'Username',
                                        icon: Icons.person_outline,
                                        validator: ValidationBuilder()
                                            .minLength(3,
                                                'Username must be at least 3 characters')
                                            .required('Username is required')
                                            .build(),
                                      ),
                                      const SizedBox(height: 16),

                                      // Full Name Field
                                      _buildGlassTextField(
                                        controller: _fullNameController,
                                        labelText: 'Full Name',
                                        icon: Icons.badge_outlined,
                                        validator: ValidationBuilder()
                                            .minLength(2,
                                                'Full name must be at least 2 characters')
                                            .required('Full name is required')
                                            .build(),
                                      ),
                                      const SizedBox(height: 16),

                                      // Email Field
                                      _buildGlassTextField(
                                        controller: _emailController,
                                        labelText: 'Email',
                                        icon: Icons.email_outlined,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: ValidationBuilder()
                                            .email('Please enter a valid email')
                                            .required('Email is required')
                                            .build(),
                                      ),
                                      const SizedBox(height: 16),

                                      // Phone Number Field
                                      _buildGlassTextField(
                                        controller: _phoneNumberController,
                                        labelText: 'Phone Number (Optional)',
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 16),

                                      // Password Field
                                      _buildGlassTextField(
                                        controller: _passwordController,
                                        labelText: 'Password',
                                        icon: Icons.lock_outlined,
                                        obscureText: _obscurePassword,
                                        validator: ValidationBuilder()
                                            .minLength(8,
                                                'Password must be at least 8 characters')
                                            .required('Password is required')
                                            .build(),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Confirm Password Field
                                      _buildGlassTextField(
                                        controller: _confirmPasswordController,
                                        labelText: 'Confirm Password',
                                        icon: Icons.lock_outline,
                                        obscureText: _obscureConfirmPassword,
                                        validator: (value) {
                                          if (value !=
                                              _passwordController.text) {
                                            return 'Passwords do not match';
                                          }
                                          return null;
                                        },
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color:
                                                Colors.white.withOpacity(0.7),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword =
                                                  !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 32),

                                      // Register Button
                                      BlocBuilder<AuthBloc, AuthState>(
                                        builder: (context, state) {
                                          return Container(
                                            height: 56,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.3),
                                                  Colors.white.withOpacity(0.1),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: ElevatedButton(
                                              onPressed: state is AuthLoading
                                                  ? null
                                                  : _handleRegister,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Colors.transparent,
                                                shadowColor: Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: state is AuthLoading
                                                  ? const SizedBox(
                                                      height: 24,
                                                      width: 24,
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: Colors.white,
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Register',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
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
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white.withOpacity(0.7),
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.white.withOpacity(0.5),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.redAccent,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          errorStyle: const TextStyle(
            color: Colors.redAccent,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

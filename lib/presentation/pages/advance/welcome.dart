import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _backgroundController;
  late AnimationController _particleController;
  late AnimationController _typewriterController;

  late Animation<double> _shimmerAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _particleAnimation;
  late Animation<int> _typewriterAnimation;

  String fullText = "GREEN GROW";
  String displayText = "";

  @override
  void initState() {
    super.initState();

    // Shimmer animation for text
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _shimmerAnimation = Tween<double>(
      begin: -2,
      end: 2,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Background zoom animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
    _backgroundAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_particleController);

    // Typewriter animation
    _typewriterController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _typewriterAnimation = IntTween(
      begin: 0,
      end: fullText.length,
    ).animate(CurvedAnimation(
      parent: _typewriterController,
      curve: Curves.easeInOut,
    ));

    _typewriterController.addListener(() {
      setState(() {
        displayText = fullText.substring(0, _typewriterAnimation.value);
      });
    });

    // Start typewriter after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _typewriterController.forward();
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    _typewriterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _particleController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/daun.jpg'),
                fit: BoxFit.cover,
                scale: _backgroundAnimation.value,
              ),
            ),
            child: Stack(
              children: [
                // Animated particles
                ...List.generate(15, (index) {
                  return AnimatedBuilder(
                    animation: _particleAnimation,
                    builder: (context, child) {
                      double offset =
                          (_particleAnimation.value + index * 0.1) % 1.0;
                      return Positioned(
                        left:
                            (index * 50.0) % MediaQuery.of(context).size.width,
                        top: MediaQuery.of(context).size.height * offset,
                        child: Transform.rotate(
                          angle: _particleAnimation.value * 2 * math.pi,
                          child: Opacity(
                            opacity: 0.3,
                            child: Icon(
                              Icons.eco,
                              color: Colors.green.withOpacity(0.5),
                              size: 20 + (index % 3) * 5,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),

                // Main content
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(flex: 2),

                            // Title section with shimmer only (no breathing)
                            AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // GREEN text with shimmer and typewriter
                                    Container(
                                      width: double.infinity,
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            begin: Alignment(
                                                _shimmerAnimation.value - 1, 0),
                                            end: Alignment(
                                                _shimmerAnimation.value + 1, 0),
                                            colors: [
                                              Colors.white.withOpacity(0.8),
                                              Colors.white,
                                              Colors.yellow.withOpacity(0.9),
                                              Colors.white,
                                              Colors.white.withOpacity(0.8),
                                            ],
                                            stops: const [
                                              0.0,
                                              0.35,
                                              0.5,
                                              0.65,
                                              1.0
                                            ],
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          displayText.length >= 5
                                              ? displayText.substring(0, 5)
                                              : displayText,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 72,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -2,
                                            height: 0.9,
                                          ),
                                        ),
                                      ),
                                    ),

                                    // GROW text with shimmer and typewriter
                                    Container(
                                      width: double.infinity,
                                      child: ShaderMask(
                                        shaderCallback: (bounds) {
                                          return LinearGradient(
                                            begin: Alignment(
                                                _shimmerAnimation.value - 1, 0),
                                            end: Alignment(
                                                _shimmerAnimation.value + 1, 0),
                                            colors: [
                                              Colors.white.withOpacity(0.8),
                                              Colors.white,
                                              Colors.green.withOpacity(0.9),
                                              Colors.white,
                                              Colors.white.withOpacity(0.8),
                                            ],
                                            stops: const [
                                              0.0,
                                              0.35,
                                              0.5,
                                              0.65,
                                              1.0
                                            ],
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          displayText.length > 6
                                              ? displayText.substring(6)
                                              : "",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 72,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                            letterSpacing: -2,
                                            height: 0.8,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),

                            const SizedBox(height: 30),

                            // Description text (static, no floating)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                    sigmaX: 10.0, sigmaY: 10.0),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    "GreenGrow hadir untuk membantu petani menjaga lingkungan dan tanaman dengan cara yang lebih mudah, cerdas, dan berkelanjutan",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      height: 1.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const Spacer(flex: 3),

                            // Sign Up Button (static, no floating)
                            _AnimatedGlassButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/register');
                              },
                              text: "Sign Up",
                            ),

                            const SizedBox(height: 16),

                            // Login Button with hover effect
                            _AnimatedTextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              text: "Login",
                            ),

                            const Spacer(flex: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Custom animated glass button widget
class _AnimatedGlassButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const _AnimatedGlassButton({
    required this.onPressed,
    required this.text,
  });

  @override
  State<_AnimatedGlassButton> createState() => _AnimatedGlassButtonState();
}

class _AnimatedGlassButtonState extends State<_AnimatedGlassButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _glowAnimation = Tween<double>(
      begin: 0.1,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(_glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _isPressed ? 15.0 : 10.0,
                    sigmaY: _isPressed ? 15.0 : 10.0,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(_glowAnimation.value),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom animated text button widget
class _AnimatedTextButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;

  const _AnimatedTextButton({
    required this.onPressed,
    required this.text,
  });

  @override
  State<_AnimatedTextButton> createState() => _AnimatedTextButtonState();
}

class _AnimatedTextButtonState extends State<_AnimatedTextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _colorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.green.shade300,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: _colorAnimation.value,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

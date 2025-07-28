import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/theme_service.dart';

/// Congratulations screen shown after successful premium subscription
class PremiumCongratulationsScreen extends StatefulWidget {
  const PremiumCongratulationsScreen({super.key});

  @override
  State<PremiumCongratulationsScreen> createState() =>
      _PremiumCongratulationsScreenState();
}

class _PremiumCongratulationsScreenState
    extends State<PremiumCongratulationsScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _confettiController;
  late AnimationController _crownController;
  late AnimationController _featuresController;

  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _crownScaleAnimation;
  late Animation<double> _crownRotationAnimation;
  late Animation<double> _confettiAnimation;

  final List<String> _premiumFeatures = [
    '🚫 Complete ad-free experience',
    '🔥 Access to Top Secret category',
    '🎨 All premium themes & customization',
    '⭐ Exclusive pickup line collections',
    '🚀 Enhanced app performance',
    '💎 Premium user badge & status',
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main animation controller for overall timing
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Confetti animation controller
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Crown animation controller
    _crownController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Features list animation controller
    _featuresController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Fade in animation
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    // Scale animation for congratulations text
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    // Crown scale animation
    _crownScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _crownController,
      curve: Curves.elasticOut,
    ));

    // Crown rotation animation
    _crownRotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _crownController,
      curve: Curves.easeInOut,
    ));

    // Confetti animation
    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));
  }

  void _startAnimations() {
    // Start main animation immediately
    _mainController.forward();

    // Start crown animation after a delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _crownController.forward();
      }
    });

    // Start confetti animation
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _confettiController.forward();
      }
    });

    // Start features animation
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _featuresController.forward();
      }
    });

    // Repeat crown animation
    _crownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            _crownController.reset();
            _crownController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    _crownController.dispose();
    _featuresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final currentThemeData = themeService.currentThemeData;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              currentThemeData.gradientColors.first.withValues(alpha: 0.3),
              currentThemeData.gradientColors.last.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Confetti particles
              _buildConfettiLayer(),

              // Main content
              AnimatedBuilder(
                animation: _fadeInAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeInAnimation.value,
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                const SizedBox(height: 40),

                                // Crown icon with animations
                                _buildAnimatedCrown(),

                                const SizedBox(height: 32),

                                // Congratulations text
                                _buildCongratulationsText(),

                                const SizedBox(height: 24),

                                // Subtitle
                                _buildSubtitle(),

                                const SizedBox(height: 40),

                                // Premium features list
                                _buildFeaturesList(),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),

                        // Continue button
                        _buildContinueButton(),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfettiLayer() {
    return AnimatedBuilder(
      animation: _confettiAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(_confettiAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedCrown() {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_crownScaleAnimation, _crownRotationAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _crownScaleAnimation.value,
          child: Transform.rotate(
            angle: _crownRotationAnimation.value *
                math.sin(_crownController.value * 4 * math.pi),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow effect
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFFD700).withValues(alpha: 0.3),
                        const Color(0xFFFFD700).withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
                // Main crown container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                        Color(0xFFFF8C00),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.6),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    size: 65,
                    color: Colors.white,
                  ),
                ),
                // Sparkle effects
                ...List.generate(6, (index) {
                  final angle = (index * 60) * math.pi / 180;
                  final radius = 70.0;
                  return Transform.translate(
                    offset: Offset(
                      math.cos(angle + _crownController.value * 2 * math.pi) *
                          radius,
                      math.sin(angle + _crownController.value * 2 * math.pi) *
                          radius,
                    ),
                    child: Transform.scale(
                      scale: 0.5 +
                          0.5 *
                              math.sin(
                                  _crownController.value * 4 * math.pi + index),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCongratulationsText() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Text(
            'Congratulations!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Welcome to Premium! 🎉\nYou now have access to all exclusive features',
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _premiumFeatures.asMap().entries.map((entry) {
        final index = entry.key;
        final feature = entry.value;

        return AnimatedBuilder(
          animation: _featuresController,
          builder: (context, child) {
            final delay = index * 0.15;
            final animationValue =
                (_featuresController.value - delay).clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.8),
                        Theme.of(context)
                            .colorScheme
                            .surface
                            .withValues(alpha: 0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    feature,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
          ),
          child: const Text(
            'Get Started',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom painter for confetti particles
class ConfettiPainter extends CustomPainter {
  final double animationValue;
  final List<ConfettiParticle> particles;

  ConfettiPainter(this.animationValue) : particles = _generateParticles();

  static List<ConfettiParticle> _generateParticles() {
    final random = math.Random();
    return List.generate(80, (index) {
      return ConfettiParticle(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.2 - 0.1, // Start above screen
        color: [
          const Color(0xFFFFD700), // Gold
          const Color(0xFFFFA500), // Orange
          const Color(0xFFFF6B6B), // Red
          const Color(0xFF4ECDC4), // Teal
          const Color(0xFF45B7D1), // Blue
          const Color(0xFF96CEB4), // Green
          const Color(0xFFDDA0DD), // Plum
          const Color(0xFFFFB6C1), // Light pink
        ][random.nextInt(8)],
        size: random.nextDouble() * 10 + 3,
        rotation: random.nextDouble() * 2 * math.pi,
        speed: random.nextDouble() * 0.5 + 0.3, // Varying fall speeds
        rotationSpeed: (random.nextDouble() - 0.5) * 4, // Rotation speed
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      final x = particle.x * size.width +
          math.sin(animationValue * 2 * math.pi) * 20; // Slight horizontal sway
      final y = particle.y * size.height +
          (animationValue * size.height * 1.5 * particle.speed);

      if (y > size.height + 30) continue;

      // Fade out as particles fall and at the end of animation
      final alpha = (1 - animationValue * 0.3) *
          (1 - math.max(0, (y - size.height * 0.8) / (size.height * 0.2)));
      paint.color = particle.color.withValues(alpha: alpha.clamp(0.0, 1.0));

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation +
          animationValue * particle.rotationSpeed * math.pi);

      // Draw different shapes for variety
      if (particle.size > 7) {
        // Larger particles as stars
        _drawStar(canvas, paint, particle.size);
      } else {
        // Smaller particles as rounded rectangles
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size * 0.6,
            ),
            Radius.circular(particle.size / 3),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double size) {
    final path = Path();
    final radius = size / 2;
    final innerRadius = radius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * math.pi) / 5;
      final r = i.isEven ? radius : innerRadius;
      final x = math.cos(angle) * r;
      final y = math.sin(angle) * r;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Data class for confetti particles
class ConfettiParticle {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double rotation;
  final double speed;
  final double rotationSpeed;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.rotation,
    required this.speed,
    required this.rotationSpeed,
  });
}

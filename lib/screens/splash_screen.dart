import 'package:flutter/material.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  static const kPrimary = Color(0xFF7d1616);

  late AnimationController _iconCtrl;
  late AnimationController _rippleCtrl;
  late AnimationController _textCtrl;
  late AnimationController _particleCtrl;

  late Animation<double> _iconScale;
  late Animation<double> _iconRotate;
  late Animation<double> _iconOpacity;
  late Animation<double> _nameOpacity;
  late Animation<double> _nameSlide;
  late Animation<double> _lineWidth;
  late Animation<double> _taglineOpacity;
  late Animation<double> _taglineSlide;
  late Animation<double> _dotsOpacity;

  @override
  void initState() {
    super.initState();

    _iconCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _rippleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // Icon animations
    _iconScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.elasticOut),
    );
    _iconRotate = Tween(begin: -pi, end: 0.0).animate(
      CurvedAnimation(
        parent: _iconCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _iconOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _iconCtrl,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _nameOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _nameSlide = Tween(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _lineWidth = Tween(begin: 0.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.4, 0.75, curve: Curves.easeOut),
      ),
    );
    _taglineOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.55, 0.85, curve: Curves.easeIn),
      ),
    );
    _taglineSlide = Tween(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOut),
      ),
    );
    _dotsOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textCtrl,
        curve: const Interval(0.8, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start sequence
    _iconCtrl.forward().then((_) => _textCtrl.forward());

    // Navigate after 3.5s
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _iconCtrl.dispose();
    _rippleCtrl.dispose();
    _textCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimary,
      body: Stack(
        alignment: Alignment.center,
        children: [

          // Floating particles
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              size: Size.infinite,
              painter: _ParticlePainter(_particleCtrl.value),
            ),
          ),

          // Ripple rings
          AnimatedBuilder(
            animation: _rippleCtrl,
            builder: (_, __) => CustomPaint(
              size: Size.infinite,
              painter: _RipplePainter(_rippleCtrl.value),
            ),
          ),

          // Center content
          AnimatedBuilder(
            animation: Listenable.merge([_iconCtrl, _textCtrl]),
            builder: (_, __) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Icon
                  Opacity(
                    opacity: _iconOpacity.value,
                    child: Transform.rotate(
                      angle: _iconRotate.value,
                      child: Transform.scale(
                        scale: _iconScale.value,
                        child: _buildIcon(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // App name
                  Opacity(
                    opacity: _nameOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _nameSlide.value),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          children: [
                            TextSpan(text: 'Enstab'),
                            TextSpan(
                              text: 'House',
                              style: TextStyle(
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Animated line
                  Container(
                    width: _lineWidth.value,
                    height: 1.5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tagline
                  Opacity(
                    opacity: _taglineOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _taglineSlide.value),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _dot(),
                          const SizedBox(width: 8),
                          const Text(
                            'YOUR CAMPUS, CONNECTED',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 2.5,
                              color: Colors.white54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _dot(),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 44),

                  // Loading dots
                  Opacity(
                    opacity: _dotsOpacity.value,
                    child: const _LoadingDots(),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.28),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.home_rounded,
        color: Colors.white,
        size: 56,
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 4, height: 4,
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

// Ripple rings
class _RipplePainter extends CustomPainter {
  final double t;
  _RipplePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (int i = 0; i < 3; i++) {
      final p = (t + i / 3) % 1.0;
      canvas.drawCircle(
        center,
        65 + p * 240,
        Paint()
          ..color = Colors.white.withOpacity((1 - p) * 0.12)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(_RipplePainter o) => o.t != t;
}

// Floating particles
class _ParticlePainter extends CustomPainter {
  final double t;
  _ParticlePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    for (int i = 0; i < 20; i++) {
      final speed  = 0.06 + rng.nextDouble() * 0.1;
      final startX = rng.nextDouble() * size.width;
      final phase  = (t * speed + i / 20) % 1.0;
      final y      = size.height - phase * size.height * 1.4;
      final radius = 1.5 + rng.nextDouble() * 3.5;
      canvas.drawCircle(
        Offset(startX, y),
        radius,
        Paint()..color = Colors.white.withOpacity((1 - phase) * 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter o) => o.t != t;
}

// Loading dots
class _LoadingDots extends StatefulWidget {
  const _LoadingDots();

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(3, (i) {
      final c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      Future.delayed(Duration(milliseconds: i * 180), () {
        if (mounted) c.repeat(reverse: true);
      });
      return c;
    });
  }

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _ctrls[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6 + _ctrls[i].value * 2,
            height: 6 + _ctrls[i].value * 2,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(0.35 + _ctrls[i].value * 0.65),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
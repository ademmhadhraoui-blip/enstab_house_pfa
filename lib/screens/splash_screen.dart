import 'package:enstabhouse/constants.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Shimmer animation controller
  late AnimationController _shimmerController;
  late Animation<double> _shimmerAnimation;

  // Scale-in / pulse for the icon
  late AnimationController _iconController;
  late Animation<double> _iconScale;

  // Fade-in for the whole content
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // ── Fade-in ──────────────────────────────────────────
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();

    // ── Icon pop-in then pulse ────────────────────────────
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _iconScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );

    // ── Shimmer sweep ─────────────────────────────────────
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _shimmerAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    // ── Navigate after 3 seconds ──────────────────────────
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _iconController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Animated school icon ───────────────────
              Hero(
                tag: 'school-icon',
                child: ScaleTransition(
                  scale: _iconScale,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // ── Shimmering title ───────────────────────
              AnimatedBuilder(
                animation: _shimmerAnimation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: const [
                          Colors.white,
                          Colors.white,
                          Color(0xFFFFD700), // golden shine
                          Colors.white,
                          Colors.white,
                        ],
                        stops: [
                          0.0,
                          (_shimmerAnimation.value - 0.3).clamp(0.0, 1.0),
                          _shimmerAnimation.value.clamp(0.0, 1.0),
                          (_shimmerAnimation.value + 0.3).clamp(0.0, 1.0),
                          1.0,
                        ],
                      ).createShader(bounds);
                    },
                    child: child,
                  );
                },
                child: const Text(
                  'ENSTABHOUSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── Subtitle ───────────────────────────────
              Text(
                'Your campus community',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 13,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 60),

              // ── Loading indicator ──────────────────────
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

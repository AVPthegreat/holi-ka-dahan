import 'dart:math' as math;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const BurnApp());
}

class BurnApp extends StatelessWidget {
  const BurnApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorSeed = Colors.deepOrange.shade400;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Holi Burn',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorSeed,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0A12),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.playfairDisplay(
            fontSize: 52,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.6,
            color: Colors.white,
          ),
          displayMedium: GoogleFonts.playfairDisplay(
            fontSize: 44,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.2,
            color: Colors.white,
          ),
        ),
      ),
      home: const RitualFlow(),
    );
  }
}

class RitualFlow extends StatefulWidget {
  const RitualFlow({super.key});

  @override
  State<RitualFlow> createState() => _RitualFlowState();
}

class _RitualFlowState extends State<RitualFlow>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TextEditingController _input = TextEditingController();
  late final AnimationController _flameController;
  late final AudioPlayer _audioPlayer;
  late final VideoPlayerController _videoController;
  bool _videoReady = false;

  bool _isBurning = false;
  bool _burnFinished = false;
  double _rating = 4;
  String _lastBurn = '';
  final _tubeColors = const [Color(0xFFFF6B35), Color(0xFFF7931E), Color(0xFFFF4500)];
  final _lightColors = const [Color(0xFFFF6B35), Color(0xFFFECA57), Color(0xFFFF4500), Color(0xFFFF7F50)];

  @override
  void initState() {
    super.initState();
    _flameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _audioPlayer = AudioPlayer();
    _videoController = VideoPlayerController.asset('assets/videos/burn.mp4')
      ..setLooping(true);
    _videoController.initialize().then((_) {
      if (mounted) setState(() => _videoReady = true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _input.dispose();
    _flameController.dispose();
    _audioPlayer.dispose();
    _videoController.dispose();
    super.dispose();
  }

  void _toInput() => _pageController.animateToPage(
      2,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutQuart,
      );

    void _toGreeting() => _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutQuart,
    );

  void _triggerBurn() {
    final text = _input.text.trim();
    if (text.isEmpty || _isBurning) return;

    setState(() {
      _isBurning = true;
      _burnFinished = false;
      _lastBurn = text;
    });

    if (_videoReady) {
      _videoController
        ..seekTo(Duration.zero)
        ..play();
    }

    _pageController.animateToPage(
      3,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutQuart,
    );

    _audioPlayer.play(AssetSource('audio/fire_crackle.mp3')).catchError((_) {
      // If the asset is missing, skip sound quietly.
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      setState(() {
        _isBurning = false;
        _burnFinished = true;
        _input.clear();
      });
      _videoController.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const AnimatedBackdrop(),
          SafeArea(
            child: PageView(
              controller: _pageController,
              allowImplicitScrolling: true,
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              children: [
                _WelcomeScreen(onStart: _toGreeting, tubeColors: _tubeColors, lightColors: _lightColors),
                _GreetingScreen(onStart: _toInput, tubeColors: _tubeColors, lightColors: _lightColors),
                _InputScreen(
                  controller: _input,
                  onBurn: _triggerBurn,
                  tubeColors: _tubeColors,
                  lightColors: _lightColors,
                ),
                _BurningScreen(
                  flameController: _flameController,
                  isBurning: _isBurning,
                  lastBurn: _lastBurn,
                  onEditAgain: _toInput,
                  rating: _rating,
                  onRatingChanged: (value) => setState(() => _rating = value),
                  tubeColors: _tubeColors,
                  lightColors: _lightColors,
                  videoController: _videoController,
                  videoReady: _videoReady,
                  burnFinished: _burnFinished,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedBackdrop extends StatefulWidget {
  const AnimatedBackdrop({super.key});

  @override
  State<AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * math.pi;
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                0.2 * math.cos(t),
                0.2 * math.sin(t),
              ),
              radius: 1.2,
              colors: const [
                Color(0xFF1A0F1F),
                Color(0xFF0E0A12),
                Color(0xFF050307),
              ],
            ),
          ),
          child: Stack(
            children: [
              _GlowCircle(
                size: 420,
                color: const Color(0xFFFF6B35).withValues(alpha: 0.18),
                offset: Offset(80 * math.cos(t), 120 * math.sin(t)),
              ),
              _GlowCircle(
                size: 260,
                color: const Color(0xFFF7931E).withValues(alpha: 0.16),
                offset: Offset(-60 * math.sin(t * .8), 80 * math.cos(t * .7)),
              ),
              _GlowCircle(
                size: 180,
                color: const Color(0xFFFF4500).withValues(alpha: 0.12),
                offset: Offset(50 * math.sin(t * 1.3), -100 * math.cos(t * .9)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({
    required this.size,
    required this.color,
    required this.offset,
  });

  final double size;
  final Color color;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx + MediaQuery.of(context).size.width / 2 - size / 2,
      top: offset.dy + MediaQuery.of(context).size.height / 3 - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0.0)],
          ),
        ),
      ),
    );
  }
}

// ColorSplash removed (reverted to previous design)

class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen({required this.onStart, required this.tubeColors, required this.lightColors});

  final VoidCallback onStart;
  final List<Color> tubeColors;
  final List<Color> lightColors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _TubeOverlay(tubeColors: tubeColors, lightColors: lightColors),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFF7931E), Color(0xFFFFC857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  blendMode: BlendMode.srcIn,
                  child: Text(
                    'Happy Holi',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.4,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Let it burn',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 36),
                FilledButton(
                  onPressed: onStart,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                    backgroundColor: Colors.white.withValues(alpha: 0.12),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: const Text('Burn it'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GreetingScreen extends StatelessWidget {
  const _GreetingScreen({required this.onStart, required this.tubeColors, required this.lightColors});

  final VoidCallback onStart;
  final List<Color> tubeColors;
  final List<Color> lightColors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          tween: Tween(begin: 0.85, end: 1),
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: Opacity(opacity: value, child: child),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Let it burn.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.2,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                'Write the habits you are done carrying.\nWe will set them on fire - in spirit - so you can step lighter into spring.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 28),
              FilledButton.tonal(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Burn it'),
                    SizedBox(width: 10),
                    Icon(Icons.local_fire_department_rounded),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputScreen extends StatelessWidget {
  const _InputScreen({
    required this.controller,
    required this.onBurn,
    required this.tubeColors,
    required this.lightColors,
  });

  final TextEditingController controller;
  final VoidCallback onBurn;
  final List<Color> tubeColors;
  final List<Color> lightColors;

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Procrastination',
      'Overthinking',
      'Self-doubt',
      'Anger',
      'Fear of failing',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 36,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - MediaQuery.of(context).viewInsets.bottom),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Tag(label: 'Write & burn'),
                  const SizedBox(height: 18),
                  Text(
                    'What are you letting go?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: controller,
                      maxLines: 5,
                      minLines: 4,
                      cursorColor: const Color(0xFFFF6B35),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'e.g. Late-night doomscrolling, skipping workouts, holding grudges...',
                        hintStyle: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: suggestions
                        .map(
                          (s) => ChoiceChip(
                            label: Text(s),
                            selected: false,
                            onSelected: (_) {
                              final current = controller.text.trim();
                              final prefix = current.isEmpty ? '' : '$current, ';
                              controller.text = '$prefix$s';
                              controller.selection = TextSelection.collapsed(
                                offset: controller.text.length,
                              );
                            },
                            backgroundColor: Colors.white.withValues(alpha: 0.06),
                            labelStyle: const TextStyle(color: Colors.white70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onBurn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      child: const Text('Burn it'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BurningScreen extends StatelessWidget {
  const _BurningScreen({
    required this.flameController,
    required this.isBurning,
    required this.lastBurn,
    required this.onEditAgain,
    required this.rating,
    required this.onRatingChanged,
    required this.tubeColors,
    required this.lightColors,
    required this.videoController,
    required this.videoReady,
    required this.burnFinished,
  });

  final AnimationController flameController;
  final bool isBurning;
  final String lastBurn;
  final VoidCallback onEditAgain;
  final double rating;
  final ValueChanged<double> onRatingChanged;
  final List<Color> tubeColors;
  final List<Color> lightColors;
  final VideoPlayerController videoController;
  final bool videoReady;
  final bool burnFinished;

  @override
  Widget build(BuildContext context) {
    if (isBurning) {
      return _FullScreenBurn(
        videoReady: videoReady,
        videoController: videoController,
        text: lastBurn,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _Tag(label: 'Burn'),
          const SizedBox(height: 18),
          Text(
            burnFinished ? 'Released' : 'Letting go...',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 26,
                ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                  child: child,
                ),
                child: burnFinished
                    ? _BurnResult(text: lastBurn, key: const ValueKey('result'))
                    : _AshesMessage(text: lastBurn),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (burnFinished) ...[
            _RatingRow(rating: rating, onChanged: onRatingChanged),
            const SizedBox(height: 8),
            Text(
              'Leave a quick review',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onEditAgain,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Burn another'),
            ),
          ] else ...[
            _RatingRow(rating: rating, onChanged: onRatingChanged),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onEditAgain,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Write another'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  child: const Text('Share feeling'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _BurningNote extends StatelessWidget {
  const _BurningNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(text),
      duration: const Duration(milliseconds: 2400),
      tween: Tween(begin: 1, end: 0),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final blur = 12 * (1 - value);
        final chars = text.split('');
        final cutoff = (1 - value) * (chars.length + 6);
        return Transform.translate(
          offset: Offset(0, -20 * (1 - value)),
          child: Opacity(
            opacity: value.clamp(0, 1),
            child: Container(
              padding: const EdgeInsets.all(18),
              constraints: const BoxConstraints(maxWidth: 320),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9 * value),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepOrange.withValues(alpha: 0.35 * value),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: List.generate(chars.length, (i) {
                          final local = (cutoff - i).clamp(0.0, 1.0);
                          final opacity = 1 - local;
                          return TextSpan(
                            text: chars[i],
                            style: TextStyle(
                              color: Colors.black87.withValues(alpha: opacity),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }),
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Burning...',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
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

class _AshesMessage extends StatelessWidget {
  const _AshesMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final hasText = text.isNotEmpty;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 450),
      opacity: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 38),
          const SizedBox(height: 10),
          Text(
            hasText ? 'Gone in smoke' : 'Ready when you are',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            hasText
                ? 'You released: "$text"'
                : 'Write a habit to set it free.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _FlamePulse extends StatelessWidget {
  const _FlamePulse({required this.controller, required this.tubeColors, required this.lightColors});

  final AnimationController controller;
  final List<Color> tubeColors;
  final List<Color> lightColors;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final scale = 1 + 0.08 * math.sin(controller.value * 2 * math.pi);
        final opacity = 0.4 + 0.25 * math.sin(controller.value * 2 * math.pi + math.pi / 3);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  tubeColors[0].withValues(alpha: opacity),
                  tubeColors[1].withValues(alpha: opacity * 0.65),
                  Colors.transparent,
                ],
                stops: const [0.08, 0.42, 1],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TubeBurst extends StatelessWidget {
  const _TubeBurst({required this.controller, required this.tubeColors, required this.lightColors});

  final AnimationController controller;
  final List<Color> tubeColors;
  final List<Color> lightColors;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _TubeBurstPainter(
              t: controller.value,
              tubeColors: tubeColors,
              lightColors: lightColors,
            ),
            size: const Size(320, 320),
            child: const SizedBox(width: 320, height: 320),
          ),
        );
      },
    );
  }
}

class _TubeBurstPainter extends CustomPainter {
  _TubeBurstPainter({required this.t, required this.tubeColors, required this.lightColors});

  final double t;
  final List<Color> tubeColors;
  final List<Color> lightColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 12);
    final baseRadius = size.width * 0.18;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Tubes: flowing curves that orbit the center.
    for (int i = 0; i < tubeColors.length; i++) {
      final path = Path();
      final hueShift = (t + i * 0.2) * 2 * math.pi;
      for (double a = 0; a <= 2 * math.pi; a += 0.22) {
        final wobble = math.sin(a * 2 + hueShift) * 14;
        final r = baseRadius + i * 16 + wobble;
        final offset = Offset(
          center.dx + r * math.cos(a + hueShift),
          center.dy + r * math.sin(a + hueShift * 0.9),
        );
        if (a == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      final alpha = 0.25 + 0.15 * math.sin(hueShift + i);
      paint
        ..strokeWidth = 3.0
        ..color = tubeColors[i].withValues(alpha: alpha.clamp(0.12, 0.5));
      canvas.drawPath(path, paint);
    }

    // Light blooms.
    for (int i = 0; i < lightColors.length; i++) {
      final angle = (t * 2 * math.pi) + i;
      final radius = baseRadius * (1.2 + i * 0.22);
      final pos = center.translate(radius * math.cos(angle), radius * math.sin(angle));
      final bloom = RadialGradient(
        colors: [lightColors[i].withValues(alpha: 0.18), Colors.transparent],
      );
      final rect = Rect.fromCircle(center: pos, radius: 46 + 10 * math.sin(angle * 1.5));
      canvas.drawRect(rect, Paint()..shader = bloom.createShader(rect));
    }
  }

  @override
  bool shouldRepaint(covariant _TubeBurstPainter oldDelegate) => true;
}

class _BurnHalo extends StatelessWidget {
  const _BurnHalo({required this.controller, required this.tubeColors, required this.lightColors});

  final AnimationController controller;
  final List<Color> tubeColors;
  final List<Color> lightColors;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final pulse = 0.12 + 0.08 * math.sin(controller.value * 2 * math.pi);
        final blur = 24 + 10 * math.sin(controller.value * 2 * math.pi + math.pi / 4);
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    tubeColors.first.withValues(alpha: 0.22 + pulse),
                    Colors.transparent,
                  ],
                  stops: const [0.35, 1],
                ),
                boxShadow: [
                  BoxShadow(
                    color: lightColors.first.withValues(alpha: 0.18 + pulse),
                    blurRadius: blur,
                    spreadRadius: 12,
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    lightColors[1 % lightColors.length].withValues(alpha: 0.10 + pulse * 0.8),
                    Colors.transparent,
                  ],
                  stops: const [0.18, 1],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BurnStageVideo extends StatelessWidget {
  const _BurnStageVideo({super.key, required this.videoReady, required this.videoController, required this.text});

  final bool videoReady;
  final VideoPlayerController videoController;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (videoReady)
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoController.value.size.width,
                height: videoController.value.size.height,
                child: VideoPlayer(videoController),
              ),
            ),
          )
        else
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E1B2E), Color(0xFF0D0A12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.25),
          ),
        ),
        _BurningFadeText(text: text),
      ],
    );
  }
}

class _BurningFadeText extends StatelessWidget {
  const _BurningFadeText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(text),
      duration: const Duration(seconds: 6),
      tween: Tween(begin: 1, end: 0),
      curve: Curves.easeOut,
      builder: (context, value, _) {
        final scale = 0.98 + 0.04 * value;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: value,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
            ),
          ),
        );
      },
    );
  }
}

class _FullScreenBurn extends StatelessWidget {
  const _FullScreenBurn({required this.videoReady, required this.videoController, required this.text});

  final bool videoReady;
  final VideoPlayerController videoController;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (videoReady)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController.value.size.width,
                  height: videoController.value.size.height,
                  child: VideoPlayer(videoController),
                ),
              ),
            )
          else
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1B2E), Color(0xFF0D0A12)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.08)),
          ),
          Center(
            child: _BurningFadeText(text: text),
          ),
        ],
      ),
    );
  }
}

class _BurnResult extends StatelessWidget {
  const _BurnResult({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final hasText = text.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          hasText ? 'You burned:' : 'Nothing burned yet',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22),
        ),
        if (hasText) ...[
          const SizedBox(height: 10),
          Text(
            '"$text"',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.35, fontSize: 18),
          ),
        ],
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 0.2),
      ),
    );
  }
}

class _TubeOverlay extends StatefulWidget {
  const _TubeOverlay({required this.tubeColors, required this.lightColors});

  final List<Color> tubeColors;
  final List<Color> lightColors;

  @override
  State<_TubeOverlay> createState() => _TubeOverlayState();
}

class _TubeOverlayState extends State<_TubeOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 2 * math.pi;
        return CustomPaint(
          painter: _TubePainter(
            progress: _controller.value,
            tubeColors: widget.tubeColors,
            lightColors: widget.lightColors,
            angle: t,
          ),
          size: MediaQuery.of(context).size,
        );
      },
    );
  }
}

class _TubePainter extends CustomPainter {
  _TubePainter({required this.progress, required this.tubeColors, required this.lightColors, required this.angle});

  final double progress;
  final List<Color> tubeColors;
  final List<Color> lightColors;
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final radius = size.shortestSide * (0.28 + i * 0.06);
      final path = Path();
      for (double a = 0; a <= 2 * math.pi; a += 0.12) {
        final r = radius + 6 * math.sin(angle + a * (1.4 + i * 0.2));
        final offset = Offset(
          center.dx + r * math.cos(a + progress * 2 * math.pi),
          center.dy + r * math.sin(a + progress * 2 * math.pi),
        );
        if (a == 0) {
          path.moveTo(offset.dx, offset.dy);
        } else {
          path.lineTo(offset.dx, offset.dy);
        }
      }
      paint.color = tubeColors[i % tubeColors.length].withValues(alpha: 0.16 + 0.08 * math.sin(angle + i));
      canvas.drawPath(path, paint);
    }

    for (int i = 0; i < lightColors.length; i++) {
      final radius = size.shortestSide * (0.15 + i * 0.05);
      final alpha = 0.10 + 0.05 * math.sin(angle * (1.2 + i * 0.1));
      final radial = RadialGradient(
        colors: [lightColors[i].withValues(alpha: alpha), Colors.transparent],
      );
      final rect = Rect.fromCircle(center: center.translate(
        16 * math.cos(angle + i),
        16 * math.sin(angle + i),
      ), radius: radius);
      canvas.drawRect(rect, Paint()..shader = radial.createShader(rect));
    }
  }

  @override
  bool shouldRepaint(covariant _TubePainter oldDelegate) => true;
}

class _FireSparks extends StatelessWidget {
  const _FireSparks({required this.controller, required this.tubeColors});

  final AnimationController controller;
  final List<Color> tubeColors;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(8);
    final sparks = List.generate(28, (i) {
      final seed = random.nextDouble();
      return _Spark(seed: seed, color: tubeColors[i % tubeColors.length]);
    });

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _SparkPainter(sparks: sparks, t: controller.value),
            size: const Size(260, 260),
            child: const SizedBox(width: 260, height: 260),
          ),
        );
      },
    );
  }
}

class _Spark {
  _Spark({required this.seed, required this.color});
  final double seed;
  final Color color;
}

class _SparkPainter extends CustomPainter {
  _SparkPainter({required this.sparks, required this.t});

  final List<_Spark> sparks;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 24);
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final spark in sparks) {
      final localT = (t + spark.seed) % 1.0;
      final rise = Curves.easeOut.transform(localT);
      final dx = math.sin((spark.seed + t) * 6) * 24 * (1 - rise);
      final dy = -rise * 180;
      final pos = center + Offset(dx, dy);
      paint.color = spark.color.withValues(alpha: (1 - rise) * 0.8);
      paint.strokeWidth = 2 + 2 * (1 - rise);
      canvas.drawPoints(PointMode.points, [pos], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => true;
}

class _EmberBurst extends StatelessWidget {
  const _EmberBurst({required this.controller, required this.tubeColors, required this.isBurning});

  final AnimationController controller;
  final List<Color> tubeColors;
  final bool isBurning;

  @override
  Widget build(BuildContext context) {
    final random = math.Random(42);
    final embers = List.generate(34, (i) {
      final seed = random.nextDouble();
      return _Spark(seed: seed, color: tubeColors[i % tubeColors.length]);
    });

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final intensity = isBurning ? 1.0 : 0.5;
        return IgnorePointer(
          child: CustomPaint(
            painter: _EmberPainter(embers: embers, t: controller.value, intensity: intensity),
            size: const Size(320, 320),
            child: const SizedBox(width: 320, height: 320),
          ),
        );
      },
    );
  }
}

class _EmberPainter extends CustomPainter {
  _EmberPainter({required this.embers, required this.t, required this.intensity});

  final List<_Spark> embers;
  final double t;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 18);
    final paint = Paint()..strokeCap = StrokeCap.round;

    for (final ember in embers) {
      final localT = (t + ember.seed) % 1.0;
      final rise = Curves.easeOut.transform(localT);
      final angle = (ember.seed * 6.28) + t * 4;
      final radius = 12 + 140 * rise;
      final pos = center + Offset(math.cos(angle) * radius, -radius * 0.6 + math.sin(angle) * 6);
      final alpha = (1 - rise) * (0.7 + 0.3 * intensity);
      paint
        ..color = ember.color.withValues(alpha: alpha)
        ..strokeWidth = 1.4 + 1.6 * (1 - rise);
      canvas.drawPoints(PointMode.points, [pos], paint);

      if (ember.seed > 0.8 && intensity > 0.8) {
        paint
          ..color = Colors.amberAccent.withValues(alpha: alpha)
          ..strokeWidth = 2.6;
        canvas.drawPoints(PointMode.points, [pos.translate(2, -4)], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EmberPainter oldDelegate) => true;
}

class _FlameLicks extends StatelessWidget {
  const _FlameLicks({required this.controller, required this.tubeColors});

  final AnimationController controller;
  final List<Color> tubeColors;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _FlameLickPainter(t: controller.value, tubeColors: tubeColors),
            size: const Size(260, 260),
            child: const SizedBox(width: 260, height: 260),
          ),
        );
      },
    );
  }
}

class _FlameLickPainter extends CustomPainter {
  _FlameLickPainter({required this.t, required this.tubeColors});

  final double t;
  final List<Color> tubeColors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.4;

    for (int i = 0; i < 6; i++) {
      final phase = t * 2 * math.pi + i * 0.8;
      final path = Path();
      final baseHeight = 70 + i * 12;
      final sway = 20 * math.sin(phase + i);
      path.moveTo(center.dx + sway * 0.2, center.dy + 30);
      path.quadraticBezierTo(
        center.dx + sway,
        center.dy - baseHeight,
        center.dx,
        center.dy - baseHeight * 1.3,
      );

      final color = tubeColors[i % tubeColors.length].withValues(alpha: 0.25 + 0.08 * math.sin(phase));
      paint.color = color;
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlameLickPainter oldDelegate) => true;
}

class _HeatHaze extends StatelessWidget {
  const _HeatHaze({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final wobble = 1 + 0.02 * math.sin(controller.value * 2 * math.pi);
        final blur = 6 + 3 * math.sin(controller.value * 2 * math.pi + math.pi / 2);
        return IgnorePointer(
          child: Transform.scale(
            scale: wobble,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withValues(alpha: 0.06), Colors.transparent],
                    stops: const [0.0, 1.0],
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

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.rating, required this.onChanged});

  final double rating;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'How did it feel?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final filled = rating >= index + 1;
            return IconButton(
              onPressed: () => onChanged(index + 1),
              icon: Icon(
                filled ? Icons.star_rounded : Icons.star_border_rounded,
                color: filled ? Colors.amber : Colors.white38,
              ),
            );
          }),
        ),
      ],
    );
  }
}

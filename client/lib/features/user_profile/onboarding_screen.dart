import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:client/core/theme/app_theme.dart';
import 'dart:ui';
import 'dart:async';
import 'package:video_player/video_player.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'user_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> with SingleTickerProviderStateMixin {
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedSex = 'M'; // Default value

  bool _isLoading = false;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Screen 1: Mood
  final List<_MoodCard> _moods = const [
    _MoodCard('😌', 'Loving', [Color(0xFF00C2A8), Color(0xFF0FD6C9)]),
    _MoodCard('🤔', 'Curious', [Color(0xFFFFA600), Color(0xFFFFC64D)]),
    _MoodCard('😰', 'Anxious', [Color(0xFF2B4EFF), Color(0xFF4C6FFF)]),
    _MoodCard('😤', 'Determined', [Color(0xFFFF1744), Color(0xFFFF5A76)]),
  ];
  int _selectedMoodIndex = 0;

  // Screen 2: Goal / Prism
  final List<_GoalPrism> _goals = const [
    _GoalPrism('Mini Cut', '4-week gentle taper', Colors.tealAccent),
    _GoalPrism('Slow Cut', '16-week steady', Color(0xFF2ECC71)),
    _GoalPrism('Normal Cut', '12-week balanced', Color(0xFFFFB020)),
    _GoalPrism('Aggressive Cut', '4-week sprint', Color(0xFFE53935)),
  ];
  int _selectedGoalIndex = 2;

  // Screen 3 controls (synced to text controllers to preserve existing logic)
  late FixedExtentScrollController _weightWheelController;
  double _weightValue = 78.0; // kg
  double _heightValue = 175; // cm
  int _ageValue = 27;

  // Hero video + parallax
  VideoPlayerController? _videoController;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  Offset _parallax = Offset.zero;

  // Hero text breath
  late final AnimationController _breathController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);
  late final Animation<double> _breath = CurvedAnimation(
    parent: _breathController,
    curve: Curves.easeInOut,
  );

  // Prism page dynamics
  late final PageController _prismController = PageController(viewportFraction: 0.72);
  double _prismBlurSigma = 12;
  double _lastPrismPixels = 0;
  int _lastPrismMillis = 0;

  void _submitForm() async {
    setState(() => _isLoading = true);
    try {
        await ref.read(userServiceProvider).saveInitialProfile(
            heightCm: int.tryParse(_heightController.text) ?? _heightValue.round(),
            ageYears: int.tryParse(_ageController.text) ?? _ageValue,
              sex: _selectedSex,
            initialWeightKg: double.tryParse(_weightController.text) ?? _weightValue,
            );
        ref.invalidate(isProfileCompleteProvider);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save profile: $e')),
        );
      } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _weightWheelController = FixedExtentScrollController(
      initialItem: ((_weightValue - 30) / 0.5).round(),
    );
    // Seed controllers so validation passes and values save
    _weightController.text = _weightValue.toStringAsFixed(1);
    _heightController.text = _heightValue.round().toString();
    _ageController.text = _ageValue.toString();

    // Hero video
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://cdn.coverr.co/videos/coverr-water-on-glass-7197/1080p.mp4'),
    )
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (mounted) setState(() {});
        _videoController?.play();
      });

    // Parallax via gyroscope
    _gyroSub = gyroscopeEvents.listen((e) {
      final dx = (_parallax.dx + e.y * 2).clamp(-10.0, 10.0);
      final dy = (_parallax.dy + e.x * 2).clamp(-10.0, 10.0);
      if (!mounted) return;
      setState(() => _parallax = Offset(dx, dy));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    children: [
                      _buildHeroPage(theme),
                      _buildMoodPage(theme),
                      _buildPrismPage(theme),
                      _buildFormPage(theme),
                      _buildSummaryPage(theme),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _currentPage == 0
                              ? null
                              : () => _pageController.previousPage(duration: AppTheme.mediumAnimation, curve: Curves.easeOut),
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: (_currentPage == 4)
                            ? (_isLoading
                                ? const SizedBox(height: 52, child: Center(child: CircularProgressIndicator()))
                                : ElevatedButton(onPressed: _submitForm, child: const Text('Start Tracking')))
                            : ElevatedButton(
                                onPressed: () => _pageController.nextPage(duration: AppTheme.mediumAnimation, curve: Curves.easeOut),
                                child: const Text('Continue'),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _gyroSub?.cancel();
    _videoController?.dispose();
    _breathController.dispose();
    _prismController.dispose();
    super.dispose();
  }

}

class _DottedBackground extends StatelessWidget {
  final double spacing;
  final double fadeRatio; // 0..1 portion of height to fade over
  const _DottedBackground({this.spacing = 12, this.fadeRatio = 0.55});

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0x14FFFFFF)
        : const Color(0x14000000);
    return CustomPaint(
      painter: _DotsPainter(base, spacing: spacing, fadeRatio: fadeRatio),
      size: Size.infinite,
    );
  }
}

class _DotsPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double fadeRatio;
  _DotsPainter(this.color, {this.spacing = 12, this.fadeRatio = 0.55});

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 1.5;
    final double fadeHeight = size.height * fadeRatio; // configurable fade
    for (double y = spacing; y < fadeHeight; y += spacing) {
      final double t = 1 - (y / fadeHeight); // 1 at top -> 0 at fade edge
      final double opacity = (color.opacity * (0.25 + 0.75 * t)).clamp(0.0, 1.0);
      final Paint rowPaint = Paint()..color = color.withOpacity(opacity);
      for (double x = spacing; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, rowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Models and small widgets ---
class _MoodCard {
  final String emoji;
  final String title;
  final List<Color> gradient;
  const _MoodCard(this.emoji, this.title, this.gradient);
}

class _GoalPrism {
  final String title;
  final String subtitle;
  final Color accent;
  const _GoalPrism(this.title, this.subtitle, this.accent);
}

extension on _OnboardingScreenState {
  Widget _glass({required Widget child, EdgeInsets padding = const EdgeInsets.all(16), double opacity = 0.92}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _prismBlurSigma, sigmaY: _prismBlurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Screen builders
  Widget _buildMoodPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How are you feeling about your body?', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: ListView.separated(
              padding: const EdgeInsets.only(right: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _moods.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final m = _moods[i];
                final isSelected = i == _selectedMoodIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedMoodIndex = i);
                    _pageController.nextPage(duration: AppTheme.mediumAnimation, curve: Curves.easeOutBack);
                  },
                  child: AnimatedScale(
                    scale: isSelected ? 1.05 : 1.0,
                    duration: AppTheme.shortAnimation,
                    child: _glass(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(colors: m.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(m.emoji, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 12),
                            Text(m.title, style: const TextStyle(fontFamily: AppTheme.fontFamily, fontSize: 20, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPage(ThemeData theme) {
    final vc = _videoController;
    return Stack(
      children: [
        if (vc != null && vc.value.isInitialized)
          Positioned.fill(
            child: Transform.translate(
              offset: _parallax * 0.6,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: vc.value.size.width,
                  height: vc.value.size.height,
                  child: VideoPlayer(vc),
                ),
              ),
            ),
          ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.2), Colors.black.withOpacity(0.2)],
              ),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _breath,
                builder: (_, __) {
                  final double t = (_breath.value - 0.5) * 0.04; // ±2%
                  final double base = FontWeight.w600.value.toDouble();
                  final int idx = ((base + base * t) ~/ 100).clamp(0, 8);
                  return Text(
                    'Adaptive Calorie',
                    style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.values[idx]),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 6),
              Text('Re-imagined', style: theme.textTheme.headlineMedium, textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrismPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose your path', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              itemCount: _goals.length,
              controller: _prismController,
              itemBuilder: (context, i) {
                final g = _goals[i];
                final isSelected = i == _selectedGoalIndex;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: isSelected ? 0.0 : 0.45),
                  duration: AppTheme.mediumAnimation,
                  builder: (context, tilt, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(tilt),
                      alignment: Alignment.center,
                      child: Opacity(
                        opacity: isSelected ? 1 : 0.3,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGoalIndex = i),
                          child: _glass(
                            child: AnimatedContainer(
                              duration: AppTheme.mediumAnimation,
                              height: isSelected ? 315 : 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [g.accent.withOpacity(0.25), g.accent.withOpacity(0.07)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: g.accent.withOpacity(isSelected ? 0.35 : 0.15),
                                    blurRadius: isSelected ? 24 : 12,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(g.title, style: const TextStyle(letterSpacing: 0.2, fontFamily: AppTheme.fontFamily, fontSize: 22, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 8),
                                  Text(g.subtitle, style: theme.textTheme.bodyMedium?.copyWith(letterSpacing: 0.2)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              onPageChanged: (i) {
                final now = DateTime.now().millisecondsSinceEpoch;
                final px = _prismController.position.pixels;
                final dt = (now - _lastPrismMillis).clamp(1, 10000);
                final velocity = ((px - _lastPrismPixels).abs() / dt) * 1000;
                _lastPrismMillis = now;
                _lastPrismPixels = px;
                setState(() {
                  _selectedGoalIndex = i;
                  _prismBlurSigma = (12 + velocity * 0.02).clamp(12, 24);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormPage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tell us about you', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          _glass(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 140,
                  child: ListWheelScrollView.useDelegate(
                    controller: _weightWheelController,
                    physics: const FixedExtentScrollPhysics(),
                    itemExtent: 36,
                    onSelectedItemChanged: (i) {
                      setState(() {
                        _weightValue = 30 + i * 0.5;
                        _weightController.text = _weightValue.toStringAsFixed(1);
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, i) {
                        if (i < 0 || i > 200) return null;
                        final v = 30 + i * 0.5;
                        final isSel = (v - _weightValue).abs() < 0.01;
                        return Center(
                          child: Text(
                            v.toStringAsFixed(1),
                            style: TextStyle(fontSize: isSel ? 22 : 16, fontWeight: isSel ? FontWeight.w600 : FontWeight.w400),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _heightValue,
                  min: 120,
                  max: 220,
                  onChanged: (v) {
                    setState(() {
                      _heightValue = v;
                      _heightController.text = _heightValue.round().toString();
                    });
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Male'),
                      selected: _selectedSex == 'M',
                      onSelected: (_) => setState(() => _selectedSex = 'M'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Female'),
                      selected: _selectedSex == 'F',
                      onSelected: (_) => setState(() => _selectedSex = 'F'),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<int>(
                      value: _ageValue,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() {
                          _ageValue = v;
                          _ageController.text = v.toString();
                        });
                      },
                      items: List.generate(70, (i) => 12 + i)
                          .map((v) => DropdownMenuItem(value: v, child: Text('Age $v')))
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPage(ThemeData theme) {
    final weeklyLoss = 0.6; // placeholder
    return Stack(
      children: [
        const _DottedBackground(spacing: 10, fadeRatio: 0.4),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Set your starting line', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              _glass(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('At ${_weightValue.toStringAsFixed(0)} kg you could lose ${weeklyLoss.toStringAsFixed(1)} kg/week safely.',
                        style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    Container(
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.04),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
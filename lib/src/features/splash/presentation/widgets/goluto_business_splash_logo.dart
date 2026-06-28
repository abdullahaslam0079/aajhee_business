import 'package:flutter/material.dart';
import 'package:goluto_business/src/imports/packages_imports.dart';
import 'package:goluto_business/src/theme/app_fonts.dart';

/// Business wordmark: "Go" lands first, brief pause, then "Business" flows in below.
class GolutoBusinessSplashLogo extends StatefulWidget {
  const GolutoBusinessSplashLogo({super.key});

  static const duration = Duration(milliseconds: 2500);

  @override
  State<GolutoBusinessSplashLogo> createState() =>
      _GolutoBusinessSplashLogoState();
}

class _GolutoBusinessSplashLogoState extends State<GolutoBusinessSplashLogo>
    with SingleTickerProviderStateMixin {
  static const _goLetters = ['G', 'o'];
  static const _businessLetters = [
    'B',
    'u',
    's',
    'i',
    'n',
    'e',
    's',
    's',
  ];

  static const _goStart = 0.06;
  static const _goStagger = 0.05;
  static const _goLetterDuration = 0.26;

  static const _businessStart = 0.46;
  static const _businessOpenDuration = 0.18;
  static const _businessStagger = 0.035;
  static const _businessLetterDuration = 0.22;

  static const _settleStart = 0.88;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: GolutoBusinessSplashLogo.duration,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _interval(
    double t,
    double start,
    double duration, {
    Curve curve = Curves.easeOutCubic,
  }) {
    if (t <= start) return 0;
    return curve.transform(((t - start) / duration).clamp(0, 1));
  }

  double _goLetterProgress(int index, double t) {
    return _interval(
      t,
      _goStart + index * _goStagger,
      _goLetterDuration,
      curve: Curves.easeOutCubic,
    );
  }

  double _goProgress(double t) => _goLetterProgress(1, t);

  double _businessOpen(double t) {
    return _interval(
      t,
      _businessStart,
      _businessOpenDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  double _businessLetterProgress(int index, double t) {
    if (t < _businessStart) return 0;

    final start = _businessStart + index * _businessStagger;
    return _interval(
      t,
      start,
      _businessLetterDuration,
      curve: Curves.easeOutQuart,
    );
  }

  double _goScale(double t) {
    if (t < _businessStart) {
      return 1 + _goProgress(t) * 0.03;
    }
    if (t >= _settleStart) return 1;

    final p = Curves.easeInOutCubic.transform(
      ((t - _businessStart) / (_settleStart - _businessStart)).clamp(0, 1),
    );
    return 1.03 - p * 0.03;
  }

  double _wordScale(double t) {
    if (t < _settleStart) return 1;
    final p = Curves.easeInOutCubic.transform(
      ((t - _settleStart) / (1 - _settleStart)).clamp(0, 1),
    );
    return 1 + (1 - p) * 0.01;
  }

  TextStyle _goStyle(BuildContext context, double scale) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return textTheme.displaySmall?.copyWith(
          fontSize: 54.sp * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1,
          color: colorScheme.primary,
        ) ??
        TextStyle(
          fontFamily: AppFonts.primary,
          fontSize: 54.sp * scale,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
          height: 1,
          color: colorScheme.primary,
        );
  }

  TextStyle _businessStyle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return textTheme.titleLarge?.copyWith(
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          height: 1,
          color: colorScheme.primary,
        ) ??
        TextStyle(
          fontFamily: AppFonts.primary,
          fontSize: 18.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          height: 1,
          color: colorScheme.primary,
        );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final goScale = _goScale(t);
        final businessOpen = _businessOpen(t);

        return Transform.scale(
          scale: _wordScale(t),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  for (var i = 0; i < _goLetters.length; i++)
                    _AnimatedLetter(
                      letter: _goLetters[i],
                      progress: _goLetterProgress(i, t),
                      style: _goStyle(context, goScale),
                      offset: Offset(0, 14.h),
                    ),
                ],
              ),
              SizedBox(height: (8.h * businessOpen).clamp(0, 8.h)),
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: businessOpen.clamp(0.001, 1),
                  child: Opacity(
                    opacity: businessOpen,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        for (var i = 0; i < _businessLetters.length; i++)
                          _AnimatedLetter(
                            letter: _businessLetters[i],
                            progress: _businessLetterProgress(i, t),
                            style: _businessStyle(context),
                            offset: Offset(0, 10.h),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedLetter extends StatelessWidget {
  const _AnimatedLetter({
    required this.letter,
    required this.progress,
    required this.style,
    required this.offset,
  });

  final String letter;
  final double progress;
  final TextStyle style;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);

    return Opacity(
      opacity: p,
      child: Transform.translate(
        offset: Offset(
          offset.dx * (1 - p),
          offset.dy * (1 - p),
        ),
        child: Text(letter, style: style),
      ),
    );
  }
}

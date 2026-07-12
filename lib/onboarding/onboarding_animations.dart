import 'package:flutter/material.dart';

/// Subtle vertical float used for hero illustrations.
class OnboardingFloatAnimation extends StatelessWidget {
  const OnboardingFloatAnimation({
    super.key,
    required this.child,
    this.amplitude = 6,
    this.duration = const Duration(milliseconds: 3200),
  });

  final Widget child;
  final double amplitude;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    return _OnboardingFloatAnimationStateful(
      amplitude: amplitude,
      duration: duration,
      child: child,
    );
  }
}

class _OnboardingFloatAnimationStateful extends StatefulWidget {
  const _OnboardingFloatAnimationStateful({
    required this.child,
    required this.amplitude,
    required this.duration,
  });

  final Widget child;
  final double amplitude;
  final Duration duration;

  @override
  State<_OnboardingFloatAnimationStateful> createState() =>
      _OnboardingFloatAnimationStatefulState();
}

class _OnboardingFloatAnimationStatefulState
    extends State<_OnboardingFloatAnimationStateful>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _offset = Tween<double>(
      begin: -widget.amplitude,
      end: widget.amplitude,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _offset.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Fade + slide-up entrance for onboarding copy blocks.
class OnboardingFadeSlide extends StatelessWidget {
  const OnboardingFadeSlide({
    super.key,
    required this.animation,
    required this.child,
    this.offset = 24,
  });

  final Animation<double> animation;
  final Widget child;
  final double offset;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final slide = Tween<Offset>(
      begin: Offset(0, offset / 400),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

/// Scale-in entrance for illustrations when a page becomes active.
class OnboardingScaleIn extends StatelessWidget {
  const OnboardingScaleIn({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;

    final scale = Tween<double>(begin: 0.86, end: 1.0).animate(
      CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(scale: scale, child: child),
    );
  }
}

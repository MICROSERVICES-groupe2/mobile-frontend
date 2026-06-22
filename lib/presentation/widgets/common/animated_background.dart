import 'dart:math';
import 'package:flutter/material.dart';
import '../../../design_tokens/design_tokens.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;

  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  final List<_OrbConfig> _orbs = [
    _OrbConfig(
      color: DesignTokens.teal400.withValues(alpha: 0.35),
      size: 280,
      top: -0.08,
      left: -0.15,
      durationSec: 14,
    ),
    _OrbConfig(
      color: DesignTokens.teal500.withValues(alpha: 0.28),
      size: 340,
      top: 0.35,
      right: -0.22,
      durationSec: 18,
    ),
    _OrbConfig(
      color: DesignTokens.gold400.withValues(alpha: 0.14),
      size: 220,
      bottom: 0.08,
      left: 0.25,
      durationSec: 16,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = _orbs
        .map(
          (orb) => AnimationController(
            vsync: this,
            duration: Duration(seconds: orb.durationSec),
          )..repeat(reverse: true),
        )
        .toList();

    _animations = _controllers
        .map(
          (controller) => Tween<double>(begin: 0, end: 2 * pi).animate(
            CurvedAnimation(parent: controller, curve: Curves.easeInOutSine),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        constraints: BoxConstraints(minHeight: screenHeight),
        decoration: const BoxDecoration(
          gradient: DesignTokens.backgroundGradient,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated orbs
            ...List.generate(_orbs.length, (index) {
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, child) {
                  final value = _animations[index].value;
                  final offsetX = sin(value) * 18;
                  final offsetY = cos(value * 0.7) * 14;
                  return Positioned(
                    top: _orbs[index].top != null
                        ? screenHeight * _orbs[index].top! + offsetY
                        : null,
                    bottom: _orbs[index].bottom != null
                        ? screenHeight * _orbs[index].bottom! - offsetY
                        : null,
                    left: _orbs[index].left != null
                        ? MediaQuery.of(context).size.width * _orbs[index].left! + offsetX
                        : null,
                    right: _orbs[index].right != null
                        ? MediaQuery.of(context).size.width * _orbs[index].right! - offsetX
                        : null,
                    child: _buildOrb(_orbs[index]),
                  );
                },
              );
            }),
            // Content
            SafeArea(child: widget.child),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb(_OrbConfig orb) {
    return Container(
      width: orb.size,
      height: orb.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            orb.color,
            orb.color.withValues(alpha: 0.0),
          ],
          stops: const [0.2, 1.0],
        ),
      ),
    );
  }
}

class _OrbConfig {
  final Color color;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final int durationSec;

  _OrbConfig({
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.durationSec,
  });
}

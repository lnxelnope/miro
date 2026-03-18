import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';
import '../../application/camera_stream_controller.dart';
import '../../application/multi_angle_capture_controller.dart';
import '../../domain/models/angle_zone.dart';
import 'angle_gauge_widget.dart';

class MultiAngleCaptureOverlay extends StatefulWidget {
  const MultiAngleCaptureOverlay({
    super.key,
    required this.controller,
    required this.streamController,
  });

  final MultiAngleCaptureController controller;
  final ArScanCameraStreamController streamController;

  @override
  State<MultiAngleCaptureOverlay> createState() =>
      _MultiAngleCaptureOverlayState();
}

class _MultiAngleCaptureOverlayState extends State<MultiAngleCaptureOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _confirmFadeController;
  late final Animation<double> _confirmOpacity;

  late final AnimationController _flashController;
  late final Animation<double> _flashOpacity;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  AngleCaptureResult? _lastResult;

  MultiAngleCaptureController get _ctrl => widget.controller;

  @override
  void initState() {
    super.initState();

    _confirmFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _confirmOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 1), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1), weight: 65),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 25),
    ]).animate(_confirmFadeController);

    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.7), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.0), weight: 70),
    ]).animate(CurvedAnimation(
      parent: _flashController,
      curve: Curves.easeOut,
    ));

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ctrl.lastCaptureResult.addListener(_onCaptureResult);
  }

  void _onCaptureResult() {
    final result = _ctrl.lastCaptureResult.value;
    if (result == null || result == _lastResult) return;
    _lastResult = result;

    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);

    _flashController.forward(from: 0);
    _confirmFadeController.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.lastCaptureResult.removeListener(_onCaptureResult);
    _confirmFadeController.dispose();
    _flashController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _ctrl.isStarted,
      builder: (_, started, __) {
        return Stack(
          children: [
            _buildFlashOverlay(),
            if (!started) ...[
              _buildViewfinderFrame(),
              _buildStartButton(),
            ] else ...[
              _buildGauge(),
              _buildZoneIndicators(),
              _buildCaptureConfirmation(context),
              _buildTapHint(),
            ],
          ],
        );
      },
    );
  }

  // ═══════════════════════════════════════════
  // PHASE 1: POSITIONING (viewfinder + start)
  // ═══════════════════════════════════════════

  Widget _buildViewfinderFrame() {
    final screenWidth = MediaQuery.of(context).size.width;
    const horizontalMargin = 32.0;
    final frameSize = screenWidth - horizontalMargin * 2;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              L10n.of(context)!.arScanPositionFood,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _pulseScale,
            builder: (_, child) => Transform.scale(
              scale: _pulseScale.value,
              child: child,
            ),
            child: SizedBox(
              width: frameSize,
              height: frameSize,
              child: CustomPaint(
                painter: _ViewfinderPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    final l10n = L10n.of(context)!;
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 24,
      child: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: _ctrl.isCapturing,
          builder: (_, capturing, __) {
            return GestureDetector(
              onTap: capturing ? null : () => _ctrl.startCapture(),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: capturing ? 0.5 : 1.0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.center_focus_strong_rounded,
                        color: Colors.black87,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        l10n.arScanStartCapture,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // PHASE 2: AUTO-CAPTURE (gauge + zones)
  // ═══════════════════════════════════════════

  Widget _buildFlashOverlay() {
    return AnimatedBuilder(
      animation: _flashOpacity,
      builder: (_, __) {
        if (_flashController.isDismissed) return const SizedBox.shrink();
        return Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: Colors.white.withValues(alpha: _flashOpacity.value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGauge() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 52,
      left: 0,
      right: 0,
      child: Center(
        child: ValueListenableBuilder<double>(
          valueListenable: _ctrl.currentAngle,
          builder: (_, angle, __) {
            return ValueListenableBuilder<AngleZone?>(
              valueListenable: _ctrl.currentTargetZone,
              builder: (_, target, __) {
                if (target == null) return const SizedBox.shrink();
                final zone = _ctrl.currentDeviceZone.value;
                final isInZone = zone == target;
                return AngleGaugeWidget(
                  currentAngle: angle,
                  targetZone: target,
                  isInZone: isInZone,
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildZoneIndicators() {
    return Positioned(
      right: 12,
      top: MediaQuery.of(context).padding.top + 80,
      child: ValueListenableBuilder<int>(
        valueListenable: _ctrl.capturedCount,
        builder: (_, count, __) {
          return ValueListenableBuilder<AngleZone?>(
            valueListenable: _ctrl.currentTargetZone,
            builder: (context, target, __) {
              final l10n = L10n.of(context)!;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...MultiAngleCaptureController.allZones
                        .map((zone) => _buildZoneItem(zone, target)),
                    const SizedBox(height: 6),
                    Text(
                      l10n.arScanAngleProgress(count, 3),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(blurRadius: 3, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildZoneItem(AngleZone zone, AngleZone? target) {
    final isCaptured = _ctrl.isZoneCaptured(zone);
    final isTarget = zone == target;
    final result = _ctrl.getCaptureResultForZone(zone);

    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCaptured
            ? const Color(0xFF4ADE80)
            : isTarget
                ? const Color(0xFFFBBF24).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.2),
        border: Border.all(
          color: isCaptured
              ? const Color(0xFF22C55E)
              : isTarget
                  ? const Color(0xFFFBBF24)
                  : Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: isCaptured && result != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(result.imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.check,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                Container(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.35),
                ),
                const Center(
                  child: Icon(Icons.check, size: 20, color: Colors.white),
                ),
              ],
            )
          : Center(
              child: Text(
                _zoneLabel(zone),
                style: TextStyle(
                  color: isTarget ? Colors.black87 : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }

  String _zoneLabel(AngleZone zone) {
    switch (zone) {
      case AngleZone.top:
        return 'T';
      case AngleZone.diagonal:
        return 'D';
      case AngleZone.side:
        return 'S';
      case AngleZone.outOfRange:
        return '?';
    }
  }

  Widget _buildCaptureConfirmation(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 110,
      child: AnimatedBuilder(
        animation: _confirmOpacity,
        builder: (_, __) {
          if (_confirmFadeController.isDismissed) {
            return const SizedBox.shrink();
          }
          return Opacity(
            opacity: _confirmOpacity.value,
            child: Center(child: _confirmText(context)),
          );
        },
      ),
    );
  }

  Widget _confirmText(BuildContext context) {
    final result = _lastResult;
    if (result == null) return const SizedBox.shrink();

    final l10n = L10n.of(context)!;
    final count = _ctrl.capturedCount.value;

    String zoneName;
    switch (result.zone) {
      case AngleZone.top:
        zoneName = l10n.arScanAngleTop;
      case AngleZone.diagonal:
        zoneName = l10n.arScanAngleDiagonal;
      case AngleZone.side:
        zoneName = l10n.arScanAngleSide;
      case AngleZone.outOfRange:
        zoneName = '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        l10n.arScanAngleCaptured(zoneName, count, 3),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTapHint() {
    final l10n = L10n.of(context)!;
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 32,
      child: Center(
        child: ValueListenableBuilder<bool>(
          valueListenable: _ctrl.isCapturing,
          builder: (_, capturing, __) {
            return ValueListenableBuilder<bool>(
              valueListenable: _ctrl.isComplete,
              builder: (_, complete, __) {
                if (complete) return _buildCompleteIndicator();
                return ValueListenableBuilder<bool>(
                  valueListenable: _ctrl.canCapture,
                  builder: (_, canTap, __) {
                    if (capturing) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white,
                          ),
                        ),
                      );
                    }
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: canTap
                            ? const Color(0xFF22C55E)
                            : Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: canTap
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF22C55E)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 16,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            canTap
                                ? Icons.touch_app_rounded
                                : Icons.screen_rotation_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            canTap
                                ? l10n.arScanTapToCapture
                                : l10n.arScanMoveToAngle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildCompleteIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
          SizedBox(width: 8),
          Text(
            '3/3',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Viewfinder corner-bracket painter ───

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final cornerLen = size.width * 0.15;
    const r = 8.0;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLen)
        ..lineTo(0, r)
        ..arcTo(Rect.fromLTWH(0, 0, r * 2, r * 2), math.pi, math.pi / 2,
            false)
        ..lineTo(cornerLen, 0),
      paint,
    );

    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLen, 0)
        ..lineTo(size.width - r, 0)
        ..arcTo(
            Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2),
            -math.pi / 2,
            math.pi / 2,
            false)
        ..lineTo(size.width, cornerLen),
      paint,
    );

    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLen)
        ..lineTo(0, size.height - r)
        ..arcTo(
            Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2),
            math.pi,
            -math.pi / 2,
            false)
        ..lineTo(cornerLen, size.height),
      paint,
    );

    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(size.width, size.height - cornerLen)
        ..lineTo(size.width, size.height - r)
        ..arcTo(
            Rect.fromLTWH(
                size.width - r * 2, size.height - r * 2, r * 2, r * 2),
            0,
            math.pi / 2,
            false)
        ..lineTo(size.width - cornerLen, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

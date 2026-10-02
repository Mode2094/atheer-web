import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

enum EEGState { idle, connecting, reading, processing, complete }

class EEGVisualizationScreen extends StatefulWidget {
  final String perfumeName;
  final VoidCallback onComplete;
  final VoidCallback? onCancel;
  final Duration readingDuration;

  const EEGVisualizationScreen({
    super.key,
    required this.perfumeName,
    required this.onComplete,
    this.onCancel,
    this.readingDuration = const Duration(seconds: 8),
  });

  @override
  State<EEGVisualizationScreen> createState() => _EEGVisualizationScreenState();
}

class _EEGVisualizationScreenState extends State<EEGVisualizationScreen>
    with TickerProviderStateMixin {
  EEGState _currentState = EEGState.idle;

  late final AnimationController _pulseController;
  late final AnimationController _waveController;
  late final AnimationController _glowController;
  late final AnimationController _rotateController;
  late final AnimationController _successController;
  late final AnimationController _scaleController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _waveAnimation;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _scaleAnimation;

  Timer? _stateTimer;
  Timer? _readingTimer;
  Timer? _signalTimer;

  double _signalStrength = 0.0;
  final List<double> _signalHistory = [];
  final List<double> _alphaWaves = [];
  final List<double> _betaWaves = [];
  final List<double> _gammaWaves = [];

  double _alphaAvg = 0.0;
  double _betaAvg = 0.0;
  double _gammaAvg = 0.0;
  double _coherence = 0.0;

  DateTime? _readingTimerStart;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _startEEGSimulation();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    _glowController.dispose();
    _rotateController.dispose();
    _successController.dispose();
    _scaleController.dispose();
    _stateTimer?.cancel();
    _readingTimer?.cancel();
    _signalTimer?.cancel();
    super.dispose();
  }

  void _startEEGSimulation() {
    setState(() => _currentState = EEGState.connecting);
    _stateTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _currentState = EEGState.reading;
        _readingTimerStart = DateTime.now();
      });
      _startSignalSimulation();

      _readingTimer = Timer(widget.readingDuration, () {
        if (!mounted) return;
        setState(() => _currentState = EEGState.processing);
        _successController.forward();

        _stateTimer = Timer(const Duration(seconds: 2), () {
          if (!mounted) return;
          setState(() => _currentState = EEGState.complete);
          _successController.reverse();
        });
      });
    });
  }

  void _startSignalSimulation() {
    _signalTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_currentState != EEGState.reading || !mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
        final alpha = 0.4 + 0.3 * sin(time * 10) + 0.1 * cos(time * 22);
        final beta = 0.3 + 0.2 * sin(time * 20) + 0.15 * cos(time * 45);
        final gamma = 0.2 + 0.25 * sin(time * 40) + 0.1 * cos(time * 90);

        _signalStrength = ((alpha + beta + gamma) / 3).clamp(0.0, 1.0);
        _signalHistory.add(_signalStrength);
        _alphaWaves.add(alpha.clamp(0.0, 1.0));
        _betaWaves.add(beta.clamp(0.0, 1.0));
        _gammaWaves.add(gamma.clamp(0.0, 1.0));

        if (_signalHistory.length > 80) {
          _signalHistory.removeAt(0);
          _alphaWaves.removeAt(0);
          _betaWaves.removeAt(0);
          _gammaWaves.removeAt(0);
        }

        _alphaAvg = _alphaWaves.isEmpty
            ? 0
            : _alphaWaves.reduce((a, b) => a + b) / _alphaWaves.length;
        _betaAvg = _betaWaves.isEmpty
            ? 0
            : _betaWaves.reduce((a, b) => a + b) / _betaWaves.length;
        _gammaAvg = _gammaWaves.isEmpty
            ? 0
            : _gammaWaves.reduce((a, b) => a + b) / _gammaWaves.length;
        _coherence = (_alphaAvg + _betaAvg + _gammaAvg) / 3;
      });
    });
  }

  int _remainingSeconds() {
    if (_readingTimerStart == null || _currentState != EEGState.reading) {
      return 0;
    }
    final elapsed = DateTime.now().difference(_readingTimerStart!).inSeconds;
    final remaining = widget.readingDuration.inSeconds - elapsed;
    return remaining.clamp(0, widget.readingDuration.inSeconds);
  }

  String _getStateText() {
    switch (_currentState) {
      case EEGState.idle:
        return StringHelper.tr('eeg_ready_to_start');
      case EEGState.connecting:
        return StringHelper.tr('eeg_connecting');
      case EEGState.reading:
        return StringHelper.tr('eeg_reading_waves');
      case EEGState.processing:
        return StringHelper.tr('eeg_processing_data');
      case EEGState.complete:
        return StringHelper.tr('eeg_analysis_complete');
    }
  }

  String _getStateSubText() {
    switch (_currentState) {
      case EEGState.idle:
        return StringHelper.tr('eeg_click_start');
      case EEGState.connecting:
        return StringHelper.tr('eeg_connect_sensor');
      case EEGState.reading:
        return StringHelper.tr('eeg_relax_focus_perfume');
      case EEGState.processing:
        return StringHelper.tr('eeg_processing_signals');
      case EEGState.complete:
        return StringHelper.tr('eeg_response_analyzed');
    }
  }

  Color _getStateColor() {
    switch (_currentState) {
      case EEGState.idle:
        return Colors.grey;
      case EEGState.connecting:
        return Colors.orange;
      case EEGState.reading:
        return ThemeConstants.accentColor;
      case EEGState.processing:
        return Colors.purple;
      case EEGState.complete:
        return Colors.green;
    }
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _getStateColor().withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: _getStateColor().withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _getStateColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getStateColor().withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _getStateText(),
            style: TextStyle(
              color: _getStateColor(),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatChip('α', _alphaAvg, Colors.blue),
        _buildStatChip('β', _betaAvg, Colors.orange),
        _buildStatChip('γ', _gammaAvg, Colors.purple),
      ],
    );
  }

  Widget _buildStatChip(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(value * 100).toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrainVisualization() {
    return AnimatedBuilder(
      animation:
          Listenable.merge([_pulseAnimation, _glowAnimation, _rotateAnimation]),
      builder: (context, child) {
        return Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _getStateColor().withValues(alpha: 0.1),
                Colors.transparent,
              ],
              stops: const [0.3, 1.0],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              ...List.generate(3, (index) {
                return Transform.rotate(
                  angle: _rotateAnimation.value + (index * pi / 2),
                  child: Container(
                    width: 200 + index * 30,
                    height: 200 + index * 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getStateColor().withValues(
                          alpha: 0.1 - index * 0.02,
                        ),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }),
              ...List.generate(12, (index) {
                final angle = index * pi / 6 + _rotateAnimation.value;
                const radius = 130.0;
                return Positioned(
                  left: 140 + radius * cos(angle) - 4,
                  top: 140 + radius * sin(angle) - 4,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _signalStrength * 8 + 2,
                    height: _signalStrength * 8 + 2,
                    decoration: BoxDecoration(
                      color: _getStateColor().withValues(
                        alpha: 0.3 + _signalStrength * 0.3,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
              Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getStateColor().withValues(alpha: 0.3),
                        _getStateColor().withValues(alpha: 0.1),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getStateColor().withValues(
                          alpha: _glowAnimation.value * 0.5,
                        ),
                        blurRadius: 40,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWaveGraph() {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: CustomPaint(
        painter: AdvancedBrainWavePainter(
          signalHistory: _signalHistory,
          alphaWaves: _alphaWaves,
          betaWaves: _betaWaves,
          gammaWaves: _gammaWaves,
          color: _getStateColor(),
          glowIntensity: _glowAnimation.value,
          phase: _waveAnimation.value,
        ),
      ),
    );
  }

  Widget _buildSignalMeter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              StringHelper.tr('signal_strength'),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(_signalStrength * 100).toInt()}%',
              style: TextStyle(
                color: _getStateColor(),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _signalStrength),
            duration: const Duration(milliseconds: 120),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                minHeight: 12,
                value: value.clamp(0.0, 1.0),
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(_getStateColor()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCoherenceIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStateColor().withValues(alpha: 0.1),
            _getStateColor().withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _getStateColor().withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            StringHelper.tr('wave_coherence'),
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStateColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(_coherence * 100).toInt()}%',
              style: TextStyle(
                color: _getStateColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_currentState == EEGState.reading || _currentState == EEGState.connecting) {
      return Center(
        child: AnimatedButton(
          text: StringHelper.tr('cancel'),
          backgroundColor: Colors.red.shade900,
          textColor: Colors.white,
          onPressed: () {
            _stateTimer?.cancel();
            _readingTimer?.cancel();
            _signalTimer?.cancel();
            widget.onCancel?.call();
            Navigator.pop(context);
          },
          width: 200,
          height: 50,
        ),
      );
    }

    if (_currentState == EEGState.complete) {
      return Center(
        child: AnimatedButton(
          text: StringHelper.tr('continue'),
          onPressed: () {
            widget.onComplete();
            Navigator.pop(context);
          },
          width: 240,
          height: 56,
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildResponsivePanel(double width) {
    final isWide = width > 700;
    return GlassContainer(
      padding: const EdgeInsets.all(32),
      borderRadius: BorderRadius.circular(40),
      blur: 15,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, ThemeConstants.accentColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              widget.perfumeName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getStateSubText(),
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildStatusBadge(),
          const SizedBox(height: 30),
          if (isWide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildBrainVisualization(),
                      const SizedBox(height: 20),
                      _buildWaveStats(),
                    ],
                  ),
                ),
                const SizedBox(width: 30),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildWaveGraph(),
                      const SizedBox(height: 20),
                      _buildSignalMeter(),
                      const SizedBox(height: 20),
                      _buildCoherenceIndicator(),
                    ],
                  ),
                ),
              ],
            )
          else
            Column(
              children: [
                _buildBrainVisualization(),
                const SizedBox(height: 20),
                _buildWaveStats(),
                const SizedBox(height: 20),
                _buildWaveGraph(),
                const SizedBox(height: 20),
                _buildSignalMeter(),
                const SizedBox(height: 20),
                _buildCoherenceIndicator(),
              ],
            ),
          const SizedBox(height: 30),
          _buildActionButtons(),
          if (_currentState == EEGState.reading) ...[
            const SizedBox(height: 16),
            Text(
              '${StringHelper.tr('auto_analysis_prefix')}${_remainingSeconds()}${StringHelper.tr('auto_analysis_suffix')}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(
                      sin(_glowAnimation.value) * 0.3,
                      cos(_glowAnimation.value) * 0.3,
                    ),
                    colors: [
                      const Color(0xFF050510),
                      _getStateColor().withValues(alpha: 0.1),
                      const Color(0xFF020208),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),
          ...List.generate(30, (index) {
            return AnimatedBuilder(
              animation: _waveAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 50 + sin(_waveAnimation.value + index * 0.5) * 100,
                  top: 100 + cos(_waveAnimation.value * 1.5 + index * 0.5) * 150,
                  child: Container(
                    width: 2,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _getStateColor().withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
          SafeArea(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const pagePadding = 24.0;
                  final availableWidth = max(
                    0.0,
                    constraints.maxWidth - (pagePadding * 2),
                  );
                  final availableHeight = max(
                    0.0,
                    constraints.maxHeight - (pagePadding * 2),
                  );
                  final designWidth = constraints.maxWidth >= 980 ? 900.0 : 620.0;

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(pagePadding),
                      child: SizedBox(
                        width: availableWidth,
                        height: availableHeight,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: designWidth,
                            child: _buildResponsivePanel(designWidth),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdvancedBrainWavePainter extends CustomPainter {
  final List<double> signalHistory;
  final List<double> alphaWaves;
  final List<double> betaWaves;
  final List<double> gammaWaves;
  final Color color;
  final double glowIntensity;
  final double phase;

  AdvancedBrainWavePainter({
    required this.signalHistory,
    required this.alphaWaves,
    required this.betaWaves,
    required this.gammaWaves,
    required this.color,
    required this.glowIntensity,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (signalHistory.isEmpty) return;

    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    _drawWave(canvas, size, alphaWaves, Colors.blue.withValues(alpha: 0.4), 2.0);
    _drawWave(
      canvas,
      size,
      betaWaves,
      Colors.orange.withValues(alpha: 0.4),
      2.0,
    );
    _drawWave(
      canvas,
      size,
      gammaWaves,
      Colors.purple.withValues(alpha: 0.4),
      2.0,
    );
    _drawWave(canvas, size, signalHistory, color.withValues(alpha: 0.8), 3.0);
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    List<double> data,
    Color waveColor,
    double strokeWidth,
  ) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = waveColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 2);

    final path = Path();
    final widthPerPoint = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * widthPerPoint;
      final y = size.height * (0.8 - data[i] * 0.6) + sin(x * 0.03 + phase) * 5;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant AdvancedBrainWavePainter oldDelegate) {
    return oldDelegate.signalHistory != signalHistory ||
        oldDelegate.alphaWaves != alphaWaves ||
        oldDelegate.betaWaves != betaWaves ||
        oldDelegate.gammaWaves != gammaWaves ||
        oldDelegate.glowIntensity != glowIntensity ||
        oldDelegate.phase != phase ||
        oldDelegate.color != color;
  }
}

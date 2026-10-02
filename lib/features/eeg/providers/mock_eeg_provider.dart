import 'dart:async';
import 'dart:math';

import 'eeg_device_provider.dart';

/// مزوّد EEG وهمي للاختبار بدون أي جهاز حقيقي.
///
/// يولّد قياسات متحركة بشكل جيبي "واقعي" ضمن المجال [0.2 .. 0.8] ويصدرها
/// مرة كل ثانية أثناء الجلسة.
class MockEEGProvider implements EEGDeviceProvider {
  final StreamController<Map<String, double>> _controller =
      StreamController<Map<String, double>>.broadcast();
  final Random _random = Random();

  Timer? _timer;
  bool _connected = false;
  bool _sessionActive = false;
  Map<String, double>? _lastMetrics;

  // زمن داخلي (ثوانٍ) لتوليد موجات مستقرة.
  double _t = 0.0;

  @override
  Future<bool> connect() async {
    _connected = true;
    return true;
  }

  @override
  Future<void> disconnect() async {
    await stopSession();
    _connected = false;
  }

  @override
  Future<bool> startSession() async {
    if (!_connected) return false;
    if (_sessionActive) return true;

    _sessionActive = true;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _t += 1.0;
      final metrics = _generateMetrics(_t);
      _lastMetrics = metrics;
      _controller.add(metrics);
    });

    return true;
  }

  @override
  Future<Map<String, double>?> stopSession() async {
    if (!_sessionActive) return _lastMetrics;
    _sessionActive = false;
    _timer?.cancel();
    _timer = null;
    return _lastMetrics;
  }

  @override
  Stream<Map<String, double>> get metricsStream => _controller.stream;

  @override
  bool get isConnected => _connected;

  @override
  bool get isSessionActive => _sessionActive;

  Map<String, double> _generateMetrics(double tSeconds) {
    // مزيج موجات بطيئة + سريعة + ضجيج خفيف يعطي حركة طبيعية.
    double wave(double baseFreq, double phase, {double noise = 0.02}) {
      final slow = sin((tSeconds * baseFreq) + phase);
      final fast = sin((tSeconds * (baseFreq * 2.3)) + (phase * 1.7));
      final jitter = (_random.nextDouble() - 0.5) * 2.0 * noise;
      final raw = 0.5 + (0.18 * slow) + (0.06 * fast) + jitter;
      return raw.clamp(0.2, 0.8).toDouble();
    }

    return <String, double>{
      'interest': wave(0.55, 0.2, noise: 0.018),
      'excitement': wave(0.75, 1.1, noise: 0.020),
      'stress': wave(0.60, 2.0, noise: 0.016),
      'relaxation': wave(0.50, 2.7, noise: 0.014),
      'engagement': wave(0.70, 3.4, noise: 0.018),
      'attention': wave(0.80, 4.1, noise: 0.020),
    };
  }
}


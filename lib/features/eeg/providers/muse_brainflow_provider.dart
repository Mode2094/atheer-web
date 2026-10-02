import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'eeg_device_provider.dart';

class MuseBrainFlowProvider implements EEGDeviceProvider {
  MuseBrainFlowProvider({
    Duration scanTimeout = const Duration(seconds: 8),
    Duration metricsInterval = const Duration(milliseconds: 500),
  }) : _scanTimeout = scanTimeout,
       _metricsInterval = metricsInterval;

  final Duration _scanTimeout;
  final Duration _metricsInterval;

  final StreamController<Map<String, double>> _metricsController =
      StreamController<Map<String, double>>.broadcast();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _controlChar;
  final Map<_MuseChannel, BluetoothCharacteristic> _eegChars = {};
  BluetoothCharacteristic? _accelChar;

  final List<StreamSubscription<List<int>>> _subscriptions = [];
  Timer? _metricsTimer;

  bool _connected = false;
  bool _sessionActive = false;
  Map<String, double>? _lastMetrics;

  // Buffers (microvolts) for each channel.
  final Map<_MuseChannel, List<double>> _buffers = {
    _MuseChannel.tp9: <double>[],
    _MuseChannel.af7: <double>[],
    _MuseChannel.af8: <double>[],
    _MuseChannel.tp10: <double>[],
  };

  // Estimated sample rate for classic Muse EEG characteristics.
  static const int _sampleRateHz = 256;
  static const int _bufferMax = 256;

  // Muse classic characteristic UUIDs (TP9/AF7/AF8/TP10 + accel + control).
  static final Guid _uuidEegTp9 = Guid(
    '273e0003-4c4d-454d-96be-f03bac821358',
  );
  static final Guid _uuidEegAf7 = Guid(
    '273e0004-4c4d-454d-96be-f03bac821358',
  );
  static final Guid _uuidEegAf8 = Guid(
    '273e0005-4c4d-454d-96be-f03bac821358',
  );
  static final Guid _uuidEegTp10 = Guid(
    '273e0006-4c4d-454d-96be-f03bac821358',
  );
  static final Guid _uuidAccel = Guid('273e000a-4c4d-454d-96be-f03bac821358');
  static final Guid _uuidControl = Guid(
    '273e0001-4c4d-454d-96be-f03bac821358',
  );

  @override
  Stream<Map<String, double>> get metricsStream => _metricsController.stream;

  @override
  bool get isConnected => _connected;

  @override
  bool get isSessionActive => _sessionActive;

  @override
  Future<bool> connect() async {
    try {
      final granted = await _requestPermissions();
      if (!granted) return false;

      final device = await _scanFirstMuseDevice(timeout: _scanTimeout);
      if (device == null) return false;

      try {
        await device.connect(
          timeout: const Duration(seconds: 20),
          mtu: null,
          autoConnect: false,
        );
      } catch (e) {
        debugPrint('MuseBluetooth.connect failed: $e');
        return false;
      }

      List<BluetoothService> services;
      try {
        services = await device.discoverServices();
      } catch (e) {
        debugPrint('MuseBluetooth.discoverServices failed: $e');
        try {
          await device.disconnect();
        } catch (_) {}
        return false;
      }

      _device = device;
      _connected = true;

      _indexCharacteristics(services);
      final hasAllEeg = _eegChars.length >= 2; // allow partial for early tests
      if (!hasAllEeg) {
        // Not fatal to app; just mark connect unsuccessful for EEG use.
        await disconnect();
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('MuseBluetooth.connect failed: $e');
      await disconnect();
      return false;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await stopSession();
    } catch (_) {}

    final device = _device;
    _device = null;
    _connected = false;

    _controlChar = null;
    _accelChar = null;
    _eegChars.clear();

    for (final entry in _buffers.entries) {
      entry.value.clear();
    }

    if (device != null) {
      try {
        await device.disconnect();
      } catch (e) {
        debugPrint('MuseBluetooth.disconnect failed: $e');
      }
    }
  }

  @override
  Future<bool> startSession() async {
    if (!_connected || _device == null) return false;
    if (_sessionActive) return true;

    try {
      // Clear previous session buffers.
      for (final entry in _buffers.entries) {
        entry.value.clear();
      }
      _lastMetrics = null;

      // Enable notifications for EEG channels.
      for (final entry in _eegChars.entries) {
        final ch = entry.value;
        try {
          await ch.setNotifyValue(true);
        } catch (e) {
          debugPrint('MuseBluetooth.notify EEG failed: $e');
          // Continue: partial channels may still work.
        }
        final sub = ch.onValueReceived.listen((value) {
          _handleEegPacket(entry.key, value);
        });
        _subscriptions.add(sub);
        _device!.cancelWhenDisconnected(sub, next: true);
      }

      // Optional: accelerometer notifications (not used in metrics yet).
      final accel = _accelChar;
      if (accel != null) {
        try {
          await accel.setNotifyValue(true);
        } catch (_) {}
        final sub = accel.onValueReceived.listen((_) {});
        _subscriptions.add(sub);
        _device!.cancelWhenDisconnected(sub, next: true);
      }

      // Best-effort: send minimal control command to start streaming on some FW.
      final control = _controlChar;
      if (control != null) {
        try {
          await control.write('d'.codeUnits, withoutResponse: true);
        } catch (_) {}
      }

      // Start periodic metrics computation.
      _metricsTimer?.cancel();
      _metricsTimer = Timer.periodic(_metricsInterval, (_) {
        final metrics = _computeMetrics();
        if (metrics == null) return;
        _lastMetrics = metrics;
        _metricsController.add(metrics);
      });

      _sessionActive = true;
      return true;
    } catch (e) {
      debugPrint('MuseBluetooth.startSession failed: $e');
      await stopSession();
      return false;
    }
  }

  @override
  Future<Map<String, double>?> stopSession() async {
    _sessionActive = false;

    _metricsTimer?.cancel();
    _metricsTimer = null;

    for (final sub in _subscriptions) {
      try {
        await sub.cancel();
      } catch (_) {}
    }
    _subscriptions.clear();

    // Disable notifications best-effort.
    for (final ch in _eegChars.values) {
      try {
        await ch.setNotifyValue(false);
      } catch (_) {}
    }
    if (_accelChar != null) {
      try {
        await _accelChar!.setNotifyValue(false);
      } catch (_) {}
    }

    return _lastMetrics;
  }

  Future<bool> _requestPermissions() async {
    try {
      final permissions = <Permission>[
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.locationWhenInUse,
      ];
      final statuses = await permissions.request();
      final okScan =
          (statuses[Permission.bluetoothScan] ?? PermissionStatus.granted)
              .isGranted;
      final okConnect =
          (statuses[Permission.bluetoothConnect] ?? PermissionStatus.granted)
              .isGranted;
      final okLocation =
          (statuses[Permission.locationWhenInUse] ?? PermissionStatus.granted)
              .isGranted;
      return okScan && okConnect && okLocation;
    } catch (e) {
      debugPrint('MuseBluetooth.permissions failed: $e');
      return false;
    }
  }

  Future<BluetoothDevice?> _scanFirstMuseDevice({
    required Duration timeout,
  }) async {
    StreamSubscription<List<ScanResult>>? sub;
    Timer? timer;
    final completer = Completer<BluetoothDevice?>();

    void finish(BluetoothDevice? device) {
      if (completer.isCompleted) return;
      completer.complete(device);
    }

    try {
      sub = FlutterBluePlus.scanResults.listen((results) {
        for (final r in results) {
          final name = _resolveDeviceName(r);
          if (!_looksLikeMuse(name)) continue;
          finish(r.device);
          break;
        }
      });

      timer = Timer(timeout, () => finish(null));

      try {
        await FlutterBluePlus.startScan(timeout: timeout);
      } catch (_) {}

      final device = await completer.future;
      try {
        await FlutterBluePlus.stopScan();
      } catch (_) {}
      return device;
    } catch (e) {
      debugPrint('MuseBluetooth.scan failed: $e');
      return null;
    } finally {
      timer?.cancel();
      await sub?.cancel();
    }
  }

  String _resolveDeviceName(ScanResult r) {
    final fromDevice = r.device.platformName.trim();
    if (fromDevice.isNotEmpty) return fromDevice;
    final advName = r.advertisementData.advName.trim();
    if (advName.isNotEmpty) return advName;
    return '';
  }

  bool _looksLikeMuse(String name) {
    final n = name.trim().toLowerCase();
    return n.contains('muse');
  }

  void _indexCharacteristics(List<BluetoothService> services) {
    _eegChars.clear();
    _controlChar = null;
    _accelChar = null;

    for (final s in services) {
      for (final c in s.characteristics) {
        final uuid = c.uuid;
        if (uuid == _uuidEegTp9) _eegChars[_MuseChannel.tp9] = c;
        if (uuid == _uuidEegAf7) _eegChars[_MuseChannel.af7] = c;
        if (uuid == _uuidEegAf8) _eegChars[_MuseChannel.af8] = c;
        if (uuid == _uuidEegTp10) _eegChars[_MuseChannel.tp10] = c;
        if (uuid == _uuidAccel) _accelChar ??= c;
        if (uuid == _uuidControl) _controlChar ??= c;
      }
    }
  }

  void _handleEegPacket(_MuseChannel channel, List<int> value) {
    // Classic Muse EEG packet: 2-byte counter + 12-bit BE packed samples.
    // EEG scale (classic): µV = 0.48828125 * (raw12 - 2048)
    if (value.length < 5) return;

    final bytes = value;
    final payload = bytes.sublist(2);
    if (payload.length < 3) return;

    final samples = <double>[];
    for (var i = 0; i + 2 < payload.length; i += 3) {
      final b0 = payload[i] & 0xFF;
      final b1 = payload[i + 1] & 0xFF;
      final b2 = payload[i + 2] & 0xFF;
      final s1 = ((b0 << 4) | (b1 >> 4)) & 0x0FFF;
      final s2 = (((b1 & 0x0F) << 8) | b2) & 0x0FFF;
      samples.add(_raw12ToMicrovolts(s1));
      samples.add(_raw12ToMicrovolts(s2));
    }

    if (samples.isEmpty) return;
    final buffer = _buffers[channel];
    if (buffer == null) return;
    buffer.addAll(samples);
    if (buffer.length > _bufferMax) {
      buffer.removeRange(0, buffer.length - _bufferMax);
    }
  }

  double _raw12ToMicrovolts(int raw12) {
    const scale = 0.48828125; // µV per count
    return scale * (raw12 - 2048);
  }

  Map<String, double>? _computeMetrics() {
    // Need at least some data from any channel to compute.
    final tp9 = _buffers[_MuseChannel.tp9]!;
    final tp10 = _buffers[_MuseChannel.tp10]!;
    final af7 = _buffers[_MuseChannel.af7]!;
    final af8 = _buffers[_MuseChannel.af8]!;

    final hasAny =
        tp9.isNotEmpty || tp10.isNotEmpty || af7.isNotEmpty || af8.isNotEmpty;
    if (!hasAny) return null;

    // Alpha proxy: RMS of rear electrodes (TP9/TP10).
    final alpha = _mean([
      _normRms(tp9),
      _normRms(tp10),
    ]);

    // Beta proxy: RMS of frontal electrodes (AF7/AF8).
    final beta = _mean([
      _normRms(af7),
      _normRms(af8),
    ]);

    // Theta/Gamma proxies: simple lag-energy over all available channels.
    final all = <List<double>>[
      if (tp9.isNotEmpty) tp9,
      if (af7.isNotEmpty) af7,
      if (af8.isNotEmpty) af8,
      if (tp10.isNotEmpty) tp10,
    ];
    final theta = _squashEnergy(_energyAtLag(all, _thetaLag()));
    final gamma = _squashEnergy(_energyAtLag(all, 1));

    final denom = (alpha + beta + theta).clamp(0.000001, double.infinity);

    final relaxation = (alpha / denom).clamp(0.0, 1.0).toDouble();
    final attention = (beta / denom).clamp(0.0, 1.0).toDouble();
    final stress = (beta / (alpha + 0.01)).clamp(0.0, 1.0).toDouble();
    final excitement = (beta + gamma).clamp(0.0, 1.0).toDouble();
    final engagement =
        ((beta + gamma) / (alpha + theta + 0.01)).clamp(0.0, 1.0).toDouble();
    final interest =
        ((engagement * 0.8) + (relaxation * 0.2)).clamp(0.0, 1.0).toDouble();

    return <String, double>{
      'interest': interest,
      'excitement': excitement,
      'stress': stress,
      'relaxation': relaxation,
      'engagement': engagement,
      'attention': attention,
    };
  }

  int _thetaLag() {
    // lag roughly matching ~6-8Hz range in a crude way.
    final lag = (_sampleRateHz / 32).round(); // ~8Hz-ish
    return max(6, lag);
  }

  double _normRms(List<double> samples) {
    if (samples.isEmpty) return 0.0;
    // Use last window only.
    final start = max(0, samples.length - _bufferMax);
    final window = samples.sublist(start);
    final rms = _rms(window);
    // Map typical EEG µV magnitudes (roughly) into 0..1.
    final absRms = rms.abs();
    return (absRms / (absRms + 50.0)).clamp(0.0, 1.0).toDouble();
  }

  double _rms(List<double> x) {
    var sum = 0.0;
    for (final v in x) {
      sum += v * v;
    }
    final mean = x.isEmpty ? 0.0 : (sum / x.length);
    return sqrt(mean);
  }

  double _mean(List<double> values) {
    final filtered = values.where((v) => v.isFinite).toList();
    if (filtered.isEmpty) return 0.0;
    final sum = filtered.fold<double>(0.0, (a, b) => a + b);
    return (sum / filtered.length).clamp(0.0, 1.0).toDouble();
  }

  double _energyAtLag(List<List<double>> channels, int lag) {
    var sum = 0.0;
    var count = 0;
    for (final ch in channels) {
      if (ch.length <= lag) continue;
      final start = max(lag, ch.length - _bufferMax);
      for (var i = start; i < ch.length; i++) {
        final d = ch[i] - ch[i - lag];
        sum += d * d;
        count++;
      }
    }
    if (count == 0) return 0.0;
    return sum / count;
  }

  double _squashEnergy(double energy) {
    // energy is in (uV^2) roughly; squash into 0..1.
    final e = energy.abs();
    return (e / (e + 1000.0)).clamp(0.0, 1.0).toDouble();
  }
}

enum _MuseChannel { tp9, af7, af8, tp10 }

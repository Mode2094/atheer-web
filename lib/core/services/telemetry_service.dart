import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class TelemetryService {
  static final TelemetryService _instance = TelemetryService._internal();
  factory TelemetryService() => _instance;
  TelemetryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logCloudCall({
    required String userId,
    required String storeId,
    required bool success,
    required Duration latency,
    String? errorCode,
    String? errorMessage,
    required String source,
  }) async {
    try {
      await _firestore.collection('telemetry_cloud').add({
        'userId': userId,
        'storeId': storeId,
        'timestamp': FieldValue.serverTimestamp(),
        'success': success,
        'latencyMs': latency.inMilliseconds,
        'errorCode': errorCode,
        'errorMessage': errorMessage,
        'source': source,
      });
      debugPrint('Telemetry cloud: $source success=$success');
    } catch (e) {
      debugPrint('Error logging cloud call: $e');
    }
  }

  Future<void> logFallback({
    required String userId,
    required String storeId,
    required String reason,
    required Duration totalLatency,
    required int retryCount,
  }) async {
    try {
      await _firestore.collection('telemetry_fallback').add({
        'userId': userId,
        'storeId': storeId,
        'timestamp': FieldValue.serverTimestamp(),
        'reason': reason,
        'totalLatencyMs': totalLatency.inMilliseconds,
        'retryCount': retryCount,
      });
      debugPrint('Telemetry fallback: $reason retries=$retryCount');
    } catch (e) {
      debugPrint('Error logging fallback: $e');
    }
  }

  Future<Map<String, dynamic>> getPerformanceStats() async {
    try {
      final cloudSnapshot = await _firestore
          .collection('telemetry_cloud')
          .orderBy('timestamp', descending: true)
          .limit(1000)
          .get();

      final fallbackSnapshot = await _firestore
          .collection('telemetry_fallback')
          .orderBy('timestamp', descending: true)
          .limit(1000)
          .get();

      final totalCloud = cloudSnapshot.docs.length;
      if (totalCloud == 0) return {};

      final successCloud =
          cloudSnapshot.docs.where((doc) => doc['success'] == true).length;
      final failedCloud = totalCloud - successCloud;

      final latencies = cloudSnapshot.docs
          .map((e) => (e['latencyMs'] as num?)?.toDouble() ?? 0)
          .where((l) => l > 0)
          .toList()
        ..sort();

      final p50 = latencies.isEmpty ? 0 : latencies[latencies.length ~/ 2];
      final p95Index = latencies.isEmpty
          ? 0
          : (latencies.length * 0.95).floor().clamp(0, latencies.length - 1);
      final p95 = latencies.isEmpty ? 0 : latencies[p95Index];
      final avgLatency = latencies.isEmpty
          ? 0
          : (latencies.reduce((a, b) => a + b) / latencies.length);

      return {
        'totalCloud': totalCloud,
        'successCloud': successCloud,
        'failedCloud': failedCloud,
        'successRate': (successCloud / totalCloud * 100).toStringAsFixed(2),
        'fallbackCount': fallbackSnapshot.docs.length,
        'fallbackRate':
            ((fallbackSnapshot.docs.length / totalCloud) * 100).toStringAsFixed(2),
        'avgLatency': avgLatency.toStringAsFixed(0),
        'p50': p50.toStringAsFixed(0),
        'p95': p95.toStringAsFixed(0),
      };
    } catch (e) {
      debugPrint('Error getting performance stats: $e');
      return {};
    }
  }
}

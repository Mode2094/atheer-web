import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/services/telemetry_service.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class TelemetryDashboard extends StatefulWidget {
  const TelemetryDashboard({super.key});

  @override
  State<TelemetryDashboard> createState() => _TelemetryDashboardState();
}

class _TelemetryDashboardState extends State<TelemetryDashboard> {
  Map<String, dynamic> _stats = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    _stats = await TelemetryService().getPerformanceStats();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('مراقبة الأداء'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stats.isEmpty
              ? const Center(
                  child: Text(
                    'لا توجد بيانات بعد',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        GlassContainer(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                'ملخص الأداء',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              _buildMetricRow(
                                'عدد استدعاءات Cloud',
                                '${_stats['totalCloud'] ?? 0}',
                                Icons.cloud,
                              ),
                              _buildMetricRow(
                                'نسبة النجاح',
                                '${_stats['successRate'] ?? '0.00'}%',
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              _buildMetricRow(
                                'معدل Fallback',
                                '${_stats['fallbackRate'] ?? '0.00'}%',
                                Icons.warning,
                                color: Colors.orange,
                              ),
                              _buildMetricRow(
                                'متوسط زمن الاستجابة',
                                '${_stats['avgLatency'] ?? '0'} ms',
                                Icons.timer,
                              ),
                              _buildMetricRow(
                                'P50',
                                '${_stats['p50'] ?? '0'} ms',
                                Icons.timer_outlined,
                              ),
                              _buildMetricRow(
                                'P95',
                                '${_stats['p95'] ?? '0'} ms',
                                Icons.timer_off,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon, {
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: ThemeConstants.accentColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

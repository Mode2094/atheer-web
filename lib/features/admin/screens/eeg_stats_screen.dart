import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/eeg/eeg_controller.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

class EEGStatsScreen extends StatefulWidget {
  final String perfumeId;
  final String perfumeName;

  const EEGStatsScreen({
    super.key,
    required this.perfumeId,
    required this.perfumeName,
  });

  @override
  State<EEGStatsScreen> createState() => _EEGStatsScreenState();
}

class _EEGStatsScreenState extends State<EEGStatsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reloadStats();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _reloadStats() async {
    _animationController.reset();
    await Provider.of<EEGController>(
      context,
      listen: false,
    ).loadPerfumeStats(widget.perfumeId);
    if (mounted) {
      _animationController.forward();
    }
  }

  double _safeMetric(double? value) {
    return (value ?? 0.0).clamp(0.0, 1.0);
  }

  Future<void> _exportPdf(Map<String, double> stats) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final regularFontData = await rootBundle.load(
        'assets/fonts/Cairo-Regular.ttf',
      );
      final boldFontData = await rootBundle.load('assets/fonts/Cairo-Bold.ttf');

      final regularFont = pw.Font.ttf(
        regularFontData.buffer.asByteData(),
      );
      final boldFont = pw.Font.ttf(
        boldFontData.buffer.asByteData(),
      );

      final metrics = <MapEntry<String, double>>[
        MapEntry(StringHelper.tr('metric_relaxation'), _safeMetric(stats['avgRelaxation'])),
        MapEntry(StringHelper.tr('metric_attention'), _safeMetric(stats['avgAttention'])),
        MapEntry(StringHelper.tr('metric_engagement'), _safeMetric(stats['avgEngagement'])),
        MapEntry(StringHelper.tr('metric_excitement'), _safeMetric(stats['avgExcitement'])),
        MapEntry(StringHelper.tr('metric_stress'), _safeMetric(stats['avgStress'])),
        MapEntry(StringHelper.tr('metric_interest'), _safeMetric(stats['avgInterest'])),
      ];

      final totalTests = (stats['totalTests'] ?? 0).toInt();
      final avgInterest = (_safeMetric(stats['avgInterest']) * 100)
          .toStringAsFixed(1);

      final doc = pw.Document();

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return [
              pw.Directionality(
                textDirection: pw.TextDirection.rtl,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                  children: [
                    pw.Text(
                      '${StringHelper.tr('eeg_results_title')} - ${widget.perfumeName}',
                      style: pw.TextStyle(
                        font: boldFont,
                        fontSize: 20,
                        color: PdfColors.black,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      StringHelper.tr('full_report_file'),
                      style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 18),
                    pw.Container(
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(8),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            '${StringHelper.tr('total_tests')}: $totalTests',
                            style: pw.TextStyle(font: boldFont, fontSize: 12),
                          ),
                          pw.Text(
                            '${StringHelper.tr('avg_interest')}: $avgInterest%',
                            style: pw.TextStyle(font: boldFont, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 18),
                    pw.Text(
                      StringHelper.tr('metrics_details'),
                      style: pw.TextStyle(font: boldFont, fontSize: 14),
                    ),
                    pw.SizedBox(height: 10),
                    ...metrics.map((entry) {
                      final value = entry.value;
                      final percent = (value * 100).toStringAsFixed(1);
                      final filled = (value * 1000).round().clamp(0, 1000);
                      final empty = 1000 - filled;

                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 10),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  '$percent%',
                                  style: pw.TextStyle(
                                    font: regularFont,
                                    fontSize: 11,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                                pw.Text(
                                  entry.key,
                                  style: pw.TextStyle(
                                    font: regularFont,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.Row(
                              children: [
                                if (filled > 0)
                                  pw.Expanded(
                                    flex: filled,
                                    child: pw.Container(
                                      height: 8,
                                      decoration: const pw.BoxDecoration(
                                        color: PdfColors.amber,
                                        borderRadius: pw.BorderRadius.all(
                                          pw.Radius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (empty > 0)
                                  pw.Expanded(
                                    flex: empty,
                                    child: pw.Container(
                                      height: 8,
                                      decoration: const pw.BoxDecoration(
                                        color: PdfColors.grey300,
                                        borderRadius: pw.BorderRadius.all(
                                          pw.Radius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      final Uint8List bytes = await doc.save();
      final fileName =
          'eeg_stats_${widget.perfumeId}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      await Printing.sharePdf(
        bytes: bytes,
        filename: fileName,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${StringHelper.tr('pdf_export_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('${StringHelper.tr('eeg_results_title')} - ${widget.perfumeName}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _reloadStats,
          ),
          IconButton(
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
            onPressed: _isExporting
                ? null
                : () {
                    final stats = Provider.of<EEGController>(
                      context,
                      listen: false,
                    ).perfumeStats;
                    if (stats.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(StringHelper.tr('no_data_to_export')),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    _exportPdf(stats);
                  },
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF0F0F1A),
        child: Consumer<EEGController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: ThemeConstants.accentColor,
                            value: value.clamp(0.0, 1.0),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            StringHelper.tr('loading_data'),
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: value.clamp(0.0, 1.0),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }

            final stats = controller.perfumeStats;
            if (stats.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.insights_outlined, color: Colors.white38, size: 80),
                    SizedBox(height: 20),
                    Text(
                      StringHelper.tr('no_eeg_results_for_perfume'),
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 10),
                    Text(
                      StringHelper.tr('eeg_results_will_appear_after_tests'),
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              StringHelper.tr('results_summary'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildStatsGrid(stats),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: ThemeConstants.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: ThemeConstants.accentColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildStatItem(
                                    StringHelper.tr('total_tests'),
                                    '${stats['totalTests']?.toInt() ?? 0}',
                                    Icons.people,
                                  ),
                                  Container(height: 40, width: 1, color: Colors.white24),
                                  _buildStatItem(
                                    StringHelper.tr('avg_interest'),
                                    '${((stats['avgInterest'] ?? 0) * 100).toStringAsFixed(1)}%',
                                    Icons.trending_up,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
                        ),
                      ),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              StringHelper.tr('neural_analysis'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutBack,
                              height: 300,
                              child: _buildRadarChart(stats),
                            ),
                            const SizedBox(height: 20),
                            _buildRadarLegend(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
                        ),
                      ),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              StringHelper.tr('metrics_comparison'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutBack,
                              height: 250,
                              child: _buildBarChart(stats),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
                        ),
                      ),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(
                              StringHelper.tr('metrics_details'),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _buildDetailsList(stats),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsGrid(Map<String, double> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      children: [
        _buildMetricCard(StringHelper.tr('metric_relaxation'), stats['avgRelaxation'] ?? 0, Colors.blue),
        _buildMetricCard(StringHelper.tr('metric_attention'), stats['avgAttention'] ?? 0, Colors.green),
        _buildMetricCard(StringHelper.tr('metric_engagement'), stats['avgEngagement'] ?? 0, Colors.purple),
        _buildMetricCard(StringHelper.tr('metric_excitement'), stats['avgExcitement'] ?? 0, Colors.orange),
        _buildMetricCard(StringHelper.tr('metric_stress'), stats['avgStress'] ?? 0, Colors.red),
        _buildMetricCard(StringHelper.tr('metric_interest'), stats['avgInterest'] ?? 0, Colors.amber),
      ],
    );
  }

  Widget _buildMetricCard(String label, double value, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutBack,
      builder: (context, animatedValue, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${(animatedValue * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: ThemeConstants.accentColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRadarChart(Map<String, double> stats) {
    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        dataSets: [
          RadarDataSet(
            fillColor: ThemeConstants.accentColor.withValues(alpha: 0.2),
            borderColor: ThemeConstants.accentColor,
            entryRadius: 4,
            dataEntries: [
              RadarEntry(value: stats['avgRelaxation'] ?? 0),
              RadarEntry(value: stats['avgAttention'] ?? 0),
              RadarEntry(value: stats['avgEngagement'] ?? 0),
              RadarEntry(value: stats['avgExcitement'] ?? 0),
              RadarEntry(value: 1 - (stats['avgStress'] ?? 0)),
              RadarEntry(value: stats['avgInterest'] ?? 0),
            ],
          ),
        ],
        radarBackgroundColor: Colors.transparent,
        borderData: FlBorderData(show: false),
        radarBorderData: const BorderSide(color: Colors.white24),
        titleTextStyle: const TextStyle(color: Colors.white70, fontSize: 10),
        titlePositionPercentageOffset: 0.2,
        getTitle: (index, angle) {
          switch (index) {
            case 0:
              return RadarChartTitle(text: StringHelper.tr('metric_relaxation'), angle: angle);
            case 1:
              return RadarChartTitle(text: StringHelper.tr('metric_attention'), angle: angle);
            case 2:
              return RadarChartTitle(text: StringHelper.tr('metric_engagement'), angle: angle);
            case 3:
              return RadarChartTitle(text: StringHelper.tr('metric_excitement'), angle: angle);
            case 4:
              return RadarChartTitle(text: StringHelper.tr('metric_calmness'), angle: angle);
            case 5:
              return RadarChartTitle(text: StringHelper.tr('metric_interest'), angle: angle);
            default:
              return const RadarChartTitle(text: '');
          }
        },
        tickCount: 5,
        ticksTextStyle: const TextStyle(color: Colors.white38, fontSize: 8),
      ),
    );
  }

  Widget _buildRadarLegend() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        StringHelper.tr('outer_values_mean_higher'),
        style: TextStyle(color: Colors.white38, fontSize: 10),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildBarChart(Map<String, double> stats) {
    final barGroups = [
      _buildBarGroup(0, stats['avgRelaxation'] ?? 0, Colors.blue),
      _buildBarGroup(1, stats['avgAttention'] ?? 0, Colors.green),
      _buildBarGroup(2, stats['avgEngagement'] ?? 0, Colors.purple),
      _buildBarGroup(3, stats['avgExcitement'] ?? 0, Colors.orange),
      _buildBarGroup(4, stats['avgStress'] ?? 0, Colors.red),
      _buildBarGroup(5, stats['avgInterest'] ?? 0, Colors.amber),
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 20,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('R', style: TextStyle(color: Colors.white38));
                  case 1:
                    return const Text('A', style: TextStyle(color: Colors.white38));
                  case 2:
                    return const Text('E', style: TextStyle(color: Colors.white38));
                  case 3:
                    return const Text('EX', style: TextStyle(color: Colors.white38));
                  case 4:
                    return const Text('S', style: TextStyle(color: Colors.white38));
                  case 5:
                    return const Text('I', style: TextStyle(color: Colors.white38));
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.2,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white24),
        ),
        barGroups: barGroups,
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double value, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsList(Map<String, double> stats) {
    final items = [
      _buildDetailItem(StringHelper.tr('metric_relaxation'), stats['avgRelaxation'] ?? 0, Colors.blue),
      _buildDetailItem(StringHelper.tr('metric_attention'), stats['avgAttention'] ?? 0, Colors.green),
      _buildDetailItem(StringHelper.tr('metric_engagement'), stats['avgEngagement'] ?? 0, Colors.purple),
      _buildDetailItem(StringHelper.tr('metric_excitement'), stats['avgExcitement'] ?? 0, Colors.orange),
      _buildDetailItem(StringHelper.tr('metric_stress'), stats['avgStress'] ?? 0, Colors.red),
      _buildDetailItem(StringHelper.tr('metric_interest'), stats['avgInterest'] ?? 0, Colors.amber),
    ];

    return Column(children: items);
  }

  Widget _buildDetailItem(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70)),
              Text(
                '${(value * 100).toStringAsFixed(1)}%',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}

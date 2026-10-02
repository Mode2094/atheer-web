import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/perfume_localization_helper.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/screens/eeg_stats_screen.dart';
import 'package:perfume/features/store_dashboard/screens/edit_perfume_screen.dart';
import 'package:perfume/features/store_dashboard/store_dashboard_controller.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class PerfumeGrid extends StatelessWidget {
  final List<PerfumeModel> perfumes;
  final String storeId;
  final Future<void> Function()? onRefresh;

  const PerfumeGrid({
    super.key,
    required this.perfumes,
    required this.storeId,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (perfumes.isEmpty) {
      return GlassContainer(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: Text(
            StringHelper.tr('no_perfumes'),
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1300
            ? 4
            : constraints.maxWidth > 950
            ? 3
            : constraints.maxWidth > 620
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: perfumes.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final perfume = perfumes[index];
            return _PerfumeTile(
              perfume: perfume,
              storeId: storeId,
              onRefresh: onRefresh,
            );
          },
        );
      },
    );
  }
}

class _PerfumeTile extends StatelessWidget {
  final PerfumeModel perfume;
  final String storeId;
  final Future<void> Function()? onRefresh;

  const _PerfumeTile({
    required this.perfume,
    required this.storeId,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  perfume.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: StringHelper.tr('eeg_stats'),
                icon: const Icon(
                  Icons.insights,
                  color: ThemeConstants.accentColor,
                  size: 18,
                ),
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
                padding: EdgeInsets.zero,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EEGStatsScreen(
                        perfumeId: perfume.id,
                        perfumeName: perfume.name,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: perfume.active ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            perfume.brandName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const Spacer(),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _chip(
                PerfumeLocalizationHelper.displayValue(perfume.family),
                ThemeConstants.accentColor,
              ),
              _chip(
                PerfumeLocalizationHelper.displayValue(perfume.genderTarget),
                Colors.lightBlue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPerfumeScreen(
                          perfume: perfume,
                          storeId: storeId,
                        ),
                      ),
                    );
                    if (onRefresh != null) {
                      await onRefresh!.call();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: Text(StringHelper.tr('edit')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text(
                            StringHelper.tr('confirm_delete_perfume_title'),
                          ),
                          content: Text(
                            '${StringHelper.tr('confirm_delete_perfume_message')} "${perfume.name}"?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(StringHelper.tr('cancel')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(StringHelper.tr('delete')),
                            ),
                          ],
                        );
                      },
                    );

                    if (ok != true) return;
                    if (!context.mounted) return;
                    final controller = Provider.of<StoreDashboardController>(
                      context,
                      listen: false,
                    );
                    await controller.deletePerfume(perfume.id);
                    if (onRefresh != null) {
                      await onRefresh!.call();
                    }
                  },
                  icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                  label: Text(
                    StringHelper.tr('delete'),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.zero,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10),
      ),
    );
  }
}

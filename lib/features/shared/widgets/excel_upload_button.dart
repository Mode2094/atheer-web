import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/shared/excel/excel_service.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class ExcelUploadButton extends StatefulWidget {
  final String storeId;
  final Future<void> Function(List<PerfumeModel> perfumes) onPerfumesLoaded;
  final VoidCallback? onTemplateDownloaded;

  const ExcelUploadButton({
    super.key,
    required this.storeId,
    required this.onPerfumesLoaded,
    this.onTemplateDownloaded,
  });

  @override
  State<ExcelUploadButton> createState() => _ExcelUploadButtonState();
}

class _ExcelUploadButtonState extends State<ExcelUploadButton> {
  bool _isLoading = false;

  Future<void> _downloadTemplate() async {
    setState(() => _isLoading = true);
    try {
      final service = ExcelService();
      final savePath = await service.saveTemplateToFile();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savePath == null
                ? StringHelper.tr('template_downloaded_success')
                : '${StringHelper.tr('template_saved_at')} $savePath',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 4),
        ),
      );
      widget.onTemplateDownloaded?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${StringHelper.tr('template_download_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadExcel() async {
    setState(() => _isLoading = true);
    try {
      final picked = await ExcelService.pickExcelFile();
      if (picked == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
      final bytes = picked.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringHelper.tr('cannot_read_file')),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final service = ExcelService();
      final result = await service.readPerfumesFromExcel(
        fileBytes: bytes,
        storeId: widget.storeId,
      );

      if (!mounted) return;

      if (result.perfumes.isEmpty) {
        final reason = result.errors.isNotEmpty
            ? _buildErrorPreview(result.errors)
            : StringHelper.tr('no_valid_perfumes_in_file');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reason),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 8),
          ),
        );
      } else {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF23233D),
            title: Text(
              StringHelper.tr('confirm_addition'),
              style: const TextStyle(color: Colors.white),
            ),
            content: Text(
              result.errors.isEmpty
                  ? '${StringHelper.tr('found_valid_perfumes')} ${result.perfumes.length}. ${StringHelper.tr('add_valid_perfumes_question')}'
                  : '${StringHelper.tr('found_valid_perfumes')} ${result.perfumes.length}. ${StringHelper.tr('invalid_rows')} ${result.errors.length}. ${StringHelper.tr('add_valid_perfumes_question')}',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  StringHelper.tr('cancel'),
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  StringHelper.tr('add'),
                  style: const TextStyle(color: ThemeConstants.accentColor),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await widget.onPerfumesLoaded(result.perfumes);
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${StringHelper.tr('excel_read_error')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _buildErrorPreview(List<String> errors) {
    const maxLines = 10;
    final preview = errors.take(maxLines).join('\n');
    if (errors.length <= maxLines) return preview;
    final remaining = errors.length - maxLines;
    return '$preview\n... +$remaining';
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringHelper.tr('upload_perfumes_batch'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            StringHelper.tr('upload_perfumes_batch_hint'),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AnimatedButton(
                  text: StringHelper.tr('download_template'),
                  icon: Icons.download,
                  isLoading: _isLoading,
                  onPressed: _downloadTemplate,
                  width: double.infinity,
                  height: 45,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AnimatedButton(
                  text: StringHelper.tr('upload_excel'),
                  icon: Icons.upload_file,
                  isLoading: _isLoading,
                  onPressed: _uploadExcel,
                  backgroundColor: ThemeConstants.accentColor,
                  width: double.infinity,
                  height: 45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/update/update_controller.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final _versionNameController = TextEditingController();
  final _versionCodeController = TextEditingController();

  @override
  void dispose() {
    _versionNameController.dispose();
    _versionCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(StringHelper.tr('auto_update_system')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<UpdateController>(
        builder: (context, controller, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: ThemeConstants.accentColor,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            StringHelper.tr('current_version_info'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              StringHelper.tr('version_code'),
                              controller.latestVersion?['latestVersion']
                                      ?.toString() ??
                                  StringHelper.tr('unknown'),
                              Icons.numbers,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              StringHelper.tr('version_name'),
                              controller.latestVersion?['versionName']
                                      ?.toString() ??
                                  StringHelper.tr('unknown'),
                              Icons.label,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard(
                              StringHelper.tr('release_date'),
                              _formatDate(
                                controller.latestVersion?['releaseDate'] ??
                                    controller.latestVersion?['updatedAt'],
                              ),
                              Icons.calendar_today,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  StringHelper.tr('upload_new_update'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GlassContainer(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: controller.pickAPK,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: controller.selectedFileName == null
                                  ? ThemeConstants.accentColor
                                  : Colors.green,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: controller.selectedFileName == null
                              ? Column(
                                  children: [
                                    const Icon(
                                      Icons.cloud_upload,
                                      color: ThemeConstants.accentColor,
                                      size: 50,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      StringHelper.tr('select_apk_file'),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      StringHelper.tr('max_size_100mb'),
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 50,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      controller.selectedFileName!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '${((controller.fileSize ?? 0) / 1024 / 1024).toStringAsFixed(2)} MB',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextButton(
                                      onPressed: controller.clearSelection,
                                      child: Text(
                                        StringHelper.tr('change_file'),
                                        style: const TextStyle(
                                          color: ThemeConstants.accentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _versionNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText: StringHelper.tr('version_name'),
                                hintText: StringHelper.tr('example_version_name'),
                                labelStyle: const TextStyle(color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(
                                    color: ThemeConstants.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _versionCodeController,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: StringHelper.tr('version_code'),
                                hintText: StringHelper.tr('example_version_code'),
                                labelStyle: const TextStyle(color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(
                                    color: ThemeConstants.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (controller.isLoading)
                        Column(
                          children: [
                            LinearProgressIndicator(
                              value: controller.uploadProgress,
                              backgroundColor: Colors.grey[800],
                              valueColor: const AlwaysStoppedAnimation(
                                ThemeConstants.accentColor,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              StringHelper.tr('uploading_file'),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                      else
                        AnimatedButton(
                          text: StringHelper.tr('upload_update'),
                          icon: Icons.cloud_upload,
                          onPressed: () async {
                            if (_versionNameController.text.isEmpty ||
                                _versionCodeController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    StringHelper.tr('enter_version_name_and_code'),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final versionCode = int.tryParse(
                              _versionCodeController.text,
                            );
                            if (versionCode == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    StringHelper.tr('version_code_must_be_number'),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (controller.selectedFilePath == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    StringHelper.tr('select_apk_file_first'),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final success = await controller.uploadUpdate(
                              versionName: _versionNameController.text.trim(),
                              versionCode: versionCode,
                            );

                            if (!context.mounted) return;
                            if (success) {
                              _versionNameController.clear();
                              _versionCodeController.clear();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    StringHelper.tr(
                                      'update_uploaded_successfully',
                                    ),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    controller.error ??
                                        StringHelper.tr('failed_upload_update'),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (controller.error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ThemeConstants.accentColor, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return StringHelper.tr('unknown');
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.year}/${date.month}/${date.day}';
    }
    return StringHelper.tr('unknown');
  }
}

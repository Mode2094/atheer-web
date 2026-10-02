import 'package:flutter/material.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/perfume_constants.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/features/shared/widgets/excel_upload_button.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class AddPerfumeScreen extends StatefulWidget {
  final String storeId;

  const AddPerfumeScreen({super.key, required this.storeId});

  @override
  State<AddPerfumeScreen> createState() => _AddPerfumeScreenState();
}

class _AddPerfumeScreenState extends State<AddPerfumeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandIdController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _notesController = TextEditingController();
  final _topNotesController = TextEditingController();
  final _heartNotesController = TextEditingController();
  final _baseNotesController = TextEditingController();

  String _genderTarget = AppConstants.genderUnisex;
  String _family = 'منعش';
  String _subFamily = PerfumeConstants.subFamilies['منعش']!.first;
  String _intensityLevel = 'معتدل';
  String _sweetnessLevel = 'حلو';
  String _freshnessLevel = 'معتدل';
  String _warmthLevel = 'محايد';
  bool _active = true;
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _brandIdController.dispose();
    _brandNameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _notesController.dispose();
    _topNotesController.dispose();
    _heartNotesController.dispose();
    _baseNotesController.dispose();
    super.dispose();
  }

  List<String> _parseNotes(String value) {
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final notes = _parseNotes(_notesController.text);

    final perfume = PerfumeModel(
      name: _nameController.text.trim(),
      brandId: _brandIdController.text.trim(),
      brandName: _brandNameController.text.trim(),
      description: _descriptionController.text.trim(),
      genderTarget: _genderTarget,
      family: _family,
      subFamily: _subFamily,
      intensityLevel: _intensityLevel,
      sweetnessLevel: _sweetnessLevel,
      freshnessLevel: _freshnessLevel,
      warmthLevel: _warmthLevel,
      notes: notes,
      topNotes: _parseNotes(_topNotesController.text),
      heartNotes: _parseNotes(_heartNotesController.text),
      baseNotes: _parseNotes(_baseNotesController.text),
      imageUrl: _imageUrlController.text.trim(),
      active: _active,
    );

    final controller = Provider.of<AdminController>(context, listen: false);
    final success = await controller.addPerfume(perfume, widget.storeId);

    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.error ?? StringHelper.tr('failed_add_perfume'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: Text(StringHelper.tr('add_perfume'))),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
              child: GlassContainer(
                padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      ExcelUploadButton(
                        storeId: widget.storeId,
                        onPerfumesLoaded: (perfumes) async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          final controller = Provider.of<AdminController>(
                            context,
                            listen: false,
                          );
                          var success = 0;
                          var failed = 0;
                          for (final perfume in perfumes) {
                            final ok = await controller.addPerfume(
                              perfume,
                              widget.storeId,
                            );
                            if (ok) {
                              success++;
                            } else {
                              failed++;
                            }
                          }
                          if (!mounted) return;
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'تمت إضافة $success عطر بنجاح، وفشل $failed عطر',
                              ),
                              backgroundColor: failed == 0
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          );
                          if (success > 0) {
                            navigator.pop();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildField(_nameController, StringHelper.tr('name')),
                      const SizedBox(height: 12),
                      _buildField(
                        _brandNameController,
                        StringHelper.tr('brand_name'),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _brandIdController,
                        StringHelper.tr('brand_id'),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _descriptionController,
                        StringHelper.tr('description'),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              label: StringHelper.tr('gender'),
                              value: _genderTarget,
                              items: AppConstants.genderOptions,
                              onChanged: (v) =>
                                  setState(() => _genderTarget = v!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDropdown(
                              label: StringHelper.tr('family'),
                              value: _family,
                              items: PerfumeConstants.mainFamilies,
                              onChanged: (v) {
                                setState(() {
                                  _family = v!;
                                  _subFamily = PerfumeConstants
                                      .subFamilies[_family]!
                                      .first;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: StringHelper.tr('sub_family'),
                        value: _subFamily,
                        items:
                            PerfumeConstants.subFamilies[_family] ?? const [],
                        onChanged: (v) => setState(() => _subFamily = v!),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _imageUrlController,
                        StringHelper.tr('image_url'),
                        required: false,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _notesController,
                        StringHelper.tr('notes_comma_separated'),
                        required: false,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _topNotesController,
                        'مقدمة العطر (مفصولة بفاصلة)',
                        required: false,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _heartNotesController,
                        'قلب العطر (مفصول بفاصلة)',
                        required: false,
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _baseNotesController,
                        'قاعدة العطر (مفصولة بفاصلة)',
                        required: false,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: StringHelper.tr('intensity'),
                        value: _intensityLevel,
                        items: PerfumeConstants.intensityOptions,
                        onChanged: (v) => setState(() => _intensityLevel = v!),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: StringHelper.tr('sweetness'),
                        value: _sweetnessLevel,
                        items: PerfumeConstants.sweetnessOptions,
                        onChanged: (v) => setState(() => _sweetnessLevel = v!),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: StringHelper.tr('freshness'),
                        value: _freshnessLevel,
                        items: PerfumeConstants.freshnessOptions,
                        onChanged: (v) => setState(() => _freshnessLevel = v!),
                      ),
                      const SizedBox(height: 12),
                      _buildDropdown(
                        label: StringHelper.tr('warmth'),
                        value: _warmthLevel,
                        items: PerfumeConstants.warmthOptions,
                        onChanged: (v) => setState(() => _warmthLevel = v!),
                      ),
                      SwitchListTile(
                        title: Text(
                          StringHelper.tr('active'),
                          style: const TextStyle(color: Colors.white),
                        ),
                        value: _active,
                        activeThumbColor: ThemeConstants.accentColor,
                        onChanged: (value) => setState(() => _active = value),
                      ),
                      const SizedBox(height: 20),
                      AnimatedButton(
                        text: StringHelper.tr('save_perfume'),
                        isLoading: _submitting,
                        onPressed: _save,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: ThemeConstants.accentColor),
        ),
      ),
      validator: (value) {
        if (!required) return null;
        if (value == null || value.trim().isEmpty) {
          return StringHelper.tr('required_field');
        }
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String value)? itemLabelBuilder,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: ThemeConstants.accentColor),
        ),
      ),
      dropdownColor: const Color(0xFF23233D),
      style: const TextStyle(color: Colors.white),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(itemLabelBuilder?.call(item) ?? item),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

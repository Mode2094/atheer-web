import 'package:flutter/material.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/perfume_constants.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/perfume_localization_helper.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/store_dashboard/store_dashboard_controller.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class EditPerfumeScreen extends StatefulWidget {
  final PerfumeModel perfume;
  final String storeId;

  const EditPerfumeScreen({
    super.key,
    required this.perfume,
    required this.storeId,
  });

  @override
  State<EditPerfumeScreen> createState() => _EditPerfumeScreenState();
}

class _EditPerfumeScreenState extends State<EditPerfumeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;
  late final TextEditingController _notesController;
  late final TextEditingController _topNotesController;
  late final TextEditingController _heartNotesController;
  late final TextEditingController _baseNotesController;

  bool _submitting = false;
  bool _deleting = false;

  late String _genderTarget;
  late String _family;
  late String _subFamily;
  late String _intensity;
  late String _sweetness;
  late String _freshness;
  late String _warmth;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.perfume.name);
    _brandController = TextEditingController(text: widget.perfume.brandName);
    _descriptionController = TextEditingController(
      text: widget.perfume.description,
    );
    _imageController = TextEditingController(text: widget.perfume.imageUrl);
    _notesController = TextEditingController(
      text: widget.perfume.notes.join(', '),
    );
    _topNotesController = TextEditingController(
      text: widget.perfume.topNotes.join(', '),
    );
    _heartNotesController = TextEditingController(
      text: widget.perfume.heartNotes.join(', '),
    );
    _baseNotesController = TextEditingController(
      text: widget.perfume.baseNotes.join(', '),
    );
    _genderTarget = widget.perfume.genderTarget;
    _family = widget.perfume.family;
    _subFamily = widget.perfume.subFamily;
    _intensity = widget.perfume.intensityLevel;
    _sweetness = widget.perfume.sweetnessLevel;
    _freshness = widget.perfume.freshnessLevel;
    _warmth = widget.perfume.warmthLevel;
    _active = widget.perfume.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
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

    final updated = widget.perfume.copyWith(
      name: _nameController.text.trim(),
      brandId: _brandController.text.trim(),
      brandName: _brandController.text.trim(),
      description: _descriptionController.text.trim(),
      imageUrl: _imageController.text.trim(),
      notes: _parseNotes(_notesController.text),
      topNotes: _parseNotes(_topNotesController.text),
      heartNotes: _parseNotes(_heartNotesController.text),
      baseNotes: _parseNotes(_baseNotesController.text),
      genderTarget: _genderTarget,
      family: _family,
      subFamily: _subFamily,
      intensityLevel: _intensity,
      sweetnessLevel: _sweetness,
      freshnessLevel: _freshness,
      warmthLevel: _warmth,
      active: _active,
    );

    final controller = Provider.of<StoreDashboardController>(
      context,
      listen: false,
    );
    final success = await controller.updatePerfume(updated);
    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.error ?? StringHelper.tr('failed_update_perfume'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    final controller = Provider.of<StoreDashboardController>(
      context,
      listen: false,
    );
    final success = await controller.deletePerfume(widget.perfume.id);
    if (!mounted) return;
    setState(() => _deleting = false);
    if (success) {
      Navigator.pop(context);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          controller.error ?? StringHelper.tr('failed_delete_perfume'),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(StringHelper.tr('edit_perfume')),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBackground(
        withParticles: true,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                child: GlassContainer(
                  padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _field(_nameController, 'perfume_name'),
                        const SizedBox(height: 12),
                        _field(_brandController, 'brand_name'),
                        const SizedBox(height: 12),
                        _field(
                          _descriptionController,
                          'description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _dropdown(
                                labelKey: 'gender',
                                value: _genderTarget,
                                items: AppConstants.genderOptions,
                                onChanged: (v) =>
                                    setState(() => _genderTarget = v!),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _dropdown(
                                labelKey: 'family',
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
                        _dropdown(
                          labelKey: 'sub_family',
                          value: _subFamily,
                          items:
                              PerfumeConstants.subFamilies[_family] ?? const [],
                          onChanged: (v) => setState(() => _subFamily = v!),
                        ),
                        const SizedBox(height: 12),
                        _field(_imageController, 'image_url', required: false),
                        const SizedBox(height: 12),
                        _field(
                          _notesController,
                          'notes_comma_separated',
                          required: false,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _topNotesController,
                          'مقدمة العطر (مفصولة بفاصلة)',
                          required: false,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _heartNotesController,
                          'قلب العطر (مفصول بفاصلة)',
                          required: false,
                        ),
                        const SizedBox(height: 12),
                        _field(
                          _baseNotesController,
                          'قاعدة العطر (مفصولة بفاصلة)',
                          required: false,
                        ),
                        const SizedBox(height: 12),
                        _dropdown(
                          labelKey: 'intensity',
                          value: _intensity,
                          items: PerfumeConstants.intensityOptions,
                          onChanged: (v) => setState(() => _intensity = v!),
                        ),
                        const SizedBox(height: 12),
                        _dropdown(
                          labelKey: 'sweetness',
                          value: _sweetness,
                          items: PerfumeConstants.sweetnessOptions,
                          onChanged: (v) => setState(() => _sweetness = v!),
                        ),
                        const SizedBox(height: 12),
                        _dropdown(
                          labelKey: 'freshness',
                          value: _freshness,
                          items: PerfumeConstants.freshnessOptions,
                          onChanged: (v) => setState(() => _freshness = v!),
                        ),
                        const SizedBox(height: 12),
                        _dropdown(
                          labelKey: 'warmth',
                          value: _warmth,
                          items: PerfumeConstants.warmthOptions,
                          onChanged: (v) => setState(() => _warmth = v!),
                        ),
                        SwitchListTile(
                          title: Text(
                            StringHelper.tr('active'),
                            style: const TextStyle(color: Colors.white),
                          ),
                          value: _active,
                          activeThumbColor: ThemeConstants.accentColor,
                          onChanged: (v) => setState(() => _active = v),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedButton(
                                text: StringHelper.tr('save_changes'),
                                isLoading: _submitting,
                                onPressed: _save,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedButton(
                                text: StringHelper.tr('delete'),
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                isLoading: _deleting,
                                onPressed: _delete,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String labelKey, {
    int maxLines = 1,
    bool required = true,
  }) {
    final label = StringHelper.tr(labelKey);
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
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ThemeConstants.accentColor),
        ),
      ),
      validator: (v) {
        if (!required) return null;
        if (v == null || v.trim().isEmpty) {
          return '${StringHelper.tr('please_enter_prefix')} $label';
        }
        return null;
      },
    );
  }

  Widget _dropdown({
    required String labelKey,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: StringHelper.tr(labelKey),
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ThemeConstants.accentColor),
        ),
      ),
      dropdownColor: const Color(0xFF23233D),
      style: const TextStyle(color: Colors.white),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(PerfumeLocalizationHelper.displayValue(item)),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/perfume_constants.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/shared/models/perfume_model.dart';
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
  late final TextEditingController _brandIdController;
  late final TextEditingController _brandNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _notesController;
  late final TextEditingController _topNotesController;
  late final TextEditingController _heartNotesController;
  late final TextEditingController _baseNotesController;

  late String _genderTarget;
  late String _family;
  late String _subFamily;
  late String _intensityLevel;
  late String _sweetnessLevel;
  late String _freshnessLevel;
  late String _warmthLevel;
  late bool _active;
  bool _submitting = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.perfume.name);
    _brandIdController = TextEditingController(text: widget.perfume.brandId);
    _brandNameController = TextEditingController(
      text: widget.perfume.brandName,
    );
    _descriptionController = TextEditingController(
      text: widget.perfume.description,
    );
    _imageUrlController = TextEditingController(text: widget.perfume.imageUrl);
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
    _genderTarget = widget.perfume.genderTarget.isEmpty
        ? AppConstants.genderUnisex
        : widget.perfume.genderTarget;
    _family = _normalizeFamily(widget.perfume.family);
    final availableSubFamilies =
        PerfumeConstants.subFamilies[_family] ?? const <String>[];
    _subFamily = availableSubFamilies.contains(widget.perfume.subFamily)
        ? widget.perfume.subFamily
        : availableSubFamilies.first;
    _intensityLevel = _normalizeIntensity(widget.perfume.intensityLevel);
    _sweetnessLevel = _normalizeSweetness(widget.perfume.sweetnessLevel);
    _freshnessLevel = _normalizeFreshness(widget.perfume.freshnessLevel);
    _warmthLevel = _normalizeWarmth(widget.perfume.warmthLevel);
    _active = widget.perfume.active;
  }

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

    final perfume = widget.perfume.copyWith(
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
    final success = await controller.updatePerfume(perfume, widget.storeId);

    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.error ?? StringHelper.tr('failed_update_perfume'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _delete() async {
    setState(() => _deleting = true);
    final controller = Provider.of<AdminController>(context, listen: false);
    final success = await controller.deletePerfume(
      widget.perfume.id,
      widget.storeId,
    );

    if (!mounted) return;
    setState(() => _deleting = false);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.error ?? StringHelper.tr('failed_delete_perfume'),
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
      appBar: AppBar(title: Text(StringHelper.tr('edit_perfume'))),
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

  String _normalizeFamily(String value) {
    if (PerfumeConstants.mainFamilies.contains(value)) {
      return value;
    }
    switch (value) {
      case 'Floral':
        return 'زهري';
      case 'Oriental':
        return 'شرقي';
      case 'Woody':
        return 'خشبي';
      case 'Fresh':
        return 'منعش';
      case 'Fougere':
      case 'Fougère':
        return 'سرخسي';
      default:
        return 'منعش';
    }
  }

  String _normalizeIntensity(String value) {
    if (PerfumeConstants.intensityOptions.contains(value)) {
      return value;
    }
    switch (value) {
      case 'Light':
        return 'خفيف';
      case 'Moderate':
        return 'معتدل';
      case 'Strong':
        return 'قوي';
      default:
        return 'معتدل';
    }
  }

  String _normalizeSweetness(String value) {
    if (PerfumeConstants.sweetnessOptions.contains(value)) {
      return value;
    }
    switch (value) {
      case 'Dry':
        return 'غير حلو';
      case 'Light Sweet':
        return 'حلو خفيف';
      case 'Sweet':
        return 'حلو';
      case 'Very Sweet':
        return 'حلو جداً';
      default:
        return 'حلو';
    }
  }

  String _normalizeFreshness(String value) {
    if (PerfumeConstants.freshnessOptions.contains(value)) {
      return value;
    }
    switch (value) {
      case 'Warm':
        return 'دافئ';
      case 'Balanced':
        return 'معتدل';
      case 'Fresh':
        return 'منعش';
      default:
        return 'معتدل';
    }
  }

  String _normalizeWarmth(String value) {
    if (PerfumeConstants.warmthOptions.contains(value)) {
      return value;
    }
    switch (value) {
      case 'Cool':
        return 'بارد';
      case 'Neutral':
        return 'محايد';
      case 'Warm':
        return 'دافئ';
      default:
        return 'محايد';
    }
  }
}

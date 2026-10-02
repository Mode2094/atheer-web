import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/store_dashboard/store_dashboard_controller.dart';
import 'package:perfume/shared/models/store_model.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class EditStoreScreen extends StatefulWidget {
  final StoreModel store;

  const EditStoreScreen({super.key, required this.store});

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _logoController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.store.name);
    _addressController = TextEditingController(text: widget.store.address);
    _phoneController = TextEditingController(text: widget.store.phone);
    _logoController = TextEditingController(text: widget.store.logo);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final updatedStore = widget.store.copyWith(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      logo: _logoController.text.trim(),
    );

    final controller = Provider.of<StoreDashboardController>(
      context,
      listen: false,
    );
    final success = await controller.updateStore(updatedStore);

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(controller.error ?? StringHelper.tr('update_failed')),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(StringHelper.tr('edit_store')),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBackground(
        withParticles: true,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                child: GlassContainer(
                  padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _buildField(_nameController, 'store_name'),
                        const SizedBox(height: 16),
                        _buildField(_addressController, 'address'),
                        const SizedBox(height: 16),
                        _buildField(_phoneController, 'phone_number'),
                        const SizedBox(height: 16),
                        _buildField(_logoController, 'logo_url_optional'),
                        const SizedBox(height: 24),
                        AnimatedButton(
                          text: StringHelper.tr('save_changes'),
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
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String labelKey) {
    final label = StringHelper.tr(labelKey);
    final optional = labelKey == 'logo_url_optional';
    return TextFormField(
      controller: controller,
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
      validator: (value) {
        if (!optional && (value == null || value.trim().isEmpty)) {
          return '${StringHelper.tr('please_enter_prefix')} $label';
        }
        return null;
      },
    );
  }
}

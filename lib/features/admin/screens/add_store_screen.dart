import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/shared/models/store_model.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({super.key});

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _logoController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final store = StoreModel(
      name: _nameController.text.trim(),
      logo: _logoController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      active: true,
    );

    final controller = Provider.of<AdminController>(context, listen: false);
    final success = await controller.createStore(store);

    if (!mounted) return;
    setState(() => _submitting = false);
    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.error ?? StringHelper.tr('failed_create_store'),
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
      appBar: AppBar(title: Text(StringHelper.tr('add_store'))),
      body: SafeArea(
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
                      _buildField(
                        _nameController,
                        StringHelper.tr('store_name'),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _addressController,
                        StringHelper.tr('address'),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _phoneController,
                        StringHelper.tr('phone_number'),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _logoController,
                        StringHelper.tr('logo_url_optional'),
                        required: false,
                      ),
                      const SizedBox(height: 20),
                      AnimatedButton(
                        text: StringHelper.tr('create_store'),
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
    bool required = true,
  }) {
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
}

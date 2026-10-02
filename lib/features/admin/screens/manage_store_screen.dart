import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/shared/models/store_model.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class ManageStoreScreen extends StatefulWidget {
  final StoreModel? store;

  const ManageStoreScreen({super.key, this.store});

  @override
  State<ManageStoreScreen> createState() => _ManageStoreScreenState();
}

class _ManageStoreScreenState extends State<ManageStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _logoController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _uniqueCodeController;
  bool _active = true;
  bool _isLoading = false;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.store != null;
    _nameController = TextEditingController(text: widget.store?.name ?? '');
    _logoController = TextEditingController(text: widget.store?.logo ?? '');
    _addressController = TextEditingController(
      text: widget.store?.address ?? '',
    );
    _phoneController = TextEditingController(text: widget.store?.phone ?? '');
    _uniqueCodeController = TextEditingController(
      text: widget.store?.uniqueCode ?? '',
    );
    _active = widget.store?.active ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _uniqueCodeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final store = StoreModel(
      id: widget.store?.id ?? '',
      name: _nameController.text.trim(),
      logo: _logoController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      uniqueCode: _uniqueCodeController.text.trim(),
      active: _active,
    );

    final controller = Provider.of<AdminController>(context, listen: false);
    final success = _isEditing
        ? await controller.updateStore(store)
        : await controller.createStore(store);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error ?? StringHelper.tr('operation_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleActive() async {
    if (!_isEditing || widget.store == null) return;

    setState(() => _isLoading = true);

    final controller = Provider.of<AdminController>(context, listen: false);
    final success = await controller.toggleStoreActive(
      widget.store!.id,
      !_active,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _active = !_active);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error ?? StringHelper.tr('update_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _delete() async {
    if (!_isEditing || widget.store == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF23233D),
        title: Text(
          StringHelper.tr('confirm'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          StringHelper.tr('confirm_delete_store'),
          style: TextStyle(color: Colors.white70),
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
              StringHelper.tr('delete'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    final controller = Provider.of<AdminController>(context, listen: false);
    final success = await controller.deleteStore(widget.store!.id);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error ?? StringHelper.tr('delete_failed')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyUniqueCode() {
    FlutterClipboard.copy(_uniqueCodeController.text).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${StringHelper.tr('code_copied')}${_uniqueCodeController.text}',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          _isEditing
              ? StringHelper.tr('edit_store')
              : StringHelper.tr('add_new_store_title'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
              child: GlassContainer(
                padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: '${StringHelper.tr('store_name')} *',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: const BorderSide(
                              color: ThemeConstants.accentColor,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return StringHelper.tr('store_name_required');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_isEditing) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _uniqueCodeController,
                                style: const TextStyle(color: Colors.white),
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: StringHelper.tr(
                                    'unique_store_code',
                                  ),
                                  labelStyle: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: BorderSide(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: ThemeConstants.accentColor.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.zero,
                                border: Border.all(
                                  color: ThemeConstants.accentColor.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.copy,
                                  color: ThemeConstants.accentColor,
                                ),
                                onPressed: _copyUniqueCode,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: StringHelper.tr('address'),
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: const BorderSide(
                              color: ThemeConstants.accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: StringHelper.tr('phone_number'),
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: const BorderSide(
                              color: ThemeConstants.accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _logoController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: StringHelper.tr('logo_url_optional'),
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: const BorderSide(
                              color: ThemeConstants.accentColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_isEditing) ...[
                        SwitchListTile(
                          title: Text(
                            StringHelper.tr('store_active'),
                            style: TextStyle(color: Colors.white),
                          ),
                          value: _active,
                          activeThumbColor: ThemeConstants.accentColor,
                          onChanged: (_) => _toggleActive(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: AnimatedButton(
                              text: _isEditing
                                  ? StringHelper.tr('update')
                                  : StringHelper.tr('add'),
                              isLoading: _isLoading,
                              onPressed: _save,
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedButton(
                                text: StringHelper.tr('delete'),
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                isLoading: _isLoading,
                                onPressed: _delete,
                              ),
                            ),
                          ],
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
}

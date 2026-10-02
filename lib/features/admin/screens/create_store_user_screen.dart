import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/features/stores/store_service.dart';
import 'package:perfume/shared/models/store_model.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class CreateStoreUserScreen extends StatefulWidget {
  const CreateStoreUserScreen({super.key});

  @override
  State<CreateStoreUserScreen> createState() => _CreateStoreUserScreenState();
}

class _CreateStoreUserScreenState extends State<CreateStoreUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  List<StoreModel> _stores = [];
  StoreModel? _selectedStore;
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadStores();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadStores() async {
    final storeService = StoreService();
    _stores = await storeService.getAllStores();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStore == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار متجر'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    final controller = Provider.of<AdminController>(context, listen: false);
    final success = await controller.createStoreUser(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      storeId: _selectedStore!.id,
      storeName: _selectedStore!.name,
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      Navigator.pop(context);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(controller.error ?? 'فشل إنشاء المستخدم'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('إنشاء مستخدم متجر جديد'),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedBackground(
        withParticles: true,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                child: GlassContainer(
                  padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ThemeConstants.accentColor,
                          ),
                        )
                      : Form(
                          key: _formKey,
                          child: ListView(
                            shrinkWrap: true,
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'اسم المستخدم',
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال اسم المستخدم';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'كلمة المرور',
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال كلمة المرور';
                                  }
                                  if (value.length < 6) {
                                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'تأكيد كلمة المرور',
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء تأكيد كلمة المرور';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'كلمة المرور غير متطابقة';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<StoreModel>(
                                initialValue: _selectedStore,
                                decoration: InputDecoration(
                                  labelText: 'اختر المتجر',
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
                                dropdownColor: const Color(0xFF23233D),
                                style: const TextStyle(color: Colors.white),
                                items: _stores.map((store) {
                                  return DropdownMenuItem<StoreModel>(
                                    value: store,
                                    child: Text(store.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedStore = value);
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'الرجاء اختيار متجر';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),
                              AnimatedButton(
                                text: 'إنشاء المستخدم',
                                isLoading: _submitting,
                                onPressed: _createUser,
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
}

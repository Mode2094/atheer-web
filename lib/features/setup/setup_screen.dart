import 'package:flutter/material.dart';
import 'package:perfume/core/services/setup_service.dart';
import 'package:perfume/core/theme/app_theme.dart';
import 'package:perfume/features/stores/store_controller.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/animated_input.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:perfume/shared/widgets/glowing_button.dart';
import 'package:provider/provider.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _storeIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _storeIdController.dispose();
    super.dispose();
  }

  Future<void> _submit(StoreController storeController) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final storeCode = _storeIdController.text.trim();
    debugPrint('Entered store code: "$storeCode"');
    final isValid = await storeController.validateStore(storeCode);

    if (!isValid && mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(storeController.error ?? 'رمز المتجر غير صحيح'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final resolvedStoreId = storeController.currentStore?.id ?? storeCode;
    await SetupService.saveStoreId(resolvedStoreId);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/splash');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        withParticles: false,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(28),
                    borderRadius: BorderRadius.zero,
                    boxShadow: AppTheme.primaryShadow,
                    child: Form(
                      key: _formKey,
                      child: Consumer<StoreController>(
                        builder: (context, storeController, child) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.settings_input_component,
                                color: AppTheme.goldLight,
                                size: 60,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'إعداد الجهاز',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'هذه الشاشة تظهر مرة واحدة فقط لإعداد الجهاز',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 26),
                              AnimatedInput(
                                controller: _storeIdController,
                                label: 'رمز المتجر',
                                hint: 'أدخل رمز المتجر الخاص بك',
                                icon: Icons.key,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'الرجاء إدخال رمز المتجر';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              DefaultTextStyle.merge(
                                style: const TextStyle(fontFamily: 'Cairo'),
                                child: GlowingButton(
                                  text: 'تأكيد وإعداد الجهاز',
                                  icon: Icons.check_circle_outline,
                                  isLoading:
                                      _isLoading || storeController.isLoading,
                                  onPressed: () => _submit(storeController),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
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

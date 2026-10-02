import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/stores/store_controller.dart';
import 'package:provider/provider.dart';

class StoreBindingScreen extends StatefulWidget {
  const StoreBindingScreen({super.key});

  @override
  State<StoreBindingScreen> createState() => _StoreBindingScreenState();
}

class _StoreBindingScreenState extends State<StoreBindingScreen> {
  final TextEditingController _storeIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _storeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeConstants.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Header
              Text(
                StringHelper.tr('store_setup'),
                style: ThemeConstants.headline1,
              ),
              const SizedBox(height: 8),
              Text(
                StringHelper.tr('enter_store_code'),
                style: ThemeConstants.bodyText2,
              ),
              const SizedBox(height: 50),
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Store ID input
                    TextFormField(
                      controller: _storeIdController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: StringHelper.tr('store_code'),
                        labelStyle: ThemeConstants.bodyText2,
                        hintText: StringHelper.tr('store_code'),
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: const BorderSide(color: Colors.grey),
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
                          return StringHelper.tr('enter_store_code');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    // Bind button
                    Consumer<StoreController>(
                      builder: (context, storeController, child) {
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: storeController.isLoading
                                ? null
                                : () async {
                                    if (!_formKey.currentState!.validate()) {
                                      return;
                                    }

                                    final success = await storeController
                                        .loadStore(_storeIdController.text);

                                    if (success && context.mounted) {
                                      // Store bound successfully, go to questionnaire
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/questionnaire',
                                      );
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            storeController.error ??
                                                StringHelper.tr(
                                                  'invalid_store',
                                                ),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ThemeConstants.accentColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: storeController.isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : Text(
                                    StringHelper.tr('continue'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

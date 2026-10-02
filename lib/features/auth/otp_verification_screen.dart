import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/auth/auth_controller.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OTPVerificationScreen extends StatefulWidget {
  const OTPVerificationScreen({super.key});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final _pinController = TextEditingController();
  String? _phoneNumber;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _phoneNumber = args;
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
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
                StringHelper.tr('verify_phone'),
                style: ThemeConstants.headline1,
              ),
              const SizedBox(height: 8),
              Text(
                StringHelper.tr('enter_otp'),
                style: ThemeConstants.bodyText2,
              ),
              Text(
                _phoneNumber ?? '',
                style: const TextStyle(
                  color: ThemeConstants.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),
              // OTP Input
              Center(
                child: Pinput(
                  controller: _pinController,
                  length: 6,
                  defaultPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConstants.surfaceColor,
                      borderRadius: BorderRadius.zero,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 50,
                    height: 50,
                    textStyle: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: BoxDecoration(
                      color: ThemeConstants.surfaceColor,
                      borderRadius: BorderRadius.zero,
                      border: Border.all(
                        color: ThemeConstants.accentColor,
                        width: 2,
                      ),
                    ),
                  ),
                  onCompleted: (pin) async {
                    final authController = Provider.of<AuthController>(
                      context,
                      listen: false,
                    );
                    final success = await authController.verifyOTP(pin);

                    if (success && context.mounted) {
                      // Navigate to next screen (questionnaire or home)
                      Navigator.pushReplacementNamed(context, '/questionnaire');
                    } else if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(StringHelper.tr('invalid_code')),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 30),
              // Resend code
              Center(
                child: TextButton(
                  onPressed: () async {
                    if (_phoneNumber != null) {
                      final authController = Provider.of<AuthController>(
                        context,
                        listen: false,
                      );
                      await authController.sendOTP(_phoneNumber!);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(StringHelper.tr('code_resent')),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    StringHelper.tr('resend_code'),
                    style: const TextStyle(
                      color: ThemeConstants.accentColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

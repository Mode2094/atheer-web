import 'package:flutter/material.dart';
import 'package:perfume/core/services/setup_service.dart';
import 'package:perfume/features/stores/store_controller.dart';
import 'package:provider/provider.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final isSetup = await SetupService.isSetupComplete();

    if (!mounted) return;
    if (isSetup) {
      final storeId = await SetupService.getStoreId();
      if (!mounted) return;
      if (storeId != null && storeId.trim().isNotEmpty) {
        await context.read<StoreController>().loadStore(storeId.trim());
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/splash');
    } else {
      Navigator.pushReplacementNamed(context, '/setup');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(child: CircularProgressIndicator(color: Color(0xFFC6A43F))),
    );
  }
}

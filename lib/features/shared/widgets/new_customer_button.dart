import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/features/shared/services/session_service.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class NewCustomerButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const NewCustomerButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(
            Icons.person_add_alt_1,
            color: ThemeConstants.accentColor,
            size: 40,
          ),
          const SizedBox(height: 8),
          const Text(
            'عميل جديد؟',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'اضغط هنا لبدء تجربة جديدة',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 16),
          AnimatedButton(
            text: 'بدء رحلة جديدة',
            icon: Icons.refresh,
            onPressed: () {
              if (onPressed != null) {
                onPressed!();
                return;
              }
              SessionService.logoutAndReset(context);
            },
            width: 200,
            height: 45,
          ),
        ],
      ),
    );
  }
}

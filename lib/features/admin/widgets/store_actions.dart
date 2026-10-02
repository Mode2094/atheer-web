import 'package:flutter/material.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/screens/manage_store_screen.dart';
import 'package:perfume/features/admin/screens/perfume_management_screen.dart';
import 'package:perfume/shared/models/store_model.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class StoreActions extends StatelessWidget {
  final StoreModel store;

  const StoreActions({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildActionButton(
            icon: Icons.inventory_2,
            label: StringHelper.tr('perfumes'),
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PerfumeManagementScreen(store: store),
                ),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.settings,
            label: StringHelper.tr('settings'),
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ManageStoreScreen(store: store),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.zero,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.zero,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

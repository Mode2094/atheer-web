import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/screens/add_perfume_screen.dart';
import 'package:perfume/features/admin/widgets/perfume_card.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/models/store_model.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class PerfumeList extends StatelessWidget {
  final StoreModel store;
  final List<PerfumeModel> perfumes;

  const PerfumeList({super.key, required this.store, required this.perfumes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AnimatedButton(
                      text: StringHelper.tr('add_perfume'),
                      icon: Icons.add,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddPerfumeScreen(storeId: store.id),
                          ),
                        );
                      },
                      width: double.infinity,
                      height: 40,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  AnimatedButton(
                    text: StringHelper.tr('add_perfume'),
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddPerfumeScreen(storeId: store.id),
                        ),
                      );
                    },
                    width: 170,
                    height: 40,
                  ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final stats = [
                  _buildStat(
                    StringHelper.tr('total_perfumes'),
                    perfumes.length.toString(),
                  ),
                  _buildStat(
                    StringHelper.tr('active'),
                    perfumes.where((p) => p.active).length.toString(),
                  ),
                  _buildStat(
                    StringHelper.tr('inactive'),
                    perfumes.where((p) => !p.active).length.toString(),
                  ),
                ];
                if (constraints.maxWidth < 500) {
                  return Column(
                    children: [
                      stats[0],
                      const SizedBox(height: 12),
                      stats[1],
                      const SizedBox(height: 12),
                      stats[2],
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(child: stats[0]),
                    Expanded(child: stats[1]),
                    Expanded(child: stats[2]),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: perfumes.isEmpty
              ? Center(
                  child: Text(
                    StringHelper.tr('no_perfumes_yet'),
                    style: const TextStyle(color: Colors.white70),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _crossAxisCount(context),
                    childAspectRatio: _childAspectRatio(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: perfumes.length,
                  itemBuilder: (context, index) {
                    return PerfumeCard(
                      perfume: perfumes[index],
                      storeId: store.id,
                    );
                  },
                ),
        ),
      ],
    );
  }

  int _crossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1300) return 3;
    if (width > 860) return 2;
    return 1;
  }

  double _childAspectRatio(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 520) return 1.35;
    if (width <= 860) return 1.6;
    return 2;
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: ThemeConstants.bodyText2),
      ],
    );
  }
}

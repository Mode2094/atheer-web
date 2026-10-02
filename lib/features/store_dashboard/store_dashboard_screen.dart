import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/localization/locale_controller.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/store_auth/store_auth_controller.dart';
import 'package:perfume/features/store_dashboard/screens/add_perfume_screen.dart';
import 'package:perfume/features/store_dashboard/screens/edit_store_screen.dart';
import 'package:perfume/features/store_dashboard/store_dashboard_controller.dart';
import 'package:perfume/features/store_dashboard/widgets/perfume_grid.dart';
import 'package:perfume/features/store_dashboard/widgets/store_info_card.dart';
import 'package:perfume/shared/widgets/animated_background.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:provider/provider.dart';

class StoreDashboardScreen extends StatefulWidget {
  const StoreDashboardScreen({super.key});

  @override
  State<StoreDashboardScreen> createState() => _StoreDashboardScreenState();
}

class _StoreDashboardScreenState extends State<StoreDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    final authController = Provider.of<StoreAuthController>(
      context,
      listen: false,
    );
    final dashboardController = Provider.of<StoreDashboardController>(
      context,
      listen: false,
    );

    if (!authController.isLoggedIn || authController.storeId == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/store-login');
      }
      return;
    }

    await dashboardController.loadStoreData(storeId: authController.storeId!);
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<StoreAuthController>(context);
    final fallbackStore = StringHelper.tr('store_singular');
    final storeName = authController.storeName ?? fallbackStore;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('${StringHelper.tr('store_dashboard')} $storeName'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF23233D),
            onSelected: (value) async {
              if (value == 'lang_ar') {
                await Provider.of<LocaleController>(
                  context,
                  listen: false,
                ).setLocale('ar');
                return;
              }
              if (value == 'lang_en') {
                await Provider.of<LocaleController>(
                  context,
                  listen: false,
                ).setLocale('en');
                return;
              }
              if (value == 'logout') {
                await authController.logout();
                if (!context.mounted) return;
                Navigator.pushReplacementNamed(context, '/store-login');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'lang_ar',
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      StringHelper.tr('arabic'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'lang_en',
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.white70),
                    const SizedBox(width: 8),
                    Text(
                      StringHelper.tr('english'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      StringHelper.tr('logout'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: AnimatedBackground(
        withParticles: true,
        child: Consumer<StoreDashboardController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ThemeConstants.accentColor,
                ),
              );
            }

            if (controller.error != null && !controller.hasStore) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 60),
                    const SizedBox(height: 20),
                    Text(
                      controller.error!,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    AnimatedButton(
                      text: StringHelper.tr('try_again'),
                      onPressed: _loadDashboardData,
                      width: 200,
                    ),
                  ],
                ),
              );
            }

            if (!controller.hasStore || controller.store == null) {
              return Center(
                child: Text(
                  StringHelper.tr('store_not_found'),
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            }

            final store = controller.store!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(ThemeConstants.paddingLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StoreInfoCard(
                    store: store,
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditStoreScreen(store: store),
                        ),
                      ).then((_) => _loadDashboardData());
                    },
                  ),
                  const SizedBox(height: 30),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 700;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              StringHelper.tr('perfumes'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
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
                                    builder: (_) =>
                                        AddPerfumeScreen(storeId: store.id),
                                  ),
                                ).then((_) => _loadDashboardData());
                              },
                              width: double.infinity,
                              height: 45,
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Text(
                            StringHelper.tr('perfumes'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
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
                                  builder: (_) =>
                                      AddPerfumeScreen(storeId: store.id),
                                ),
                              ).then((_) => _loadDashboardData());
                            },
                            width: 170,
                            height: 45,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  PerfumeGrid(
                    perfumes: controller.perfumes,
                    storeId: store.id,
                    onRefresh: _loadDashboardData,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

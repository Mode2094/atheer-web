import 'package:flutter/material.dart';
import 'package:perfume/core/constants/app_constants.dart';
import 'package:perfume/core/constants/perfume_constants.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/admin_controller.dart';
import 'package:perfume/features/admin/screens/add_perfume_screen.dart';
import 'package:perfume/features/admin/widgets/perfume_card.dart';
import 'package:perfume/shared/models/perfume_model.dart';
import 'package:perfume/shared/models/store_model.dart';
import 'package:perfume/shared/widgets/animated_button.dart';
import 'package:perfume/shared/widgets/glass_container.dart';
import 'package:provider/provider.dart';

class PerfumeManagementScreen extends StatefulWidget {
  final StoreModel store;

  const PerfumeManagementScreen({super.key, required this.store});

  @override
  State<PerfumeManagementScreen> createState() =>
      _PerfumeManagementScreenState();
}

class _PerfumeManagementScreenState extends State<PerfumeManagementScreen> {
  static const String _allFilter = 'all';
  static const String _activeFilter = 'active';
  static const String _inactiveFilter = 'inactive';

  String _searchQuery = '';
  String _filterFamily = _allFilter;
  String _filterGender = _allFilter;
  String _filterActive = _allFilter;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminController>(
        context,
        listen: false,
      ).loadStorePerfumes(widget.store.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          '${StringHelper.tr('manage_store_perfumes')} ${widget.store.name}',
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
              color: ThemeConstants.accentColor,
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
        ],
      ),
      body: Consumer<AdminController>(
        builder: (context, controller, child) {
          final perfumes = controller.currentStorePerfumes;
          final filteredPerfumes = _filteredPerfumes(perfumes);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        StringHelper.tr('total_perfumes'),
                        perfumes.length.toString(),
                        Icons.inventory,
                        Colors.blue,
                      ),
                      _buildStatItem(
                        StringHelper.tr('active'),
                        perfumes.where((p) => p.active).length.toString(),
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatItem(
                        StringHelper.tr('inactive'),
                        perfumes.where((p) => !p.active).length.toString(),
                        Icons.cancel,
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GlassContainer(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: '🔍 ${StringHelper.tr('search_perfume')}',
                      hintStyle: const TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: ThemeConstants.accentColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              if (_showFilters) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          StringHelper.tr('filter_by'),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          StringHelper.tr('fragrance_family'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                StringHelper.tr('all'),
                                _filterFamily == _allFilter,
                                () => setState(() => _filterFamily = _allFilter),
                              ),
                              ...PerfumeConstants.mainFamilies.map(
                                (family) => _buildFilterChip(
                                  _familyLabel(family),
                                  _filterFamily == family,
                                  () => setState(() => _filterFamily = family),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          StringHelper.tr('gender'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                StringHelper.tr('all'),
                                _filterGender == _allFilter,
                                () => setState(() => _filterGender = _allFilter),
                              ),
                              _buildFilterChip(
                                StringHelper.tr('gender_male'),
                                _filterGender == AppConstants.genderMale,
                                () => setState(
                                  () => _filterGender = AppConstants.genderMale,
                                ),
                              ),
                              _buildFilterChip(
                                StringHelper.tr('gender_female'),
                                _filterGender == AppConstants.genderFemale,
                                () => setState(
                                  () =>
                                      _filterGender = AppConstants.genderFemale,
                                ),
                              ),
                              _buildFilterChip(
                                StringHelper.tr('gender_unisex'),
                                _filterGender == AppConstants.genderUnisex,
                                () => setState(
                                  () =>
                                      _filterGender = AppConstants.genderUnisex,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          StringHelper.tr('status'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                StringHelper.tr('all'),
                                _filterActive == _allFilter,
                                () => setState(() => _filterActive = _allFilter),
                              ),
                              _buildFilterChip(
                                StringHelper.tr('active'),
                                _filterActive == _activeFilter,
                                () => setState(
                                  () => _filterActive = _activeFilter,
                                ),
                              ),
                              _buildFilterChip(
                                StringHelper.tr('inactive'),
                                _filterActive == _inactiveFilter,
                                () => setState(
                                  () => _filterActive = _inactiveFilter,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: perfumes.isEmpty
                    ? _buildEmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 1300
                              ? 4
                              : constraints.maxWidth > 950
                                  ? 3
                                  : constraints.maxWidth > 650
                                      ? 2
                                      : 1;

                          return GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 1.5,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredPerfumes.length,
                            itemBuilder: (context, index) {
                              final perfume = filteredPerfumes[index];
                              return PerfumeCard(
                                perfume: perfume,
                                storeId: widget.store.id,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final adminController = Provider.of<AdminController>(
            context,
            listen: false,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddPerfumeScreen(storeId: widget.store.id),
            ),
          ).then((_) {
            adminController.loadStorePerfumes(widget.store.id);
          });
        },
        backgroundColor: ThemeConstants.accentColor,
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontSize: 12,
          ),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        selectedColor: ThemeConstants.accentColor,
        checkmarkColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: selected
                ? ThemeConstants.accentColor
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: GlassContainer(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: ThemeConstants.accentColor.withValues(alpha: 0.5),
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              StringHelper.tr('no_perfumes'),
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              StringHelper.tr('add_first_perfume_now'),
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 20),
            AnimatedButton(
              text: StringHelper.tr('add_perfume'),
              icon: Icons.add,
              onPressed: () {
                final adminController = Provider.of<AdminController>(
                  context,
                  listen: false,
                );
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddPerfumeScreen(storeId: widget.store.id),
                  ),
                ).then((_) {
                  adminController.loadStorePerfumes(widget.store.id);
                });
              },
              width: 150,
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  List<PerfumeModel> _filteredPerfumes(List<PerfumeModel> perfumes) {
    final query = _searchQuery.trim().toLowerCase();

    return perfumes.where((p) {
      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.brandName.toLowerCase().contains(query);
      final matchesFamily =
          _filterFamily == _allFilter || p.family == _filterFamily;
      final matchesGender =
          _filterGender == _allFilter ||
          _normalizeGender(p.genderTarget) == _filterGender;
      final matchesActive = _filterActive == _allFilter ||
          (_filterActive == _activeFilter && p.active) ||
          (_filterActive == _inactiveFilter && !p.active);

      return matchesSearch && matchesFamily && matchesGender && matchesActive;
    }).toList();
  }

  String _familyLabel(String rawFamily) {
    final normalized = rawFamily.toLowerCase();
    if (normalized.contains('زهري') || normalized.contains('floral')) {
      return StringHelper.tr('family_floral');
    }
    if (normalized.contains('شرقي') || normalized.contains('oriental')) {
      return StringHelper.tr('family_oriental');
    }
    if (normalized.contains('خشبي') || normalized.contains('woody')) {
      return StringHelper.tr('family_woody');
    }
    if (normalized.contains('منعش') || normalized.contains('fresh')) {
      return StringHelper.tr('family_fresh');
    }
    if (normalized.contains('سرخسي') || normalized.contains('fern')) {
      return StringHelper.tr('family_fern');
    }
    return rawFamily;
  }

  String _normalizeGender(String rawGender) {
    final normalized = rawGender.toLowerCase();
    if (normalized.contains('male') || normalized.contains('ذكر')) {
      return AppConstants.genderMale;
    }
    if (normalized.contains('female') || normalized.contains('أنثى')) {
      return AppConstants.genderFemale;
    }
    if (normalized.contains('unisex') || normalized.contains('للجنسين')) {
      return AppConstants.genderUnisex;
    }
    return rawGender;
  }
}

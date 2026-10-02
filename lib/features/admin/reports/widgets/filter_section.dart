import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/shared/widgets/glass_container.dart';

class FilterSection extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilterChanged;

  const FilterSection({super.key, required this.onFilterChanged});

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  static const String _allFilter = '__all__';

  final TextEditingController _searchController = TextEditingController();
  String _genderFilter = _allFilter;
  String _familyFilter = _allFilter;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<MapEntry<String, String>> _families = const [
    MapEntry(_allFilter, 'all'),
    MapEntry('floral', 'family_floral'),
    MapEntry('oriental', 'family_oriental'),
    MapEntry('woody', 'family_woody'),
    MapEntry('fresh', 'family_fresh'),
    MapEntry('fern', 'family_fern'),
  ];

  final List<MapEntry<String, String>> _genders = const [
    MapEntry(_allFilter, 'all'),
    MapEntry('male', 'gender_male'),
    MapEntry('female', 'gender_female'),
    MapEntry('unisex', 'gender_unisex'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    widget.onFilterChanged({
      'search': _searchController.text.trim().toLowerCase(),
      'gender': _genderFilter,
      'family': _familyFilter,
      'startDate': _startDate,
      'endDate': _endDate,
    });
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StringHelper.tr('filter_results'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            onChanged: (_) => _applyFilters(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: StringHelper.tr('search_name_phone'),
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: ThemeConstants.accentColor),
              ),
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                return Column(
                  children: [
                    _buildDropdown(
                      StringHelper.tr('gender'),
                      _genderFilter,
                      _genders,
                      (value) {
                        setState(() => _genderFilter = value!);
                        _applyFilters();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdown(
                      StringHelper.tr('favorite_family'),
                      _familyFilter,
                      _families,
                      (value) {
                        setState(() => _familyFilter = value!);
                        _applyFilters();
                      },
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      StringHelper.tr('gender'),
                      _genderFilter,
                      _genders,
                      (value) {
                        setState(() => _genderFilter = value!);
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDropdown(
                      StringHelper.tr('favorite_family'),
                      _familyFilter,
                      _families,
                      (value) {
                        setState(() => _familyFilter = value!);
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 700;
              if (isNarrow) {
                return Column(
                  children: [
                    _buildDateButton(StringHelper.tr('from_date'), _startDate, () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                        _applyFilters();
                      }
                    }),
                    const SizedBox(height: 8),
                    _buildDateButton(StringHelper.tr('to_date'), _endDate, () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                        _applyFilters();
                      }
                    }),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: _buildDateButton(
                      StringHelper.tr('from_date'),
                      _startDate,
                      () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _startDate = date);
                          _applyFilters();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildDateButton(
                      StringHelper.tr('to_date'),
                      _endDate,
                      () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => _endDate = date);
                          _applyFilters();
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          if (_startDate != null || _endDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                  _applyFilters();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(StringHelper.tr('clear_date_filter')),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<MapEntry<String, String>> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: ThemeConstants.accentColor),
        ),
      ),
      dropdownColor: const Color(0xFF23233D),
      style: const TextStyle(color: Colors.white),
      items: items
          .map(
            (item) => DropdownMenuItem(
              value: item.key,
              child: Text(StringHelper.tr(item.value)),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateButton(
    String label,
    DateTime? date,
    VoidCallback onPressed,
  ) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: BorderSide(
          color: date != null ? ThemeConstants.accentColor : Colors.grey,
        ),
      ),
      child: Text(
        date == null ? label : '$label ${date.day}/${date.month}',
        style: TextStyle(
          color: date != null ? ThemeConstants.accentColor : Colors.grey,
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:perfume/core/constants/theme_constants.dart';
import 'package:perfume/core/utils/string_helper.dart';
import 'package:perfume/features/admin/reports/models/user_report_model.dart';
import 'package:perfume/features/admin/reports/services/reports_data_service.dart';
import 'package:perfume/features/admin/reports/widgets/distribution_charts.dart';
import 'package:perfume/features/admin/reports/widgets/filter_section.dart';
import 'package:perfume/features/admin/reports/widgets/stats_cards.dart';
import 'package:perfume/features/admin/reports/widgets/users_list.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const String _allFilter = '__all__';

  final ReportsDataService _dataService = ReportsDataService();
  List<UserReportModel> _allUsers = [];
  List<UserReportModel> _filteredUsers = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() => _isLoading = true);

    final pageData = await _dataService.getReportsPageData(
      forceRefresh: forceRefresh,
    );

    if (!mounted) return;
    setState(() {
      _allUsers = pageData.users;
      _filteredUsers = pageData.users;
      _stats = pageData.stats;
      _isLoading = false;
    });
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      _filteredUsers = _allUsers.where((report) {
        final search = filters['search'] as String? ?? '';
        final matchesSearch =
            search.isEmpty ||
            report.user.name.toLowerCase().contains(search) ||
            report.user.phone.toLowerCase().contains(search);

        final genderFilter = filters['gender'] as String? ?? _allFilter;
        final matchesGender =
            genderFilter == _allFilter ||
            _normalizeGender(report.user.gender) == genderFilter;

        final familyFilter = filters['family'] as String? ?? _allFilter;
        final matchesFamily =
            familyFilter == _allFilter ||
            _normalizeFamily(report.favoriteFamily) == familyFilter;

        final startDate = filters['startDate'] as DateTime?;
        final endDate = filters['endDate'] as DateTime?;

        DateTime? createdAt;
        if (report.user.createdAt is Timestamp) {
          createdAt = (report.user.createdAt as Timestamp).toDate();
        } else if (report.user.createdAt is DateTime) {
          createdAt = report.user.createdAt as DateTime;
        }

        final dateAfterStart =
            startDate == null ||
            (createdAt != null && !createdAt.isBefore(startDate));
        final dateBeforeEnd =
            endDate == null ||
            (createdAt != null &&
                !createdAt.isAfter(endDate.add(const Duration(days: 1))));

        return matchesSearch &&
            matchesGender &&
            matchesFamily &&
            dateAfterStart &&
            dateBeforeEnd;
      }).toList();
    });
  }

  String _normalizeGender(String rawGender) {
    final value = rawGender.toLowerCase().trim();
    if (value.contains('male') || value.contains('ذكر')) return 'male';
    if (value.contains('female') || value.contains('أنثى')) return 'female';
    if (value.contains('unisex') || value.contains('للجنسين')) return 'unisex';
    return value;
  }

  String _normalizeFamily(String rawFamily) {
    final value = rawFamily.toLowerCase().trim();
    if (value.contains('floral') || value.contains('زهري')) return 'floral';
    if (value.contains('oriental') || value.contains('شرقي')) return 'oriental';
    if (value.contains('woody') || value.contains('خشبي')) return 'woody';
    if (value.contains('fresh') || value.contains('منعش')) return 'fresh';
    if (value.contains('fern') || value.contains('سرخسي')) return 'fern';
    return value;
  }

  void _exportCSV() async {
    final csv = await ReportsDataService.exportToCSV(_filteredUsers);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          csv.isEmpty
              ? StringHelper.tr('no_rows_to_export')
              : StringHelper.tr('csv_generated'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(color: ThemeConstants.accentColor),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(StringHelper.tr('reports_and_analytics')),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeConstants.primaryColor,
                      ThemeConstants.surfaceColor,
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StatsCards(stats: _stats),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilterSection(onFilterChanged: _applyFilters),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DistributionCharts(stats: _stats),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: UsersList(
              users: _filteredUsers,
              onRefresh: () => _loadData(forceRefresh: true),
              onExport: _exportCSV,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'health_timeline_tab.dart';
import 'health_diet_tab.dart';
import 'health_my_meal_tab.dart';
// import 'health_workout_tab.dart';  // v1.0: ซ่อน
// import 'health_other_tab.dart';    // v1.0: ซ่อน
// import 'health_lab_tab.dart';      // v1.0: ซ่อน

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tabs
        Container(
          color: Theme.of(context).cardColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.health,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.health,
            tabs: const [
              Tab(text: 'Timeline'),
              Tab(text: 'Diet'),
              Tab(text: 'My Meal'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              HealthTimelineTab(),
              HealthDietTab(),
              HealthMyMealTab(),
            ],
          ),
        ),
      ],
    );
  }
}

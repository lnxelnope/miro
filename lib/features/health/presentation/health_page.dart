import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'health_timeline_tab.dart';
import 'health_my_meal_tab.dart';

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
    _tabController = TabController(length: 2, vsync: this);
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
              Tab(text: 'My Meal'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              HealthTimelineTab(),
              HealthMyMealTab(),
            ],
          ),
        ),
      ],
    );
  }
}

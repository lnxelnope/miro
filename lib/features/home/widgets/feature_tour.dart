import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Feature Tour for first-time users
class FeatureTour {
  static const String _keyTutorialCompleted = 'feature_tour_completed_v1';
  
  /// Check if tutorial has been completed
  static Future<bool> hasCompletedTour() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTutorialCompleted) ?? false;
  }
  
  /// Mark tutorial as completed
  static Future<void> completeTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialCompleted, true);
  }
  
  /// Reset tutorial (for testing or "Show again")
  static Future<void> resetTour() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTutorialCompleted);
  }
  
  /// Create and show the feature tour
  static void show({
    required BuildContext context,
    required List<TargetFocus> targets,
    VoidCallback? onFinish,
    VoidCallback? onSkip,
  }) {
    TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      paddingFocus: 10,
      opacityShadow: 0.8,
      textSkip: "SKIP",
      onFinish: () {
        completeTour();
        onFinish?.call();
        return true;
      },
      onSkip: () {
        completeTour();
        onSkip?.call();
        return true;
      },
    ).show(context: context);
  }
  
  /// Build Energy Badge target (Step 1)
  static TargetFocus buildEnergyBadgeTarget(GlobalKey key) {
    return TargetFocus(
      identify: "energy-badge",
      keyTarget: key,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 8,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '⚡ Energy System',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'This is your Energy balance.\n\n'
                    'Each AI food analysis costs 1 Energy.\n'
                    'You start with 100 FREE Energy!\n\n'
                    'Tap here to visit the Energy Store.',
                    style: TextStyle(fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => controller.next(),
                      child: const Text('Next →'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// Build Pull-to-Refresh target (Step 2)
  static TargetFocus buildPullRefreshTarget(GlobalKey key) {
    return TargetFocus(
      identify: "pull-refresh",
      keyTarget: key,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
          builder: (context, controller) {
            return _PullToRefreshAnimatedWidget(controller: controller);
          },
        ),
      ],
    );
  }
  
  /// Build Chat/Magic Button target (Step 3)
  static TargetFocus buildChatButtonTarget(GlobalKey key) {
    return TargetFocus(
      identify: "chat-button",
      keyTarget: key,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.Circle,
      radius: 10,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          padding: const EdgeInsets.all(20),
          builder: (context, controller) {
            return SafeArea(
              child: Container(
                margin: const EdgeInsets.only(bottom: 100),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with icon
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chat_bubble,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '💬 Chat with Miro',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Feature descriptions
                    _buildFeatureRow(
                      icon: Icons.restaurant_menu,
                      text: 'Type food names to analyze nutrition',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(
                      icon: Icons.language,
                      text: 'Use multiple languages with Miro AI mode',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(
                      icon: Icons.flash_on,
                      text: 'Quick Actions for common tasks',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureRow(
                      icon: Icons.battery_charging_full,
                      text: 'Uses 1 Energy per message with Miro AI',
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Note box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Local AI mode is free but English-only',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            controller.skip();
                          },
                          child: const Text(
                            'SKIP',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () {
                            controller.next();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('FINISH'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  /// Helper method for feature rows
  static Widget _buildFeatureRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

/// Animated widget for Pull-to-Refresh tutorial
class _PullToRefreshAnimatedWidget extends StatefulWidget {
  final TutorialCoachMarkController controller;

  const _PullToRefreshAnimatedWidget({required this.controller});

  @override
  State<_PullToRefreshAnimatedWidget> createState() =>
      _PullToRefreshAnimatedWidgetState();
}

class _PullToRefreshAnimatedWidgetState
    extends State<_PullToRefreshAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimation = Tween<double>(
      begin: 0,
      end: 50,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start animation and repeat
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '📸 Auto Photo Scan',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          const Text(
            'Pull down on the food list to automatically '
            'scan your photo gallery for food images!\n\n'
            'Found food photos will be added to your timeline.\n'
            'You can then analyze them with AI.',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 20),
          
          // Animated "Swipe Down" gesture
          Center(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.orange,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_downward,
                          size: 40,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Swipe Down',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Got it button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => widget.controller.next(),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'GOT IT →',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

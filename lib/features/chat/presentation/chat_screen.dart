import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/ai/gemini_chat_service.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_ai_mode.dart';
import '../widgets/message_bubble.dart';
import '../../health/providers/health_provider.dart';
import '../../health/models/food_entry.dart';
import '../../profile/providers/profile_provider.dart';
import '../../energy/providers/energy_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isComposing = false;
  bool _showQuickActions = false; // Collapsible quick actions

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isComposing = _controller.text.trim().isNotEmpty;
      });
    });

    // Listen for AI mode changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen<ChatAiMode>(
        chatAiModeProvider,
        (previous, next) {
          if (previous == ChatAiMode.local && next == ChatAiMode.miroAi) {
            // Switched to Miro AI → Show greeting
            _showMiroAiGreeting();
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    final isLoading = ref.watch(chatLoadingProvider);

    // Scroll to bottom when new message
    if (messages.isNotEmpty) {
      _scrollToBottom();
    }

    // No Scaffold — this is a tab inside HomeScreen's Scaffold
    return Column(
      children: [
        // Top toolbar (replaces AppBar actions)
        _buildChatToolbar(),

        // AI mode indicator
        _buildAiModeIndicator(),

        // Quick actions (expandable)
        if (_showQuickActions) _buildQuickActions(),

        // Messages
        Expanded(
          child: messages.isEmpty
              ? _buildWelcomeScreen()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isLoading && index == messages.length) {
                      return _buildTypingIndicator();
                    }
                    return MessageBubble(message: messages[index]);
                  },
                ),
        ),

        // Input field
        _buildInputField(),
      ],
    );
  }

  /// Modern toolbar row replacing the old AppBar actions
  Widget _buildChatToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.history_rounded,
            tooltip: 'History',
            onPressed: () => _showChatHistory(context),
          ),
          const SizedBox(width: 8),
          _buildToolbarButton(
            icon: Icons.add_comment_outlined,
            tooltip: 'New chat',
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).startNewSession();
            },
          ),
          const Spacer(),
          _buildToolbarButton(
            icon: _showQuickActions
                ? Icons.keyboard_arrow_up_rounded
                : Icons.apps_rounded,
            tooltip: 'Quick Actions',
            onPressed: () {
              setState(() {
                _showQuickActions = !_showQuickActions;
              });
            },
          ),
          const SizedBox(width: 8),
          _buildToolbarButton(
            icon: Icons.delete_outline_rounded,
            tooltip: 'Clear',
            onPressed: () => _showClearConfirmation(),
            color: Colors.red.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final btnColor = color ?? AppColors.textSecondary;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: btnColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: btnColor),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Modern avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    Colors.purple.withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(AppIcons.ai, size: 40, color: AppIcons.aiColor),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Hello! I\'m Miro',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tell me what you ate today!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 28),

            // Example cards
            _buildExampleCard(AppIcons.breakfast, AppIcons.breakfastColor, 'Breakfast', 'scrambled eggs with toast'),
            const SizedBox(height: 10),
            _buildExampleCard(AppIcons.lunch, AppIcons.lunchColor, 'Lunch', 'chicken caesar salad'),
            const SizedBox(height: 10),
            _buildExampleCard(AppIcons.dinner, AppIcons.dinnerColor, 'Dinner', 'grilled salmon with rice'),
            const SizedBox(height: 10),
            _buildExampleCard(AppIcons.snack, AppIcons.snackColor, 'Snack', 'apple and peanut butter'),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(IconData icon, Color iconColor, String meal, String food) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  food,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Quick FAQ buttons (below AI mode toggle)
  Widget _buildQuickActions() {
    final aiMode = ref.watch(chatAiModeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: aiMode == ChatAiMode.miroAi
              ? _buildMiroAiActions()
              : _buildLocalAiActions(),
        ),
      ),
    );
  }

  /// Miro AI Quick Actions (No Log Food)
  List<Widget> _buildMiroAiActions() {
    return [
      _buildActionChip(
        icon: AppIcons.meal,
        iconColor: AppIcons.mealColor,
        label: 'Menu',
        action: () => _requestMenuSuggestion(),
        energyCost: 2,
      ),
      const SizedBox(width: 8),
      _buildActionChip(
        icon: AppIcons.statistics,
        iconColor: AppIcons.statisticsColor,
        label: 'Weekly',
        action: () => _showWeeklySummary(),
        energyCost: 0,
      ),
      const SizedBox(width: 8),
      _buildActionChip(
        icon: AppIcons.statistics,
        iconColor: AppIcons.statisticsColor,
        label: 'Monthly',
        action: () => _showMonthlySummary(),
        energyCost: 0,
      ),
      const SizedBox(width: 8),
      _buildActionChip(
        icon: AppIcons.tips,
        iconColor: AppIcons.tipsColor,
        label: 'Tips',
        action: () => _sendQuickMessage('Give me tips for healthy eating'),
        energyCost: 2,
      ),
    ];
  }

  /// Local AI Quick Actions (No Log Food)
  List<Widget> _buildLocalAiActions() {
    return [
      _buildActionChip(
        icon: AppIcons.statistics,
        iconColor: AppIcons.statisticsColor,
        label: 'Summary',
        action: () => _sendQuickMessage('How many calories today?'),
        energyCost: 0,
      ),
      const SizedBox(width: 8),
      _buildActionChip(
        icon: Icons.help_outline_rounded,
        iconColor: Colors.grey.shade700,
        label: 'Help',
        action: () => _showLocalAiHelp(),
        energyCost: 0,
      ),
    ];
  }

  /// Build action chip button — modern pill style
  Widget _buildActionChip({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? hint,
    VoidCallback? action,
    required int energyCost,
  }) {
    final isPremium = energyCost > 0;
    return GestureDetector(
      onTap: () {
        if (hint != null) {
          _controller.text = hint;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: hint.length),
          );
        } else if (action != null) {
          action();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isPremium
              ? AppColors.primary.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPremium ? AppColors.primary : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Send quick message (for AI actions)
  void _sendQuickMessage(String message) {
    _controller.text = message;
    _sendCurrentMessage();
  }

  /// Show weekly summary (local query)
  Future<void> _showWeeklySummary() async {
    try {
      // Get date range for this week (last 7 days)
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));

      // Get all food entries for this week
      final weekEntries = <FoodEntry>[];

      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final entriesAsync = ref.read(foodEntriesByDateProvider(date));
        final entries = await entriesAsync.when(
          data: (data) => Future.value(data),
          loading: () => Future.value(<FoodEntry>[]),
          error: (_, __) => Future.value(<FoodEntry>[]),
        );
        weekEntries.addAll(entries);
      }

      // Calculate daily calories
      final dailyCalories = <DateTime, double>{};
      for (final entry in weekEntries) {
        final date = DateTime(
            entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
        dailyCalories[date] = (dailyCalories[date] ?? 0) + entry.calories;
      }

      // Get target calories
      final profileAsync = ref.read(profileNotifierProvider);
      final profile = await profileAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value(null),
        error: (_, __) => Future.value(null),
      );
      final targetCalories = profile?.calorieGoal ?? 2000;

      // Build summary message
      final buffer = StringBuffer();
      buffer.writeln(
          '📊 Weekly Summary (${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)})');
      buffer.writeln();

      // List each day
      double totalCalories = 0;
      int daysWithData = 0;

      for (int i = 0; i < 7; i++) {
        final date = startOfWeek.add(Duration(days: i));
        final dateOnly = DateTime(date.year, date.month, date.day);
        final calories = dailyCalories[dateOnly] ?? 0;

        if (calories > 0) {
          totalCalories += calories;
          daysWithData++;

          final diff = calories - targetCalories;
          final diffText = diff > 0
              ? '${diff.toStringAsFixed(0)} over target'
              : '${(-diff).toStringAsFixed(0)} under target';
          final emoji = diff > 0 ? '⚠️' : '✅';

          buffer.writeln(
              '📅 ${_getDayName(date)}: ${calories.toStringAsFixed(0)} kcal $emoji ($diffText)');
        }
      }

      if (daysWithData == 0) {
        buffer.writeln('No food logged this week yet.');
      } else {
        buffer.writeln();
        final average = totalCalories / daysWithData;
        final weekDiff = totalCalories - (targetCalories * daysWithData);

        buffer.writeln('🔥 Average: ${average.toStringAsFixed(0)} kcal/day');
        buffer.writeln(
            '🎯 Target: ${targetCalories.toStringAsFixed(0)} kcal/day');

        if (weekDiff > 0) {
          buffer.writeln(
              '📈 Result: ${weekDiff.toStringAsFixed(0)} kcal over target');
        } else {
          buffer.writeln(
              '📈 Result: ${(-weekDiff).toStringAsFixed(0)} kcal under target — Great job! 💪');
        }
      }

      // Add message to chat
      final message = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content = buffer.toString();

      await ref.read(chatNotifierProvider.notifier).addMessage(message);
    } catch (e) {
      final errorMsg = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content = '❌ Failed to load weekly summary: ${e.toString()}';

      await ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
    }
  }

  /// Show monthly summary (local query)
  Future<void> _showMonthlySummary() async {
    try {
      // Get date range for this month
      final now = DateTime.now();
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      // Get all food entries for this month
      final monthEntries = <FoodEntry>[];

      for (int day = 1; day <= endOfMonth.day; day++) {
        final date = DateTime(now.year, now.month, day);
        final entriesAsync = ref.read(foodEntriesByDateProvider(date));
        final entries = await entriesAsync.when(
          data: (data) => Future.value(data),
          loading: () => Future.value(<FoodEntry>[]),
          error: (_, __) => Future.value(<FoodEntry>[]),
        );
        monthEntries.addAll(entries);
      }

      // Calculate total calories
      double totalCalories = 0;
      for (final entry in monthEntries) {
        totalCalories += entry.calories;
      }

      // Get target calories
      final profileAsync = ref.read(profileNotifierProvider);
      final profile = await profileAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value(null),
        error: (_, __) => Future.value(null),
      );
      final targetCalories = profile?.calorieGoal ?? 2000;

      // Calculate days in month
      final daysInMonth = endOfMonth.day;
      final targetTotal = targetCalories * daysInMonth;
      final average = monthEntries.isEmpty ? 0 : totalCalories / daysInMonth;

      // Build summary message
      final buffer = StringBuffer();
      buffer.writeln('📊 Monthly Summary (${_getMonthName(now)} ${now.year})');
      buffer.writeln();
      buffer.writeln('📅 Total Days: $daysInMonth');
      buffer.writeln(
          '🔥 Total Consumed: ${totalCalories.toStringAsFixed(0)} kcal');
      buffer.writeln('🎯 Target Total: ${targetTotal.toStringAsFixed(0)} kcal');
      buffer.writeln('📈 Average: ${average.toStringAsFixed(0)} kcal/day');
      buffer.writeln();

      final diff = totalCalories - targetTotal;
      if (diff > 0) {
        buffer.writeln(
            '⚠️ ${diff.toStringAsFixed(0)} kcal over target this month');
      } else {
        buffer.writeln(
            '✅ ${(-diff).toStringAsFixed(0)} kcal under target — Excellent! 💪');
      }

      // Add message to chat
      final message = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content = buffer.toString();

      await ref.read(chatNotifierProvider.notifier).addMessage(message);
    } catch (e) {
      final errorMsg = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content = '❌ Failed to load monthly summary: ${e.toString()}';

      await ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
    }
  }

  /// Show Local AI help
  Future<void> _showLocalAiHelp() async {
    const helpText = '''
🤖 Local AI Help

Format: [food] [amount] [unit]

Examples:
• chicken 100g and rice 200g
• pizza 2 slices
• apple 1 piece, banana 1 piece

Note: English only, basic parsing
Switch to Miro AI for better results!
''';

    final message = ChatMessage()
      ..sessionId = ref.read(currentSessionIdProvider)
      ..role = MessageRole.assistant
      ..content = helpText;

    await ref.read(chatNotifierProvider.notifier).addMessage(message);
  }

  /// Helper: Format date as "Feb 10"
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Helper: Get day name
  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }

  /// Helper: Get month name
  String _getMonthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[date.month - 1];
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 3,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Tell me what you ate...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendCurrentMessage(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Send button — animated circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isComposing ? AppColors.primary : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isComposing ? _sendCurrentMessage : null,
                borderRadius: BorderRadius.circular(21),
                child: Center(
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: _isComposing ? Colors.white : Colors.grey.shade400,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    ref.read(chatNotifierProvider.notifier).sendMessage(message);
    _controller.clear();
  }

  void _sendCurrentMessage() {
    _sendMessage(_controller.text);
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(AppIcons.ai, size: 18, color: AppIcons.aiColor),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 5),
                _buildDot(1),
                const SizedBox(width: 5),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Clear history?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text('All messages in this session will be deleted.',
            style: TextStyle(color: Colors.grey.shade600)),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearMessages();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// แสดง Bottom Sheet ประวัติการแชท — Modern design
  void _showChatHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (sheetCtx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.history_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Chat History',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(sheetCtx);
                        ref
                            .read(chatNotifierProvider.notifier)
                            .startNewSession();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded,
                                size: 16, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'New',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Divider(height: 1, color: Colors.grey.shade200),

              // Sessions list
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final sessionsAsync = ref.watch(chatSessionsProvider);

                    return sessionsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (sessions) {
                        if (sessions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline,
                                    size: 56, color: Colors.grey.shade300),
                                const SizedBox(height: 16),
                                Text(
                                  'No chat history yet',
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          itemCount: sessions.length,
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            final currentSessionId =
                                ref.read(currentSessionIdProvider);
                            final isActive =
                                session.sessionId == currentSessionId;

                            return _buildSessionTile(
                                context, session, isActive);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSessionTile(
      BuildContext context, ChatSession session, bool isActive) {
    final dateFormat = DateFormat('dd MMM', 'th');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.06)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: isActive
            ? Border.all(color: AppColors.primary.withOpacity(0.2), width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            ref
                .read(chatNotifierProvider.notifier)
                .loadSession(session.sessionId!);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withOpacity(0.15)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chat_rounded,
                    color: isActive ? AppColors.primary : Colors.grey.shade500,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(session.updatedAt)} ${timeFormat.format(session.updatedAt)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDeleteSession(context, session),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, ChatSession session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.delete_outline_rounded,
                  color: Colors.red.shade400, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Delete chat?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        content: Text('Delete "${session.title}"?',
            style: TextStyle(color: Colors.grey.shade600)),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child:
                Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref
                  .read(chatNotifierProvider.notifier)
                  .deleteSession(session.sessionId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// AI Mode Indicator — clean pill badge
  Widget _buildAiModeIndicator() {
    final chatAiMode = ref.watch(chatAiModeProvider);
    final isMiroAi = chatAiMode == ChatAiMode.miroAi;
    final modeColor =
        isMiroAi ? const Color(0xFF6366F1) : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: modeColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMiroAi ? Icons.auto_awesome : Icons.psychology,
                  size: 14,
                  color: modeColor,
                ),
                const SizedBox(width: 6),
                Text(
                  chatAiMode.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: modeColor,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isMiroAi
                        ? Colors.amber.shade600
                        : const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isMiroAi) ...[
                        Icon(AppIcons.energy, size: 10, color: Colors.white),
                        const Text('2+', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                      ] else
                        const Text('Free', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show smart greeting when switching to Miro AI
  Future<void> _showMiroAiGreeting() async {
    try {
      // Get today's calories
      final todayCaloriesAsync = ref.read(todayCaloriesProvider);
      final todayCalories = await todayCaloriesAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value(0.0),
        error: (_, __) => Future.value(0.0),
      );

      // Get health goal from profile
      final profileAsync = ref.read(profileNotifierProvider);
      final profile = await profileAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value(null),
        error: (_, __) => Future.value(null),
      );
      final targetCalories = profile?.calorieGoal ?? 2000;

      // Calculate remaining
      final remaining = targetCalories - todayCalories;

      // Build greeting message
      String greeting;
      if (todayCalories == 0) {
        greeting = '🤖 Hi! No food logged yet today.\n'
            '   Target: ${targetCalories.toStringAsFixed(0)} kcal — Ready to start logging? 🍽️';
      } else if (remaining > 0) {
        greeting =
            '🤖 Hi! You have ${remaining.toStringAsFixed(0)} kcal left for today.\n'
            '   Ready to log your meals? 😊';
      } else {
        greeting =
            '🤖 Hi! You\'ve consumed ${todayCalories.toStringAsFixed(0)} kcal today.\n'
            '   ${(-remaining).toStringAsFixed(0)} kcal over target — Let\'s keep tracking! 💪';
      }

      // Add greeting message
      final greetingMsg = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content = greeting;

      await ref.read(chatNotifierProvider.notifier).addMessage(greetingMsg);
    } catch (e) {
      // Fallback greeting
      final fallbackMsg = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content = '🤖 Hi! Ready to log your meals? 😊';

      await ref.read(chatNotifierProvider.notifier).addMessage(fallbackMsg);
    }
  }

  /// Request menu suggestions from Miro AI (costs 1 Energy)
  Future<void> _requestMenuSuggestion() async {
    // Check Energy (2 required for menu suggestion)
    final energyService = ref.read(energyServiceProvider);
    final balance = await energyService.getBalance();

    if (balance < 2) {
      final errorMsg = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content =
            '❌ Not enough Energy (minimum 2⚡ required). Please purchase more from the store.';

      await ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
      return;
    }

    // Show loading
    final loadingMsg = ChatMessage()
      ..sessionId = ref.read(currentSessionIdProvider)
      ..role = MessageRole.assistant
      ..content = '🤖 Thinking of great meal ideas for you...';

    await ref.read(chatNotifierProvider.notifier).addMessage(loadingMsg);

    try {
      // Get user profile for personalization
      final profileAsync = ref.read(profileNotifierProvider);
      final profile = await profileAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value(null),
        error: (_, __) => Future.value(null),
      );

      // Get recent food context (last 7 days)
      final now = DateTime.now();
      final weekAgo = now.subtract(const Duration(days: 7));
      final recentEntries = <FoodEntry>[];

      for (int i = 0; i < 7; i++) {
        final date = weekAgo.add(Duration(days: i));
        final entriesAsync = ref.read(foodEntriesByDateProvider(date));
        final entries = await entriesAsync.when(
          data: (data) => Future.value(data),
          loading: () => Future.value(<FoodEntry>[]),
          error: (_, __) => Future.value(<FoodEntry>[]),
        );
        recentEntries.addAll(entries);
      }

      // Build context string
      String context = 'Recent meals: ';
      if (recentEntries.isEmpty) {
        context += 'No recent food logged.';
      } else {
        final foodNames =
            recentEntries.map((e) => e.foodName).take(10).join(', ');
        context += foodNames;
      }

      // Get today's remaining calories
      final todayCaloriesAsync = ref.read(todayCaloriesProvider);
      final todayCalories = await todayCaloriesAsync.when(
        data: (data) => Future.value(data),
        loading: () => Future.value(0.0),
        error: (_, __) => Future.value(0.0),
      );

      final targetCalories = profile?.calorieGoal ?? 2000;
      final remaining = targetCalories - todayCalories;

      context +=
          '. Remaining calories today: ${remaining.toStringAsFixed(0)} kcal.';

      // Call AI with profile context
      final response = await GeminiChatService.getMenuSuggestions(
        recentFoodContext: context,
        energyService: energyService,
        userProfile: profile,
      );

      // Remove loading message
      await ref.read(chatNotifierProvider.notifier).removeMessage(loadingMsg);

      // Parse and display suggestions
      await _displayMenuSuggestions(response);
    } catch (e) {
      // Remove loading message
      await ref.read(chatNotifierProvider.notifier).removeMessage(loadingMsg);

      // Show error
      final errorMsg = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content = '❌ Failed to get menu suggestions: ${e.toString()}';

      await ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
    }
  }

  /// Display menu suggestions
  Future<void> _displayMenuSuggestions(Map<String, dynamic> response) async {
    if (response['type'] != 'menu_suggestion') {
      throw Exception('Invalid response type');
    }

    final suggestions = response['suggestions'] as List<dynamic>?;
    if (suggestions == null || suggestions.isEmpty) {
      throw Exception('No suggestions returned');
    }

    // Build message
    final buffer = StringBuffer();
    buffer.writeln('🤖 Based on your food log, here are 3 meal suggestions:\n');

    int index = 1;
    for (final suggestion in suggestions) {
      final name = suggestion['name'] as String;
      final emoji = suggestion['emoji'] as String? ?? '🍽️';
      final calories = suggestion['calories'] as num;
      final protein = suggestion['protein'] as num;
      final carbs = suggestion['carbs'] as num;
      final fat = suggestion['fat'] as num;

      buffer.writeln(
          '$index. $emoji $name (~${calories.toStringAsFixed(0)} kcal)');
      buffer.writeln('   P: ${protein}g | C: ${carbs}g | F: ${fat}g');
      if (index < suggestions.length) buffer.writeln();
      index++;
    }

    buffer.writeln('\nPick one and I\'ll log it for you! 😊');
    buffer.writeln('\n⚡ -2 Energy');

    // Add message
    final message = ChatMessage()
      ..sessionId = ref.read(currentSessionIdProvider)
      ..role = MessageRole.assistant
      ..content = buffer.toString();

    await ref.read(chatNotifierProvider.notifier).addMessage(message);
  }
}

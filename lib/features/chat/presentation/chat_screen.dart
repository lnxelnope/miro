import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/app_icons.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/ai/gemini_chat_service.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../models/chat_ai_mode.dart';
import '../services/greeting_service.dart';
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
  bool _showQuickActions = false;
  bool _greetingSent = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isComposing = _controller.text.trim().isNotEmpty;
      });
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

    // Listen for AI mode changes (moved from initState)
    ref.listen<ChatAiMode>(
      chatAiModeProvider,
      (previous, next) {
        if (previous == ChatAiMode.local && next == ChatAiMode.miroAi) {
          // Switched to Miro AI → Show greeting
          _showMiroAiGreeting();
        }
      },
    );

    // Auto-send greeting when chat opens with empty messages
    if (messages.isEmpty && !_greetingSent && !isLoading) {
      _greetingSent = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendAutoGreeting();
      });
    }

    // Reset flag when session changes (messages become empty again)
    if (messages.isNotEmpty) {
      _greetingSent = true;
    }

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
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.dividerDark : AppColors.divider, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          _buildToolbarButton(
            icon: Icons.history_rounded,
            tooltip: L10n.of(context)!.chatHistory,
            onPressed: () => _showChatHistory(context),
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildToolbarButton(
            icon: Icons.add_comment_outlined,
            tooltip: L10n.of(context)!.newChat,
            onPressed: () {
              _greetingSent = false;
              ref.read(chatNotifierProvider.notifier).startNewSession();
            },
          ),
          const Spacer(),
          _buildToolbarButton(
            icon: _showQuickActions
                ? Icons.keyboard_arrow_up_rounded
                : Icons.apps_rounded,
            tooltip: L10n.of(context)!.quickActions,
            onPressed: () {
              setState(() {
                _showQuickActions = !_showQuickActions;
              });
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildToolbarButton(
            icon: Icons.delete_outline_rounded,
            tooltip: L10n.of(context)!.clear,
            onPressed: () => _showClearConfirmation(),
            color: AppColors.error,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final btnColor = color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.md,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: btnColor.withValues(alpha: 0.08),
              borderRadius: AppRadius.md,
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
        padding: const EdgeInsets.all(AppSpacing.xxl + AppSpacing.xs),
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
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.premium.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(AppIcons.ai, size: 40, color: AppIcons.aiColor),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              L10n.of(context)!.helloImMiro,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              L10n.of(context)!.tellMeWhatYouAteToday,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl + AppSpacing.xs),

            // Example cards
            _buildExampleCard(AppIcons.breakfast, AppIcons.breakfastColor, 'Breakfast', 'scrambled eggs with toast'),
            const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
            _buildExampleCard(AppIcons.lunch, AppIcons.lunchColor, 'Lunch', 'chicken caesar salad'),
            const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
            _buildExampleCard(AppIcons.dinner, AppIcons.dinnerColor, 'Dinner', 'grilled salmon with rice'),
            const SizedBox(height: AppSpacing.xs + AppSpacing.xxs),
            _buildExampleCard(AppIcons.snack, AppIcons.snackColor, 'Snack', 'apple and peanut butter'),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard(IconData icon, Color iconColor, String meal, String food) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(width: AppSpacing.md),
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
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
        label: L10n.of(context)!.menuLabel,
        action: () => _requestMenuSuggestion(),
        energyCost: 1,
      ),
      const SizedBox(width: AppSpacing.sm),
      _buildActionChip(
        icon: AppIcons.statistics,
        iconColor: AppIcons.statisticsColor,
        label: L10n.of(context)!.weeklyLabel,
        action: () => _showWeeklySummary(),
        energyCost: 0,
      ),
      const SizedBox(width: AppSpacing.sm),
      _buildActionChip(
        icon: AppIcons.statistics,
        iconColor: AppIcons.statisticsColor,
        label: L10n.of(context)!.monthlyLabel,
        action: () => _showMonthlySummary(),
        energyCost: 0,
      ),
      const SizedBox(width: AppSpacing.sm),
      _buildActionChip(
        icon: AppIcons.tips,
        iconColor: AppIcons.tipsColor,
        label: L10n.of(context)!.tipsLabel,
        action: () => _sendQuickMessage(L10n.of(context)!.giveMeTipsForHealthyEating),
        energyCost: 1,
      ),
    ];
  }

  /// Local AI Quick Actions (No Log Food)
  List<Widget> _buildLocalAiActions() {
    return [
      _buildActionChip(
        icon: AppIcons.statistics,
        iconColor: AppIcons.statisticsColor,
        label: L10n.of(context)!.summaryLabel,
        action: () => _sendQuickMessage(L10n.of(context)!.howManyCaloriesToday),
        energyCost: 0,
      ),
      const SizedBox(width: AppSpacing.sm),
      _buildActionChip(
        icon: Icons.help_outline_rounded,
        iconColor: Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        label: L10n.of(context)!.helpLabel,
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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isPremium
              ? AppColors.primary.withValues(alpha: 0.08)
              : (Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant),
          borderRadius: AppRadius.xl,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPremium ? AppColors.primary : (Theme.of(context).brightness == Brightness.dark ? AppColors.textSecondaryDark : AppColors.textSecondary),
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
          L10n.of(context)!.weeklySummaryTitle(_formatDate(startOfWeek), _formatDate(endOfWeek)));
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
              ? L10n.of(context)!.overTarget(diff.toStringAsFixed(0))
              : L10n.of(context)!.underTarget((-diff).toStringAsFixed(0));
          final emoji = diff > 0 ? '⚠️' : '✅';

          buffer.writeln(
              L10n.of(context)!.daySummary(_getDayName(date), calories.toStringAsFixed(0), emoji, diffText));
        }
      }

      if (daysWithData == 0) {
        buffer.writeln(L10n.of(context)!.noFoodLoggedThisWeek);
      } else {
        buffer.writeln();
        final average = totalCalories / daysWithData;
        final weekDiff = totalCalories - (targetCalories * daysWithData);

        buffer.writeln(L10n.of(context)!.averageKcalPerDay(average.toStringAsFixed(0)));
        buffer.writeln(L10n.of(context)!.targetKcalPerDay(targetCalories.toStringAsFixed(0)));

        if (weekDiff > 0) {
          buffer.writeln(L10n.of(context)!.resultOverTarget(weekDiff.toStringAsFixed(0)));
        } else {
          buffer.writeln(L10n.of(context)!.resultUnderTarget((-weekDiff).toStringAsFixed(0)));
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
        ..content = L10n.of(context)!.failedToLoadWeeklySummary(e.toString());

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
      buffer.writeln(L10n.of(context)!.monthlySummaryTitle(_getMonthName(now), now.year));
      buffer.writeln();
      buffer.writeln(L10n.of(context)!.totalDays(daysInMonth));
      buffer.writeln(L10n.of(context)!.totalConsumed(totalCalories.toStringAsFixed(0)));
      buffer.writeln(L10n.of(context)!.targetTotal(targetTotal.toStringAsFixed(0)));
      buffer.writeln(L10n.of(context)!.averageKcalPerDayShort(average.toStringAsFixed(0)));
      buffer.writeln();

      final diff = totalCalories - targetTotal;
      if (diff > 0) {
        buffer.writeln(L10n.of(context)!.overTargetThisMonth(diff.toStringAsFixed(0)));
      } else {
        buffer.writeln(L10n.of(context)!.underTargetThisMonth((-diff).toStringAsFixed(0)));
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
        ..content = L10n.of(context)!.failedToLoadMonthlySummary(e.toString());

      await ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
    }
  }

  /// Show Local AI help
  Future<void> _showLocalAiHelp() async {
    final helpText = '''
${L10n.of(context)!.localAiHelpTitle}

${L10n.of(context)!.localAiHelpFormat}

${L10n.of(context)!.localAiHelpExamples}

${L10n.of(context)!.localAiHelpNote}
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
                color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
                borderRadius: AppRadius.xxl,
              ),
              child: TextField(
                controller: _controller,
                maxLines: 3,
                minLines: 1,
                style: TextStyle(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: L10n.of(context)!.tellMeWhatYouAte,
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                ),
                onSubmitted: (_) => _sendCurrentMessage(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
          // Send button — animated circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _isComposing ? AppColors.primary : (isDark ? AppColors.surfaceVariantDark : AppColors.divider),
              shape: BoxShape.circle,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isComposing ? _sendCurrentMessage : null,
                borderRadius: AppRadius.xl,
                child: Center(
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: _isComposing ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textTertiary),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(AppIcons.ai, size: 18, color: AppIcons.aiColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
              borderRadius: AppRadius.lg,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
                _buildDot(1),
                const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
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
            color: AppColors.primary.withValues(alpha: 0.2 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  void _showClearConfirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(L10n.of(context)!.clearHistoryTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        content: Text(L10n.of(context)!.clearHistoryMessage,
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs + AppSpacing.xxs),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
            ),
            child:
                Text('Cancel', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearMessages();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs + AppSpacing.xxs),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
              elevation: 0,
            ),
            child: Text(L10n.of(context)!.clear),
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
        builder: (sheetCtx, scrollController) {
          final isDark = Theme.of(sheetCtx).brightness == Brightness.dark;
          return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxlValue)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dividerDark : AppColors.divider,
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
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: AppRadius.md,
                      ),
                      child: const Icon(Icons.history_rounded,
                          color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      L10n.of(context)!.chatHistoryTitle,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
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
                            horizontal: AppSpacing.md, vertical: AppSpacing.xs + AppSpacing.xxs),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: AppRadius.xl,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded,
                                size: 16, color: AppColors.primary),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              L10n.of(context)!.newLabel,
                              style: const TextStyle(
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

              Divider(height: 1, color: isDark ? AppColors.dividerDark : AppColors.divider),

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
                                    size: 56, color: isDark ? Colors.white38 : AppColors.textTertiary),
                                const SizedBox(height: AppSpacing.lg),
                                Text(
                                  L10n.of(context)!.noChatHistoryYet,
                                  style: TextStyle(
                                      color: isDark ? Colors.white38 : AppColors.textTertiary,
                                      fontSize: 14),
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
        );
      },
      ),
    );
  }

  Widget _buildSessionTile(
      BuildContext context, ChatSession session, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd MMM', 'th');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.06)
            : (isDark ? AppColors.backgroundDark : AppColors.background),
            borderRadius: AppRadius.lg,
        border: isActive
            ? Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1)
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
          borderRadius: AppRadius.lg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md + AppSpacing.xxs),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark ? AppColors.dividerDark : AppColors.divider),
                    borderRadius: AppRadius.md,
                  ),
                  child: Icon(
                    Icons.chat_rounded,
                    color: isActive ? AppColors.primary : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
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
                                  horizontal: AppSpacing.xs + AppSpacing.xxs, vertical: AppSpacing.xxs),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: AppRadius.sm,
                              ),
                              child: Text(
                                L10n.of(context)!.active,
                                style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${dateFormat.format(session.updatedAt)} ${timeFormat.format(session.updatedAt)}',
                        style: TextStyle(
                            fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                GestureDetector(
                  onTap: () => _confirmDeleteSession(context, session),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18, color: isDark ? Colors.white38 : AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, ChatSession session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xl),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.md,
              ),
              child: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(L10n.of(context)!.deleteChatTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        content: Text(L10n.of(context)!.deleteChatMessage(session.title),
            style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs + AppSpacing.xxs),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
            ),
            child:
                Text('Cancel', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref
                  .read(chatNotifierProvider.notifier)
                  .deleteSession(session.sessionId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xs + AppSpacing.xxs),
              shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.md),
              elevation: 0,
            ),
            child: Text(L10n.of(context)!.delete),
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
        isMiroAi ? AppColors.ai : AppColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + AppSpacing.xxs),
            decoration: BoxDecoration(
              color: modeColor.withValues(alpha: 0.08),
              borderRadius: AppRadius.xl,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMiroAi ? Icons.auto_awesome : Icons.psychology,
                  size: 14,
                  color: modeColor,
                ),
                const SizedBox(width: AppSpacing.xs + AppSpacing.xxs),
                Text(
                  chatAiMode.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: modeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Auto-send a random greeting message when chat is opened for the first time
  Future<void> _sendAutoGreeting() async {
    try {
      if (!mounted) return;

      final greeting = await GreetingService.generateGreeting(
        context: context,
        ref: ref,
      );

      if (!mounted) return;

      final greetingMsg = ChatMessage()
        ..sessionId = ref.read(currentSessionIdProvider)
        ..role = MessageRole.assistant
        ..content = greeting;

      await ref.read(chatNotifierProvider.notifier).addMessage(greetingMsg);
    } catch (e) {
      // Silent fail — greeting is not critical
      debugPrint('Auto greeting failed: $e');
    }
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
        greeting = L10n.of(context)!.hiNoFoodLogged(targetCalories.toStringAsFixed(0));
      } else if (remaining > 0) {
        greeting = L10n.of(context)!.hiKcalLeft(remaining.toStringAsFixed(0));
      } else {
        greeting = L10n.of(context)!.hiOverTarget(todayCalories.toStringAsFixed(0), (-remaining).toStringAsFixed(0));
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
        ..content = L10n.of(context)!.hiReadyToLog;

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
            L10n.of(context)!.notEnoughEnergy;

      await ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
      return;
    }

    // Show loading
    final loadingMsg = ChatMessage()
      ..sessionId = ref.read(currentSessionIdProvider)
      ..role = MessageRole.assistant
      ..content = L10n.of(context)!.thinkingMealIdeas;

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
      String contextString = L10n.of(context)!.recentMeals;
      if (recentEntries.isEmpty) {
        contextString += L10n.of(context)!.noRecentFood;
      } else {
        final foodNames =
            recentEntries.map((e) => e.foodName).take(10).join(', ');
        contextString += foodNames;
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

      contextString += L10n.of(context)!.remainingCaloriesToday(remaining.toStringAsFixed(0));

      // Call AI with profile context
      final response = await GeminiChatService.getMenuSuggestions(
        recentFoodContext: contextString,
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
        ..content = L10n.of(context)!.failedToGetMenuSuggestions(e.toString());

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
    buffer.writeln(L10n.of(context)!.mealSuggestionsTitle);

    int index = 1;
    for (final suggestion in suggestions) {
      final name = suggestion['name'] as String;
      final emoji = suggestion['emoji'] as String? ?? '🍽️';
      final calories = suggestion['calories'] as num;
      final protein = suggestion['protein'] as num;
      final carbs = suggestion['carbs'] as num;
      final fat = suggestion['fat'] as num;

      buffer.writeln(L10n.of(context)!.mealSuggestionItem(index, emoji, name, calories.toStringAsFixed(0)));
      buffer.writeln(L10n.of(context)!.mealSuggestionMacros(protein.toStringAsFixed(1), carbs.toStringAsFixed(1), fat.toStringAsFixed(1)));
      if (index < suggestions.length) buffer.writeln();
      index++;
    }

    buffer.writeln(L10n.of(context)!.pickOneAndLog);
    buffer.writeln(L10n.of(context)!.energyCost(2));

    // Add message
    final message = ChatMessage()
      ..sessionId = ref.read(currentSessionIdProvider)
      ..role = MessageRole.assistant
      ..content = buffer.toString();

    await ref.read(chatNotifierProvider.notifier).addMessage(message);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🤖', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('Chat'),
          ],
        ),
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Chat history',
            onPressed: () => _showChatHistory(context),
          ),
          // New chat button
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New chat',
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).startNewSession();
            },
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearConfirmation(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showQuickActions ? 74 : 40),
          child: Column(
            children: [
              _buildAiModeIndicator(),
              if (_showQuickActions) _buildQuickActions(),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.isEmpty
                ? _buildWelcomeScreen()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      // แสดง loading indicator ตัวสุดท้าย
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
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🤖',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            const Text(
              'Hello! I\'m Miro',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tell me what you ate today!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        '💡',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Example:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildExampleMessage('🌅 Breakfast: scrambled eggs with toast'),
                  const SizedBox(height: 8),
                  _buildExampleMessage('🌞 Lunch: chicken caesar salad'),
                  const SizedBox(height: 8),
                  _buildExampleMessage('🌙 Dinner: grilled salmon with rice'),
                  const SizedBox(height: 8),
                  _buildExampleMessage('🍎 Snack: apple and peanut butter'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleMessage(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
    );
  }

  /// Quick FAQ buttons (below AI mode toggle)
  Widget _buildQuickActions() {
    final aiMode = ref.watch(chatAiModeProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
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
        icon: '🍽️',
        label: 'Menu',
        action: () => _requestMenuSuggestion(),
        energyCost: 2,
      ),
      const SizedBox(width: 8),
      _buildActionChip(
        icon: '📊',
        label: 'Weekly',
        action: () => _showWeeklySummary(),
        energyCost: 0,
      ),
      const SizedBox(width: 8),
      _buildActionChip(
        icon: '📊',
        label: 'Monthly',
        action: () => _showMonthlySummary(),
        energyCost: 0,
      ),
      const SizedBox(width: 8),
      _buildActionChip(
        icon: '💡',
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
        icon: '📊',
        label: 'Summary',
        action: () => _sendQuickMessage('How many calories today?'),
        energyCost: 0,
      ),
      const SizedBox(width: 8),
      _buildActionChip(
        icon: '❓',
        label: 'Help',
        action: () => _showLocalAiHelp(),
        energyCost: 0,
      ),
    ];
  }

  /// Build action chip button (Compact)
  Widget _buildActionChip({
    required String icon,
    required String label,
    String? hint,
    VoidCallback? action,
    required int energyCost,
  }) {
    return ActionChip(
      avatar: Text(icon, style: const TextStyle(fontSize: 14)),
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 10),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
      visualDensity: VisualDensity.compact,
      onPressed: () {
        if (hint != null) {
          // Show hint in text field
          _controller.text = hint;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: hint.length),
          );
        } else if (action != null) {
          action();
        }
      },
      backgroundColor: energyCost > 0
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
          : Theme.of(context).colorScheme.surfaceContainerHighest,
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
        final date = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
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
      buffer.writeln('📊 Weekly Summary (${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)})');
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
          
          buffer.writeln('📅 ${_getDayName(date)}: ${calories.toStringAsFixed(0)} kcal $emoji ($diffText)');
        }
      }
      
      if (daysWithData == 0) {
        buffer.writeln('No food logged this week yet.');
      } else {
        buffer.writeln();
        final average = totalCalories / daysWithData;
        final weekDiff = totalCalories - (targetCalories * daysWithData);
        
        buffer.writeln('🔥 Average: ${average.toStringAsFixed(0)} kcal/day');
        buffer.writeln('🎯 Target: ${targetCalories.toStringAsFixed(0)} kcal/day');
        
        if (weekDiff > 0) {
          buffer.writeln('📈 Result: ${weekDiff.toStringAsFixed(0)} kcal over target');
        } else {
          buffer.writeln('📈 Result: ${(-weekDiff).toStringAsFixed(0)} kcal under target — Great job! 💪');
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
      buffer.writeln('🔥 Total Consumed: ${totalCalories.toStringAsFixed(0)} kcal');
      buffer.writeln('🎯 Target Total: ${targetTotal.toStringAsFixed(0)} kcal');
      buffer.writeln('📈 Average: ${average.toStringAsFixed(0)} kcal/day');
      buffer.writeln();
      
      final diff = totalCalories - targetTotal;
      if (diff > 0) {
        buffer.writeln('⚠️ ${diff.toStringAsFixed(0)} kcal over target this month');
      } else {
        buffer.writeln('✅ ${(-diff).toStringAsFixed(0)} kcal under target — Excellent! 💪');
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
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Helper: Get day name
  String _getDayName(DateTime date) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[date.weekday - 1];
  }

  /// Helper: Get month name
  String _getMonthName(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[date.month - 1];
  }

  Widget _buildInputField() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: 2,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'พิมพ์ข้อความ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendCurrentMessage(),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _isComposing ? _sendCurrentMessage : null,
                icon: Icon(
                  Icons.send,
                  color: _isComposing ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
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
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary,
            child: Text('🤖', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
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
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.textSecondary.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('All messages will be deleted'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearMessages();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  /// แสดง Bottom Sheet ประวัติการแชท
  void _showChatHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'Chat History',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(chatNotifierProvider.notifier).startNewSession();
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Chat'),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Sessions list
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final sessionsAsync = ref.watch(chatSessionsProvider);
                    
                    return sessionsAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (e, _) => Center(
                        child: Text('Error: $e'),
                      ),
                      data: (sessions) {
                        if (sessions.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: AppColors.textTertiary.withOpacity(0.5),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'ยังไม่มีประวัติการแชท',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: sessions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
                          itemBuilder: (context, index) {
                            final session = sessions[index];
                            final currentSessionId = ref.read(currentSessionIdProvider);
                            final isActive = session.sessionId == currentSessionId;
                            
                            return _buildSessionTile(
                              context,
                              session,
                              isActive,
                            );
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

  Widget _buildSessionTile(BuildContext context, ChatSession session, bool isActive) {
    final dateFormat = DateFormat('dd MMM', 'th');
    final timeFormat = DateFormat('HH:mm');
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isActive ? AppColors.primary : AppColors.surfaceVariant,
        child: Icon(
          Icons.chat,
          color: isActive ? Colors.white : AppColors.textSecondary,
          size: 20,
        ),
      ),
      title: Text(
        session.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        '${dateFormat.format(session.updatedAt)} ${timeFormat.format(session.updatedAt)}',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textTertiary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.textTertiary,
            onPressed: () => _confirmDeleteSession(context, session),
          ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        ref.read(chatNotifierProvider.notifier).loadSession(session.sessionId!);
      },
    );
  }

  void _confirmDeleteSession(BuildContext context, ChatSession session) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete chat history?'),
        content: Text('Delete "${session.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(chatNotifierProvider.notifier).deleteSession(session.sessionId!);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// AI Mode Indicator — shows current mode (changeable in Settings)
  Widget _buildAiModeIndicator() {
    final chatAiMode = ref.watch(chatAiModeProvider);
    final isMiroAi = chatAiMode == ChatAiMode.miroAi;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Current mode badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isMiroAi
                  ? const Color(0xFF6366F1).withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMiroAi
                    ? const Color(0xFF6366F1).withOpacity(0.3)
                    : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isMiroAi ? Icons.auto_awesome : Icons.psychology,
                  size: 14,
                  color: isMiroAi ? const Color(0xFF6366F1) : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  chatAiMode.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isMiroAi ? const Color(0xFF6366F1) : Colors.green,
                  ),
                ),
                if (isMiroAi) ...[
                  const SizedBox(width: 4),
                  Text(
                    '2⚡+',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ] else ...[
                  const SizedBox(width: 4),
                  const Text(
                    'Free',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
          // Quick Actions Toggle
          IconButton(
            icon: Icon(
              _showQuickActions ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _showQuickActions = !_showQuickActions;
              });
            },
            tooltip: 'Quick Actions',
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
        greeting = '🤖 Hi! You have ${remaining.toStringAsFixed(0)} kcal left for today.\n'
            '   Ready to log your meals? 😊';
      } else {
        greeting = '🤖 Hi! You\'ve consumed ${todayCalories.toStringAsFixed(0)} kcal today.\n'
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
        ..content = '❌ Not enough Energy (minimum 2⚡ required). Please purchase more from the store.';
      
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
        final foodNames = recentEntries.map((e) => e.foodName).take(10).join(', ');
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
      
      context += '. Remaining calories today: ${remaining.toStringAsFixed(0)} kcal.';
      
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
      
      buffer.writeln('$index. $emoji $name (~${calories.toStringAsFixed(0)} kcal)');
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

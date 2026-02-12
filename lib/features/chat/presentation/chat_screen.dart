import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';
import '../models/chat_message.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isComposing = false;

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

          // Quick actions
          _buildQuickActions(),

          // Input field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🤖',
              style: TextStyle(fontSize: 64),
            ),
            SizedBox(height: 16),
            Text(
              'Hello!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'I\'m Miro, ready to help you manage your daily life\nTry typing or select a Quick Action below',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildQuickActionChip('🍔 Log Food', 'What did I eat'),
          _buildQuickActionChip('🏃 Workout', 'Show me today\'s workout program'),
          _buildQuickActionChip('💰 Expense', 'What did I pay for'),
          _buildQuickActionChip('📅 Task', 'What appointments do I have tomorrow'),
          _buildQuickActionChip('❓ What can you do', 'What can you help me with'),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String label, String message) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: () => _sendMessage(message),
      ),
    );
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
}

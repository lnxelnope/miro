import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/image_picker_service.dart';
import '../../chat/presentation/chat_screen.dart';
import '../../health/presentation/food_preview_screen.dart';
import '../../chat/providers/chat_provider.dart';
import '../../chat/widgets/message_bubble.dart';

class MagicButton extends ConsumerStatefulWidget {
  const MagicButton({super.key});

  @override
  ConsumerState<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends ConsumerState<MagicButton> {
  void _openChatOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ChatOverlaySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openChatOverlay(context),
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.auto_awesome, color: Colors.white),
    );
  }
}

class ChatOverlaySheet extends ConsumerStatefulWidget {
  const ChatOverlaySheet({super.key});

  @override
  ConsumerState<ChatOverlaySheet> createState() => _ChatOverlaySheetState();
}

class _ChatOverlaySheetState extends ConsumerState<ChatOverlaySheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isComposing = false;
  File? _selectedImage;

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

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedImage == null) return;

    if (text.isNotEmpty) {
      ref.read(chatNotifierProvider.notifier).sendMessage(text);
    }
    
    if (_selectedImage != null) {
      // Logic for sending image to AI
      Navigator.pop(context); // Close overlay first
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FoodPreviewScreen(imageFile: _selectedImage!),
        ),
      );
      return;
    }

    _controller.clear();
    setState(() {
      _selectedImage = null;
    });
    // Don't close overlay to show AI response
  }

  Future<void> _pickImage(bool fromCamera) async {
    final file = fromCamera 
        ? await ImagePickerService.pickFromCamera() 
        : await ImagePickerService.pickFromGallery();
    
    if (file != null) {
      setState(() {
        _selectedImage = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    final isLoading = ref.watch(chatLoadingProvider);
    
    // Scroll to bottom when new message arrives
    if (messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! < -10) {
            // Swipe up to open full chat
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          }
        },
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Swipe handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.textTertiary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Chat messages area
              Expanded(
                child: messages.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '🤖',
                              style: TextStyle(fontSize: 48),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Hello!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Type to start chatting',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                        itemCount: messages.length + (isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show loading indicator at the end
                          if (isLoading && index == messages.length) {
                            return _buildTypingIndicator();
                          }
                          return MessageBubble(message: messages[index]);
                        },
                      ),
              ),

              // Selected image preview
              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImage!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: AppColors.error),
                          onPressed: () => setState(() => _selectedImage = null),
                        ),
                      ),
                    ],
                  ),
                ),

              // Input field
              Container(
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
                    IconButton(
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: () => _pickImage(true),
                      color: AppColors.primary,
                    ),
                    IconButton(
                      icon: const Icon(Icons.photo_library_outlined),
                      onPressed: () => _pickImage(false),
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        maxLines: 2,
                        minLines: 1,
                        decoration: InputDecoration(
                          hintText: 'Tell Miro e.g. "log fried rice"...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.send,
                        color: (_isComposing || _selectedImage != null) 
                            ? AppColors.primary 
                            : AppColors.textSecondary,
                      ),
                      onPressed: (_isComposing || _selectedImage != null) ? _sendMessage : null,
                    ),
                  ],
                ),
              ),
              
              // Swipe hint
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Swipe up for full chat history',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../chat/presentation/chat_screen.dart';

class MagicButton extends ConsumerStatefulWidget {
  const MagicButton({super.key});

  @override
  ConsumerState<MagicButton> createState() => _MagicButtonState();
}

class _MagicButtonState extends ConsumerState<MagicButton> {
  void _openChatScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48.0,
      height: 48.0,
      child: FloatingActionButton(
        heroTag: 'chat_fab',
        onPressed: () => _openChatScreen(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
      ),
    );
  }
}

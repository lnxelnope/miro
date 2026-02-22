import 'dart:io';
import 'package:flutter/material.dart';

/// Widget ที่ wrap content และแสดง "Done" bar เหนือ keyboard บน iOS
/// เมื่อ keyboard ขึ้นมา จะมีแถบ Done ให้กดปิด keyboard ได้
///
/// ใช้งาน: ครอบ body ของ Scaffold หรือ Column หลักของ bottom sheet
///
/// ```dart
/// KeyboardDoneBar(child: myScrollView)
/// ```
class KeyboardDoneBar extends StatelessWidget {
  final Widget child;

  const KeyboardDoneBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return child;

    return Stack(
      children: [
        child,
        _DoneBarOverlay(),
      ],
    );
  }
}

class _DoneBarOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    if (bottom == 0) return const SizedBox.shrink();

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottom,
      child: _DoneBar(),
    );
  }
}

class _DoneBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      color: const Color(0xFFD1D3D9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CupertinoStyleDoneButton(
            onTap: () => FocusScope.of(context).unfocus(),
          ),
        ],
      ),
    );
  }
}

/// ปุ่ม Done สไตล์ iOS ใช้แยกได้ถ้าต้องการ
class CupertinoStyleDoneButton extends StatelessWidget {
  final VoidCallback? onTap;

  const CupertinoStyleDoneButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => FocusScope.of(context).unfocus(),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          'Done',
          style: TextStyle(
            color: Color(0xFF007AFF),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

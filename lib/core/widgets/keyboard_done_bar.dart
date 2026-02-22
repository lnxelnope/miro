import 'dart:io';
import 'package:flutter/material.dart';

/// Global iOS keyboard "Done" bar — ใส่ครั้งเดียวที่ MaterialApp.builder
/// แสดงแถบ Done ลอยเหนือ keyboard ทุกหน้า ทุก bottom sheet อัตโนมัติ
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => IOSKeyboardDoneBar(child: child!),
/// )
/// ```
class IOSKeyboardDoneBar extends StatelessWidget {
  final Widget child;

  const IOSKeyboardDoneBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!Platform.isIOS) return child;

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = bottomInset > 0;

    return Stack(
      children: [
        child,
        if (isKeyboardVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            child: const _DoneBar(),
          ),
      ],
    );
  }
}

class _DoneBar extends StatelessWidget {
  const _DoneBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0,
      color: Colors.transparent,
      child: Container(
        height: 44,
        decoration: const BoxDecoration(
          color: Color(0xFFD1D5DB),
          border: Border(
            top: BorderSide(color: Color(0xFFBBBFC4), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFF007AFF),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

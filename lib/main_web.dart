import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MiroApp()));
}

class MiroApp extends StatelessWidget {
  const MiroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miro Hybrid',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Miro Hybrid - Web Preview',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This is a UI preview only.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Note: Database and ML Kit features\nare not available on Web.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

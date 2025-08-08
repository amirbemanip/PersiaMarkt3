// lib/features/profile/presentation/view/profile_view.dart
import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پروفایل من'),
      ),
      body: const Center(
        child: Text(
          'این صفحه به زودی با امکانات جدید کامل خواهد شد.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
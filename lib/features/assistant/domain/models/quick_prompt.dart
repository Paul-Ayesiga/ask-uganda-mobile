import 'package:flutter/material.dart';

@immutable
class QuickPrompt {
  const QuickPrompt({
    required this.label,
    required this.prompt,
    required this.icon,
    required this.category,
  });

  final String label;
  final String prompt;
  final IconData icon;
  final String category;
}

abstract final class QuickPrompts {
  static const all = <QuickPrompt>[
    QuickPrompt(
      label: 'Renew my driving permit',
      prompt: 'I want to renew my driving permit. What do I need to do?',
      icon: Icons.directions_car_outlined,
      category: 'Transport',
    ),
    QuickPrompt(
      label: 'Register a small business',
      prompt: 'How do I formally register a small produce business?',
      icon: Icons.storefront_outlined,
      category: 'Business',
    ),
    QuickPrompt(
      label: 'Apply for a national ID',
      prompt: 'How do I apply for a new National ID?',
      icon: Icons.badge_outlined,
      category: 'Identity',
    ),
    QuickPrompt(
      label: 'Get a birth certificate',
      prompt: 'How do I obtain a birth certificate for my child?',
      icon: Icons.child_care_outlined,
      category: 'Civil',
    ),
    QuickPrompt(
      label: 'Check my tax compliance',
      prompt: 'Is my TIN compliant and do I owe anything?',
      icon: Icons.receipt_long_outlined,
      category: 'Revenue',
    ),
    QuickPrompt(
      label: 'Renew my passport',
      prompt: 'What do I need to renew my passport before travelling?',
      icon: Icons.flight_takeoff_outlined,
      category: 'Travel',
    ),
  ];
}

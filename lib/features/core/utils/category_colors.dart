import 'package:flutter/material.dart';

class CategoryColors {
  static Color getColorForCategory(String? category) {
    if (category == null) return const Color(0xFFD7CDE9); // Default lavender
    
    // Normalize category: trim whitespace and convert to lowercase for consistent matching
    final normalized = category.trim().toLowerCase();
    
    switch (normalized) {
      case 'work':
        return const Color(0xFFE6C0C0); // Soft coral
      case 'study':
        return const Color(0xFFB2C8BA); // Sage green
      case 'personal':
        return const Color(0xFFD7CDE9); // Lavender
      case 'health':
        return const Color(0xFFFADCD9); // Soft peach
      case 'other':
        return const Color(0xFFE8D5C4); // Beige
      default:
        return const Color(0xFFD7CDE9); // Default lavender
    }
  }
  
  static String getDisplayName(String? category) {
    if (category == null) return 'Other';
    return category;
  }
}


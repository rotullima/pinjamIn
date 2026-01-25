import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const SearchField({
    super.key,
    required this.controller,
    this.hint = 'search...',
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: 225,
          height: 35,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.background),
              filled: true,
              fillColor: AppColors.secondary,
              prefixIcon: const Icon(Icons.search, color: AppColors.background),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: AppColors.background),
          ),
        ),
      ),
    );
  }
}

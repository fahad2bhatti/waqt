import 'package:flutter/material.dart';
import 'package:waqt/app/theme/app_colors.dart';

class BrandIcon extends StatelessWidget {
  const BrandIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.hero,
        shape: BoxShape.circle,
      ),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.gold,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

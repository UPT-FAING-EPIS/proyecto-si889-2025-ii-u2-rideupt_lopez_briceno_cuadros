import 'package:flutter/material.dart';
import 'package:rideupt_app/widgets/modern_loading.dart';

class SkeletonTripList extends StatelessWidget {
  const SkeletonTripList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 5, // Show 5 skeleton cards
      itemBuilder: (context, index) => ModernSkeleton(
        width: double.infinity,
        height: 180,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}


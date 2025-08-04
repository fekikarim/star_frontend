import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:star_frontend/core/constants/app_colors.dart';
import 'package:star_frontend/core/constants/app_strings.dart';
import 'package:star_frontend/presentation/providers/global_participants_provider.dart';
import 'package:star_frontend/presentation/widgets/leaderboard/global_participants_widget.dart';

/// Leaderboard screen showing global participants rankings
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GlobalParticipantsProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.leaderboard),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
        ),
        body: const GlobalParticipantsWidget(),
      ),
    );
  }
}

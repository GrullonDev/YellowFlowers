import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';
import 'package:yellow_flowers/features/home/pages/home_layout.dart';
import 'package:yellow_flowers/features/onboarding/pages/storytelling_onboarding.dart';
import 'package:yellow_flowers/utils/base_model_scaffold.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showOnboarding = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool('seen_premium_onboarding') ?? false;
    if (mounted) {
      setState(() {
        _showOnboarding = !seen;
        _isLoading = false;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_premium_onboarding', true);
    if (mounted) {
      setState(() => _showOnboarding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (_showOnboarding) {
      return StorytellingOnboarding(onComplete: _completeOnboarding);
    }

    return BaseModelScaffold(
      model: HomeBloc(context: context),
      builder: (context, value) => const HomeLayout(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';
import 'package:yellow_flowers/features/home/pages/home_layout.dart';
import 'package:yellow_flowers/utils/base_model_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseModelScaffold(
      model: HomeBloc(),
      builder: (context, value) => const HomeLayout(),
    );
  }
}

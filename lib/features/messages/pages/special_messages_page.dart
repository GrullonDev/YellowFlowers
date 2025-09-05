import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/messages/bloc/special_messages_bloc.dart';
import 'package:yellow_flowers/features/messages/pages/special_messages_layout.dart';

class SpecialMessagesPage extends StatelessWidget {
  const SpecialMessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SpecialMessagesBloc()..init(),
      child: const SpecialMessagesLayout(),
    );
  }
}

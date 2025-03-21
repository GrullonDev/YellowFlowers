import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_screen.dart';

class NameEntryFlower extends StatelessWidget {
  const NameEntryFlower({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FlowerBloc(),
      child: Builder(
        builder: (context) {
          final model = context.watch<FlowerBloc>();

          return Scaffold(
            appBar: AppBar(
              title: const Center(
                child: Text('Ingresa tu nombre'),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      controller: model.nameController,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      child: const Text('Ingresar'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FlowerScreen(
                              recipientName: model.nameController.text,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

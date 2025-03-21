import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/Flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/features/Flowers/widgets/name_entry_flower.dart';
import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeBloc>(
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Menú Principal'),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.pink[50]!,
                Colors.white,
              ],
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: model.menuItems.length,
            itemBuilder: (context, index) {
              final item = model.menuItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(item.icon, color: Colors.pink[300]),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => item.destination,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

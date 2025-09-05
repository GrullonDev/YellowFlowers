import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/moments_gallery/bloc/moments_gallery_bloc.dart';
import 'package:yellow_flowers/features/moments_gallery/pages/moments_gallery_layout.dart';

class MomentsGalleryPage extends StatelessWidget {
  const MomentsGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MomentsGalleryBloc(),
      child: const MomentsGalleryLayout(),
    );
  }
}

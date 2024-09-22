import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class BaseModelScaffold<T extends BaseModel> extends StatefulWidget {
  const BaseModelScaffold({
    super.key,
    required this.model,
    required this.builder,
    this.forceBlocBackTap = false,
  });

  final T model;

  final Widget Function(BuildContext context, T value) builder;

  final bool forceBlocBackTap;

  @override
  State<StatefulWidget> createState() => _BaseModelScaffoldState<T>();
}

class _BaseModelScaffoldState<T extends BaseModel>
    extends State<BaseModelScaffold<T>> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        FocusScope.of(context).unfocus();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) => widget.model,
      child: Consumer<T>(
        builder: (context, model, child) {
          return Stack(
            children: <Widget>[
              PopScope(
                canPop: !(model.busy || widget.forceBlocBackTap),
                child: widget.builder(context, model),
              ),
              model.busy
                  ? Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : const SizedBox(),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stable_diffusion_example/src/models/model_info.dart';

Future<ModelInfo?> showSelectModelDialog(BuildContext context, List<ModelInfo> models) {
  return showCupertinoDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          constraints: const BoxConstraints(maxHeight: 300),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          child: ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return TextButton(
                onPressed: () {
                  Navigator.of(context).pop(models[index]);
                },
                child: Text(
                  models[index].id,
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: models.length,
          ),
        ),
      );
    },
  );
}

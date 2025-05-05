import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> customAlertDialog(
  BuildContext context, {
  String? title,
  String? description,
  String? primaryLabel,
  String? secondaryLabel,
  TextStyle? primaryLabelStyle,
  TextStyle? secondaryLabelStyle,
  GestureTapCallback? primaryButton,
  GestureTapCallback? secondaryButton,
  double? height,
}) async {
  kIsWeb || Platform.isAndroid
      ? showDialog<String>(
        context: context,
        builder:
            (BuildContext context) => Dialog(
              child: Container(
                height: height ?? 140,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(title.toString()),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 15),
                      child: Text(
                        description.toString(),
                        // style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                primaryButton ??
                                () {
                                  Navigator.pop(context);
                                },
                            child: Text('No'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed:
                                secondaryButton ??
                                () {
                                  Navigator.pop(context);
                                },
                            child: Text('Yes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      )
      : showCupertinoModalPopup<void>(
        context: context,
        barrierDismissible: false,
        builder:
            (BuildContext context) => Theme(
              data: ThemeData.light(),
              child: CupertinoAlertDialog(
                insetAnimationCurve: Curves.bounceIn,
                title: Text(
                  title.toString(),
                  // style: Theme.of(context).textTheme.titleLarge,
                ),
                content: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    description.toString(),
                    // style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                actions: <CupertinoDialogAction>[
                  CupertinoDialogAction(
                    isDefaultAction: true,
                    onPressed:
                        primaryButton ??
                        () {
                          Navigator.pop(context);
                        },
                    child: Text(
                      primaryLabel ?? 'No',
                      // style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    onPressed:
                        secondaryButton ??
                        () {
                          Navigator.pop(context);
                        },
                    child: Text(
                      secondaryLabel ?? 'Yes',
                      // style: Theme.of(context).textTheme.displayMedium!
                      //     .copyWith(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),
      );
}

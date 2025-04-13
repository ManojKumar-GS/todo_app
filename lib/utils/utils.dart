import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Utils {
  Color getRandomNonBlackColor() {
    final Random random = Random();

    int min = 50;
    int max = 200;

    return Color.fromARGB(
      255,
      min + random.nextInt(max - min),
      min + random.nextInt(max - min),
      min + random.nextInt(max - min),
    );
  }

  getActionButton({void Function()? onTap, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: CircleAvatar(
        backgroundColor: CupertinoColors.white,
        child: IconButton(
          onPressed: onTap,
          icon: Icon(icon),
        ),
      ),
    );
  }
}

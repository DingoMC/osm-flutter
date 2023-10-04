import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

enum CRoot { red, green, aqua, blue, gray }

extension ColorExtension on CRoot {
  String get name => describeEnum(this);
  Color color({double brightness = 0.5, double opacity = 1.0}) {
    switch (this) {
      case CRoot.red:
        return Color.fromRGBO(
            min(-510 * brightness * brightness + 765 * brightness, 255).toInt(),
            max(350 * brightness * brightness - 95 * brightness, 0).toInt(),
            max(350 * brightness * brightness - 95 * brightness, 0).toInt(),
            opacity);
      case CRoot.green:
        return Color.fromRGBO(
            max(350 * brightness * brightness - 95 * brightness, 0).toInt(),
            min(-510 * brightness * brightness + 765 * brightness, 255).toInt(),
            max(350 * brightness * brightness - 95 * brightness, 0).toInt(),
            opacity);
      case CRoot.aqua:
        return Color.fromRGBO(
            max(350 * brightness * brightness - 95 * brightness, 0).toInt(),
            min(-510 * brightness * brightness + 765 * brightness, 255).toInt(),
            min(-510 * brightness * brightness + 765 * brightness, 255).toInt(),
            opacity);
      case CRoot.blue:
        return Color.fromRGBO(
            max(350 * brightness * brightness - 95 * brightness, 0).toInt(),
            (-170 * brightness * brightness + 425 * brightness).toInt(),
            min(-510 * brightness * brightness + 765 * brightness, 255).toInt(),
            opacity);
      case CRoot.gray:
        return Color.fromRGBO((brightness * 255).toInt(),
            (brightness * 255).toInt(), (brightness * 255).toInt(), opacity);
      default:
        return const Color.fromRGBO(0, 0, 0, 1);
    }
  }
}

import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppShadows {
  static const List<BoxShadow> surface = <BoxShadow>[
    BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
  ];
}

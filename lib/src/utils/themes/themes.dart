import 'package:flutter/material.dart';

import '../colors/colors.dart';

TextStyle? gameTextStyle(
        {Color color = Colors.black, double height = 1, double? fontSize}) =>
    TextStyle(
        fontFamily: 'Permanent Marker', height: height, fontSize: fontSize);
ThemeData mainTheme = ThemeData(scaffoldBackgroundColor: backgroundMain);

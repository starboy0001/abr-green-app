import 'package:flutter/material.dart';

import 'colors.dart';

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

const appThemeTextWhiteC = TextStyle(
  color: whiteC,
  fontSize: 19,
);
const appThemeTextBlackCSmall = TextStyle(
  fontWeight: FontWeight.w500,
  color: blackC,
  fontSize: 15,
);
const appThemeTextBlackC = TextStyle(
  color: blackC,
  fontSize: 19,
);
const orangeText = TextStyle(
  color: orangeC,
  fontSize: 19,
);
const extraSmallBlack = TextStyle(
  color: blackC,
  fontSize: 13,
);
const smalTxtBoldBlack = TextStyle(
  fontWeight: FontWeight.w500,
  color: blackC,
  fontSize: 15,
);
const smalTxtBoldLightBlack = TextStyle(
  fontWeight: FontWeight.w300,
  color: Colors.black54,
  fontSize: 12,
);
const historySmalltextBlue = TextStyle(
    color: apptextColorBlue, fontSize: 14, fontWeight: FontWeight.w500);

const historySmalltextwhite =
    TextStyle(color: whiteC, fontSize: 14, fontWeight: FontWeight.w500);

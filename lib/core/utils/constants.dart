import 'package:flutter/material.dart';

import 'package:spendwise/utils/colors.dart';

class SpConstants {
  static TextStyle numStyle(bool isExpense) => TextStyle(
    fontFamily: 'Noto',
    color: isExpense ? SpColor.expenseRed : SpColor.incomeGreen,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );
}

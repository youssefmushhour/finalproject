import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/expense_model.dart';
import '../../../../core/theme/app_colors.dart';

class ExpensePieChart extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const ExpensePieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    Map<String, double> categoryTotals = {};
    for (var e in expenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }

    List<PieChartSectionData> sections = [];
    int index = 0;
    List<Color> colors = [
      AppColors.emeraldGreen,
      AppColors.deepBlue,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.redAccent,
    ];

    categoryTotals.forEach((category, total) {
      sections.add(
        PieChartSectionData(
          color: colors[index % colors.length],
          value: total,
          title: category,
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      );
      index++;
    });

    if (sections.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 180,
      child: PieChart(
        PieChartData(
          sections: sections,
          centerSpaceRadius: 50,
          sectionsSpace: 4,
        ),
      ),
    );
  }
}
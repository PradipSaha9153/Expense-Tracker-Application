import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'input_model.dart';

class ChartPie extends StatelessWidget {
  final List<InputModel> transactionsSorted;
  final double totalAmount;
  final String type;
  final bool showPercentage;

  const ChartPie(
    this.transactionsSorted, {
    this.totalAmount = 0,
    this.type = 'Expense',
    this.showPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    bool haveRecords = transactionsSorted.isNotEmpty && transactionsSorted[0].category != '';
    double animationDuration = haveRecords ? 300 : 0;

    return SfCircularChart(
      tooltipBehavior: TooltipBehavior(enable: haveRecords),
      annotations: <CircularChartAnnotation>[
        CircularChartAnnotation(
          width: '55%',
          height: '55%',
          widget: ChartCenterAnnotation(
            haveRecords: haveRecords,
            totalAmount: totalAmount,
            type: type,
          ),
        ),
      ],
      series: <CircularSeries<InputModel, String>>[
        DoughnutSeries<InputModel, String>(
          startAngle: 90,
          endAngle: 90,
          animationDuration: animationDuration,
          sortingOrder: SortingOrder.descending,
          sortFieldValueMapper: (InputModel data, _) => data.category,
          enableTooltip: haveRecords,
          dataSource: transactionsSorted,
          pointColorMapper: (InputModel data, _) => data.color,
          xValueMapper: (InputModel data, _) =>
              getTranslated(context, data.category!) ?? data.category,
          yValueMapper: (InputModel data, _) => data.amount ?? 0,
          dataLabelMapper: (InputModel data, _) {
            if (!haveRecords) return '';
            double amt = data.amount ?? 0;
            if (showPercentage && totalAmount > 0) {
              double pct = (amt / totalAmount) * 100;
              return '${pct.toStringAsFixed(1)}%';
            } else {
              return '${format(amt)} $currency';
            }
          },
          dataLabelSettings: DataLabelSettings(
            showZeroValue: false,
            useSeriesColor: true,
            labelPosition: ChartDataLabelPosition.outside,
            connectorLineSettings: ConnectorLineSettings(
              type: ConnectorType.curve,
              length: '15%',
            ),
            isVisible: haveRecords,
            textStyle: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          innerRadius: '60%',
          radius: '75%',
        ),
      ],
    );
  }
}

class ChartCenterAnnotation extends StatelessWidget {
  final bool haveRecords;
  final double totalAmount;
  final String type;

  const ChartCenterAnnotation({
    required this.haveRecords,
    required this.totalAmount,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (!haveRecords) {
      return Center(
        child: Text(
          getTranslated(context, 'There is no data') ?? 'There is no data',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.grey[500],
            fontSize: 13.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Total',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                '${format(totalAmount)} $currency',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            type == 'Income' ? 'Income' : 'Expenses',
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

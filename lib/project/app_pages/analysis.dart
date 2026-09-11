import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_assistant_2608/project/classes/category_item.dart';
import 'package:money_assistant_2608/project/classes/chart_pie.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/classes/input_model.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/database_management/sqflite_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:provider/provider.dart';
import '../provider.dart';
import 'report.dart';

final List<InputModel> chartDataNull = [
  InputModel(
      id: null,
      type: null,
      amount: 1,
      category: '',
      description: null,
      date: null,
      time: null,
      color: const Color.fromRGBO(0, 220, 252, 1))
];

class Analysis extends StatefulWidget {
  @override
  _AnalysisState createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  String currentType = 'Expense';
  bool isAmountMode = true; // true = Amount, false = Percentage

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ChangeSelectedDate>(
      create: (context) => ChangeSelectedDate(),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/analysis_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: Selector<ChangeSelectedDate, String?>(
              selector: (_, changeSelectedDate) =>
                  changeSelectedDate.selectedAnalysisDate,
              builder: (context, selectedAnalysisDate, child) {
                selectedAnalysisDate ??= sharedPrefs.selectedDate;

                return Column(
                  children: [
                    // Top Segmented Toggle Switch (EXPENSE / INCOME)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: Container(
                        height: 56.h,
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: Color(0xFFE2F4EE),
                          borderRadius: BorderRadius.circular(35.r),
                        ),
                        child: Row(
                          children: [
                            // Expense Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentType = 'Expense';
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 250),
                                  decoration: BoxDecoration(
                                    gradient: currentType == 'Expense'
                                        ? LinearGradient(
                                            colors: [Color(0xFF00897B), Color(0xFF00564C)],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(36.r),
                                    border: currentType == 'Expense'
                                        ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5.w)
                                        : null,
                                    boxShadow: currentType == 'Expense'
                                        ? [
                                            BoxShadow(
                                              color: Color(0xFF004D40).withOpacity(0.35),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32.r,
                                        height: 32.r,
                                        decoration: BoxDecoration(
                                          color: currentType == 'Expense'
                                              ? Colors.white
                                              : Color(0xFF80CBC4).withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.south_west_rounded,
                                          color: Color(0xFFFF5252),
                                          size: 16.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'EXPENSE',
                                        style: GoogleFonts.poppins(
                                          color: currentType == 'Expense'
                                              ? Colors.white
                                              : Color(0xFF004D40),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Income Tab
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    currentType = 'Income';
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 250),
                                  decoration: BoxDecoration(
                                    gradient: currentType == 'Income'
                                        ? LinearGradient(
                                            colors: [Color(0xFF00897B), Color(0xFF00564C)],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(36.r),
                                    border: currentType == 'Income'
                                        ? Border.all(color: Colors.white.withOpacity(0.5), width: 1.5.w)
                                        : null,
                                    boxShadow: currentType == 'Income'
                                        ? [
                                            BoxShadow(
                                              color: Color(0xFF004D40).withOpacity(0.35),
                                              blurRadius: 10,
                                              offset: Offset(0, 4),
                                            )
                                          ]
                                        : [],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32.r,
                                        height: 32.r,
                                        decoration: BoxDecoration(
                                          color: currentType == 'Income'
                                              ? Colors.white
                                              : Color(0xFF80CBC4).withOpacity(0.4),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.north_east_rounded,
                                          color: Color(0xFF4CAF50),
                                          size: 16.sp,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        'INCOME',
                                        style: GoogleFonts.poppins(
                                          color: currentType == 'Income'
                                              ? Colors.white
                                              : Color(0xFF004D40),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.sp,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Scrollable Main Analysis Dashboard Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                        child: Column(
                          children: [
                            // Date Filter Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DateFilterDropdown(
                                  selectedDate: selectedAnalysisDate!,
                                  onDateChanged: (newDate) {
                                    context
                                        .read<ChangeSelectedDate>()
                                        .changeSelectedAnalysisDate(
                                            newSelectedDate: newDate);
                                    sharedPrefs.selectedDate = newDate;
                                  },
                                ),
                                DateFilterDropdown(
                                  selectedDate: 'All',
                                  onDateChanged: (_) {},
                                ),
                              ],
                            ),
                            SizedBox(height: 14.h),

                            // Main Dashboard Content FutureBuilder
                            ShowDashboardDetails(
                              type: currentType,
                              selectedDate: selectedAnalysisDate,
                              isAmountMode: isAmountMode,
                              onModeToggle: (isAmount) {
                                setState(() {
                                  isAmountMode = isAmount;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DateFilterDropdown extends StatelessWidget {
  final String selectedDate;
  final ValueChanged<String> onDateChanged;

  const DateFilterDropdown({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: Color(0xFFE2F4EE),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: timeline.contains(selectedDate) ? selectedDate : 'All',
          icon: Padding(
            padding: EdgeInsets.only(left: 6.w),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 20.sp,
              color: Color(0xFF00695C),
            ),
          ),
          style: GoogleFonts.poppins(
            color: Color(0xFF004D40),
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          dropdownColor: Colors.white,
          onChanged: (value) {
            if (value != null) {
              onDateChanged(value);
            }
          },
          items: timeline.map((time) {
            return DropdownMenuItem<String>(
              value: time,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16.sp,
                    color: Color(0xFF00695C),
                  ),
                  SizedBox(width: 8.w),
                  Text(getTranslated(context, time) ?? time),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String type;
  final double typeValue;
  final double balance;

  const SummaryCard({
    required this.type,
    required this.typeValue,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Type Section (Expense / Income)
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0F2F1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      type == 'Income'
                          ? Icons.account_balance_wallet_rounded
                          : Icons.account_balance_wallet_rounded,
                      size: 22.sp,
                      color: Color(0xFF00695C),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type == 'Income' ? 'Income' : 'Expense',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${format(typeValue)} $currency',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Vertical Divider Line
          Container(
            height: 38.h,
            width: 1.w,
            color: Color(0xFFEEEEEE),
          ),
          SizedBox(width: 14.w),

          // Balance Section
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.savings_rounded,
                      size: 22.sp,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Balance',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${format(balance)} $currency',
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ShowDashboardDetails extends StatelessWidget {
  final String type;
  final String selectedDate;
  final bool isAmountMode;
  final ValueChanged<bool> onModeToggle;

  const ShowDashboardDetails({
    required this.type,
    required this.selectedDate,
    required this.isAmountMode,
    required this.onModeToggle,
  });

  @override
  Widget build(BuildContext context) {
    late Map<String, double> chartDataMap;

    return FutureBuilder<List<InputModel>>(
      initialData: [],
      future: DB.inputModelList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        double calcIncome = 0.0;
        double calcExpense = 0.0;
        double calcBalance = 0.0;
        List<InputModel> allTransactions = [];

        if (snapshot.hasData && snapshot.data != null) {
          allTransactions = filterData(context, snapshot.data!, selectedDate);

          if (allTransactions.isNotEmpty) {
            for (var tx in allTransactions) {
              final amt = tx.amount;
              if (amt != null) {
                if (tx.type == 'Income') {
                  calcIncome += amt;
                } else if (tx.type == 'Expense') {
                  calcExpense += amt;
                }
              }
            }
            calcBalance = calcIncome - calcExpense;

            allTransactions = allTransactions
                .where((d) => d.type == type)
                .toList();
          }
        }

        double totalTypeAmount = type == 'Income' ? calcIncome : calcExpense;

        if (allTransactions.isEmpty) {
          return Column(
            children: [
              SummaryCard(type: type, typeValue: 0.0, balance: calcBalance),
              SizedBox(height: 16.h),
              _buildBreakdownHeader(),
              SizedBox(
                height: 280.h,
                child: ChartPie(
                  chartDataNull,
                  totalAmount: 0.0,
                  type: type,
                  showPercentage: !isAmountMode,
                ),
              ),
              _buildCategoryHeader(context),
              SizedBox(height: 8.h),
              CategoryWiseCard(
                type: type,
                category: getTranslated(context, 'Category') ?? 'Category',
                amount: 0.0,
                totalAmount: 0.0,
                color: type == 'Income' ? green : red,
                icon: Icons.category_outlined,
                forNullDetail: true,
                onTap: () {},
              ),
              SizedBox(height: 30.h),
            ],
          );
        }

        List<InputModel> transactionsSorted = [
          InputModel(
            type: type,
            amount: allTransactions[0].amount,
            category: allTransactions[0].category,
          )
        ];

        int i = 1;
        while (i < allTransactions.length) {
          allTransactions.sort((a, b) => a.category!.compareTo(b.category!));

          double currAmt = allTransactions[i].amount ?? 0;
          double prevAmt = allTransactions[i - 1].amount ?? 0;

          if (i == 1) {
            chartDataMap = {
              allTransactions[0].category!: allTransactions[0].amount ?? 0
            };
          }

          if (allTransactions[i].category == allTransactions[i - 1].category) {
            chartDataMap.update(
              allTransactions[i].category!,
              (value) => value + currAmt,
              ifAbsent: () => prevAmt + currAmt,
            );
            i++;
          } else {
            chartDataMap.addAll({
              allTransactions[i].category!: currAmt
            });
            i++;
          }

          transactionsSorted = chartDataMap.entries
              .map((entry) => InputModel(
                    type: type,
                    category: entry.key,
                    amount: entry.value,
                  ))
              .toList();
        }

        void recurringFunc({required int i, n}) {
          if (n > i) {
            for (int c = 1; c <= n - i; c++) {
              transactionsSorted[i + c - 1].color = chartPieColors[c - 1];
              recurringFunc(i: i, n: c);
            }
          }
        }

        for (int n = 1; n <= transactionsSorted.length; n++) {
          transactionsSorted[n - 1].color = chartPieColors[n - 1];
          recurringFunc(i: chartPieColors.length, n: n);
        }

        // Generate category list items
        List<CategoryItem> itemList = createItemList(
          transactions: transactionsSorted,
          forAnalysisPage: true,
          isIncomeType: type == 'Income',
          forSelectIconPage: false,
        );

        return Column(
          children: [
            SummaryCard(
              type: type,
              typeValue: totalTypeAmount,
              balance: calcBalance,
            ),
            SizedBox(height: 18.h),

            // Expense / Income Breakdown Header & Switch
            _buildBreakdownHeader(),
            SizedBox(height: 10.h),

            // Center Donut Chart
            SizedBox(
              height: 280.h,
              child: ChartPie(
                transactionsSorted,
                totalAmount: totalTypeAmount,
                type: type,
                showPercentage: !isAmountMode,
              ),
            ),
            SizedBox(height: 10.h),

            // Category Wise Header
            _buildCategoryHeader(context),
            SizedBox(height: 10.h),

            // Category List Cards
            ...List.generate(itemList.length, (idx) {
              var item = itemList[idx];
              double catAmount = transactionsSorted[idx].amount ?? 0.0;
              Color catColor = transactionsSorted[idx].color ?? Color(0xFF00695C);

              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: CategoryWiseCard(
                  type: type,
                  category: getTranslated(context, item.text) ?? item.text,
                  amount: catAmount,
                  totalAmount: totalTypeAmount,
                  color: catColor,
                  icon: iconData(item),
                  forNullDetail: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Report(
                          type: type,
                          category: item.text,
                          selectedDate: selectedDate,
                          icon: iconData(item),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
            SizedBox(height: 30.h),
          ],
        );
      },
    );
  }

  Widget _buildBreakdownHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          type == 'Income' ? 'Income Breakdown' : 'Expense Breakdown',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // Amount / Percentage Toggle Pill
        Container(
          height: 36.h,
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onModeToggle(true),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isAmountMode ? Color(0xFF00695C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Amount',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: isAmountMode ? FontWeight.bold : FontWeight.w500,
                      color: isAmountMode ? Colors.white : Color(0xFF004D40),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onModeToggle(false),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: !isAmountMode ? Color(0xFF00695C) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    'Percentage',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: !isAmountMode ? FontWeight.bold : FontWeight.w500,
                      color: !isAmountMode ? Colors.white : Color(0xFF004D40),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Category Wise',
          style: GoogleFonts.poppins(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            children: [
              Text(
                'See All',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00695C),
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.chevron_right_rounded,
                size: 18.sp,
                color: Color(0xFF00695C),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CategoryWiseCard extends StatelessWidget {
  final String type;
  final String category;
  final double amount;
  final double totalAmount;
  final Color color;
  final IconData icon;
  final bool forNullDetail;
  final VoidCallback onTap;

  const CategoryWiseCard({
    required this.type,
    required this.category,
    required this.amount,
    required this.totalAmount,
    required this.color,
    required this.icon,
    required this.forNullDetail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double percentage = totalAmount > 0 ? (amount / totalAmount) * 100 : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // Category Icon Badge
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: color,
                      size: 22.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),

                // Category Name
                Expanded(
                  child: Text(
                    category,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Amount
                Text(
                  '${format(amount)} $currency',
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: type == 'Income' ? Color(0xFF4CAF50) : Color(0xFFFF5252),
                  ),
                ),
                SizedBox(width: 10.w),

                // Percentage Badge
                if (!forNullDetail)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${percentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),

                if (!forNullDetail) SizedBox(width: 6.w),

                // Chevron Right
                if (!forNullDetail)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

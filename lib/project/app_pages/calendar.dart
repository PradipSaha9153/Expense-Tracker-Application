import 'dart:collection';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_swipe_action_cell/core/cell.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:money_assistant_2608/project/classes/alert_dialog.dart';
import 'package:money_assistant_2608/project/classes/category_item.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/classes/custom_toast.dart';
import 'package:money_assistant_2608/project/classes/input_model.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/database_management/sqflite_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:table_calendar/table_calendar.dart';

import 'edit.dart';

class Calendar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CalendarBody();
  }
}

class CalendarBody extends StatefulWidget {
  @override
  _CalendarBodyState createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<CalendarBody> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay, _rangeStart, _rangeEnd;
  late Map<DateTime, List<InputModel>> transactions = {};
  late ValueNotifier<List<InputModel>> _selectedEvents;
  String selectedCategoryFilter = 'All Categories';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<String> _getCategoryFilterList(List<InputModel> allData) {
    Set<String> categories = {'All Categories'};
    for (var tx in allData) {
      if (tx.category != null && tx.category!.isNotEmpty) {
        categories.add(tx.category!);
      }
    }
    return categories.toList();
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  List<DateTime> daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/analysis_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<List<InputModel>>(
            initialData: [],
            future: DB.inputModelList(),
            builder: (context, snapshot) {
              connectionUI(snapshot);
              Map<String, List<InputModel>> map = {};
              if (snapshot.data != null) {
                for (int i = 0; i < snapshot.data!.length; i++) {
                  String description = snapshot.data![i].description!;
                  InputModel map1 = InputModel(
                      id: snapshot.data![i].id,
                      type: snapshot.data![i].type,
                      amount: snapshot.data![i].amount,
                      category: snapshot.data![i].category,
                      description: description,
                      date: snapshot.data![i].date,
                      time: snapshot.data![i].time);

                  void updateMapValue<K, V>(
                          Map<K, List<V>> map, K key, V value) =>
                      map.update(key, (list) => list..add(value),
                          ifAbsent: () => [value]);

                  updateMapValue(
                    map,
                    '${snapshot.data![i].date}',
                    map1,
                  );
                }
                transactions = map.map((key, value) =>
                    MapEntry(DateFormat('dd/MM/yyyy').parse(key), value));
              }

              late LinkedHashMap linkedHashedMapTransactions =
                  LinkedHashMap<DateTime, List<InputModel>>(
                equals: isSameDay,
                hashCode: getHashCode,
              )..addAll(transactions);

              List<InputModel> transactionsForDay(DateTime? day) =>
                  linkedHashedMapTransactions[day] ?? [];

              if (_selectedDay != null) {
                _selectedEvents = ValueNotifier(transactionsForDay(_selectedDay));
              }

              List<InputModel> _getEventsForRange(DateTime start, DateTime end) {
                final days = daysInRange(start, end);
                return [
                  for (final d in days) ...transactionsForDay(d),
                ];
              }

              void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _rangeStart = null;
                    _rangeEnd = null;
                    _rangeSelectionMode = RangeSelectionMode.toggledOff;
                  });
                  _selectedEvents.value = transactionsForDay(selectedDay);
                }
              }

              void _onRangeSelected(
                  DateTime? start, DateTime? end, DateTime focusedDay) {
                setState(() {
                  _selectedDay = null;
                  _focusedDay = focusedDay;
                  _rangeStart = start;
                  _rangeEnd = end;
                  _rangeSelectionMode = RangeSelectionMode.toggledOn;
                  if (start != null && end != null) {
                    _selectedEvents = ValueNotifier(_getEventsForRange(start, end));
                  } else if (start != null) {
                    _selectedEvents = ValueNotifier(transactionsForDay(start));
                  } else if (end != null) {
                    _selectedEvents = ValueNotifier(transactionsForDay(end));
                  }
                });
              }

              return Column(
                children: [
                  // Top Header Banner
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, 'Calendar') ?? 'Calendar',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF00574A),
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Track your spending day by day',
                              style: GoogleFonts.poppins(
                                color: Color(0xFF00574A).withOpacity(0.85),
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.asset(
                            'images/app_icon.png',
                            height: 42.r,
                            width: 42.r,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Main Scrollable Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                      child: Column(
                        children: [
                          // Calendar Card Container
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 15,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Custom Month/Year Navigation Header & Arrows
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            _focusedDay.month - 1,
                                            _focusedDay.day,
                                          );
                                        });
                                      },
                                      child: Container(
                                        width: 38.r,
                                        height: 38.r,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE2F4EE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.chevron_left_rounded,
                                            color: Color(0xFF00695C),
                                            size: 22.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: _focusedDay,
                                          firstDate: DateTime(2000, 1, 1),
                                          lastDate: DateTime(2050, 12, 31),
                                          initialDatePickerMode: DatePickerMode.year,
                                          confirmText: getTranslated(context, 'OK') ?? 'OK',
                                          cancelText: getTranslated(context, 'CANCEL'),
                                          helpText: getTranslated(context, 'Select Month & Year') ?? 'Select Month & Year',
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                  primary: Color(0xFF00695C),
                                                  onPrimary: Colors.white,
                                                  onSurface: Colors.black,
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          },
                                        ).then((selected) {
                                          if (selected != null) {
                                            setState(() {
                                              _focusedDay = selected;
                                              _selectedDay = selected;
                                            });
                                          }
                                        });
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            DateFormat('MMMM yyyy').format(_focusedDay),
                                            style: GoogleFonts.poppins(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF004D40),
                                            ),
                                          ),
                                          SizedBox(width: 4.w),
                                          Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: Color(0xFF00695C),
                                            size: 20.sp,
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _focusedDay = DateTime(
                                            _focusedDay.year,
                                            _focusedDay.month + 1,
                                            _focusedDay.day,
                                          );
                                        });
                                      },
                                      child: Container(
                                        width: 38.r,
                                        height: 38.r,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE2F4EE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.chevron_right_rounded,
                                            color: Color(0xFF00695C),
                                            size: 22.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 14.h),

                                // Timeframe Scope Segmented Toggle (2 weeks | Month | 3 months)
                                Container(
                                  height: 44.h,
                                  padding: EdgeInsets.all(3.r),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE2F4EE),
                                    borderRadius: BorderRadius.circular(25.r),
                                  ),
                                  child: Row(
                                    children: [
                                      // 2 weeks
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _calendarFormat = CalendarFormat.twoWeeks;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: _calendarFormat == CalendarFormat.twoWeeks
                                                  ? LinearGradient(
                                                      colors: [Color(0xFF00897B), Color(0xFF00564C)],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    )
                                                  : null,
                                              borderRadius: BorderRadius.circular(22.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '2 weeks',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  fontWeight: _calendarFormat == CalendarFormat.twoWeeks
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: _calendarFormat == CalendarFormat.twoWeeks
                                                      ? Colors.white
                                                      : Color(0xFF004D40),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // Month
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _calendarFormat = CalendarFormat.month;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: _calendarFormat == CalendarFormat.month
                                                  ? LinearGradient(
                                                      colors: [Color(0xFF00897B), Color(0xFF00564C)],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    )
                                                  : null,
                                              borderRadius: BorderRadius.circular(22.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                'Month',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  fontWeight: _calendarFormat == CalendarFormat.month
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: _calendarFormat == CalendarFormat.month
                                                      ? Colors.white
                                                      : Color(0xFF004D40),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 3 months / Week
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _calendarFormat = CalendarFormat.week;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: _calendarFormat == CalendarFormat.week
                                                  ? LinearGradient(
                                                      colors: [Color(0xFF00897B), Color(0xFF00564C)],
                                                      begin: Alignment.topCenter,
                                                      end: Alignment.bottomCenter,
                                                    )
                                                  : null,
                                              borderRadius: BorderRadius.circular(22.r),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '3 months',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12.sp,
                                                  fontWeight: _calendarFormat == CalendarFormat.week
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: _calendarFormat == CalendarFormat.week
                                                      ? Colors.white
                                                      : Color(0xFF004D40),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12.h),

                                // TableCalendar Widget
                                TableCalendar<InputModel>(
                                  headerVisible: false,
                                  rowHeight: 48.h,
                                  daysOfWeekHeight: 24.h,
                                  firstDay: DateTime.utc(2000, 01, 01),
                                  lastDay: DateTime.utc(2050, 01, 01),
                                  focusedDay: _focusedDay,
                                  calendarFormat: _calendarFormat,
                                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                                  rangeStartDay: _rangeStart,
                                  rangeEndDay: _rangeEnd,
                                  rangeSelectionMode: _rangeSelectionMode,
                                  eventLoader: transactionsForDay,
                                  startingDayOfWeek: StartingDayOfWeek.monday,
                                  calendarStyle: CalendarStyle(
                                    outsideDaysVisible: true,
                                    outsideTextStyle: GoogleFonts.poppins(
                                      color: Colors.grey[300],
                                      fontSize: 13.sp,
                                    ),
                                    defaultTextStyle: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    weekendTextStyle: GoogleFonts.poppins(
                                      color: Colors.black87,
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  calendarBuilders: CalendarBuilders(
                                    dowBuilder: (context, day) {
                                      final text = DateFormat.E().format(day);
                                      return Center(
                                        child: Text(
                                          text,
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[500],
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      );
                                    },
                                    selectedBuilder: (context, date, _) {
                                      return Container(
                                        margin: EdgeInsets.all(4.r),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Color(0xFF00897B), Color(0xFF00564C)],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          borderRadius: BorderRadius.circular(12.r),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Color(0xFF004D40).withOpacity(0.3),
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${date.day}',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    todayBuilder: (context, date, _) {
                                      return Container(
                                        margin: EdgeInsets.all(4.r),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE0F2F1),
                                          borderRadius: BorderRadius.circular(12.r),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${date.day}',
                                            style: GoogleFonts.poppins(
                                              color: Color(0xFF00695C),
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    markerBuilder: (context, date, events) {
                                      if (events.isNotEmpty) {
                                        return Positioned(
                                          bottom: 3.h,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: events.take(3).map((e) {
                                              bool isIncome = (e as InputModel).type == 'Income';
                                              return Container(
                                                margin: EdgeInsets.symmetric(horizontal: 1.5.w),
                                                width: 5.r,
                                                height: 5.r,
                                                decoration: BoxDecoration(
                                                  color: isIncome ? Color(0xFF4CAF50) : Color(0xFF2196F3),
                                                  shape: BoxShape.circle,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        );
                                      }
                                      return null;
                                    },
                                  ),
                                  onDaySelected: _onDaySelected,
                                  onRangeSelected: _onRangeSelected,
                                  onFormatChanged: (format) {
                                    if (_calendarFormat != format) {
                                      setState(() {
                                        _calendarFormat = format;
                                      });
                                    }
                                  },
                                  onPageChanged: (focusedDay) {
                                    _focusedDay = focusedDay;
                                  },
                                  pageJumpingEnabled: true,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Daily Summary Card (Income, Expense, Balance)
                          ValueListenableBuilder<List<InputModel>>(
                            valueListenable: _selectedEvents,
                            builder: (context, events, _) {
                              return DailySummaryCard(
                                selectedDay: _selectedDay ?? _focusedDay,
                                dayEvents: events,
                              );
                            },
                          ),
                          SizedBox(height: 18.h),

                          // Transactions Section Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Transactions',
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _getCategoryFilterList(snapshot.data ?? []).contains(selectedCategoryFilter)
                                      ? selectedCategoryFilter
                                      : 'All Categories',
                                  icon: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18.sp,
                                    color: Color(0xFF00695C),
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00695C),
                                  ),
                                  dropdownColor: Colors.white,
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        selectedCategoryFilter = newValue;
                                      });
                                    }
                                  },
                                  items: _getCategoryFilterList(snapshot.data ?? [])
                                      .map<DropdownMenuItem<String>>((String catName) {
                                    return DropdownMenuItem<String>(
                                      value: catName,
                                      child: Text(
                                        getTranslated(context, catName) ?? catName,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // Transactions List Cards
                          ValueListenableBuilder<List<InputModel>>(
                            valueListenable: _selectedEvents,
                            builder: (context, events, _) {
                              List<InputModel> filteredEvents = selectedCategoryFilter == 'All Categories'
                                  ? events
                                  : events.where((e) => e.category == selectedCategoryFilter).toList();

                              if (filteredEvents.isEmpty) {
                                return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(vertical: 30.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      getTranslated(context, 'There is no data') ?? 'No transactions for this day',
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[500],
                                        fontSize: 13.sp,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              List<CategoryItem> itemList = createItemList(
                                transactions: filteredEvents,
                                forAnalysisPage: false,
                                forSelectIconPage: false,
                                isIncomeType: false,
                              );

                              return Column(
                                children: List.generate(itemList.length, (idx) {
                                  var tx = filteredEvents[idx];
                                  var catItem = itemList[idx];

                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    child: CalendarTransactionCard(
                                      transaction: tx,
                                      categoryItem: catItem,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => Edit(
                                              inputModel: tx,
                                              categoryIcon: iconData(catItem),
                                            ),
                                          ),
                                        ).then((_) => setState(() {}));
                                      },
                                      onDelete: () async {
                                        if (tx.id != null) {
                                          await DB.delete(tx.id!);
                                          setState(() {});
                                          customToast(context, 'Transaction has been deleted');
                                        }
                                      },
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                          SizedBox(height: 30.h),
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
    );
  }
}

class DailySummaryCard extends StatelessWidget {
  final DateTime selectedDay;
  final List<InputModel> dayEvents;

  const DailySummaryCard({
    required this.selectedDay,
    required this.dayEvents,
  });

  @override
  Widget build(BuildContext context) {
    double income = 0.0, expense = 0.0, balance = 0.0;
    for (var event in dayEvents) {
      double amt = event.amount ?? 0.0;
      if (event.type == 'Income') {
        income += amt;
      } else {
        expense += amt;
      }
    }
    balance = income - expense;

    String dateStr = DateFormat('d MMMM yyyy').format(selectedDay);
    int count = dayEvents.length;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$count ${count == 1 ? "Transaction" : "Transactions"}',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00695C),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Three Summary Columns (Income, Expense, Balance)
          Row(
            children: [
              // Income
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5E9),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_upward_rounded,
                          size: 18.sp,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Income', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey[600])),
                          FittedBox(
                            child: Text(
                              '${format(income)} $currency',
                              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Expense
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_downward_rounded,
                          size: 18.sp,
                          color: Color(0xFFFF5252),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expense', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey[600])),
                          FittedBox(
                            child: Text(
                              '${format(expense)} $currency',
                              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Color(0xFFFF5252)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Balance
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36.r,
                      height: 36.r,
                      decoration: BoxDecoration(
                        color: Color(0xFFE3F2FD),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 18.sp,
                          color: Color(0xFF42A5F5),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Balance', style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey[600])),
                          FittedBox(
                            child: Text(
                              '${format(balance)} $currency',
                              style: GoogleFonts.poppins(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
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
        ],
      ),
    );
  }
}

class CalendarTransactionCard extends StatelessWidget {
  final InputModel transaction;
  final CategoryItem categoryItem;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CalendarTransactionCard({
    required this.transaction,
    required this.categoryItem,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    bool isIncome = transaction.type == 'Income';
    Color catColor = isIncome ? Color(0xFF4CAF50) : Color(0xFFFF5252);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: SwipeActionCell(
          key: ObjectKey(transaction),
          trailingActions: <SwipeAction>[
            SwipeAction(
              title: getTranslated(context, 'Delete') ?? 'Delete',
              onTap: (CompletionHandler handler) async {
                Future<void> performDelete() async {
                  await handler(true);
                  onDelete();
                }

                if (Platform.isIOS) {
                  await iosDialog(
                    context,
                    'Are you sure you want to delete this transaction?',
                    'Delete',
                    performDelete,
                  );
                } else {
                  await androidDialog(
                    context,
                    'Are you sure you want to delete this transaction?',
                    'Delete',
                    performDelete,
                  );
                }
              },
              color: red,
            ),
          ],
          child: Material(
            color: Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(20.r),
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
                      color: catColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        iconData(categoryItem),
                        color: catColor,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Category Name & Date / Description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, categoryItem.text) ?? categoryItem.text,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          transaction.description != null && transaction.description!.isNotEmpty
                              ? transaction.description!
                              : (transaction.date ?? ''),
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Amount
                  Text(
                    '${format(transaction.amount ?? 0)} $currency',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: catColor,
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Chevron Right
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
      ),
    ),
  );
  }
}

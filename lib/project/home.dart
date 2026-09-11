import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_assistant_2608/project/database_management/sqflite_services.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'app_pages/analysis.dart';
import 'app_pages/calendar.dart';
import 'app_pages/input.dart';
import 'app_pages/others.dart';
import 'localization/methods.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  List<Widget> myBody = [
    AddInput(),
    Analysis(),
    Calendar(),
    Other(),
  ];

  @override
  void initState() {
    super.initState();
    DB.init();
    var rateMyApp = RateMyApp(
      minDays: 0,
      minLaunches: 1,
      remindDays: 4,
      remindLaunches: 15,
      googlePlayIdentifier: 'com.mmas.money_assistant_2608',
      appStoreIdentifier: '1582638369',
    );

    WidgetsBinding.instance?.addPostFrameCallback((_) async {
      await rateMyApp.init();
      if (mounted && rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          ignoreNativeDialog: Platform.isAndroid,
          onDismissed: () => rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        );
      }
    });
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isSelected ? Color(0xFF00695C) : Colors.grey[500],
            ),
            SizedBox(height: 4.h),
            Text(
              getTranslated(context, label) ?? label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Color(0xFF00695C) : Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.h),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: 3.h,
              width: isSelected ? 24.w : 0,
              decoration: BoxDecoration(
                color: Color(0xFF00695C),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: myBody[_selectedIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        height: 68.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildNavItem(0, Icons.add_circle_outline_rounded, 'Add'),
            _buildNavItem(1, Icons.bar_chart_rounded, 'Analysis'),
            _buildNavItem(2, Icons.calendar_today_rounded, 'Calendar'),
            _buildNavItem(3, Icons.person_outline_rounded, 'Other'),
          ],
        ),
      ),
    );
  }
}

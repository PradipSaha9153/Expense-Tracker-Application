import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:money_assistant_2608/project/app_pages/currency.dart';
import 'package:money_assistant_2608/project/app_pages/select_date_format.dart';
import 'package:money_assistant_2608/project/app_pages/select_language.dart';
import 'package:money_assistant_2608/project/auth_pages/user_account.dart';
import 'package:money_assistant_2608/project/classes/alert_dialog.dart';
import 'package:money_assistant_2608/project/classes/custom_toast.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/database_management/sqflite_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:share_plus/share_plus.dart';

class Other extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsPage();
  }
}

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    String todayFormatted = DateFormat(sharedPrefs.dateFormat).format(DateTime.now());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/analysis_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Header Banner
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                child: Row(
                  children: [
                    // Profile Avatar with Yellow Ring
                    Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFB300),
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 52.r,
                        height: 52.r,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.sentiment_satisfied_alt_rounded,
                            color: Colors.black87,
                            size: 38.r,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 14.w),

                    // Greeting Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated(context, 'Hi you') != null
                                ? '${getTranslated(context, 'Hi you')}!'
                                : 'Hi you!',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Manage your app, your way 🌱',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserAccount()),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.w,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Edit',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Settings List Cards
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                  children: [
                    // My Account
                    SettingsCard(
                      icon: Icons.person_rounded,
                      iconColor: Color(0xFF2196F3),
                      bgColor: Color(0xFFE3F2FD),
                      title: 'My Account',
                      subtitle: 'View and edit your profile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserAccount()),
                        );
                      },
                    ),

                    // Language
                    SettingsCard(
                      icon: Icons.language_rounded,
                      iconColor: Color(0xFF9C27B0),
                      bgColor: Color(0xFFF3E5F5),
                      title: 'Language',
                      subtitle: 'Choose your preferred language',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SelectLanguage()),
                        );
                      },
                    ),

                    // Currency
                    SettingsCard(
                      icon: Icons.currency_rupee_rounded,
                      iconColor: Color(0xFF009688),
                      bgColor: Color(0xFFE0F2F1),
                      title: 'Currency',
                      subtitle: 'Select your currency',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Currency()),
                        );
                      },
                    ),

                    // Date Format
                    SettingsCard(
                      icon: Icons.calendar_month_rounded,
                      iconColor: Color(0xFFFF5722),
                      bgColor: Color(0xFFFFF3E0),
                      title: 'Date Format',
                      subtitle: 'Set date format ($todayFormatted)',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FormatDate()),
                        ).then((_) => setState(() {}));
                      },
                    ),

                    // Reset All Categories
                    SettingsCard(
                      icon: Icons.refresh_rounded,
                      iconColor: Color(0xFFE91E63),
                      bgColor: Color(0xFFFFEBEE),
                      title: 'Reset All Categories',
                      subtitle: 'Remove and restore default categories',
                      onTap: () async {
                        void onReset() {
                          sharedPrefs.setItems(setCategoriesToDefault: true);
                          customToast(context, 'Categories have been reset');
                        }

                        if (Platform.isIOS) {
                          await iosDialog(
                            context,
                            'This action cannot be undone. Are you sure you want to reset all categories?',
                            'Reset',
                            onReset,
                          );
                        } else {
                          await androidDialog(
                            context,
                            'This action cannot be undone. Are you sure you want to reset all categories?',
                            'Reset',
                            onReset,
                          );
                        }
                      },
                    ),

                    // Delete All Data
                    SettingsCard(
                      icon: Icons.delete_outline_rounded,
                      iconColor: Color(0xFFF44336),
                      bgColor: Color(0xFFFFEBEE),
                      title: 'Delete All Data',
                      subtitle: 'Permanently delete your data',
                      onTap: () async {
                        Future onDeletion() async {
                          await DB.deleteAll();
                          customToast(context, 'All data has been deleted');
                        }

                        if (Platform.isIOS) {
                          await iosDialog(
                            context,
                            'Deleted data can not be recovered. Are you sure you want to delete all data?',
                            'Delete',
                            onDeletion,
                          );
                        } else {
                          await androidDialog(
                            context,
                            'Deleted data can not be recovered. Are you sure you want to delete all data?',
                            'Delete',
                            onDeletion,
                          );
                        }
                      },
                    ),

                    // Share with Friends
                    SettingsCard(
                      icon: Icons.share_rounded,
                      iconColor: Color(0xFF03A9F4),
                      bgColor: Color(0xFFE3F2FD),
                      title: 'Share with Friends',
                      subtitle: 'Tell your friends about this app',
                      onTap: () {
                        Share.share(
                            'https://apps.apple.com/us/app/mmas-money-tracker-bookkeeper/id1582638369');
                      },
                    ),

                    // Rate App
                    SettingsCard(
                      icon: Icons.star_rounded,
                      iconColor: Color(0xFFFFB300),
                      bgColor: Color(0xFFFFFDE7),
                      title: 'Rate App',
                      subtitle: 'If you like the app, please rate us',
                      onTap: () async {
                        final InAppReview inAppReview = InAppReview.instance;
                        await inAppReview.openStoreListing(
                          appStoreId: Platform.isIOS
                              ? '1582638369'
                              : 'com.mmas.money_assistant_2608',
                        );
                      },
                    ),

                    // About
                    SettingsCard(
                      icon: Icons.info_outline_rounded,
                      iconColor: Color(0xFF673AB7),
                      bgColor: Color(0xFFF3E5F5),
                      title: 'About',
                      subtitle: 'App version, privacy policy, more',
                      onTap: () {
                        showAboutDialog(
                          context: context,
                          applicationName: 'Spendrym',
                          applicationVersion: '1.0.8',
                          applicationIcon: Image.asset('images/app_icon.png', width: 48, height: 48),
                          children: [
                            Text('Spendrym is your personal daily expense tracker and finance assistant.'),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsCard({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Container(
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
                  // Icon Badge
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: 22.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 14.w),

                  // Title & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, title) ?? title,
                          style: GoogleFonts.poppins(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          getTranslated(context, subtitle) ?? subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Chevron Right
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22.sp,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

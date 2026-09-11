import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class CustomKeyboard extends StatelessWidget {
  CustomKeyboard({
    required this.panelController,
    this.mainFocus,
    this.nextFocus,
    required this.onTextInput,
    required this.onBackspace,
    required this.page,
  });

  final PanelController panelController;
  final FocusNode? mainFocus;
  final FocusNode? nextFocus;
  final VoidCallback onBackspace;
  final ValueSetter<String> onTextInput;
  final Widget page;

  List<Widget> generatedKeys() {
    List<Widget> keys = [];
    for (String i in ['1', '2', '3', '4', '5', '6', '7', '8', '9', '.', '0', '']) {
      keys.add(
        TextKey(
          text: i,
          onTextInput: onTextInput,
          onBackspace: onBackspace,
        ),
      );
    }
    return keys;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFE8F6F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Control Bar
          Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Color(0xFFD4EFEA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    panelController.close();
                    if (nextFocus != null) {
                      FocusScope.of(context).requestFocus(nextFocus);
                    }
                  },
                  child: Container(
                    height: 32.h,
                    width: 50.w,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 26.sp,
                      color: Color(0xFF00695C),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    panelController.close();
                    if (mainFocus != null) {
                      mainFocus!.unfocus();
                    }
                  },
                  child: Text(
                    getTranslated(context, "Done") ?? "Done",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00695C),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),

          // Key Grid (3 columns x 4 rows)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Wrap(
              children: generatedKeys(),
            ),
          ),
          SizedBox(height: 80.h), // Clearance for bottom navigation bar
        ],
      ),
    );
  }
}

class TextKey extends StatelessWidget {
  const TextKey({
    required this.text,
    this.onBackspace,
    this.onTextInput,
  });

  final VoidCallback? onBackspace;
  final String text;
  final ValueSetter<String>? onTextInput;

  @override
  Widget build(BuildContext context) {
    double itemWidth = (1.sw - 36.w) / 3;

    return Container(
      width: itemWidth,
      height: 52.h,
      padding: EdgeInsets.all(3.r),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.04),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () {
            if (text.isEmpty) {
              onBackspace?.call();
            } else {
              onTextInput?.call(text);
            }
          },
          child: Center(
            child: text.isEmpty
                ? Icon(
                    Icons.backspace_outlined,
                    color: Color(0xFFFF5252),
                    size: 22.sp,
                  )
                : Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004D40),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

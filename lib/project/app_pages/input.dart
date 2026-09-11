import 'dart:core';
import 'dart:io' show Platform;
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:money_assistant_2608/project/app_pages/currency.dart';
import 'package:money_assistant_2608/project/classes/alert_dialog.dart';
import 'package:money_assistant_2608/project/classes/category_item.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/classes/custom_toast.dart';
import 'package:money_assistant_2608/project/classes/input_model.dart';
import 'package:money_assistant_2608/project/classes/keyboard.dart';
import 'package:money_assistant_2608/project/classes/saveOrSaveAndDeleteButtons.dart';
import 'package:money_assistant_2608/project/database_management/shared_preferences_services.dart';
import 'package:money_assistant_2608/project/database_management/sqflite_services.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../provider.dart';
import 'expense_category.dart';
import 'income_category.dart';

late CategoryItem defaultCategory;
var selectedTime = TimeOfDay.now();
var selectedDate = DateTime.now();
InputModel model = InputModel();
PanelController _pc = PanelController();
late TextEditingController _amountController;
FocusNode? amountFocusNode, descriptionFocusNode;

class AddInput extends StatefulWidget {
  @override
  _AddInputState createState() => _AddInputState();
}

class _AddInputState extends State<AddInput> {
  static final _formKey1 = GlobalKey<FormState>(debugLabel: '_formKey1'),
      _formKey2 = GlobalKey<FormState>(debugLabel: '_formKey2');

  String currentType = 'Expense';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasFocus || !currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
          if (_pc.isPanelOpen) {
            _pc.close();
          }
        }
      },
      child: Scaffold(
        body: PanelForKeyboard(
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/login_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top Header Banner
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getTranslated(context, 'Add Transaction') ?? 'Add Transaction',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Track today • Balance tomorrow',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12.w),
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

                  // Segmented Expense / Income Toggle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    child: Container(
                      height: 60.h,
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: Color(0xFFE2F4EE),
                        borderRadius: BorderRadius.circular(40.r),
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
                                      width: 34.r,
                                      height: 34.r,
                                      decoration: BoxDecoration(
                                        color: currentType == 'Expense'
                                            ? Colors.white
                                            : Color(0xFF80CBC4).withOpacity(0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.south_west_rounded,
                                        color: Color(0xFF00695C),
                                        size: 18.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'EXPENSE',
                                      style: GoogleFonts.poppins(
                                        color: currentType == 'Expense'
                                            ? Colors.white
                                            : Color(0xFF004D40),
                                        fontWeight: FontWeight.w600,
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
                                      width: 34.r,
                                      height: 34.r,
                                      decoration: BoxDecoration(
                                        color: currentType == 'Income'
                                            ? Colors.white
                                            : Color(0xFF80CBC4).withOpacity(0.4),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.north_east_rounded,
                                        color: Color(0xFF00695C),
                                        size: 18.sp,
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      'INCOME',
                                      style: GoogleFonts.poppins(
                                        color: currentType == 'Income'
                                            ? Colors.white
                                            : Color(0xFF004D40),
                                        fontWeight: FontWeight.w600,
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

                  // Main Form Body
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: currentType == 'Expense'
                          ? AddEditInput(
                              type: 'Expense',
                              formKey: _formKey2,
                            )
                          : AddEditInput(
                              type: 'Income',
                              formKey: _formKey1,
                            ),
                    ),
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

class PanelForKeyboard extends StatelessWidget {
  const PanelForKeyboard(
    this.body,
  );
  final Widget body;
  void _insertText(String myText) {
    final text = _amountController.text;
    TextSelection textSelection = _amountController.selection;
    String newText = text.replaceRange(
      textSelection.start,
      textSelection.end,
      myText,
    );
    if (newText.length > 13) {
      newText = newText.substring(0, 13);
    }
    if (newText.contains('.')) {
      String fractionalNumber = newText.split('.').last;
      if (fractionalNumber.length > 2) {
        String wholeNumber = newText.split('.').first;
        newText = wholeNumber + '.' + fractionalNumber.substring(0, 2);
      }

      if (newText.substring(newText.length - 1) == '.') {
        if ('.'.allMatches(newText).length == 2) {
          newText = newText.substring(0, newText.length - 1);
        }
      }
      _amountController.text = newText;
    } else {
      _amountController.text =
          format(double.parse(newText.replaceAll(',', '')));
    }

    textSelection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length));
    _amountController.selection = textSelection;
  }

  void _backspace() {
    final text = _amountController.text;
    TextSelection textSelection = _amountController.selection;

    if (textSelection.start == 0) {
      return;
    }

    final selectionLength = textSelection.end - textSelection.start;
    if (selectionLength > 0) {
      final newText = text.replaceRange(
        textSelection.start,
        textSelection.end,
        '',
      );
      if (newText == '' || newText.contains('.')) {
        _amountController.text = newText;
      } else {
        _amountController.text =
            format(double.parse(newText.replaceAll(',', '')));
      }

      textSelection = TextSelection.fromPosition(
          TextPosition(offset: _amountController.text.length));
      _amountController.selection = textSelection;
      return;
    }

    final previousCodeUnit = text.codeUnitAt(textSelection.start - 1);
    final offset = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
    final newStart = textSelection.start - offset;
    final newEnd = textSelection.start;
    final newText = text.replaceRange(
      newStart,
      newEnd,
      '',
    );
    if (newText == '' || newText.contains('.')) {
      _amountController.text = newText;
    } else {
      _amountController.text =
          format(double.parse(newText.replaceAll(',', '')));
    }
    textSelection = TextSelection.fromPosition(
        TextPosition(offset: _amountController.text.length));
    _amountController.selection = textSelection;
  }

  bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanel(
        controller: _pc,
        minHeight: 0,
        maxHeight: 350.h,
        parallaxEnabled: true,
        isDraggable: false,
        panelSnapping: true,
        panel: CustomKeyboard(
          panelController: _pc,
          mainFocus: amountFocusNode,
          nextFocus: descriptionFocusNode,
          onTextInput: (myText) {
            _insertText(myText);
          },
          onBackspace: () {
            _backspace();
          },
          page: model.type == 'Income'
              ? IncomeCategory()
              : ExpenseCategory(),
        ),
        body: this.body);
  }
}

class AddEditInput extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final InputModel? inputModel;
  final String? type;
  final IconData? categoryIcon;
  const AddEditInput({
    required this.formKey,
    this.inputModel,
    this.type,
    this.categoryIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (this.inputModel != null) {
      model = this.inputModel!;
      defaultCategory = categoryItem(this.categoryIcon!, model.category!);
    } else {
      model = InputModel(
        type: this.type,
      );
      defaultCategory = categoryItem(Icons.category_outlined, 'Category');
    }
    return ChangeNotifierProvider<ChangeCategoryA>(
        create: (context) => ChangeCategoryA(),
        child: Column(
          children: [
            AmountCard(),
            SizedBox(height: 16.h),
            Container(
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
                  CategoryCard(),
                  Divider(height: 1, color: Color(0xFFF0F0F0), indent: 70.w, endIndent: 20.w),
                  DescriptionCard(),
                  Divider(height: 1, color: Color(0xFFF0F0F0), indent: 70.w, endIndent: 20.w),
                  DateCard(),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            this.inputModel != null
                ? SaveAndDeleteButton(
                    saveAndDeleteInput: true,
                    formKey: this.formKey,
                  )
                : SaveButton(true, null, true),
            SizedBox(height: 20.h),
          ],
        ));
  }
}

class AmountCard extends StatefulWidget {
  @override
  _AmountCardState createState() => _AmountCardState();
}

class _AmountCardState extends State<AmountCard> {
  @override
  void initState() {
    super.initState();
    amountFocusNode = FocusNode();
    _amountController = TextEditingController(
      text: model.id == null ? '' : format(model.amount!),
    );
  }

  @override
  Widget build(BuildContext context) {
    String currencySymbol = sharedPrefs.currencySymbol;
    String currencyCode = 'INR';
    try {
      if (sharedPrefs.appCurrency.isNotEmpty) {
        currencyCode = sharedPrefs.appCurrency.toUpperCase();
      }
    } catch (_) {}

    return Container(
      padding: EdgeInsets.all(20.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Amount',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              // Currency symbol circle badge
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    currencySymbol,
                    style: GoogleFonts.poppins(
                      color: Color(0xFF00695C),
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),

              // Amount Input Field
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  readOnly: true,
                  showCursor: true,
                  maxLines: 1,
                  onTap: () => _pc.open(),
                  cursorColor: Color(0xFF00695C),
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  focusNode: amountFocusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Currency code dropdown badge
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Currency()),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      currencyCode,
                      style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.grey[700],
                      size: 20.sp,
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

class CategoryCard extends StatefulWidget {
  @override
  _CategoryCardState createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeCategoryA>(builder: (_, changeCategoryA, __) {
      changeCategoryA.categoryItemA ??= defaultCategory;
      var categoryItem = changeCategoryA.categoryItemA;
      model.category = categoryItem!.text;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async {
          if (_pc.isPanelOpen) {
            _pc.close();
          }
          CategoryItem? newCategoryItem = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => model.type == 'Income'
                  ? IncomeCategory()
                  : ExpenseCategory(),
            ),
          );
          if (newCategoryItem != null) {
            changeCategoryA.changeCategory(newCategoryItem);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                width: 46.r,
                height: 46.r,
                decoration: BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Icon(
                    iconData(categoryItem),
                    size: 24.sp,
                    color: Color(0xFFFF5252),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: GoogleFonts.poppins(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      getTranslated(context, categoryItem.text) ?? categoryItem.text,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey[500],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 22.sp,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class DescriptionCard extends StatefulWidget {
  @override
  _DescriptionCardState createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<DescriptionCard> {
  static late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    descriptionFocusNode = FocusNode();
    descriptionController =
        TextEditingController(text: model.description ?? '');
  }

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
        nextFocus: false,
        keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
        keyboardBarColor: Colors.grey[200],
        actions: [
          KeyboardActionsItem(
              focusNode: descriptionFocusNode!,
              toolbarButtons: [
                (node) {
                  return SizedBox(
                    width: 1.sw,
                    child: Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                FocusScope.of(context)
                                    .requestFocus(amountFocusNode);
                                _pc.open();
                              },
                              child: SizedBox(
                                height: 35.h,
                                width: 60.w,
                                child: Icon(Icons.keyboard_arrow_up,
                                    size: 25.sp, color: Colors.blueGrey),
                              ),
                            ),
                            GestureDetector(
                                onTap: () => node.unfocus(),
                                child: Text(
                                  getTranslated(context, "Done") ?? "Done",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ))
                          ],
                        )),
                  );
                },
              ])
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardActions(
      overscroll: 0,
      disableScroll: true,
      tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
      autoScroll: false,
      config: _buildConfig(context),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 46.r,
              height: 46.r,
              decoration: BoxDecoration(
                color: Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Icon(
                  Icons.description_rounded,
                  size: 24.sp,
                  color: Color(0xFF42A5F5),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  TextFormField(
                    controller: descriptionController,
                    maxLines: null,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    keyboardAppearance: Brightness.light,
                    onTap: () {
                      if (_pc.isPanelOpen) {
                        _pc.close();
                      }
                    },
                    cursorColor: Color(0xFF00695C),
                    textCapitalization: TextCapitalization.sentences,
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.black87,
                    ),
                    focusNode: descriptionFocusNode,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      border: InputBorder.none,
                      hintText: 'Add a note...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DateCard extends StatefulWidget {
  const DateCard();
  @override
  _DateCardState createState() => _DateCardState();
}

class _DateCardState extends State<DateCard> {
  @override
  Widget build(BuildContext context) {
    if (model.date == null) {
      model.date = DateFormat('dd/MM/yyyy').format(selectedDate);
      model.time = selectedTime.format(context);
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          // Date Section
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_pc.isPanelOpen) {
                  _pc.close();
                }
                showDatePicker(
                  context: context,
                  initialDate: DateFormat('dd/MM/yyyy').parse(model.date!),
                  firstDate: DateTime(1990, 1, 1),
                  lastDate: DateTime(2050, 12, 31),
                  confirmText: getTranslated(context, 'OK') ?? 'OK',
                  cancelText: getTranslated(context, 'CANCEL'),
                  helpText: getTranslated(context, 'Select a date'),
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
                ).then((value) {
                  if (value != null) {
                    setState(() {
                      selectedDate = value;
                      model.date = DateFormat('dd/MM/yyyy').format(value);
                    });
                  }
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 20.sp,
                        color: Color(0xFF66BB6A),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        DateFormat(sharedPrefs.dateFormat).format(
                            DateFormat('dd/MM/yyyy').parse(model.date!)),
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Container(
            height: 35.h,
            width: 1.w,
            color: Color(0xFFF0F0F0),
          ),
          SizedBox(width: 12.w),

          // Time Section
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (_pc.isPanelOpen) {
                  _pc.close();
                }
                Navigator.of(context).push(
                  showPicker(
                      cancelText: getTranslated(context, 'Cancel') ?? 'Cancel',
                      okText: getTranslated(context, 'Ok') ?? 'Ok',
                      unselectedColor: grey,
                      dialogInsetPadding: EdgeInsets.symmetric(
                          horizontal: 50.w, vertical: 30.0.h),
                      elevation: 12,
                      context: context,
                      value: Time(hour: selectedTime.hour, minute: selectedTime.minute),
                      is24HrFormat: true,
                      onChange: (value) => setState(() {
                            selectedTime = TimeOfDay(hour: value.hour, minute: value.minute);
                            model.time = selectedTime.format(context);
                          })),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: Color(0xFFF3E5F5),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.access_time_rounded,
                        size: 20.sp,
                        color: Color(0xFFAB47BC),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        model.time!,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void saveInputFunc(BuildContext context, bool saveFunction) {
  model.amount = _amountController.text.isEmpty
      ? 0
      : double.parse(_amountController.text.replaceAll(',', ''));
  model.description = _DescriptionCardState.descriptionController.text;
  if (saveFunction) {
    DB.insert(model);
    _amountController.clear();
    if (_DescriptionCardState.descriptionController.text.length > 0) {
      _DescriptionCardState.descriptionController.clear();
    }
    customToast(context, 'Data has been saved');
  } else {
    DB.update(model);
    Navigator.pop(context);
    customToast(context, getTranslated(context, 'Transaction has been updated') ?? 'Transaction has been updated');
  }
}

Future<void> deleteInputFunction(
  BuildContext context,
) async {
  void onDeletion() {
    DB.delete(model.id!);
    Navigator.pop(context);
    customToast(context, 'Transaction has been deleted');
  }

  Platform.isIOS
      ? await iosDialog(
          context,
          'Are you sure you want to delete this transaction?',
          'Delete',
          onDeletion)
      : await androidDialog(
          context,
          'Are you sure you want to delete this transaction?',
          'Delete',
          onDeletion);
}

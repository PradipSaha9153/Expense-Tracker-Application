import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:intl/intl.dart';
import 'package:money_assistant_2608/project/classes/category_item.dart';
import 'package:money_assistant_2608/project/classes/constants.dart';
import 'package:money_assistant_2608/project/localization/methods.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPrefs = SharedPrefs();
String get currency => sharedPrefs.currencySymbol;
// constants/strings.dart
// const String appCurrency = 'app_currency';
var incomeItems = sharedPrefs.getItems('income items');

class SharedPrefs {
  static SharedPreferences? _sharedPrefs;

  sharePrefsInit() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
  }

  String get selectedDate => _sharedPrefs!.getString('selectedDate')!;

  set selectedDate(String value) {
    _sharedPrefs!.setString('selectedDate', value);
  }

  String get appCurrency =>
      _sharedPrefs!.getString('appCurrency') ?? Platform.localeName;

  set appCurrency(String appCurrency) =>
      _sharedPrefs!.setString('appCurrency', appCurrency);

  String get currencySymbol {
    try {
      var format = NumberFormat.simpleCurrency(locale: appCurrency);
      return format.currencySymbol;
    } catch (_) {
      return '₹';
    }
  }

  String get currency => currencySymbol;

  String get dateFormat =>
      _sharedPrefs!.getString('dateFormat') ?? 'dd/MM/yyyy';

  set dateFormat(String dateFormat) =>
      _sharedPrefs!.setString('dateFormat', dateFormat);


  bool get isPasscodeOn => _sharedPrefs!.getBool('isPasscodeOn') ?? false;

  set isPasscodeOn(bool value) => _sharedPrefs!.setBool('isPasscodeOn', value);

  String get passcodeScreenLock =>
      _sharedPrefs!.getString('passcodeScreenLock')!;

  set passcodeScreenLock(String value) =>
      _sharedPrefs!.setString('passcodeScreenLock', value);

  List<String> get parentExpenseItemNames =>
      _sharedPrefs!.getStringList('parent expense item names')!;

  // not yet use this set method
  set parentExpenseItemNames(List<String> parentExpenseItemNames) =>
      _sharedPrefs!
          .setStringList('parent expense item names', parentExpenseItemNames);

  Locale setLocale(String languageCode) {
    _sharedPrefs!.setString('languageCode', languageCode);
    return locale(languageCode);
  }

  Locale getLocale() {
    String languageCode = _sharedPrefs?.getString('languageCode') ?? "en";
    return locale(languageCode);
  }

  void getCurrency() {
    // currency is dynamically retrieved via the currency getter
  }

  //jsonEncode turns a Map<String, dynamic> into a json string,
  //jsonDecode turns a json string into a Map<String, dynamic>
  List<CategoryItem> getItems(String parentItemName) {
    List<String> itemsEncoded = _sharedPrefs!.getStringList(parentItemName)!;
    List<CategoryItem> items = itemsEncoded
        .map((item) => CategoryItem.fromJson(jsonDecode(item)))
        .toList();
    return items;
  }

  void saveItems(String parentItemName, List<CategoryItem> items) {
    List<String> itemsEncoded =
        items.map((item) => jsonEncode(item.toJson())).toList();

    _sharedPrefs!.setStringList(parentItemName, itemsEncoded);
  }

  List<List<CategoryItem>> getAllExpenseItemsLists() {
    List<List<CategoryItem>> expenseItemsLists = [];
    for (int i = 0; i < this.parentExpenseItemNames.length; i++) {
      var parentExpenseItem =
          sharedPrefs.getItems(this.parentExpenseItemNames[i]);
      expenseItemsLists.add(parentExpenseItem);
    }
    return expenseItemsLists;
  }

  void removeItem(String itemName) {
    _sharedPrefs!.remove(itemName);
  }

  void setItems({required bool setCategoriesToDefault}) {
    // _sharedPrefs!.clear();

    if (!_sharedPrefs!.containsKey('parent expense item names') ||
        setCategoriesToDefault) {
      _sharedPrefs!.setStringList('parent expense item names', [
        'Food & Beverages',
        'Transport',
        'Personal Development',
        'Shopping',
        'Entertainment',
        'Home',
        'Utility Bills',
        'Health',
        'Gifts & Donations',
        'Kids',
        'OtherExpense'
      ]);

      saveItems('income items', [
        categoryItem(Icons.account_balance_wallet, 'Salary'),
        categoryItem(Icons.business_center_rounded, 'InvestmentIncome'),
        categoryItem(Icons.monetization_on, 'Bonus'),
        categoryItem(Icons.work, 'Side job'),
        categoryItem(Icons.card_giftcard, 'GiftsIncome'),
        categoryItem(Icons.attach_money, 'OtherIncome'),
      ]);

      saveItems('Food & Beverages', [
        categoryItem(Icons.fastfood, 'Food & Beverages'),
        categoryItem(Icons.restaurant, 'Food'),
        categoryItem(Icons.local_bar, 'Beverages'),
        categoryItem(Icons.add_shopping_cart, 'Daily Necessities'),
      ]);

      saveItems('Transport', [
        categoryItem(Icons.commute, 'Transport'),
        categoryItem(Icons.local_gas_station, 'Fuel'),
        categoryItem(Icons.local_parking, 'Parking'),
        categoryItem(Icons.home_repair_service, 'Services & Maintenance'),
        categoryItem(Icons.local_taxi_outlined, 'Taxi'),
      ]);

      saveItems('Personal Development', [
        categoryItem(Icons.person, 'Personal Development'),
        categoryItem(Icons.business, 'Business'),
        categoryItem(Icons.school, 'Education'),
        categoryItem(Icons.savings, 'InvestmentExpense'),
      ]);

      saveItems('Shopping', [
        categoryItem(Icons.shopping_cart, 'Shopping'),
        categoryItem(Boxicons.bxs_t_shirt, 'Clothes'),
        categoryItem(Boxicons.bxs_binoculars, 'Accessories'),
        categoryItem(Boxicons.bxs_devices, 'Electronic Devices'),
      ]);

      saveItems('Entertainment', [
        categoryItem(Icons.add_photo_alternate_outlined, 'Entertainment'),
        categoryItem(Icons.movie_filter, 'Movies'),
        categoryItem(Icons.sports_esports, 'Games'),
        categoryItem(Icons.library_music, 'Music'),
        categoryItem(Icons.airplanemode_active, 'Travel'),
      ]);

      saveItems('Home', [
        categoryItem(Icons.home, 'Home'),
        categoryItem(Icons.pets, 'Pets'),
        categoryItem(Icons.chair, 'Furnishings'),
        categoryItem(Icons.build, 'Home Services'),
        categoryItem(Icons.house, 'Mortgage & Rent'),
      ]);

      saveItems('Utility Bills', [
        categoryItem(Icons.receipt_long, 'Utility Bills'),
        categoryItem(Icons.lightbulb, 'Electricity'),
        categoryItem(Icons.language, 'Internet'),
        categoryItem(Icons.phone_android, 'Mobile Phone'),
        categoryItem(Icons.water_drop, 'Water'),
      ]);

      saveItems('Health', [
        categoryItem(Icons.health_and_safety, 'Health'),
        categoryItem(Icons.sports_soccer, 'Sports'),
        categoryItem(Icons.description, 'Health Insurance'),
        categoryItem(Icons.medical_services, 'Doctor'),
        categoryItem(Icons.local_hospital, 'Medicine'),
      ]);

      saveItems('Gifts & Donations', [
        categoryItem(Boxicons.bxs_donate_heart, 'Gifts & Donations'),
        categoryItem(Icons.card_giftcard, 'GiftsExpense'),
        categoryItem(Icons.favorite, 'Wedding'),
        categoryItem(Icons.sentiment_dissatisfied, 'Funeral'),
        categoryItem(Icons.group, 'Charity'),
      ]);

      saveItems('Kids', [
        categoryItem(Icons.child_care, 'Kids'),
        categoryItem(Icons.monetization_on, 'Pocket Money'),
        categoryItem(Icons.child_friendly, 'Baby Products'),
        categoryItem(Icons.baby_changing_station, 'Babysitter & Daycare'),
        categoryItem(Icons.menu_book, 'Tuition'),
      ]);
      saveItems('OtherExpense', [
        categoryItem(Icons.attach_money, 'OtherExpense'),
      ]);
      if (!setCategoriesToDefault) {
        _sharedPrefs!.setString('selectedDate', 'Today');
        _sharedPrefs!.setBool('isPasscodeOn', false);
        _sharedPrefs!.setString('passcodeScreenLock', '');
        _sharedPrefs!.setString('dateFormat', 'dd/MM/yyyy');
      }
    }
    if (_sharedPrefs!.containsKey('parent expense item names') == false) {
      print('didnt save successfully');
    }
  }
}

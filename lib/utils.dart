import 'package:card_validator_app/credit_card.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

List<String> bannedCountries = ['usa', 'india', 'china'];

String inferCardType(String cardNumber) {
  if (cardNumber.startsWith('5')) {
    return 'Mastercard';
  } else if (cardNumber.startsWith('4')) {
    return 'Visa';
  } else if (cardNumber.startsWith('3')) {
    return 'American Express';
  }

  return '';
}

bool isBanned(String country) => bannedCountries.contains(country.toLowerCase());

String extractEnumVal(String e) {
  String enumValue = e.toString().split('.').last;
  return enumValue[0].toUpperCase() + enumValue.substring(1);
}

void saveCardToLocalStorage(List<CreditCard> processedCards, BuildContext context) async {
  List<String> jsonList =
    processedCards.map((card) => jsonEncode(card.toJson())).toList();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setStringList('SavedCards', jsonList);
  ScaffoldMessenger.of(context)
      .showSnackBar(const SnackBar(content: Text('Card saved locally')));
}

void loadCardsFromLocalStorage(List<CreditCard> processedCards) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  List<String>? jsonList = prefs.getStringList('SavedCards');

  if (jsonList != null && jsonList.isNotEmpty) {
    processedCards = jsonList
        .map((jsonCard) => CreditCard.fromJson(jsonDecode(jsonCard)))
        .toList();
  }
}


// ignore_for_file: library_prefixes

import 'package:card_validator_app/credit_card.dart';
import 'package:card_validator_app/utils.dart';

import 'package:credit_card_scanner/credit_card_scanner.dart';
import 'package:flutter/material.dart';

class CardForm extends StatefulWidget {
  const CardForm({super.key});

  @override
  CardFormState createState() => CardFormState();
}

class CardFormState extends State<CardForm> {
  final _formKey = GlobalKey<FormState>();

  String cardNumber = '';
  String cvv = '';
  String cardIssuer = '';
  String country = '';

  bool banned = false;
  bool duplicate = false;

  List<CreditCard> processedCards = [];

  TextEditingController cardNumberController = TextEditingController();
  TextEditingController cardIssuerController = TextEditingController();

  void scanCard() async {
    CardDetails cardDetails = await CardScanner.scanCard() as CardDetails;

    setState(() {
      cardNumber = cardDetails.cardNumber;
      cardIssuer = extractEnumVal(cardDetails.cardIssuer);

      cardNumberController.text = cardDetails.cardNumber;
      cardIssuerController.text = extractEnumVal(cardDetails.cardIssuer);
    });

    return;
  }

  void saveCard() async {
    bool valid = !duplicate &&
        banned == false &&
        cardIssuer.isNotEmpty &&
        country.isNotEmpty &&
        cvv.isNotEmpty &&
        cardNumber.length <= 16 &&
        cardNumber.length >= 15;

    setState(() {
      duplicate = false;

      for (var card in processedCards) {
        if (cardNumber == card.number) {
          duplicate = true;
          return;
        }
      }

      if (valid) {
        final newCard = CreditCard(
            number: cardNumber, cvv: cvv, country: country, issuer: cardIssuer);
        processedCards.add(newCard);
        saveCardToLocalStorage(processedCards, context);
      }
    });
  }

  Widget displayErrorMessage() {
    if (duplicate) {
      return generateErrorWidget('Duplicate Card');
    } else if (cardNumber.length > 16 &&
        cardNumber.length < 15) {
      return generateErrorWidget('Invalid Card Number');
    } else if (banned) {
      return generateErrorWidget('Banned Country');
    } else if (cardNumber.isEmpty ||
        cardIssuer.isEmpty ||
        cvv.isEmpty ||
        country.isEmpty) {
      return generateErrorWidget('Please enter your card details');
    }

    return Container();
  }

  Widget generateErrorWidget(String message) {
    return Padding(
        padding: const EdgeInsets.all(6.0),
        child: Text(
          style: const TextStyle(color: Colors.red), 
          message
        ));
  }

  @override
  void initState() {
    super.initState();
    loadCardsFromLocalStorage(processedCards);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('Please enter your card information'),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Card Number',
                    ),
                    onSaved: (value) => cardNumber = value ?? '',
                    onChanged: (value) {
                      setState(() {
                        cardNumber = value;
                        cardIssuer = inferCardType(value);
                        cardIssuerController.text = cardIssuer;
                      });
                    },
                    controller: cardNumberController,
                  ),
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 220,
                    child: TextFormField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Card Issuer',
                      ),
                      onSaved: (value) => cardIssuer = value ?? '',
                      controller: cardIssuerController,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: 60,
                    child: TextFormField(
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'CVV',
                      ),
                      onSaved: (value) => cvv = value ?? '',
                      onChanged: (value) {
                        setState(() {
                          cvv = value;
                        });
                      },
                    ),
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 300,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Country',
                    ),
                    onSaved: (value) => country = value ?? '',
                    onChanged: (value) {
                      setState(() {
                        country = value;
                        banned = isBanned(country);
                      });
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                      padding: const EdgeInsets.all(15),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(20)),
                          onPressed: () => saveCard(),
                          child: const Text('Submit'))),
                  Padding(
                      padding: const EdgeInsets.all(15),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.all(20)),
                          onPressed: () => scanCard(),
                          child: const Text('Scan Card'))),
                ],
              ),
              displayErrorMessage(),
              SizedBox(
                  height: 301,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: processedCards.length,
                    itemBuilder: (context, index) {
                      final card = processedCards[index];
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text("Card Number: ${card.number}")),
                            Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Text(card.issuer)),
                          ]);
                    },
                  )),
            ],
          )
        )
      ),
    );
  }
}

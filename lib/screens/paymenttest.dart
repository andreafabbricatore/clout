import 'dart:convert';

import 'package:clout/components/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class PaymentTestScreen extends StatefulWidget {
  PaymentTestScreen({super.key, required this.curruser});
  AppUser curruser;

  @override
  State<PaymentTestScreen> createState() => _PaymentTestScreenState();
}

class _PaymentTestScreenState extends State<PaymentTestScreen> {
  Future<void> initPayment({
    required double amount,
  }) async {
    try {
      // 1. Create a payment intent on the server
      final response = await http.post(
          Uri.parse(
              'https://us-central1-clout-1108.cloudfunctions.net/stripePaymentIntentRequest'),
          body: {
            'email': widget.curruser.email,
            'amount': (amount * 100).toString(),
            'name': widget.curruser.fullname,
            'uid': widget.curruser.uid
          });

      final jsonResponse = jsonDecode(response.body);
      // 2. Initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: jsonResponse['paymentIntent'],
              merchantDisplayName: 'Clout',
              customerId: jsonResponse['customer'],
              customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
              applePay: const PaymentSheetApplePay(
                merchantCountryCode: 'IT',
              ),
              googlePay: const PaymentSheetGooglePay(merchantCountryCode: "IT"),
              style: ThemeMode.light));
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment is successful'),
        ),
      );
    } catch (error) {
      if (error is StripeException) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured ${error.error.localizedMessage}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occured $error'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: GestureDetector(
        onTap: () {
          initPayment(amount: 20);
        },
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20)),
          width: 200,
          height: 50,
          child: const Center(
            child: Text("Pay",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      )),
    );
  }
}

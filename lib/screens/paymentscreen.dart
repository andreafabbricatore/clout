import 'package:clout/blocs/payment/payment_bloc.dart';
import 'package:clout/components/primarybutton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentScreen extends StatelessWidget {
  PaymentScreen({super.key});

  bool buttonpressed = false;

  @override
  Widget build(BuildContext context) {
    final screenheight = MediaQuery.of(context).size.height;
    final screenwidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Pay",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        elevation: 0.0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          CardFormEditController controller = CardFormEditController(
              initialDetails: state.cardFieldInputDetails);
          if (state.status == PaymentStatus.initial) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  Container(
                    height: screenheight * 0.06,
                    color: Colors.black,
                    child: Center(
                      child: Text(
                        "Apple Pay",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  Center(
                    child: const Text(
                      "or",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    height: screenheight * 0.02,
                  ),
                  CardFormField(
                    style: CardFormStyle(
                        textColor: Colors.black,
                        placeholderColor: Colors.black,
                        backgroundColor: Colors.black),
                    controller: CardFormEditController(),
                  ),
                  GestureDetector(
                    onTap: () {
                      (controller.details.complete)
                          ? context.read<PaymentBloc>().add(PaymentCreateIntent(
                                  billingDetails: const BillingDetails(
                                      email: "andrea.fabbricatore@outlook.com"),
                                  items: const [
                                    {"id": 0}
                                  ]))
                          : null;
                    },
                    child: SizedBox(
                        height: 50,
                        width: screenwidth * 0.5,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20))),
                          child: const Center(
                              child: Text(
                            "Pay Event",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w800),
                          )),
                        )),
                  ),
                ],
              ),
            );
          } else if (state.status == PaymentStatus.success) {
            return Column(children: [
              const Text("Payment is successful"),
              ElevatedButton(
                onPressed: () {
                  context.read<PaymentBloc>().add(PaymentStart());
                },
                child: Text("Back to home"),
              )
            ]);
          } else if (state.status == PaymentStatus.failure) {
            return Column(children: [
              const Text("Payment failed"),
              ElevatedButton(
                onPressed: () {
                  context.read<PaymentBloc>().add(PaymentStart());
                },
                child: Text("Back to home"),
              )
            ]);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}

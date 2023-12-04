import 'package:bunyan/prossepayment.dart';
import 'package:flutter/material.dart';


class PaymentPage extends StatefulWidget {
  const PaymentPage({Key key}) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController expiryMonthController = TextEditingController();
  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  bool isProcessingPayment = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        title: const Text('Payment',style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter your card details:',
                style: TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryMonthController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Month',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: expiryYearController,
                      decoration: const InputDecoration(
                        labelText: 'Expiry Year',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: cvvController,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Enter payment amount:',
                style: TextStyle(fontSize: 20.0),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 50,
                width: 400,
                child: ElevatedButton(
                  onPressed: isProcessingPayment
                      ? null
                      : () async {
                    setState(() {
                      isProcessingPayment = true;
                    });

                    await processPayment(
                      cardNumberController.text,
                      expiryMonthController.text,
                      expiryYearController.text,
                      cvvController.text,
                      '8685598',
                      'xKQZ//aq1EceRoJF',
                      'https://www.example.com/return',
                      double.parse(amountController.text),
                      'SAR',
                      'Test payment',
                    );

                    setState(() {
                      isProcessingPayment = false;
                    });
                  },
                  child: isProcessingPayment
                      ? const CircularProgressIndicator()
                      : const Text('Pay'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

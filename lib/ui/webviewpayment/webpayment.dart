import 'package:flutter/material.dart';
import '../../models/paymentmodel.dart';
import '../../tools/webservices/products.dart';

class PaymentInitiatePage extends StatefulWidget {
  @override
  _PaymentInitiatePageState createState() => _PaymentInitiatePageState();
}

class _PaymentInitiatePageState extends State<PaymentInitiatePage> {
  PaymentGatewayData _paymentGatewayData;
  List<PaymentGatewayData> paymentGatewayData = [];

  void initState() {
    super.initState();
    getpaymentdata();
  }

  getpaymentdata() {
    ProductsWebService().makePaymentRequest().then((rgs) {
      setState(() {
        paymentGatewayData = rgs;
        print('payment is youssef  $paymentGatewayData');
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Initiate Page'),
      ),
      body: Center(
        child: paymentGatewayData == null
            ? CircularProgressIndicator()
            : Text('Payment Gateway Data: $paymentGatewayData'),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localization/locale_constant.dart';
import '../main/main_screen.dart';
import 'api_payment.dart';



class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final amountController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MainScreen()));
          },
          child: Icon(Icons.arrow_back_ios,size: 30.sp,color: Colors.black,)
        ),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter Payment Amount',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              child: TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                ),
              ),
            ),
            SizedBox(height: 20),
            MaterialButton(
              onPressed: () async {
                double amount = double.tryParse(amountController.text);
                if (amount == null) {
                  return;
                }
                setState(() {
                  _isLoading = true;
                });
                try {
                  Map<String, dynamic> responseData = await initiatePayment(
                    'your_merchant_id',
                    'your_merchant_password',
                    amount,
                    'your_order_id',
                  );
                  // Navigate to the payment gateway
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PaymentGateway(responseData)));
                } catch (e) {
                  // Handle payment initiation failure
                  setState(() {
                    _isLoading = false;
                  });
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Payment Error'),
                      content: Text('Failed to initiate payment. Please try again later.'),
                      actions: [
                        MaterialButton(
                          child: Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: Text('Pay'),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentGateway extends StatefulWidget {
  final Map<String, dynamic> responseData;

  PaymentGateway(this.responseData);

  @override
  _PaymentGatewayState createState() => _PaymentGatewayState();
}

class _PaymentGatewayState extends State<PaymentGateway> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    launch(widget.responseData['paymentURL']).then((value) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sadad Payment'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            SizedBox(height: 20),
            Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            MaterialButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}

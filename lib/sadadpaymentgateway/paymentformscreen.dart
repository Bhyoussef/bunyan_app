import 'package:bunyan/sadadpaymentgateway/sadadservice.dart';
import 'package:double_back_to_close/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:fluttertoast/fluttertoast.dart';


class PaymentFormScreen extends StatefulWidget {
  @override
  _PaymentFormScreenState createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _sadadService = SadadService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Payment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'amount',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Amount'),
                //validator: FormBuilderValidators.required(context),
              ),
              FormBuilderTextField(
                name: 'description',
                decoration: InputDecoration(labelText: 'Description'),
                //validator: FormBuilderValidators.required(context),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    final result = await _sadadService.makePayment(
                      _formKey.currentState.fields['amount'].value as String,
                      _formKey.currentState.fields['description']
                          .value as String,
                    );
                    if (result != null && result['paymentUrl'] != null) {
                      Navigator.of(context).pushNamed(
                          '/paymentWebView', arguments: result['paymentUrl']);
                    } else {
                      Fluttertoast.showToast(
                        msg: 'Failed to make payment',
                        //toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  }
                },
                child: Text('Make Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }}

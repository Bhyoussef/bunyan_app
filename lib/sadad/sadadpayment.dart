import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/parser.dart' show parse;
import '../tools/res.dart';


class PaymentScreentest1 extends StatefulWidget {
  @override
  _PaymentScreentest1State createState() => _PaymentScreentest1State();
}

class _PaymentScreentest1State extends State<PaymentScreentest1> {
  String _url;
  String _merchantId;
  String _orderId;
  String _website;
  String _txnAmount;
  String _custId;
  String _email;
  String _mobileNo;
  String _callbackUrl;
  String _checksumHash;

  @override
  void initState() {
    super.initState();
    //_fetchPaymentData();
  }

  Future<void> _fetchPaymentData() async {
    final response = await http
        .get(Uri.parse('https://bunyan.qa/api/proceed-property-payment'),
        headers: {'accept': 'application/json',
          'Authorization': 'Bearer ${Res.token}'});
    final document = parse(response.body);
    final inputFields = document.querySelectorAll('input');
    final inputValues = inputFields.fold<Map<String, String>>({}, (values, input) {
      values[input.attributes['name']] = input.attributes['value'];

      return values;
    });

    setState(() {
      _url = 'https://sadadqa.com/webpurchase';
      _merchantId = '8685598';
      _orderId = '630';
      _website = 'bunyan.qa';
      _txnAmount = '40';
      _custId = 'ammalnaveed50@gmail.com';
      _email = 'ammalnaveed50@gmail.com';
      _mobileNo = '66235580';
      _callbackUrl = 'http://bunyan.qa/property-payment-response';
      _checksumHash ='VzuYvhiNm+JornqN7XerIa5gzi4fRZT7fKtJH3vIs9RVVlwPuytNE03DyOgH7Rh1DKaes3k01/jD9gGxo2GkQ3kBSEeCpydN0H2d9vFBaIE=';

    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WebViewBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Payment'),
        ),
        body: _url != null
            ? BlocBuilder<WebViewBloc, WebViewState>(
                builder: (context, state) {
                  if (state is WebViewInitial) {
                    return WebView(
                      initialUrl: _url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onPageFinished: (_) {
                        final postData = {
                          'merchant_id': _merchantId,
                          'ORDER_ID': _orderId,
                          'WEBSITE': _website,
                          'TXN_AMOUNT': _txnAmount,
                          'CUST_ID': _custId,
                          'EMAIL': _email,
                          'MOBILE_NO': _mobileNo,
                          'CALLBACK_URL': _callbackUrl,
                          'txnDate': DateTime.now().toString(),
                          'productdetail[0][order_id]': _orderId,
                          'productdetail[0][itemname]': 'test to test',
                          'productdetail[0][amount]': _txnAmount,
                          'productdetail[0][quantity]': '1',
                          'checksumhash': _checksumHash,
                        };

                        final postUrl = Uri.parse(_url);
                        context.read<WebViewBloc>().add(
                            SendPostData(postUrl: postUrl, postData: postData));
                      },
                    );
                  } else if (state is WebViewLoaded) {
                    return WebView(
                      initialUrl: state.url,
                      javascriptMode: JavascriptMode.unrestricted,
                    );
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}

class WebViewBloc extends Bloc<WebViewEvent, WebViewState> {
  WebViewBloc() : super(WebViewInitial()) {
    on<SendPostData>((event, emit) async {
      final response = await http.post(event.postUrl, body: event.postData);
      emit(WebViewLoaded(url: response.headers['location']));
    });
  }

  @override
  Stream<WebViewState> mapEventToState(
    WebViewEvent event,
  ) async* {
    if (event is SendPostData) {
      final response = await http.post(event.postUrl, body: event.postData);
      final redirectUrl = response.headers['location'];
      yield WebViewLoaded(url: redirectUrl);
    }
  }
}

abstract class WebViewEvent {}

class SendPostData extends WebViewEvent {
  final Uri postUrl;
  final Map<String, String> postData;

  SendPostData({ this.postUrl,  this.postData});
}

abstract class WebViewState {}

class WebViewInitial extends WebViewState {}

class WebViewLoaded extends WebViewState {
  final String url;

  WebViewLoaded({this.url});

  @override
  List<Object> get props => [url];
}



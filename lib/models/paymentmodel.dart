class PaymentGatewayData {
  String merchantId;
  String orderId;
  String website;
  String txnAmount;
  String custId;
  String email;
  String mobileNo;
  String callbackUrl;
  String txnDate;
  String productOrderId;
  String productItemName;
  String productAmount;
  String productQuantity;
  String checksumhash;

  PaymentGatewayData({
     this.merchantId,
     this.orderId,
     this.website,
     this.txnAmount,
     this.custId,
     this.email,
     this.mobileNo,
     this.callbackUrl,
     this.txnDate,
     this.productOrderId,
     this.productItemName,
     this.productAmount,
     this.productQuantity,
     this.checksumhash,
  });
}

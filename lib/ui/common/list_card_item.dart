import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/add/real_estate_page.dart';
import 'package:bunyan/ui/add/service_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/product_list.dart';

class ListCardItem extends StatefulWidget {
  final ProductListModel product;
  final ServiceModel service;
  final Function onChanged;

  const ListCardItem({Key key, this.product, this.onChanged,this.service}) : super(key: key);

  @override
  State<ListCardItem> createState() => _ListCardItemState();
}

class _ListCardItemState extends State<ListCardItem> {
  Locale currentLang;
  String _photo = '';

  @override
  void initState() {

    setState(() {
      super.initState();
      if (widget.product?.ownerImage != null) {
        setState(() {
          _photo = widget.product?.ownerImage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 0.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        minHeight: 180.h, minWidth: double.infinity),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      child: CachedNetworkImage(
                          imageUrl: 'https://bunyan.qa/images/posts/' +
                              (widget.product?.photos.isEmpty
                                  ? ''
                                  : widget.product?.photos?.first ??
                                      (widget.product?.photos ?? '')),
                          progressIndicatorBuilder: (_, __, ___) {
                            return Shimmer.fromColors(
                                child: Container(
                                  //width: double.infinity,
                                  height: 230.0,
                                  color: Colors.grey,
                                ),
                                baseColor: Colors.grey.withOpacity(.5),
                                highlightColor: Colors.white);
                          },
                          errorWidget: (_, __, ___) =>
                              Icon(Icons.broken_image_outlined),
                          fit: BoxFit.cover,
                          height: 230.0,
                          width: double.infinity),
                    ),
                  ),
                  Positioned(
                    top: .0,
                    left: .0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: widget.product.forSell ?? true
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0),
                              topLeft: Radius.circular(10))),
                      padding:
                          EdgeInsets.symmetric(vertical: 5.w, horizontal: 20.w),
                      child: Text(
                        '${NumberFormat('###,###').format(widget.product?.price??'')} QAR',
                        style: GoogleFonts.cairo(
                            fontSize: 20.0.sp,
                            color: Colors.white.withOpacity(.9),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 1.sw,
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  WidgetSpan(
                                      child: Icon(Icons.remove_red_eye_sharp)),
                                  TextSpan(text: '  ${widget.product.views}'),
                                ],
                              ),
                            ),
                            _textIcon(
                              icon: Icons.date_range,
                              text: timeago.format(widget.product.createdAt,
                                  locale: Languages.of(context)
                                              .labelSelectLanguage ==
                                          'English'
                                      ? 'en'
                                      : 'ar'),
                            ),
                            Text(
                              Languages.of(context).labelSelectLanguage ==
                                      "English"
                                  ? widget.product.title
                                  : widget.product.titleAr,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 666,
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                  fontSize: 18.0,
                                  height: 1.2),
                            ),
                            widget.product.region == null
                                ? Container()
                                : Row(
                                    children: [

                                      SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          (Languages.of(context)
                                                          .labelSelectLanguage ==
                                                      'English'
                                                  ? widget.product.region.name
                                                  : widget
                                                      .product.region.nameAr)
                                              .replaceAll('-', ''),
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.black),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                      ),
                      widget.product.status==true?Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                          color: Colors.green,
                              borderRadius: BorderRadius.circular(5.0)),
                          padding: EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 15.0),
                          child: Text(
                            widget.product.status
                                ? Languages.of(context).completedAd
                                : Languages.of(context).inReviewAds,
                            style: GoogleFonts.cairo(
                                color: Colors.white, fontSize: 17.0),
                          ),
                        ),
                      ):
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(5.0)),
                          padding: EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 15.0),
                          child: Text(
                            widget.product.status
                                ? Languages.of(context).completedAd
                                : Languages.of(context).inReviewAds,
                            style: GoogleFonts.cairo(
                                color: Colors.white, fontSize: 17.0),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    _button(
                        text: 'Promote',

                        color: Colors.green,
                        onTap: () => {}),

                    _button(
                        text: Languages.of(context).edit,
                        color: Colors.white,
                        onTap: () =>
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Scaffold(
                                      body: SingleChildScrollView(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 20.w),
                                          child: widget.product is ProductModel
                                              ? RealEstatePage(
                                                  product: widget.product,
                                                )
                                              : ServicePage(
                                                  service: widget.service,
                                                )),
                                    )))),
                    _button(
                        text: Languages.of(context).share,
                        color: Colors.blue,
                        onTap: () {
                          return Share.share(
                              'https://bunyan.qa/${widget.product is ProductModel ?
                              'property' : 'service'}/${widget.product.slug}');
                        }),
                    Flexible(
                      child: _button(
                          text: Languages.of(context).delete,
                          color: Colors.red,
                          onTap: () => _deleteProduct(widget.product)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _button({VoidCallback onTap, String text, Color color}) {
    return MaterialButton(
      onPressed: onTap,
      child: Text(
        text,
        style: GoogleFonts.cairo(),
      ),
      textColor: color == Colors.white ? Colors.black : Colors.white,
      color: color,
    );
  }

  Widget _textIcon({String text, IconData icon}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 25.sp,
        ),
        SizedBox(
          width: 10.w,
        ),
        Text(
          text,
          style: GoogleFonts.cairo(
              color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
      ],
    );
  }

  void _deleteProduct(ProductListModel product) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.QUESTION,
      title: 'Do you want to delete?',
      btnOkText: 'Yes',
      btnCancelText: 'No',
      btnOkOnPress: () async {
        await ProductsWebService().deleteProduct(product);
        widget.onChanged();
      },
      btnCancelOnPress: () => print(''),
    )..show();
  }

  String formatDecimal(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }
}

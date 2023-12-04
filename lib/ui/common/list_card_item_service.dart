import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/ui/add/service_page.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart' show NumberFormat;
import '../../localization/language/languages.dart';
import '../../models/service.dart';
import '../../tools/webservices/products.dart';

class ListCardItemService extends StatefulWidget {

  final ServiceModel service;
  final Function onChanged;

  const ListCardItemService({Key key, this.onChanged,this.service}) : super(key: key);

  @override
  State<ListCardItemService> createState() => _ListCardItemServiceState();
}

class _ListCardItemServiceState extends State<ListCardItemService> {
  Locale currentLang;
  String _photo = '';

  @override
  void initState() {

    setState(() {
      super.initState();
      if (widget.service?.ownerImage != null) {
        setState(() {
          _photo = widget.service?.ownerImage;
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
                              (widget.service?.photos.isEmpty
                                  ? ''
                                  : widget.service?.photos?.first ??
                                  (widget.service?.photos ?? '')),
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
                          color: widget.service.forSell ?? true
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0),
                              topLeft: Radius.circular(10))),
                      padding:
                      EdgeInsets.symmetric(vertical: 5.w, horizontal: 20.w),
                      child: Text(
                        '${NumberFormat('###,###').format(widget.service?.price??'')} QAR',
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
                                  TextSpan(text: '  ${widget.service.views}'),
                                ],
                              ),
                            ),
                            _textIcon(
                              icon: Icons.date_range,
                              text: timeago.format(widget.service.createdAt,
                                  locale: Languages.of(context)
                                      .labelSelectLanguage ==
                                      'English'
                                      ? 'en'
                                      : 'ar'),
                            ),
                            Text(
                              Languages.of(context).labelSelectLanguage ==
                                  "English"
                                  ? widget.service.title
                                  : widget.service.titleAr,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              maxLines: 666,
                              style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red,
                                  fontSize: 18.0,
                                  height: 1.2),
                            ),
                            widget.service.region == null
                                ? Container()
                                : Row(
                              children: [

                                SizedBox(width: 3),
                                Flexible(
                                  child: Text(
                                    (Languages.of(context)
                                        .labelSelectLanguage ==
                                        'English'
                                        ? widget.service.region.name
                                        : widget
                                        .service.region.nameAr)
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
                      widget.service.status==true?Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5.0)),
                          padding: EdgeInsets.symmetric(
                              vertical: 3.0, horizontal: 15.0),
                          child: Text(
                            widget.service.status
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
                            widget.service.status
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
                                      child: widget.service is ProductModel
                                          ? ServicePage(
                                        service: widget.service,
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
                              'https://bunyan.qa/${widget.service is ProductModel ?
                              'property' : 'service'}/${widget.service.slug}');
                        }),
                    Flexible(
                      child: _button(
                          text: Languages.of(context).delete,
                          color: Colors.red,
                          onTap: () => _deleteProduct(widget.service)),
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

  void _deleteProduct(ServiceModel product) {
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

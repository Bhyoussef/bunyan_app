import 'dart:math';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/product.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';

class CardItem extends StatefulWidget {
  final ProductModel product;

  const CardItem({Key key, this.product}) : super(key: key);

  @override
  State<CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<CardItem> {
  Locale currentLang;
  String _photo = '';

  @override
  void initState() {
    setState(() {
      super.initState();
      if (widget.product.ownerImage != null) {
        setState(() {
          _photo = widget.product.ownerImage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.sp, vertical: 3.sp),
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
                constraints:
                    BoxConstraints(minHeight: 180.h, minWidth: double.infinity),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: CachedNetworkImage(
                      imageUrl: 'https://bunyan.qa/images/posts/' +
                              (widget.product?.photos == null ? '' : widget.product?.photos?.first ??
                          widget.product?.photos ??
                          ''),
                      progressIndicatorBuilder: (_, __, ___) {
                        return Shimmer.fromColors(
                            child: Container(
                              //width: double.infinity,
                              height: Random().nextInt(1) == 1 ? 480.h : 320.h,
                              color: Colors.grey,
                            ),
                            baseColor: Colors.grey.withOpacity(.5),
                            highlightColor: Colors.white);
                      },
                      errorWidget: (_, __, ___) =>
                          Icon(Icons.broken_image_outlined),
                      fit: BoxFit.cover,
                      width: double.infinity),
                ),
              ),
              Positioned(
                top: .0,
                left: .0,
                child: Container(
                  decoration: BoxDecoration(
                      color: widget.product.forSell ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                          topLeft: Radius.circular(10))),
                  padding:
                      EdgeInsets.symmetric(vertical: 5.w, horizontal: 25.w),
                  child: Text(
                    '${NumberFormat('###,###').format(widget.product.price)} QAR',
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
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      height: 32,
                      width: 32,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99999),
                        child: CachedNetworkImage(
                          imageUrl:
                          'https://bunyan.qa/images/users/' +
                              _photo,
                          progressIndicatorBuilder: (_, __, ___) {
                            return Shimmer.fromColors(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.red,
                                ),
                                baseColor:
                                const Color(0xFFf3f3f3),
                                highlightColor: Colors.white);
                          },
                          errorWidget: (_, __, ___) => Container(
                            width: double.infinity,
                            height: double.infinity,
                            padding: EdgeInsets.all(8.0),
                            child: Image.asset('assets/icons/avatar.png'),
                          ),
                          fit: BoxFit.fill,
                        ),
                      )),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          Languages.of(context)
                              .labelSelectLanguage ==
                              "English"
                              ? widget.product.title
                              : widget.product.titleAr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 20.0.sp,
                              height: 1.2),
                        ),
                        widget.product.region == null
                            ? Container()
                            : Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 22.0.sp,
                              color: Colors.black,
                            ),
                            SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                (Languages.of(context).labelSelectLanguage == 'English'
                                    ? widget.product.region.name
                                    : widget.product.region.nameAr).replaceAll('-', ''),
                                style: TextStyle(
                                    fontSize: 18.0.sp,
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
                  InkWell(
                    onTap: () {
                      return Share.share('https://bunyan.qa/property/${widget.product.slug}');
                    },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.share, size: 25.sp,),
                      )
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }


  String formatDecimal(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }
}

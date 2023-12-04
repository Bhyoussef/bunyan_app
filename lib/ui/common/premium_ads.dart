import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/ui/product/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../tools/res.dart';
import '../../tools/webservices/products.dart';
import '../redirect_to_auth.dart';

class PremiumAds extends StatefulWidget {
  final List<ProductModel> ads;

  const PremiumAds({Key key, this.ads}) : super(key: key);

  @override
  State<PremiumAds> createState() => _PremiumAdsState();
}

class _PremiumAdsState extends State<PremiumAds> {
  bool favorite = false;
  int selectedfav = 0;
  TextEditingController textfavid = TextEditingController();
  _updateFavorite() {
    ProductsWebService()
        .updateFav(id: selectedfav, type: ProductsWebService.REAL_ESTATE)
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.shortestSide);
    return widget.ads.isNotEmpty
        ? CarouselSlider.builder(
            itemCount: widget.ads?.length ?? 0,
            itemBuilder: (context, index, realIndex) => InkWell(
                onTap: widget.ads[index] == null
                    ? null
                    : () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductScreen(
                                      product: widget.ads[index],
                                    )));
                      },
                child: Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Stack(children: [
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              width: double.infinity,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20.0),
                                      topLeft: Radius.circular(20.0)),
                                  child: widget.ads[index] == null
                                      ? _shimmer()
                                      : CachedNetworkImage(
                                          imageUrl:
                                              'https://bunyan.qa/images/posts/' +
                                                  widget.ads[index].photos[0],
                                          progressIndicatorBuilder:
                                              (_, __, ___) {
                                            return _shimmer();
                                          },
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                            width: .1.sh,
                                            height: .1.sh,
                                            child: Icon(
                                                Icons.broken_image_outlined),
                                            color: Colors.white,
                                          ),
                                          fit: BoxFit.fill,
                                          width: .15.sw,
                                        )),
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 3.0, top: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,

                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.red,
                                                  width: 2.h),
                                              borderRadius:
                                                  BorderRadius.circular(6.0)),
                                          child: widget.ads[index] == null
                                              ? SizedBox(
                                                  width: .1.sw +
                                                      Random().nextInt(50),
                                                  child: _shimmer(
                                                      width: .01.sw,
                                                      height: 4.h),
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.all(1.0),
                                                  child: Text(
                                                    Languages.of(context)
                                                                .labelSelectLanguage ==
                                                            'English'
                                                        ? widget.ads[index]
                                                                .category_name ??
                                                            ''
                                                        : widget.ads[index]
                                                                .categoryAr ??
                                                            widget.ads[index]
                                                                .category_name,
                                                    style: GoogleFonts.cairo(
                                                        color: Colors.black,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20.sp),
                                                  ),
                                                ),
                                        ),
                                        Flexible(
                                          child: Align(
                                              alignment: Alignment.center,
                                              child: widget.ads[index] == null
                                                  ? Shimmer.fromColors(
                                                      child: Text(''),
                                                      baseColor: Colors.grey
                                                          .withOpacity(.5),
                                                      highlightColor:
                                                          Colors.white)
                                                  : _priceWidget(
                                                      price:
                                                          widget.ads[index].price,
                                                      forSell: widget
                                                          .ads[index].forSell,
                                                    )),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                      flex: 1,
                                      child: widget.ads[index] == null
                                          ? SizedBox(
                                              width:
                                                  .1.sw + Random().nextInt(50),
                                              child: _shimmer(
                                                  width: .05.sw, height: 8.h),
                                            )
                                          : Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: Text(
                                                Languages.of(context)
                                                            .labelSelectLanguage ==
                                                        "English"
                                                    ? widget.ads[index].title
                                                    : widget.ads[index].titleAr,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.cairo(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.black,
                                                    fontSize: 22.0.sp,
                                                    height: 1.2),
                                              ),
                                            )),
                                  Flexible(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Colors.black,
                                                size: 20.sp,
                                              ),
                                              widget.ads[index] == null
                                                  ? SizedBox(
                                                      width: .1.sw +
                                                          Random().nextInt(50),
                                                      child: _shimmer(
                                                          width: .05.sw,
                                                          height: 8.h),
                                                    )
                                                  : widget.ads[index].region
                                                              .name ==
                                                          null
                                                      ? Center()
                                                      : Text(
                                                          (Languages.of(context)
                                                                          .labelSelectLanguage ==
                                                                      "English"
                                                                  ? widget
                                                                      .ads[
                                                                          index]
                                                                      .region
                                                                      .name
                                                                  : widget
                                                                      .ads[
                                                                          index]
                                                                      .region
                                                                      .nameAr)
                                                              .replaceAll(
                                                                  '-', ''),
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              GoogleFonts.cairo(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      17.0.sp,
                                                                  height: 1.2),
                                                        ),
                                            ],
                                          ),
                                          GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedfav = index;
                                                  selectedfav =
                                                      widget.ads[index].id;
                                                  textfavid.text =
                                                      selectedfav.toString();
                                                  favorite = !favorite;

                                                  Res.USER != null
                                                      ? _updateFavorite()
                                                      : Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  RedirectToAuth()));
                                                });
                                              },
                                              child: Icon(
                                                favorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: Colors.transparent,
                                              ))
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                )),
            options: CarouselOptions(
              height: MediaQuery.of(context).size.shortestSide > 700
                  ? 320.0
                  : 260.0,

              enableInfiniteScroll: true,
              viewportFraction:
                  MediaQuery.of(context).size.shortestSide > 700 ? .3 : .60,
              autoPlay: true,
              reverse: true,
              pauseAutoPlayOnTouch: true,
              autoPlayInterval: Duration(seconds: 5),
              //autoPlayAnimationDuration: Duration(milliseconds: 1000)
            ),
          )
        : Container();
  }

  String formatDecimal(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  Widget _shimmer({height: double.infinity, width: double.infinity}) {
    return Shimmer.fromColors(
        child: Container(
          //width: double.infinity,
          color: Colors.grey,
          height: height,
        ),
        baseColor: Colors.grey.withOpacity(.5),
        highlightColor: Colors.white);
  }

  _priceWidget({double price, bool forSell}) {
    return Text(
      price != null
          ? '${NumberFormat('###,###').format(price)} QAR'
          : "                    ",
      //'${formatDecimal(widget.product.price)} QAR'
      style: GoogleFonts.cairo(
          fontSize: 18.0.sp,
          color: Colors.red.withOpacity(.9),
          fontWeight: FontWeight.bold),
      overflow: TextOverflow.ellipsis,
    );
  }
}

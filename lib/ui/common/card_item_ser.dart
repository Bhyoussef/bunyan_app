import 'dart:math';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';

class CardItemService extends StatefulWidget {
  final ServiceModel service;
  final Function onChanged;

  const CardItemService({Key key, this.service, this.onChanged}) : super(key: key);

  @override
  State<CardItemService> createState() => _CardItemServiceState();
}

class _CardItemServiceState extends State<CardItemService> {
  Locale currentLang;
  String _photo = '';

  @override
  void initState() {
    setState(() {
      super.initState();
      if (widget.service.ownerImage != null) {
        setState(() {
          _photo = widget.service.ownerImage;
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
                BoxConstraints(minHeight: 180.h,
                    minWidth: double.infinity),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: CachedNetworkImage(
                      imageUrl: widget.service.photos.isNotEmpty
                          ? 'https://bunyan.qa/images/posts/' +
                          widget.service.photos.first : '',
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
                      errorWidget: (_, __, ___) => Container(
                        width: .1.sh,
                        height: .1.sh,
                        child:
                        Icon(Icons.broken_image_outlined),
                        color: Colors.white,
                      ),
                      fit: BoxFit.cover,
                    width: double.infinity,
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
                        borderRadius: BorderRadius.circular(999999),
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
                              ? widget.service.title
                              : widget.service.titleAr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                              fontSize: 20.0.sp,
                              height: 1.2),
                        ),
                        widget.service.region == null
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
                                    ? widget.service.region.name
                                    : widget.service.region.nameAr).replaceAll('-', ''),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 18.0.sp,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        return Share.share('https://bunyan.qa/property/${widget.service.slug}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.share, size: 25.sp,),
                      ))
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

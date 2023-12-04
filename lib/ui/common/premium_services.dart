import 'dart:math';

import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/ui/services/service_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

class PremiumSrv extends StatelessWidget {
  final List ads;

  const PremiumSrv({Key key, this.ads}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (ads.isNotEmpty) {
      return CarouselSlider.builder(
      itemCount: ads?.length ?? 0,
      itemBuilder: (context, index, realIndex) => InkWell(
          onTap: ads[index] == null ? null : () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ServiceScreen(
                      service: ads[index],
                    )));
          },
          child: Padding(
            padding:  EdgeInsets.all(1.0),
            child: Stack(
                children: [
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
                                child: ads[index] == null
                                    ? _shimmer()
                                    : CachedNetworkImage(
                                  imageUrl:
                                  'https://bunyan.qa/images/posts/' +
                                      ads[index].photos[0],
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            decoration:BoxDecoration(
                                                border:Border.all(
                                                    color: Colors.red

                                                ),
                                                borderRadius: BorderRadius.circular(6.0)
                                            ),
                                            child: ads[index] == null
                                                ? SizedBox(
                                              width: .1.sw +
                                                  Random().nextInt(50),
                                              child: _shimmer(
                                                  width: .05.sw, height: 8.h),
                                            )
                                                :Padding(
                                              padding: const EdgeInsets.all(1.0),
                                              child: Text(
                                                 ads[index].category_name,
                                                style: GoogleFonts.cairo
                                                  (color: Colors.black,fontWeight:
                                                FontWeight.bold,fontSize: 20.sp),),
                                            ),
                                          ),

                                        ],
                                      ),


                                    ],
                                  ),
                                ),

                                Flexible(
                                    flex: 1,
                                    child: ads[index] == null
                                        ? SizedBox(
                                      width: .1.sw +
                                          Random().nextInt(50),
                                      child: _shimmer(
                                          width: .05.sw, height: 8.h),
                                    )
                                        : Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        Languages.of(context)
                                            .labelSelectLanguage ==
                                            "English"
                                            ? ads[index].title
                                            : ads[index].titleAr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black,
                                            fontSize: 18.0.sp,
                                            height: 1.2),
                                      ),
                                    )
                                ),
                                Flexible(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(Icons.location_on,color: Colors.black,size: 20.sp,),
                                        ads[index] == null
                                            ? SizedBox(
                                          width: .1.sw +
                                              Random().nextInt(50),
                                          child: _shimmer(
                                              width: .05.sw, height: 8.h),)
                                            : ads[index].region.name==null?
                                        Center():Text(
                                          Languages.of(context)
                                              .labelSelectLanguage ==
                                              "English"
                                              ? ads[index].region.name.replaceAll('-', '')
                                              : ads[index].region.nameAr.replaceAll('-', ''),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.cairo(
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black,
                                              fontSize: 20.0.sp,
                                              height: 1.2),
                                        ),
                                        Icon(Icons.favorite,color:
                                        Colors.transparent,size: 30.sp,)

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
        height:  MediaQuery.of(context).size.shortestSide > 700 ? 320.0 : 260.0,
        viewportFraction: MediaQuery.of(context).size.shortestSide > 700 ? .3 : .60 ,
        autoPlay: true,
         reverse: true,
        // pauseAutoPlayOnTouch: true,
        // enableInfiniteScroll: true,
        autoPlayInterval: Duration(seconds: 5),
        // autoPlayAnimationDuration: Duration(milliseconds: 800)
      ),
    );
    } else {
      return Container();
    }
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
}

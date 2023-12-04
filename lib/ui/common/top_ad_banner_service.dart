import 'package:bunyan/models/banner.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class TopAdBannerService extends StatelessWidget {
  final List<BannerModel> banners;


  const TopAdBannerService({Key key, this.banners}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: banners.length,
      itemBuilder: (context, index, realIndex) => Container(
        width: 1.sw,
        height: .18.sh,
        child: Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: banners[index] == null ? _shimmer()
                  : CachedNetworkImage(
                imageUrl: 'https://bunyan.qa/images/sliders/${(banners[index].photo)}',
                progressIndicatorBuilder: (_, __, ___) {
                  return _shimmer();
                },
                errorWidget: (_,__, ___) => Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 35.sp,
                  ),
                ),
                fit: BoxFit.fill,
                width: .15.sw,
              )
          ),
        ),
      ),
      options: CarouselOptions(
          height: .18.sh,
          enlargeCenterPage: true,
          autoPlay: true,
          disableCenter: true,
          enableInfiniteScroll: true,
          scrollDirection: Axis.horizontal,
          pauseAutoPlayInFiniteScroll: true,
          pauseAutoPlayOnTouch: true,
          autoPlayCurve: Curves.fastOutSlowIn,
          viewportFraction: .98,
          pauseAutoPlayOnManualNavigate: true,
          autoPlayInterval: Duration(seconds: 5),
          autoPlayAnimationDuration: Duration(milliseconds: 800)
      ),
    );
  }

  Widget _shimmer() {
    return Shimmer.fromColors(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.red,
        ),
        baseColor: const Color(0xFFf3f3f3),
        highlightColor: Colors.white);
  }
}

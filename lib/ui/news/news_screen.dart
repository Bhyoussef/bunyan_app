import 'dart:async';

import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/news.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/news/article_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/widgets/clay_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:share/share.dart';
import 'package:shimmer/shimmer.dart';

class NewsScreen extends StatefulWidget {
  NewsScreen({Key key}) : super(key: key);

  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with RouteAware, RouteObserverMixin {
  ScrollController _scrollController = ScrollController();

  List<NewsModel> _news = [];
  bool _isFetching = true;
  int _currentIndex = 0;
  Locale currentLang;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  _getData() async {
    final data = await ProductsWebService().getNews();
    setState(() {
      _news.addAll(data);
      _isFetching = false;
    });
  }

  @override
  void didPop() {
    Res.bottomNavBarAnimStream.add(true);
    super.didPop();
  }

  @override
  void didPopNext() {
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon:  Icon(Icons.notifications_outlined,size: 40.sp,),
            tooltip: 'Show Snackbar',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NotificationsScreen()));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.language_outlined,size: 40.sp,),
            onSelected: (String result) {
              changeLanguage(context, result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'ar',
                child: Text('العربية',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
              PopupMenuItem<String>(
                value: 'en',
                child: Text('English',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 30.sp,
            ),
          ),
        ),
        title: Text(
          Languages.of(context).news,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 22.0.sp,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: (_news.isNotEmpty && !_isFetching) || _isFetching
          ? SafeArea(
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  controller: _scrollController,
                  itemCount: _isFetching ? 5 : _news.length,
                  itemBuilder: (context, index) => _isFetching
                      ? _shimmerCard()
                      : _news[index].isFeatured
                          ? _featuredNewsItem(index)
                          : _newsItem(index)),
            )
          : Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.list_alt,
                    color: Color(0xffd6d6d6),
                    size: 90.sp,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClayText(
                      Languages.of(context).noNews,
                      style: GoogleFonts.cairo(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      depth: -10,
                      textColor: Color(0xffd6d6d6),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 3.0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: 65,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: BottomNavigationBar(
                selectedLabelStyle:
                    GoogleFonts.cairo(fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.cairo(),
                currentIndex: _currentIndex,
                backgroundColor: Colors.black,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.grey,
                onTap: (index) {
                  print(index);
                  setState(() {
                    _currentIndex = index;
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MainScreen(
                                  menu_index: _currentIndex,
                                )));
                  });
                },
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.home_outlined,
                    ),
                    activeIcon: Icon(Icons.home),
                    label: Languages.of(context).menuHome,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.favorite_outline,
                    ),
                    activeIcon: Icon(Icons.favorite),
                    label: Languages.of(context).menuFavorite,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      FontAwesome.comments,
                      color: Colors.transparent,
                    ),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.chat_outlined,
                    ),
                    activeIcon: Icon(Icons.chat),
                    label: Languages.of(context).productDetailsCallChat,
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person_outline,
                    ),
                    activeIcon: Icon(Icons.person),
                    label: Languages.of(context).menuProfile,
                  ),
                ]),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black,
              child: Icon(FontAwesome.plus),
              onPressed: () => setState(() {}),
            )
          : Container(),
    );
  }

  Widget _shimmerCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      child: Column(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: _shimmerBox(width: double.infinity, height: .3.sh)),
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _shimmerBox(width: .8.sw, height: 15.h),
          ),
          Center(child: _shimmerBox(width: .3.sw, height: 15.h)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: List<int>.generate(5, (index) => index).map((e) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _shimmerBox(
                      width: e < 4 ? double.infinity : .2.sw, height: 8.h),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 50.h,
          )
        ],
      ),
    );
  }

  Widget _shimmerBox({double width, double height}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFf3f3f3),
      highlightColor: const Color(0xFFE8E8E8),
      child: Container(
        height: height,
        width: width,
        color: Colors.grey,
      ),
    );
  }

  Widget _newsItem(int index) {
    final news = _news[index];
    final ltr = Languages.of(context).labelSelectLanguage == 'English';
    final expandStream = StreamController<bool>.broadcast();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 5.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(ltr ? 0.0 : .0),
                      bottomLeft: Radius.circular(ltr ? 0.0 : .0),
                      topRight: Radius.circular(ltr ? 0.0 : 0.0),
                      bottomRight: Radius.circular(ltr ? 0.0 : 0.0),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: news.photo,
                      progressIndicatorBuilder: (_, __, ___) {
                        return _shimmerBox(
                          height: .15.sh,
                          width: .45.sw,
                        );
                      },
                      errorWidget: (_, __, ___) => Container(
                        height: .15.sh,
                        width: .45.sw,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                      height: .30.sh,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            return Share.share(news.url);
                          },
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Icon(
                              Icons.share,
                              size: 30.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              StreamBuilder<bool>(
                  stream: expandStream.stream,
                  initialData: false,
                  builder: (context, snapshot) {
                    final expand = snapshot.data;
                    print(expand);
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 0.0),
                      child: Column(
                        children: [
                          Container(
                            width:double.infinity,
                            decoration:BoxDecoration(
                              color: Colors.grey.withOpacity(.3)

                            ),
                            child: Text(
                              Languages.of(context).labelSelectLanguage ==
                                      'English'
                                  ? news.title
                                  : news.titleArabic,
                              style: GoogleFonts.cairo(
                                  fontSize: 20.sp, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          AnimatedSize(
                            duration: Duration(milliseconds: 100),
                            curve: Curves.easeInOut,
                            child: Container(
                              color: Colors.white,
                              height: expand ? null : 100.0,
                              child: Theme(
                                data: ThemeData(
                                    textTheme: TextTheme(
                                        bodyMedium: GoogleFonts.cairo(
                                            fontSize: 18.sp))),
                                child: Html(
                                  data: Languages.of(context)
                                              .labelSelectLanguage ==
                                          'English'
                                      ? news.description
                                      : news.descAr,
                                  shrinkWrap: true,

                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: .0),
                              child: TextButton(
                                onPressed: () {
                                  print('pressed');
                                  expandStream.add(!expand);
                                },
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      expand
                                          ? Languages.of(context).showLess
                                          : Languages.of(context).showMore,
                                      style: GoogleFonts.cairo(
                                          color: Colors.blue, fontSize: 12.0),
                                    ),
                                    Icon(
                                      expand
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      color: Colors.blue,
                                      size: 13.0,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }

  Widget _featuredNewsItem(int index) {
    final news = _news[index];
    final expandStream = StreamController<bool>.broadcast();
    return Card(
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: news.photo,
                  progressIndicatorBuilder: (_, __, ___) {
                    return _shimmerBox(
                      height: .3.sh,
                    );
                  },
                  errorWidget: (_, __, ___) => Container(
                    height: .3.sh,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.broken_image_outlined),
                  ),
                  height: .3.sh,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
                Positioned(
                  top: 10.0,
                  right: 20.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          print('implement share');
                        },
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          child: Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: .0,
                  left: .0,
                  right: .0,
                  child: Container(
                    color: Colors.blueGrey.withOpacity(.3),
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(horizontal: .1.sw, vertical: 15),
                    child: Text(
                      Languages.of(context).labelSelectLanguage == 'English'
                          ? news.title
                          : news.titleArabic,
                      style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold, fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              ],
            ),
            StreamBuilder<bool>(
                stream: expandStream.stream,
                initialData: false,
                builder: (context, snapshot) {
                  final expand = snapshot.data;
                  return Column(
                    children: [
                      AnimatedSize(
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut,
                        child: Container(
                          color: Colors.white,
                          height: expand ? null : 100.0,
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: .04.sw),
                          child: Html(
                              data: Languages.of(context).labelSelectLanguage ==
                                      'English'
                                  ? news.description
                                  : news.descAr),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: TextButton(
                            onPressed: () {
                              print('pressed');
                              expandStream.add(!expand);
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  expand
                                      ? Languages.of(context).showLess
                                      : Languages.of(context).showMore,
                                  style: TextStyle(color: Colors.blue),
                                ),
                                Icon(
                                  expand
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.blue,
                                )
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
  Widget _firstCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 5.0,
      child: Column(
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: _shimmerBox(width: double.infinity, height: .3.sh)),
          SizedBox(
            height: 20.h,
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _shimmerBox(width: .8.sw, height: 15.h),
          ),
          Center(child: _shimmerBox(width: .3.sw, height: 15.h)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.ltr,
              children: List<int>.generate(5, (index) => index).map((e) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: _shimmerBox(
                      width: e < 4 ? double.infinity : .2.sw, height: 8.h),
                );
              }).toList(),
            ),
          ),
          SizedBox(
            height: 50.h,
          )
        ],
      ),
    );
  }
  Widget _firstnewsItem() {
    final news = _news.first;
    final ltr = Languages.of(context).labelSelectLanguage == 'English';
    final expandStream = StreamController<bool>.broadcast();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Card(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 5.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(ltr ? 0.0 : .0),
                      bottomLeft: Radius.circular(ltr ? 0.0 : .0),
                      topRight: Radius.circular(ltr ? 0.0 : 0.0),
                      bottomRight: Radius.circular(ltr ? 0.0 : 0.0),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: news.photo,
                      progressIndicatorBuilder: (_, __, ___) {
                        return _shimmerBox(
                          height: .15.sh,
                          width: .45.sw,
                        );
                      },
                      errorWidget: (_, __, ___) => Container(
                        height: .15.sh,
                        width: .45.sw,
                        color: Colors.grey.shade200,
                        child: Icon(Icons.broken_image_outlined),
                      ),
                      height: .0.sh,
                      width: MediaQuery.of(context).size.width,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Positioned(
                    top: 10.0,
                    right: 10.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            return Share.share(news.url);
                          },
                          child: Container(
                            padding: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                                color: Colors.black12,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            child: Icon(
                              Icons.share,
                              size: 13.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(.8)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        Languages.of(context).labelSelectLanguage ==
                            'English'
                            ? news.title
                            : news.titleArabic,
                        style: GoogleFonts.cairo(
                            fontSize: 15.0, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.start,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: StreamBuilder<bool>(
                    stream: expandStream.stream,
                    initialData: false,
                    builder: (context, snapshot) {
                      final expand = snapshot.data;
                      print(expand);
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        child: Column(
                          children: [

                            AnimatedSize(
                              duration: Duration(milliseconds: 100),
                              curve: Curves.easeInOut,
                              child: Container(
                                color: Colors.white,
                                height: expand ? null : 50.0,
                                child: Theme(
                                  data: ThemeData(
                                      textTheme: TextTheme(
                                          bodyMedium: GoogleFonts.cairo(
                                              fontSize: 10.0))),
                                  child: Html(
                                    data: Languages.of(context)
                                        .labelSelectLanguage ==
                                        'English'
                                        ? news.description
                                        : news.descAr,
                                    shrinkWrap: true,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: .0),
                                child: TextButton(
                                  onPressed: () {
                                    print('pressed');
                                    expandStream.add(!expand);
                                  },
                                  child: Row(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        expand
                                            ? Languages.of(context).showLess
                                            : Languages.of(context).showMore,
                                        style: GoogleFonts.cairo(
                                            color: Colors.blue, fontSize: 9.0),
                                      ),
                                      Icon(
                                        expand
                                            ? Icons.keyboard_arrow_up_rounded
                                            : Icons.keyboard_arrow_down_rounded,
                                        color: Colors.blue,
                                        size: 13.0,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    }),
              )

            ],
          ),
        ),
      ),
    );
  }
}

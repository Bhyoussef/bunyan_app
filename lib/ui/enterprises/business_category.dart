import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shimmer/shimmer.dart';
import '../../localization/language/languages.dart';
import '../../localization/locale_constant.dart';
import '../../models/businessesmodel.dart';
import '../../tools/res.dart';
import '../../tools/webservices/entreprise/entreprise_api.dart';
import '../main/main_screen.dart';
import '../notifications/notifications_screen.dart';
import 'add_busniss.dart';
import 'enterprises_screen.dart';

class Business_Category extends StatefulWidget {
  const Business_Category({Key key}) : super(key: key);

  @override
  State<Business_Category> createState() => _Business_CategoryState();
}

class _Business_CategoryState extends State<Business_Category>
    with RouteAware, RouteObserverMixin {
  List<Busnisscategory> businesses = [];
  List<Busnisscategory> businessesseconde = [];
  bool _isFetching = true;
  bool _isLoading = false;
  int _currentIndex = 0;

  void initState() {
    super.initState();
    Res.titleStream.add('شركات');

    BusnissApi().getEnterprises().then((busniss) {
      setState(() {
        _isFetching = false;
        businesses = busniss;
        print(businesses);
      });
    });
    BusnissApi().getEnterprisessecond().then((busniss) {
      setState(() {

        businessesseconde = busniss;
        _isFetching = false;
        print(businessesseconde);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
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
              icon: Icon(Icons.language_outlined,size: 40.sp),
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 30.sp),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            Languages.of(context).agencies,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 22.0.sp,
            ),
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
        body:  businesses.isEmpty
            ? Center(
                child: _loadingWidget(),
              )
            : SafeArea(
                child: Stack(children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 30.h),
                    child: Column(
                      textDirection: TextDirection.rtl,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 10.h,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Add_Busniss()));
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: 180.h, minWidth: 300.w),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: CachedNetworkImage(
                                            imageUrl:
                                                'https://bunyan.qa/images/default/business.jpg',
                                            progressIndicatorBuilder:
                                                (_, __, ___) {
                                              return Shimmer.fromColors(
                                                  child: Container(
                                                    //width: double.infinity,
                                                    height:
                                                        Random().nextInt(1) == 1
                                                            ? 480.h
                                                            : 320.h,
                                                    color: Colors.grey,
                                                  ),
                                                  baseColor: Colors.grey
                                                      .withOpacity(.5),
                                                  highlightColor: Colors.white);
                                            },
                                            errorWidget: (_, __, ___) => Icon(
                                                Icons.broken_image_outlined),
                                            fit: BoxFit.cover,
                                            width: 180.w),
                                      ),
                                    ),
                                    SizedBox(height: 10.h,),
                                    Padding(
                                      padding:  EdgeInsets.only(left: 8.w),
                                      child: Text(
                                        'Create Business profile',
                                        maxLines: 1,
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF750606),
                                            fontSize: 25.0.sp,
                                            height: 1.2),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 15.w,
                              ),
                              InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EnterprisesScreen(type: 'Property'),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ConstrainedBox(
                                      constraints: BoxConstraints(
                                          minHeight: 180.h, minWidth: 300.w),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        child: CachedNetworkImage(
                                            imageUrl: 'https://bunyan.qa/images/categories/167592890987.jpg',
                                            progressIndicatorBuilder:
                                                (_, __, ___) {
                                              return Shimmer.fromColors(
                                                  child: Container(
                                                    //width: double.infinity,
                                                    height:
                                                        Random().nextInt(1) == 1
                                                            ? 480.h
                                                            : 320.h,
                                                    color: Colors.grey,
                                                  ),
                                                  baseColor: Colors.grey
                                                      .withOpacity(.5),
                                                  highlightColor: Colors.white);
                                            },
                                            errorWidget: (_, __, ___) => Icon(
                                                Icons.broken_image_outlined),
                                            fit: BoxFit.cover,
                                            width: 180.w),
                                      ),
                                    ),
                                    SizedBox(height: 10.h,),
                                    Padding(
                                      padding:  EdgeInsets.only(left: 8.w),
                                      child: Text(
                                        Languages.of(context)
                                                    .labelSelectLanguage ==
                                                "English"
                                            ? businesses.first.name
                                            : businesses.first.nameAr,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.cairo(
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF750606),
                                            fontSize: 25.0.sp,
                                            height: 1.2),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        /*Padding(
                      padding:
                          EdgeInsets.only(bottom: 10.h, left: 8.h, right: 8.h),
                      child: StaggeredGridView.countBuilder(

                          itemCount: businesses.length,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EnterprisesScreen(
                                        type:'Property'


                                    ),
                                  ),
                                ),
                                child: Container(
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
                                                  imageUrl: 'https://bunyan.qa/images/categories/167592890987.jpg',
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


                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      Languages.of(context)
                                                          .labelSelectLanguage ==
                                                          "English"
                                                          ? businesses[index].name
                                                          : businesses[index].nameAr,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: GoogleFonts.cairo(
                                                          fontWeight: FontWeight.w700,
                                                          color: Color(0xFF750606),
                                                          fontSize: 25.0.sp,
                                                          height: 1.2),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ));
                          })),*/
                        SizedBox(height: 10.h,),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: 10.h, left: 8.h, right: 8.h),
                          child: StaggeredGridView.countBuilder(
                              //childAspectRatio: MediaQuery.of(context).size.width /
                              //  (MediaQuery.of(context).size.height / 1.7),
                              itemCount: businessesseconde.length,
                              physics: NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                              staggeredTileBuilder: (index) =>
                                  StaggeredTile.fit(1),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EnterprisesScreen(
                                          category_id: businessesseconde[index]
                                              .id
                                              .toString()),
                                    ),
                                  ),
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 3.sp, vertical: 3.sp),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      textDirection: TextDirection.rtl,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          children: [
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                  minHeight: 180.h,
                                                  minWidth: double.infinity),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                child: CachedNetworkImage(
                                                    imageUrl:
                                                        'https://bunyan.qa/images/categories/' +
                                                            businessesseconde[
                                                                    index]
                                                                .image,
                                                    progressIndicatorBuilder:
                                                        (_, __, ___) {
                                                      return Shimmer.fromColors(
                                                          child: Container(
                                                            //width: double.infinity,
                                                            height: Random()
                                                                        .nextInt(
                                                                            1) ==
                                                                    1
                                                                ? 480.h
                                                                : 320.h,
                                                            color: Colors.grey,
                                                          ),
                                                          baseColor: Colors.grey
                                                              .withOpacity(.5),
                                                          highlightColor:
                                                              Colors.white);
                                                    },
                                                    errorWidget: (_, __, ___) =>
                                                        Icon(Icons
                                                            .broken_image_outlined),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 1.sw,
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 7),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        Languages.of(context)
                                                                    .labelSelectLanguage ==
                                                                "English"
                                                            ? businessesseconde[
                                                                    index]
                                                                .name
                                                            : businessesseconde[
                                                                    index]
                                                                .nameAr,
                                                        maxLines: 1,
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style:
                                                            GoogleFonts.cairo(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                color: Color(
                                                                    0xFF750606),
                                                                fontSize:
                                                                    25.0.sp,
                                                                height: 1.2),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ])));
  }

  Widget _loadingWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CupertinoActivityIndicator(
          radius: 20.sp,
        ),
        SizedBox(width: 20.w),
        Text(
          Languages.of(context).loader,
          style: GoogleFonts.cairo(
              color: Colors.grey, fontSize: 30.sp, fontWeight: FontWeight.w600),
        )
      ],
    );
  }
}

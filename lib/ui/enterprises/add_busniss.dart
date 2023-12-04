import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../localization/language/languages.dart';
import '../../localization/locale_constant.dart';
import '../../models/businessesmodel.dart';
import '../../tools/webservices/entreprise/entreprise_api.dart';
import '../../tools/webservices/products.dart';
import '../main/main_screen.dart';
import '../notifications/notifications_screen.dart';
import 'create_business.dart';

class Add_Busniss extends StatefulWidget {
  const Add_Busniss({Key key}) : super(key: key);

  @override
  State<Add_Busniss> createState() => _Add_BusnissState();
}

class _Add_BusnissState extends State<Add_Busniss> {
  int _currentIndex = 0;
  bool _isFetching = true;
  List<Busnisscategory> addbusnisscategory = [];
  List<Busnisscategory> addbusnisscategories = [];
  @override
  void initState() {
    super.initState();



    BusnissApi().getcategoriesbusiness().then((entrs) {
      setState(() {

        addbusnisscategory = entrs;
        _isFetching = false;
        print('here youssef$addbusnisscategory');
      });
    });
    BusnissApi().getcategorybusiness().then((entrs) {
      setState(() {

        addbusnisscategories = entrs;
        _isFetching = false;
        print('here youssef$addbusnisscategory');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Show Snackbar',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NotificationsScreen()));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.language_outlined),
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.00),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        /*title: _searchWidget(),*/

        centerTitle: true,
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
      body: addbusnisscategories.isEmpty
          ? Center(
        child: _loadingWidget(),
      )
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text('Select A Category That Define Your Business',
                            style: TextStyle(
                                color: Color(0xFF750606),fontWeight: FontWeight.bold,
                              fontSize: 30.sp
                            ),),
                            SizedBox(height: 10.h,),
                            ClipRRect(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              child: CachedNetworkImage(
                                height: 100.h,
                                  width: 100.w,
                                  imageUrl: 'https://bunyan.qa/images/categories/' +
                                      addbusnisscategory.first.image ,
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
                                 ),
                            ),
                            Text(addbusnisscategory.first.name,style: TextStyle(
                                color: Color(0xFF750606),
                              fontWeight: FontWeight.bold
                            ),),
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        StaggeredGridView.countBuilder(
                          itemCount: addbusnisscategories.length,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0,
                          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateBusiness(
                                    title:addbusnisscategories[index].name,
                                        category_id:addbusnisscategories[index].id.toString()


                                  ),
                                ),
                              ),
                              child: Container(
                                width: 1.sw,
                                height: .13.sw,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    color: Colors.grey[200]),
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 7),
                                    child: Text(
                                      Languages.of(context).labelSelectLanguage ==
                                              "English"
                                          ? addbusnisscategories[index].name
                                          : addbusnisscategories[index].nameAr,
                                      maxLines: 2,
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF750606),
                                          fontSize: 20.0.sp,
                                          height: 1.2),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
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

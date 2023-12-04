/*
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../localization/language/languages.dart';
import '../../localization/locale_constant.dart';
import '../../models/enterprise.dart';
import '../notifications/notifications_screen.dart';
import '../profileInfo.dart';


class EnterpriseDetailScreen extends StatefulWidget {
  final EnterpriseModel enterprise;

  EnterpriseDetailScreen({ this.enterprise});

  @override
  State<EnterpriseDetailScreen> createState() => _EnterpriseDetailScreenState();
}

class _EnterpriseDetailScreenState extends State<EnterpriseDetailScreen> {
  Locale currentLang;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Text(
          Languages.of(context).agencydetails,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 22.0.sp,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: Color(0XFFeeeeee),
        child: NestedScrollView(
            headerSliverBuilder: (context, scrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Color(0XFFeeeeee),
                  expandedHeight: .55.sh,
                  //collapsedHeight: kToolbarHeight,
                  automaticallyImplyLeading: false,
                  flexibleSpace: LayoutBuilder(builder: (context, constraints) {
                    double scale = 1.0;
                    if (constraints.biggest.height <= 290)
                      scale = (constraints.biggest.height - 56) / (290 - 56.0);
                    return Stack(
                      children: [
                        FlexibleSpaceBar(
                          collapseMode: CollapseMode.parallax,
                          background: Padding(
                            padding: EdgeInsets.only(
                                right: 4, left: 4, bottom: .26.sh),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                child: CachedNetworkImage(
                                  imageUrl: 'https://bunyan.qa/images/agencies/' +
                                      widget.enterprise?.photo ??
                                      '',
                                  progressIndicatorBuilder: (_, __, ___) {
                                    return _shimmer(
                                        width: 600.w, height: 400.w);
                                  },
                                  errorWidget: (_, __, ___) => Container(
                                    width: 600.w,
                                    height: 400.w,
                                    child: Icon(Icons.broken_image_outlined),
                                    color: Colors.white,
                                  ),
                                  width: 600.w,
                                  height: 400.w,
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                        ),
                        */
/*Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  child: Icon(
                                    Icons.share,
                                    size: 20,
                                  ),
                                  onTap: () {

                                  },
                                ),
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                            )),*//*

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: AnimatedOpacity(
                            opacity: scale,
                            duration: Duration(seconds: 0),
                            child: Transform.scale(
                              scale: scale,
                              origin: Offset(.0, .2.sh),
                              child: Card(
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                        height: .35.sh,
                                        width: .85.sw,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(20.0),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 25.h, horizontal: 30.w),
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            SizedBox(height: 40),
                                            Text(
                                              widget.enterprise.name,
                                              style: GoogleFonts.cairo(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 28.sp),
                                              textAlign: TextAlign.center,
                                            ),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.email,size: 30.sp,),
                                                SizedBox(width: 10.w,),
                                                Text(
                                                  widget.enterprise.email,
                                                  style: GoogleFonts.cairo(
                                                      fontSize: 20.sp),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.phone,size: 30.sp,),
                                                SizedBox(width: 10.w,),

                                                Text(
                                                  widget.enterprise.phone,
                                                  style: GoogleFonts.cairo(
                                                      fontSize: 20.sp),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            widget.enterprise.address == null?Row():Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(Icons.place,size: 30.sp,),
                                                SizedBox(width: 10.w,),
                                                Flexible(
                                                  child: Text(
                                                    widget.enterprise.address ?? '',
                                                    style: GoogleFonts.cairo(
                                                        fontSize: 20.sp),
                                                    textAlign: TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),

                                          ],
                                        )),

                                    Positioned(
                                        top: -70,
                                        left:
                                        MediaQuery.of(context).size.width *
                                            0.5 -
                                            .075.sw -
                                            60,
                                        child: GestureDetector(
                                          onTap: () {

                                          },
                                          child: ProfileInfo(
                                              'https://bunyan.qa/images/agencies/'+ widget.enterprise.photo,false),
                                        )),
                                    Positioned(
                                      top: -20,
                                      right: currentLang.toString() == 'en'
                                          ? 0
                                          : .85.sw - 40,
                                      child: (widget.enterprise == null &&
                                          _profile == Res.USER)
                                          ? GestureDetector(
                                        child: Container(
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(
                                                      40))),
                                          child: Icon(
                                            Icons.edit,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                        ),
                                      )
                                          : Container(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  }),
                )
              ];
            },
            body: Scaffold(
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
                          //print(index);
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
              floatingActionButton:
              MediaQuery.of(context).viewInsets.bottom == 0
                  ? FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black,
                child: Icon(FontAwesome.plus),
                onPressed: () => setState(() {}),
              )
                  : Container(),
              body: Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        details == false
                            ? Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                details = true;
                              });
                            },
                            child: Text(
                              Languages.of(context).agencydetails + " >>",
                              style: TextStyle(
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp),
                            ),
                          ),
                        )
                            : Container(),
                        details == true
                            ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _moreDescCard(),
                        )
                            : Container(),
                        details == true && widget.enterprise.lng != 0
                            ? Padding(
                          padding:
                          const EdgeInsets.fromLTRB(25, 10, 25, 0),
                          child: Card(
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Languages.of(context)
                                                .adLocation,
                                            style: TextStyle(
                                                fontWeight:
                                                FontWeight.bold,
                                                fontSize: 17.sp),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text("$address2 "
                                              "\n$address1"
                                              "\n$address3")
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 150,
                                      width: 150,
                                      child: GoogleMap(
                                        mapType: MapType.hybrid,
                                        initialCameraPosition:
                                        CameraPosition(
                                          target: LatLng(
                                              widget.enterprise.lat,
                                              widget.enterprise.lng),
                                          zoom: 14.4746,
                                        ),
                                        onMapCreated: (GoogleMapController
                                        controller) {
                                          _controller
                                              .complete(controller);
                                        },
                                        onTap: openMaps,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                            : Container(),
                        details == true
                            ? Padding(
                          padding:
                          const EdgeInsets.fromLTRB(25, 10, 25, 0),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: MaterialButton(
                                  onPressed: () {
                                    launch(
                                        'mailto:${widget.enterprise.email}');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        2, 7, 2, 7),
                                    child: Text(
                                      Languages.of(context).email,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  color: Colors.red,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: MaterialButton(
                                  onPressed: () {
                                    launch(
                                        'tel:${widget.enterprise.phone}');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        2, 7, 2, 7),
                                    child: Text(
                                      Languages.of(context)
                                          .productDetailsCallPhone,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  color: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: MaterialButton(
                                  onPressed: () {
                                    launch(
                                        'https://wa.me/${widget.enterprise.phone}');
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        2, 7, 2, 7),
                                    child: Text(
                                      Languages.of(context)
                                          .productDetailsCallWhats,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  color: Colors.green,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        )
                            : Container(),
                        SizedBox(
                          height: 20,
                        ),

                        Expanded(
                          child: ListView.builder(
                            itemCount: 4,
                            itemBuilder: (BuildContext context, int index) {
                              final product = widget.enterprise.products[index];

                              return ProductItem(
                                product: product,
                              );
                            },
                          ),
                        ),

                        */
/* Padding(
                padding: EdgeInsets.only(bottom: 50.h, left: 20.h, right: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Languages.of(context).related,
                      style:
                      GoogleFonts.cairo(color: Colors.black, fontSize: 30.sp),
                    ),
                    StaggeredGridView.countBuilder(
                        itemCount: 4,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: singleentreprise.length,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return _isFetching
                              ? _shimmerItem(index)
                              : InkWell(
                              onTap: () {
                                   Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProductScreen(
                              product: _products[index],
                            )));
                                Res.titleStream
                                    .add(Languages.of(context).realEstate);
                              },
                              child: Card(
                                elevation: 5,
                                child: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // TODO: Add functionality to change main image
                                      },
                                      child: Image.network(
                                        _images[_selectedImageIndex],
                                        width: double.infinity,
                                        height: 250,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        for (int i = 0; i < _images.length; i++)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedImageIndex = i;
                                              });
                                            },
                                            child: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 8),
                                              width: 70,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: _selectedImageIndex == i
                                                      ? Colors.blue
                                                      : Colors.grey,
                                                  width: 2,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: NetworkImage(_images[i]),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      singleentreprise[index].name?? '',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      singleentreprise[index].name ?? '',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 16),
                                  ],
                                ),
                              )
                          );
                        }),
                  ],
                ),
              )*//*







                      ],
                    ),
                  )),
            )),
      ),
    );
  }

  _shimmerItem(index) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: const Color(0xFFf3f3f3),
                  highlightColor: const Color(0xFFE8E8E8),
                  child: Container(
                    height: index.isOdd ? 380.h : 280.h,
                    width: double.infinity,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  top: .0,
                  left: .0,
                  child: Shimmer.fromColors(
                    baseColor: Color(0xffbfbdbd),
                    highlightColor: const Color(0xFFE8E8E8),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.8),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(20.0))),
                      width: .25.sw,
                      height: 30.h,
                      padding:
                      EdgeInsets.symmetric(vertical: 5.w, horizontal: 25.w),
                    ),
                  ),
                ),
                Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3.0),
                      child: Container(
                        width: 1.sw,
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 20.w, bottom: 20.h, left: 15.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Padding(
                                    padding: EdgeInsets.only(left: 10.w),
                                    child: Shimmer.fromColors(
                                      baseColor: Color(0xffbfbdbd),
                                      highlightColor: const Color(0xFFE8E8E8),
                                      child: Container(
                                        width: .1.sw,
                                        height: 20.h,
                                        color: Colors.grey.withOpacity(.8),
                                      ),
                                    )),
                              ),
                              Icon(
                                Icons.location_pin,
                                color: Colors.white,
                                size: 22.w,
                              ),
                              Shimmer.fromColors(
                                baseColor: Color(0xffbfbdbd),
                                highlightColor: const Color(0xFFE8E8E8),
                                child: Container(
                                  width: .08.sw,
                                  height: 10.h,
                                  color: Colors.grey.withOpacity(.8),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _shimmer({double width, double height}) {
    return Shimmer.fromColors(
        child: Container(
          width: width,
          height: height,
          color: Colors.grey,
        ),
        baseColor: Colors.grey.withOpacity(.5),
        highlightColor: Colors.white);
  }

  Widget _moreDescCard() {
    final desc = Languages.of(context).labelSelectLanguage == "English"
        ? widget.enterprise.description
        : widget.enterprise.description_ar;

    return widget.enterprise.description == null
        ? Center()
        : Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Text(
                Languages.of(context).productDetailsDescrption,
                style: GoogleFonts.cairo(
                    fontSize: 35.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: AnimatedSize(
                duration: Duration(milliseconds: 300),
                child: Html(
                  data: desc.substring(0,
                      _seeAllDesc ? desc.length : min(desc.length, 200)),
                ),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  _seeAllDesc = !_seeAllDesc;
                });
              },
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  _seeAllDesc
                      ? Languages.of(context).showLess
                      : Languages.of(context).showMore,
                  style: GoogleFonts.cairo(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 18.sp),
                ),
              ),
            ),
            SizedBox(
              height: 40.h,
            ),
          ],
        ),
      ),
    );
  }
}
class ProductItem extends StatelessWidget {
  final Products product;

  ProductItem({ this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Text(
            product.description ?? '',
            style: TextStyle(
              fontSize: 16.0,
            ),
          ),
          SizedBox(height: 8.0),
          // Display images list
          SizedBox(
            height: 150.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: product.images.length,
              itemBuilder: (BuildContext context, int index) {
                final image = product.images[index];

                return Container(
                  margin: EdgeInsets.only(right: 8.0),
                  child: Image.network(
                    image.image,
                    fit: BoxFit.cover,
                    width: 150.0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/

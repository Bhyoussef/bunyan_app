import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../localization/language/languages.dart';
import '../../localization/locale_constant.dart';
import '../../models/enterprise.dart';
import '../../models/product_list.dart';
import '../../tools/webservices/entreprise/entreprise_api.dart';
import '../../tools/webservices/products.dart';
import '../main/main_screen.dart';
import '../notifications/notifications_screen.dart';

class Busniss_List_Screen extends StatefulWidget {
  const Busniss_List_Screen({Key key}) : super(key: key);

  @override
  State<Busniss_List_Screen> createState() => _Busniss_List_ScreenState();
}

class _Busniss_List_ScreenState extends State<Busniss_List_Screen> {

  int _currentIndex = 0;
  bool _isFetching = true;
  List<EnterpriseModel> listBusniss = [];


  @override
  void initState() {

    super.initState();
    BusnissApi().getEnterprisesuser().then((busniss) {
      setState(() {
        _isFetching = false;
        listBusniss = busniss;
        print(listBusniss);
      });
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.00),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
        centerTitle: true,
        //title: Text(widget.product.first.title),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
          ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: listBusniss.length,
          itemBuilder: (context, index) {
            final product = listBusniss[index];
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
                                  imageUrl: 'https://bunyan.qa/images/agencies/' +
                                      (product.image.isEmpty
                                          ? ''
                                          : product?.image ??
                                          (product?.image ?? '')),
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
                                  fit: BoxFit.fill,
                                  height: 230.0,
                                  width: double.infinity),
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
                                    Text(
                                      Languages.of(context).labelSelectLanguage ==
                                          "English"
                                          ? product.name
                                          : product.name,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      maxLines: 666,
                                      style: GoogleFonts.cairo(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          fontSize: 18.0,
                                          height: 1.2),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          WidgetSpan(
                                              child: Icon(Icons.phone)),
                                          TextSpan(text: '  ${product.phone}'),
                                        ],
                                      ),
                                    ),
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          WidgetSpan(
                                              child: Icon(Icons.email)),
                                          TextSpan(text: '  ${product.email}'),
                                        ],
                                      ),
                                    ),
                               /*     _textIcon(
                                      icon: Icons.date_range,
                                      text: timeago.format(widget.product.createdAt,
                                          locale: Languages.of(context)
                                              .labelSelectLanguage ==
                                              'English'
                                              ? 'en'
                                              : 'ar'),
                                    ),*/

                                    product.address == null
                                        ? Container()
                                        : Row(
                                      children: [

                                        SizedBox(width: 3),
                                        Flexible(
                                          child: Text(
                                            (Languages.of(context)
                                                .labelSelectLanguage ==
                                                'English'
                                                ?product.address
                                                : product.address)
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
                            /*  widget.product.status==true?Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(5.0)),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3.0, horizontal: 15.0),
                                  child: Text(
                                    widget.product.status
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
                                    widget.product.status
                                        ? Languages.of(context).completedAd
                                        : Languages.of(context).inReviewAds,
                                    style: GoogleFonts.cairo(
                                        color: Colors.white, fontSize: 17.0),
                                  ),
                                ),
                              )*/
                            ],
                          ),
                        ),
                      ),
                      /*Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            _button(
                                text: Languages.of(context).edit,
                                color: Colors.white,
                                onTap: () =>
                                    Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => Scaffold(
                                          body: SingleChildScrollView(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w),
                                              child: widget.product is ProductModel
                                                  ? RealEstatePage(
                                                product: widget.product,
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
                                      'https://bunyan.qa/${widget.product is ProductModel ?
                                      'property' : 'service'}/${widget.product.slug}');
                                }),
                            Flexible(
                              child: _button(
                                  text: Languages.of(context).delete,
                                  color: Colors.red,
                                  onTap: () => _deleteProduct(widget.product)),
                            ),
                          ],
                        ),
                      )*/
                    ],
                  ),
                ),
              ),
            );
          },
        )
          ],
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

  void _deleteProduct(ProductListModel product) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.QUESTION,
      title: 'Do you want to delete?',
      btnOkText: 'Yes',
      btnCancelText: 'No',
      btnOkOnPress: () async {
        await ProductsWebService().deleteProduct(product);

      },
      btnCancelOnPress: () => print(''),
    )..show();
  }

  String formatDecimal(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }
}

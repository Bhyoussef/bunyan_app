import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/favorite.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/common/card_item.dart';
import 'package:bunyan/ui/common/card_item_ser.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:bunyan/ui/product/product_screen.dart';
import 'package:bunyan/ui/redirect_to_auth.dart';
import 'package:bunyan/ui/services/service_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesScreen extends StatefulWidget {
  FavoritesScreen({Key key}) : super(key: key);

  @override
  _FavoritesState createState() => _FavoritesState();
}

class _FavoritesState extends State<FavoritesScreen>
    with RouteAware, RouteObserverMixin {
  FavoriteModel _favs;
  bool _isFetching = true;
  List<ProductModel> _products = [];
  List<ServiceModel> _services = [];

  @override
  void initState() {
    print('user ${Res.USER}');
    super.initState();
    print('_favs');
    Res.titleStream.add('المفضلة');
    _getData();
  }

  _getData() {
    setState(() {
      _isFetching = true;
      _products.clear();
      _services.clear();
    });
    ProductsWebService().getFavorites().then((value) {
      if (value == null) {
        _isFetching = false;
        return;
      }
      setState(() {
        _favs = value;
        _isFetching = false;
        _favs.services.forEach((element) {element.favorite = true;});
        _favs.products.forEach((element) {element.favorite = true;});
        _products.addAll(_favs.products);
        _services.addAll(_favs.services);
      });
    });
  }

  @override
  void didPopNext() {
    Res.titleStream.add('المفضلة');
    super.didPopNext();
    print('to here');
    _getData();
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
          leading: InkWell(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
                height: 45,
                width: 45,
                /* decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 1.5,
                          blurRadius: 1.5,
                        ),
                      ],
                    ),*/
                child: Icon(
                  Icons.menu_outlined,
                  color: Colors.black,
                  size: 25,
                )),
          ),
          centerTitle: true,
          title: InkWell(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => MainScreen()));
            },
            child: Image.asset(
              'assets/logo.min.png',
              height: 40,
              fit: BoxFit.cover,
            ),
          ),
        ),
        body: Res.USER != null
            ? Stack(
                children: [
                  if (!_isFetching &&
                      _products.isEmpty &&
                      _services.isEmpty)
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            color: Color(0xffd6d6d6),
                            size: 90.sp,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ClayText(
                              Languages.of(context).noFavorite,
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
                    )
                  else
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          _productsView(),
                          _servicesView()],
                      ),
                    )
                ],
              )
            : RedirectToAuth(
                destination: 'favourites',
              ));
  }

  Widget _productsView() {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, left: 8.h, right: 8.h),
      child: StaggeredGridView.countBuilder(
          //childAspectRatio: MediaQuery.of(context).size.width /
          //  (MediaQuery.of(context).size.height / 1.7),
          itemCount: _isFetching ? 4 : _products.length,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          staggeredTileBuilder: (index) => StaggeredTile.fit(1),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return _isFetching
                ? _shimmerItem(index)
                : _products.isNotEmpty
                    ? InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductScreen(
                                        product: _products[index],
                                      )));
                          Res.titleStream.add(Languages.of(context).realEstate);
                        },
                        child: CardItem(product: _products[index]),
                      )
                    : Container();
          }),
    );
  }

  Widget _servicesView() {
    return Padding(
        padding: EdgeInsets.only(bottom: 10.h, right: 8.h, left: 8.h),
        child: StaggeredGridView.countBuilder(
            // childAspectRatio: MediaQuery.of(context).size.width /
            //   (MediaQuery.of(context).size.height / 1.7),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _isFetching && _services.isEmpty ? 4 : _services.length,
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
            shrinkWrap: true,
            itemBuilder: (context, index) {
              return _isFetching
                  ? _shimmerItem(index)
                  : InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ServiceScreen(
                                      service: _services[index],
                                    )));
                        //Res.titleStream.add(Languages.of(context).realEstate);
                      },
                      child: CardItemService(service: _services[index]),
                    );
            }));
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

  Widget _shimmerItem(index) {
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
                    height: index.isOdd ? 300.h : 280.h,
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

  void _unsetFavorite({int id, int type}) {
    ProductsWebService().updateFav(id: id, type: type).then((value) {
      if (value != null) {
        setState(() {
          if (type == ProductsWebService.SERVICE) {
            _favs.services.removeWhere((element) => element.id == id);
          } else {
            _favs.products.removeWhere((element) => element.id == id);
          }
        });
      }
    });
  }
}

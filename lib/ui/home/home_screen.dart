import 'dart:async';
import 'dart:ui';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/banner.dart';
import 'package:bunyan/models/passthrough_home.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/models/properties_filter.dart';
import 'package:bunyan/models/real_estate_filter.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/models/service_filter.dart';
import 'package:bunyan/models/services_filter.dart';
import 'package:bunyan/tools/image_loader.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/addresses.dart';
import 'package:bunyan/tools/webservices/advertises.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/common/card_item.dart';
import 'package:bunyan/ui/common/card_item_ser.dart';
import 'package:bunyan/ui/common/premium_ads.dart';
import 'package:bunyan/ui/common/premium_services.dart';
import 'package:bunyan/ui/common/top_ad_banner.dart';
import 'package:bunyan/ui/enterprises/enterprises_screen.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/news/news_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:bunyan/ui/product/product_screen.dart';
import 'package:bunyan/ui/services//service_screen.dart';
import 'package:bunyan/ui/real_estates/real_estates_screen.dart';
import 'package:bunyan/ui/services/services_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_launch/flutter_launch.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/Furnish.dart';
import '../../models/category.dart';
import '../../models/city.dart';
import '../../pay.dart';
import '../../sadad/sadadpayment.dart';
import '../../sadad/webviewtest2.dart';
import '../common/top_ad_banner_service.dart';
import '../enterprises/business_category.dart';
import '../paymentpayment/payhtmlinitiate.dart';


class HomeScreen extends StatefulWidget {
  final PassthroughHome passthrough;
  final RealEstatesPassThrough data;
  final ServicesPassThrough dataservice;

  HomeScreen(
      {Key key,
      bool showVerifMail,
      this.passthrough,
      this.dataservice,
      this.data})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with RouteAware, RouteObserverMixin {
  bool isLoading;
  List<ProductModel> _products = [];
  List<ProductModel> _productsPremium = [];
  List<ProductModel> _productsSearch = [];
  List<ServiceModel> _services = [];
  List<ServiceModel> _servicesPremium = [];
  List<ServiceModel> _servicesSearch = [];
  List<BannerModel> _banners = [];
  List<BannerModel> _banners_services = [];
  List<CategoryModel> _cats = [];
  List<CategoryModel> _cats_service = [];
  List<ProductListModel> services = [];
  CategoryModel _selectedCategory;
  List<ProductListModel> _realEstatesSearch;
  PropertiesFilterModel filter;
  ServicesFilterModel service_filter;
  // List<ProductListModel> servicesSearch;
  int realEstatesLength = 10;
  int servicesLength = 10;
  int pageProduct = 0;
  int pageService = 0;
  String isSelected = 'R';
  bool err = false;
  String msgErr = '';
  Locale currentLang;
  bool _isLoading = true;
  bool _stillFetch = true;
  String region;
  String serviceId;

  bool _isFetching = true;
  bool favorite = false;
  TextEditingController txt = TextEditingController();
  int selectedfav = 0;
  int searchPage = 0;
  int page = 0;

  RealEstatesPassThrough _realEstatesPassThrough;
  ServicesPassThrough _servicesPassThrough;

  bool fetchingMoreRealEstate = false;
  bool fetchingMoreService = false;
  bool showMoreStatus = false;

  ScrollController _scrollController = ScrollController();
  RealEstateFilterModel _filter = RealEstateFilterModel();

  ServicesFilter _service_filter = ServicesFilter();
  GlobalKey<FormFieldState> _key = new GlobalKey();
  GlobalKey<FormFieldState> _key_service = new GlobalKey();

  bool isLoadingSearch = false;
  Locale _locale;
  bool allowed = false;
  String query = '';
  TextEditingController _searchController = TextEditingController();
  List<RegionModel> regions = [];
  List<CityModel> cities = [];
  List<Furnish> furnishes = [
    Furnish(name: "Fully Furnished", id: true, name_ar: 'جميع المفروشات'),
    Furnish(name: "Semi Furnished", id: false, name_ar: 'مفروش جزئيا'),
    Furnish(name: "Unfurnished", id: true, name_ar: 'غير مفروش'),
  ];

  String regionId;
  String cityId;
  String city;
  String categoryId;
  int rooms;
  int baths;
  double priceFrom;
  double priceTo;
  String furnished;

  @override
  void initState() {
    getregion();
    getData4();

    _getRealEstatesData();
    _getServicesData();
    if (widget.dataservice == null) {
      _stillFetch = true;
      isLoading = true;
      getData3();
    } else {
      setState(() {
        _isFetching = false;
        Res.catgories = widget.dataservice.categories;
        _cats_service = widget.dataservice.categories;
      });
    }
    if (widget.data == null) {
      getData2();
      _stillFetch = true;
      isLoading = true;
    } else {
      setState(() {
        _cats = widget.data.cats;
        print(_cats);
      });
      Provider.of<CityBasket>(context, listen: false).cities =
          widget.data.cities;
    }
    if (widget.passthrough == null) {
      _isFetching = true;
      _isLoading = true;
      getData();
    } else {
      _isFetching = false;
      _isLoading = false;
      _products = widget.passthrough.products;
      _services = widget.passthrough.services;
      _servicesPremium = widget.passthrough.premiumServices;
      _productsPremium = widget.passthrough.premiumProducts;
      _banners = widget.passthrough.banners;
      _banners_services = widget.passthrough.serviceBanners;
      _loadImages();
    }

    super.initState();
  }

  getregion() {
    AddressesWebService().getRegions().then((rgs) {
      setState(() {
        regions = rgs;
        print('regions is youssef  ${regions.length}');
      });
    });
  }

  getCities(int regionSelected) async {
    AddressesWebService().getCities(regionSelected).then((cts) {
      setState(() {
        Provider.of<CityBasket>(context, listen: false).affectCities(cts);
        cities = cts;
        print(cities);
      });
    });
  }

  getData2() async {
    final futures = await Future.wait([
      ProductsWebService().getCategories(currentLang.toString()),
    ]);
    setState(() {
      _cats = futures[0];

      isLoading = false;
    });
  }

  getData3() async {
    final futures = await Future.wait([
      ProductsWebService().getServicesCategories(currentLang.toString()),
      //ProductsWebService().getServices(filter: ServicesFilterModel(promoted: true)),
    ]);
    setState(() {
      Res.servicesCategories = futures[0];
      _cats_service = futures[0];

      isLoading = false;
    });
  }

  getData4() async {
    final futures = await Future.wait([
      AdvertisesWebService().getCities()

      ,]);

    setState(() {
      Provider.of<CityBasket>(context, listen: false).cities = futures[0];
      print(futures);


    });

  }

  mockFetch() async {
    if (allowed) {
      return;
    }
    setState(() {
      isLoadingSearch = true;
    });

    await Future.delayed(Duration(milliseconds: 500));
    // List<ServiceListModel> newData = _services.length >= 60 ? [] :List.generate(20, (index) => )
  }

  StreamSubscription<Map> streamSubscription;
  StreamController<String> controllerData = StreamController<String>();
  StreamController<String> controllerInitSession = StreamController<String>();
  StreamController<String> controllerUrl = StreamController<String>();

  moreRealEstate() async {
    setState(() {
      fetchingMoreRealEstate = true;
    });
    if (realEstatesLength < _products.length) {
      setState(() {
        realEstatesLength = realEstatesLength + 10;
        fetchingMoreRealEstate = false;
      });
    } else {
      fetchingMoreRealEstate = false;
    }
  }

  moreService() async {
    setState(() {
      fetchingMoreService = true;
    });
    if (servicesLength < _services.length) {
      setState(() {
        servicesLength = servicesLength + 10;
        fetchingMoreService = false;
      });
    } else {
      fetchingMoreService = false;
    }
  }

  getData() async {
    bool fetchedPremium = false;
    bool fetchedProds = false;
    bool fetchedServices = false;
    bool fetchedBS = false;
    bool fetchedB = false;

    AdvertisesWebService().getHomeData().then((value) {
      final List properties = value['properties'];
      final List services = value['services'];
      setState(() {
        _productsPremium =
            properties.map((e) => ProductModel.fromJson(e)).toList();
        _servicesPremium =
            services.map((e) => ServiceModel.fromJson(e)).toList();
        fetchedPremium = true;
        _isFetching =
            !(fetchedProds && fetchedServices && fetchedBS && fetchedB);
      });
    });
    ProductsWebService().getTop10(page: pageProduct).then((value) {
      _products = value;
      setState(() {
        fetchedProds = true;
        _isFetching =
            !(fetchedPremium && fetchedServices && fetchedBS && fetchedB);
      });
    });

    ProductsWebService().getServices(page: pageService).then((value) {
      _services = value;
      setState(() {
        fetchedServices = true;
        _isFetching =
            !(fetchedPremium && fetchedProds && fetchedBS && fetchedB);
      });
    });

    AdvertisesWebService().getBannersService(2).then((value) {
      setState(() {
        _banners_services = value;
        fetchedBS = true;
        _isFetching =
            !(fetchedPremium && fetchedProds && fetchedServices && fetchedB);
      });
    });

    AdvertisesWebService().getBanners(1).then((value) {
      setState(() {
        _banners = value;
        fetchedB = true;
        _isFetching =
            !(fetchedPremium && fetchedProds && fetchedServices && fetchedBS);
      });
    });

    _loadImages();

    setState(() {
      // _products = futures[0];
      // _services = futures[1];
      // _banners_services = futures[3];
      // _region = futures[4];
      _isLoading = false;
    });
  }

  getCurrentLang() async {
    getLocale().then((locale) {
      setState(() {
        currentLang = locale;
        getData();
      });
    });
  }

  _scrollListener() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse)
      Res.bottomNavBarAnimStream.add(false);
    else
      Res.bottomNavBarAnimStream.add(true);

    if (_scrollController.position.pixels <
            _scrollController.position.maxScrollExtent - 60.0 &&
        !_isFetching) {
      _filter.page++;
      getData();
    }
  }

  @override
  void didPop() {
    Res.bottomNavBarAnimStream.add(true);
    super.didPop();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_scrollListener);
  }

  // void _filterData() {
  //   setState(() {
  //     isLoadingSearch = true;
  //   });
  //   ProductsWebService().getHomeProducts(filter: _filter).then((value) {
  //     setState(() {
  //       _products.removeRange(0, _products.length);
  //       _products.addAll(value);
  //       //_services.removeRange(0, _services.length);
  //       //_services.addAll(value);
  //       isLoadingSearch = false;
  //     });
  //   }).catchError((err) {
  //     isLoadingSearch = false;
  //   });
  // }

  // void _servicesData() {
  //   setState(() {
  //     isLoadingSearch = true;
  //   });
  //   ProductsWebService().getHomeServices(filter: _service_filter).then((value) {
  //     setState(() {
  //       _services.removeRange(0, _services.length);
  //       _services.addAll(value);
  //       //_services.removeRange(0, _services.length);
  //       //_services.addAll(value);
  //       isLoadingSearch = false;
  //     });
  //   }).catchError((err) {
  //     isLoadingSearch = false;
  //   });
  // }

  @override
  void didPopNext() {
    Res.titleStream.add('الرئيسية');
    super.didPopNext();
  }

  @override
  void didPush() {
    super.didPush();
    Res.titleStream.add('الرئيسية');
  }

  @override
  Widget build(BuildContext context) {
    //Future.delayed(Duration.zero, () => showAlert(context));
    return !_isLoading
        ? Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon:  Icon(Icons.notifications_outlined,size: 40.sp,),
                  tooltip: 'Show Snackbar',
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PaymentScreentest2()));
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.language_outlined,size: 40.sp),
                  onSelected: (String result) {
                    changeLanguage(context, result);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'ar',
                      child: Text('العربية',
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    ),
                    PopupMenuItem<String>(
                      value: 'en',
                      child: Text('English',
                          style:
                              GoogleFonts.cairo(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              centerTitle: true,
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
            body:
                SafeArea(
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
                      Padding(
                          padding: EdgeInsets.only(
                              bottom: 10.h, left: 0.h, right: 0.h),
                          child: _searchWidget()),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: _categoriesList(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Banner',
                              style: GoogleFonts.cairo(
                                  color: Color(
                                    0xFF750606,
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.sp),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: TopAdBanner(
                          banners: (_banners ?? []).isNotEmpty
                              ? _banners
                              : List.generate(3, (index) => null),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Properties',
                              style: GoogleFonts.cairo(
                                  color: Color(0xFF750606),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.sp),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: PremiumAds(
                          ads: _productsPremium.isNotEmpty
                              ? _productsPremium
                              : List.generate(10, (index) => null),
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Divider(
                            color: Color(0xFF750606),
                            thickness: 2,
                          )),
                      Padding(
                        padding: EdgeInsets.only(left: 12.h, bottom: 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Real Estate Category',
                              style: GoogleFonts.cairo(
                                  color: Color(0xFF750606),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28.sp),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4.h, bottom: 0.h),
                        child: _categories(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12.h, bottom: 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Real Estate',
                              style: GoogleFonts.cairo(
                                  color: Color(0xFF750606),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28.sp),
                            ),
                          ],
                        ),
                      ),

                      // Padding(
                      //     padding: EdgeInsets.only(
                      //         bottom: 10.h, left: 0.h, right: 0.h),
                      //     child: _searchWidget()
                      // ),

                      (_productsSearch?.isNotEmpty ?? false) &&
                              query.isNotEmpty &&
                              _servicesSearch.isEmpty
                          ? Center(
                              child: Text(Languages.of(context).noAds),
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10.h, left: 8.h, right: 8.h),
                              child: StaggeredGridView.countBuilder(
                                  //childAspectRatio: MediaQuery.of(context).size.width /
                                  //  (MediaQuery.of(context).size.height / 1.7),
                                  itemCount: _isFetching
                                      ? 4
                                      : (_productsSearch?.isNotEmpty ?? false
                                          ? _productsSearch.length
                                          : query.isEmpty
                                              ? (_products.length >= 2
                                                  ? _products.length
                                                  : 0)
                                              : 0),
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  staggeredTileBuilder: (index) =>
                                      StaggeredTile.fit(1),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return _isFetching
                                        ? _shimmerItem(index)
                                        : _productsSearch?.isNotEmpty ?? false
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ProductScreen(
                                                                product:
                                                                    _productsSearch[
                                                                        index],
                                                              )));
                                                  Res.titleStream.add(
                                                      Languages.of(context)
                                                          .realEstate);
                                                },
                                                child: CardItem(
                                                    product:
                                                        _productsSearch[index]),
                                              )
                                            : _products.isNotEmpty
                                                ? InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ProductScreen(
                                                                    product:
                                                                        _products[
                                                                            index],
                                                                  )
                                                          )
                                                      );
                                                      Res.titleStream.add(
                                                          Languages.of(context)
                                                              .realEstate);
                                                    },
                                                    child: CardItem(
                                                        product:
                                                            _products[index]),
                                                  )
                                                : Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20),
                                                    child: Text(
                                                      Languages.of(context)
                                                          .redirectToAuthMessage,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  );
                                  }),
                            ),
                      if (fetchingMoreRealEstate)
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ))
                      else
                        TextButton(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(20)),
                              child: Text(
                                Languages.of(context).showMore,
                                style: TextStyle(
                                    color: Color(0xFF750606),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 30.sp),
                              )),
                          onPressed: () {
                            setState(() {
/*
                              pageProduct++;
                              showMoreDataProperty(pageProduct);*/

                              if (filter != null)
                                pageProduct++;
                              else
                                page++;
                              showMoreData(filter != null ? pageProduct : page);
                            });
                          },
                        ),
                      Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Divider(
                            color: Color(0xFF750606),
                            thickness: 2,
                          )),
                      Padding(
                        padding: EdgeInsets.only(left: 12.h, bottom: 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Banner',
                              style: GoogleFonts.cairo(
                                  color: Color(0xFF750606),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.sp),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 10.h, top: 10.h),
                        child: TopAdBannerService(
                          banners: (_banners_services ?? []).isNotEmpty
                              ? _banners_services
                              : List.generate(10, (index) => null),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 12.h, bottom: 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Premium Services',
                              style: GoogleFonts.cairo(
                                  color: Color(0xFF750606),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25.sp),
                            ),
                          ],
                        ),
                      ),
                      if (query.isEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: PremiumSrv(
                            ads: _services.isNotEmpty
                                ? _services
                                : List.generate(20, (index) => null),
                          ),
                        ),
                      Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Divider(
                            color: Color(0xFF750606),
                            thickness: 2,
                          )),
                      Padding(
                        padding: EdgeInsets.only(left: 12.h, bottom: 10.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Service Category',
                              style: GoogleFonts.cairo(
                                  color: Color(0xFF750606),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28.sp),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                          padding: EdgeInsets.only(left: 0.h),
                          child: _categories_service()),
                      Padding(
                        padding: EdgeInsets.only(left: 12.h, bottom: 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'SERVICES',
                              style: GoogleFonts.cairo(
                                  color: Color(0xFF750606),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28.sp),
                            ),
                          ],
                        ),
                      ),
                      (_servicesSearch?.isNotEmpty ?? false) && query.isNotEmpty
                          ? Center(
                              child: Text(Languages.of(context).noAds),
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10.h, left: 8.h, right: 8.h),
                              child: StaggeredGridView.countBuilder(
                                  //childAspectRatio: MediaQuery.of(context).size.width /
                                  //  (MediaQuery.of(context).size.height / 1.7),
                                  itemCount: _isFetching
                                      ? 4
                                      : (_servicesSearch?.isNotEmpty ?? false
                                          ? _servicesSearch.length
                                          : query.isEmpty
                                              ? (_services.length >= 2
                                                  ? _services.length
                                                  : 0)
                                              : 0),
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  staggeredTileBuilder: (index) =>
                                      StaggeredTile.fit(1),
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return _isFetching
                                        ? _shimmerItem(index)
                                        : _servicesSearch?.isNotEmpty ?? false
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              ServiceScreen(
                                                                service:
                                                                    _servicesSearch[
                                                                        index],
                                                              )));
                                                },
                                                child: CardItemService(
                                                    service:
                                                        _servicesSearch[index]),
                                              )
                                            : _services.isNotEmpty
                                                ? InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  ServiceScreen(
                                                                    service:
                                                                        _services[
                                                                            index],
                                                                  )));
                                                      Res.titleStream.add(
                                                          Languages.of(context)
                                                              .service);
                                                    },
                                                    child: CardItemService(
                                                        service:
                                                            _services[index]),
                                                  )
                                                : Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 20),
                                                    child: Text(
                                                      Languages.of(context)
                                                          .redirectToAuthMessage,
                                                      style: GoogleFonts.cairo(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  );
                                  }),
                            ),
                      fetchingMoreService
                          ? Center(
                              child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ))
                          : TextButton(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Text(
                                    Languages.of(context).showMore,
                                    style: TextStyle(
                                        color: Color(0xFF750606),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30.sp),
                                  )),
                              onPressed: () {
                                setState(() {
                                  /*       pageService++;
                                  showMoreDataServices(pageService);*/
                                  if (service_filter != null)
                                    pageService++;
                                  else
                                    page++;
                                  showMoreDataService(service_filter != null
                                      ? pageService
                                      : page);
                                });
                              },
                            )
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 5,
                bottom: 5,
                child: InkWell(
                  onTap: () {
                    whatsAppOpen();
                  },
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                          color: Colors.green.withOpacity(0.75),
                          child: Padding(
                            padding: EdgeInsets.all(20.h),
                            child: Icon(
                              CupertinoIcons.phone_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                          ))),
                ),
              ),
            ])))
        : Center(
            child: LoadingBouncingGrid.square(
              backgroundColor: Color(0xffd6d6d6),
              size: 100.sp,
            ),
          );
  }

  void showMoreDataProperty(int page) {
    setState(() {
      fetchingMoreRealEstate = true;
    });
    ProductsWebService().getTop10(page: page, filter: filter).then((value) {
      print(value.toString() + ' dadadadad');
      setState(() {
        if (filter != null)
          _productsSearch.addAll(value);
        else
          _products.addAll(value);
        //_productsSearch.addAll(value);
        fetchingMoreRealEstate = false;
      });
    }).catchError((err) {});
  }

  void showMoreData(int page) {
    setState(() {
      fetchingMoreRealEstate = true;
    });
    ProductsWebService().getTop10(page: page, filter: filter).then((value) {
      setState(() {
        _isFetching = false;
        if (filter != null)
          _productsSearch.addAll(value);
        else
          _products.addAll(value);
        fetchingMoreRealEstate = false;
      });
    }).catchError((err) {
      _isFetching = false;
      _stillFetch = false;
    });
  }

  void showMoreDataService(int page) {
    setState(() {
      fetchingMoreService = true;
    });
    ProductsWebService()
        .getServices(page: page, filter: service_filter)
        .then((value) {
      setState(() {
        _isFetching = false;
        if (service_filter != null)
          _servicesSearch.addAll(value);
        else
          _services.addAll(value);
        fetchingMoreService = false;
      });
    }).catchError((err) {
      _isFetching = false;
      _stillFetch = false;
    });
  }

  void showMoreDataServices(int page) {
    setState(() {
      fetchingMoreService = true;
    });
    ProductsWebService().getServices(page: page).then((value) {
      setState(() {
        _services.addAll(value);
        fetchingMoreService = false;
      });
    }).catchError((err) {});
  }

  void showAlert(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
              content: Container(
                height: 300.h,
                width: 400.w,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Languages.of(context).shareapp,
                        style: TextStyle(
                            fontSize: 25.0.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        Languages.of(context).shaareapp,
                        style: TextStyle(
                            fontSize: 25.0.sp, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                            onPressed: () => null,
                            icon: Image.asset("assets/Facebook.png"),
                          ),
                          IconButton(
                            onPressed: () => null,
                            icon: Image.asset(
                              "assets/Twitter.png",
                            ),
                          ),
                          IconButton(
                            onPressed: () => null,
                            icon: Image.asset("assets/Instagram.png"),
                          ),
                          IconButton(
                            onPressed: () => null,
                            icon: Image.asset("assets/Whatsapp.png"),
                          ),
                          IconButton(
                            onPressed: () => null,
                            icon: Image.asset("assets/More.png"),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 20.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ButtonTheme(
                              minWidth: 400.w,
                              height: 45.h,
                              child: TextButton(
                                child: Text(
                                  Languages.of(context).later,
                                  style: TextStyle(
                                      fontSize: 20.0.sp,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red.shade900),
                                ),
                                style: ButtonStyle(
                                    side: MaterialStateProperty.all<BorderSide>(
                                        BorderSide(
                                            color: Colors.red.shade900,
                                            style: BorderStyle.solid,
                                            width: 2.0))),
                                onPressed: () => Navigator.pop(context),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget _categories() {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: _cats
                .map((cat) => InkWell(
                      onTap: () {
                        setState(() {
                          if (_selectedCategory == cat) {
                            setState(() {
                              _productsSearch = null;
                              filter = null;
                              _selectedCategory = null;
                              searchPage = 0;
                            });
                          } else {
                            _selectedCategory = cat;
                            _filterProducts(
                                PropertiesFilterModel(category: cat.name));
                          }
                        });
                        getData();
                        _stillFetch = false;
                        print('yussef  $cat');
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          children: [
                            Container(
                                width: 170.w,
                                height: 140.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                  border: _selectedCategory == cat
                                      ? Border.all(color: Colors.blue)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0.0, 3.0), //(x,y)
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (rect) {
                                        return const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.transparent
                                          ],
                                        ).createShader(Rect.fromLTRB(
                                            0, 60, rect.width, rect.height));
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              'https://bunyan.qa/images/categories/' +
                                                  cat.photo,
                                          progressIndicatorBuilder:
                                              (_, __, ___) => _shimmer(
                                                  width: 160.w, height: 150.w),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          end: Alignment.topCenter,
                                          begin: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            SizedBox(
                              height: 5.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.5),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Wrap(
                                  children: [
                                    Center(
                                      child: Text(
                                        Languages.of(context)
                                                    .labelSelectLanguage ==
                                                "English"
                                            ? cat.name
                                            : cat.arabicName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize: 20.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.h,
                                    ),
                                    Center(
                                      child: Text(
                                        cat.properties_count.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade900,
                                            fontSize: 20.sp),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _categories_service() {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: _cats_service
                .map((cat) => InkWell(
                      onTap: () {
                        setState(() {
                          if (_selectedCategory == cat) {
                            setState(() {
                              _servicesSearch = null;
                              service_filter = null;
                              _selectedCategory = null;
                              searchPage = 0;
                            });
                          } else {
                            _selectedCategory = cat;
                            _filterServices(
                                ServicesFilterModel(category: cat.name));
                          }
                        });

                        getData();
                        _stillFetch = false;
                        print("youssef ${cat.name})");
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          children: [
                            Container(
                                width: 170.w,
                                height: 140.h,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                  border: _selectedCategory == cat
                                      ? Border.all(color: Colors.blue)
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      offset: const Offset(0.0, 3.0), //(x,y)
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ShaderMask(
                                      shaderCallback: (rect) {
                                        return const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white,
                                            Colors.transparent
                                          ],
                                        ).createShader(Rect.fromLTRB(
                                            0, 60, rect.width, rect.height));
                                      },
                                      blendMode: BlendMode.dstIn,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl:
                                              'https://bunyan.qa/images/categories/' +
                                                  cat.photo,
                                          progressIndicatorBuilder:
                                              (_, __, ___) => _shimmer(
                                                  width: 160.w, height: 150.w),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: LinearGradient(
                                          end: Alignment.topCenter,
                                          begin: Alignment.bottomCenter,
                                          colors: [
                                            Colors.white.withOpacity(0.3),
                                            Colors.white.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                            SizedBox(
                              height: 5.h,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.5),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Wrap(
                                  children: [
                                    Center(
                                      child: Text(
                                        Languages.of(context)
                                                    .labelSelectLanguage ==
                                                "English"
                                            ? cat.name
                                            : cat.arabicName,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                            fontSize: 20.sp),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5.h,
                                    ),
                                    Center(
                                      child: Text(
                                        cat.services_count.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade900,
                                            fontSize: 20.sp),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }

  Widget _shimmer({double width, double height}) {
    return Shimmer.fromColors(
      child: Container(
        width: 180,
        height: 170,
        color: Colors.grey,
      ),
      baseColor: const Color(0xFFf3f3f3),
      highlightColor: const Color(0xFFE8E8E8),
    );
  }

  Widget _categoriesList() {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      RealEstatesScreen(data: _realEstatesPassThrough))),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[350],
                ),
                width: 150.w,
                height: 50.h,
                child: Text(
                  Languages.of(context).realEstate,
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.w700,
                    fontSize: 20.0.sp,
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: .02.sw),
                margin: EdgeInsets.symmetric(horizontal: .02.sw),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      ServicesScreen(data: _servicesPassThrough))),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[350],
                ),
                width: 150.w,
                height: 50.h,
                child: Text(
                  "  " + Languages.of(context).services + "  ",
                  style: GoogleFonts.cairo(
                      fontSize: 20.0.sp, fontWeight: FontWeight.w700),
                ),
                padding: EdgeInsets.symmetric(horizontal: .02.sw),
                margin: EdgeInsets.symmetric(horizontal: .02.sw),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => Business_Category())),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[350],
                ),
                width: 150.w,
                height: 50.h,
                child: Text(
                  "  " + Languages.of(context).agencies + " ",
                  style: GoogleFonts.cairo(
                      fontSize: 20.0.sp, fontWeight: FontWeight.w700),
                ),
                padding: EdgeInsets.symmetric(horizontal: .02.sw),
                margin: EdgeInsets.symmetric(horizontal: .02.sw),
              ),
            ),
            InkWell(
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => NewsScreen())),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[350],
                ),
                width: 150.w,
                height: 50.h,
                child: Text(
                  Languages.of(context).news,
                  style: GoogleFonts.cairo(
                      fontSize: 20.0.sp, fontWeight: FontWeight.w700),
                ),
                padding: EdgeInsets.symmetric(horizontal: .02.sw),
                margin: EdgeInsets.symmetric(horizontal: .02.sw),
              ),
            )
          ],
        ),
      ),
    );
  }

  void whatsAppOpen() async {
    bool whatsapp = await FlutterLaunch.hasApp(name: "whatsapp");
    String _phone = '+97444440119';
    if (whatsapp) {
      await FlutterLaunch.launchWhatsapp(
          phone: _phone,
          message:
              "Hello, I’m looking for a property/service, can you help...");
    } else {
      setState(() {
        err = false;
        msgErr = '';
      });
      launch('https://wa.me/' + _phone);
    }
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

  searchProducts() {
    _productsSearch.clear();

    if (Languages.of(context).labelSelectLanguage == 'English') {
      setState(() {
        _productsSearch = _products.where((product) {
          final titleLower = product.title.toLowerCase();

          return titleLower.contains(this.query.toLowerCase());
        }).toList();
        _servicesSearch = _services.where((service) {
          final titleLower = service.title.toLowerCase();

          return titleLower.contains(this.query.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        _productsSearch = _products.where((product) {
          final titleLower = product.titleAr.toLowerCase();

          return titleLower.contains(this.query.toLowerCase());
        }).toList();
        _servicesSearch = _services.where((service) {
          final titleLower = service.titleAr.toLowerCase();

          return titleLower.contains(this.query.toLowerCase());
        }).toList();
      });
    }
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

  Widget _searchWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SizedBox(
        height: 50.h,
        child: Row(
          children: [
            Expanded(
              flex: 9,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    query = value;
                    searchProducts();
                  });
                },
                cursorHeight: 26,
                cursorColor: Colors.black,
                enabled: true,
                style: GoogleFonts.cairo(fontSize: 26.sp),
                decoration: InputDecoration(
                    prefixIcon: Container(
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                          size: 25.sp,
                      ),
                    ),
                    border: InputBorder.none,
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide(color: Colors.red)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(color: Colors.black)),
                    suffixIcon: query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _productsSearch.clear();
                                query = '';
                                _searchController.text = '';

                                // return ListView.builder(
                                //     itemBuilder: (context, index) => ListTile(
                                //           leading: Text(
                                //               _region[index].name.toString(),style: TextStyle(color: Colors.black),),
                                //           title: Text(_region[index]
                                //               .ads_nbr
                                //               .toString()),
                                //         ),
                                //   itemCount: _region.length,
                                // );
                              });
                            },
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topLeft: (Radius.circular(
                                        _locale.toString() == 'ar' ? 8 : 8)),
                                    bottomLeft: (Radius.circular(
                                        _locale.toString() == 'ar' ? 8 : 8)),
                                    topRight: (Radius.circular(
                                        _locale.toString() == 'ar' ? 8 : 8)),
                                    bottomRight: (Radius.circular(
                                        _locale.toString() == 'ar' ? 8 : 8)),
                                  ),
                                  //color: Colors.black,
                                ),
                                child: Icon(
                                  Icons.close,
                                  //color: Colors.black87,
                                  size: 24,
                                )),
                          )
                        : Container(),
                    suffixIconConstraints: BoxConstraints(
                        minWidth: 60, minHeight: 40, maxWidth: 60),
                    contentPadding:
                        EdgeInsets.only(top: 0, left: 20.w, right: 20),
                    hintStyle: GoogleFonts.cairo(
                        color: Colors.black38, fontSize: 25.0.sp),
                    hintText: Languages.of(context).search),
              ),
            ),
            Expanded(
                flex: 1,
                child: GestureDetector(
                    onTap: () {
                      _showFilterDialog();
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 6.0),
                      child: Image.asset("assets/filter.png",height: 60.sp,),
                    )))
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    GlobalKey<FormState> formKeyservice = GlobalKey<FormState>();
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        final filter = PropertiesFilterModel();
        final service_filter = ServicesFilterModel();
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 35,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.4),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              topLeft: Radius.circular(5))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Languages.of(context).advsearoption,
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(1000)),
                            child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {});
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          InkWell(
                              onTap: () {
                                setState(() {
                                  isSelected = 'R';

                                });
                              },
                              child: isSelected == 'R'
                                  ? Text('Real Estate',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ))
                                  : Text(
                                      'Real Estate',
                                      style: GoogleFonts.cairo(),
                                    )),
                          InkWell(
                              onTap: () {
                                setState(() {
                                  isSelected = 'S';

                                });
                              },
                              child: isSelected == 'S'
                                  ? Text('Services',
                                      style: TextStyle(
                                        decoration: TextDecoration.underline,
                                      ))
                                  : Text(
                                      'Services',
                                      style: GoogleFonts.cairo(),
                                    ))
                        ],
                      ),
                    ),
                    isSelected == 'R'
                        ? Form(
                      key: formKey,

                          child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(Languages.of(context).rent),
                                    visualDensity: VisualDensity.compact,
                                    leading: Radio(
                                      value: true,
                                      groupValue: filter.forRent,
                                      activeColor: Colors.black,
                                      onChanged: (value) {
                                        setState(() {
                                          filter.forRent = value;
                                        });
                                      },
                                    ),
                                  ),
                                  ListTile(
                                    title: Text(Languages.of(context).sale),
                                    visualDensity: VisualDensity.compact,
                                    leading: Radio(
                                      value: false,
                                      groupValue: filter.forRent,
                                      activeColor: Colors.black,
                                      onChanged: (value) {
                                        setState(() {
                                          filter.forRent = value;
                                        });
                                      },
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, top: 20.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: DropdownButtonFormField(
                                          key: _key,
                                          hint: Text(
                                            Languages.of(context).regions,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 20.sp),
                                          ),
                                          isExpanded: true,
                                          onChanged: (value) {
                                            setState(() {
                                              cityId = value;
                                            });
                                          },
                                          onSaved: (value) {
                                            filter.city = value;
                                          },
                                          // TODO:  HERE
                                          items: Provider.of<CityBasket>(context,
                                              listen: false)
                                              .cities
                                              .map((CityModel val){
                                            return DropdownMenuItem(
                                              value: val.name,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    Languages.of(context)
                                                                .labelSelectLanguage ==
                                                            "English"
                                                        ? val.name.replaceAll('-', '')
                                                        : val.arabicName.replaceAll('-', '') ??
                                                            val.name.replaceAll('-', ''),
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.w300),
                                                  ),
                                                  Text(
                                                    val.propertiesNumber
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        color: Colors
                                                            .red.shade900),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.only(
                                                left: 10.0, right: 10.0),
                                          ),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_sharp,
                                            color: Colors.black,
                                          ),
                                        )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, top: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: DropdownButtonFormField(
                                        hint: Text(
                                          Languages.of(context).categorie,
                                          style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        isExpanded: true,
                                        onSaved: (value) {
                                          filter.category = value;
                                          print('youssef cat pro is ${filter.category }');
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            categoryId = value;
                                          });
                                        },
                                        items: _cats.map((CategoryModel val) {
                                          return DropdownMenuItem(
                                            value: val.name,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  Languages.of(context)
                                                              .labelSelectLanguage ==
                                                          "English"
                                                      ? val.name
                                                      : val.arabicName ??
                                                          val.name,
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Text(
                                                  val.properties_count
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color:
                                                          Colors.red.shade900),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        decoration: const InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                        ),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_sharp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12.0,
                                              right: 12.0,
                                              top: 20.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30.w),
                                            child: TextFormField(
                                              keyboardType: TextInputType
                                                  .numberWithOptions(),
                                              onSaved: (txt) {
                                                filter.rooms =
                                                    int.tryParse(txt);
                                              },
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              decoration: InputDecoration(
                                                hintText:
                                                    Languages.of(context).rooms,
                                                isDense: true,
                                                border: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                focusedErrorBorder:
                                                    InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12.0,
                                              right: 12.0,
                                              top: 20.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.4),
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 30.w),
                                            child: TextFormField(
                                              keyboardType: TextInputType
                                                  .numberWithOptions(),
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              onSaved: (txt) {
                                                filter.baths =
                                                    int.tryParse(txt);
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    Languages.of(context).baths,
                                                isDense: true,
                                                border: InputBorder.none,
                                                disabledBorder:
                                                    InputBorder.none,
                                                enabledBorder: InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                focusedBorder: InputBorder.none,
                                                focusedErrorBorder:
                                                    InputBorder.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, top: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  60,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30.w),
                                              child: TextFormField(
                                                keyboardType: TextInputType
                                                    .numberWithOptions(),
                                                onSaved: (txt) {
                                                  filter.minPrice =
                                                      int.tryParse(txt);
                                                },
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration: InputDecoration(
                                                  hintText:
                                                      Languages.of(context)
                                                          .minPrice,
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  focusedErrorBorder:
                                                      InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 30.w,
                                          ),
                                          Expanded(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  60,
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 30.w),
                                              child: TextFormField(
                                                keyboardType: TextInputType
                                                    .numberWithOptions(),
                                                onSaved: (txt) {
                                                  filter.maxPrice =
                                                      int.tryParse(txt);
                                                },
                                                inputFormatters: <
                                                    TextInputFormatter>[
                                                  FilteringTextInputFormatter
                                                      .digitsOnly
                                                ],
                                                decoration: InputDecoration(
                                                  hintText:
                                                      Languages.of(context)
                                                          .maxPrice,
                                                  isDense: true,
                                                  border: InputBorder.none,
                                                  disabledBorder:
                                                      InputBorder.none,
                                                  enabledBorder:
                                                      InputBorder.none,
                                                  errorBorder: InputBorder.none,
                                                  focusedBorder:
                                                      InputBorder.none,
                                                  focusedErrorBorder:
                                                      InputBorder.none,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, top: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: DropdownButtonFormField(
                                        hint: Text(
                                          Languages.of(context).furnishing,
                                          style: TextStyle(
                                              fontSize: 20.sp,
                                              fontWeight: FontWeight.w300),
                                        ),
                                        isExpanded: true,
                                        onChanged: (value) {
                                          setState(() {
                                            furnished = value;
                                          });
                                        },
                                        onSaved: (value) {
                                          filter.furnished = value;
                                        },
                                        items: furnishes.map((Furnish frn) {
                                          return DropdownMenuItem(
                                            value: Languages.of(context)
                                                        .labelSelectLanguage ==
                                                    "English"
                                                ? frn.name
                                                : frn.name_ar,
                                            child: Text(
                                              frn.name,
                                              style: TextStyle(
                                                  fontSize: 20.sp,
                                                  fontWeight: FontWeight.w300),
                                            ),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                        ),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_sharp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        )
                        : SingleChildScrollView(
                            child: Form(
                              key: formKeyservice,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, top: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: DropdownButtonFormField(
                                        hint: Text(
                                          Languages.of(context).regions,
                                          style: TextStyle(fontSize: 20.sp),
                                        ),
                                        isExpanded: true,
                                        onChanged: (value) {
                                          setState(() {
                                            region = value;
                                            _key.currentState.reset();
                                            getCities(value);
                                          });
                                        },
                                        onSaved: (value) {
                                          service_filter.city = value;

                                        },
                                        items: regions.map((RegionModel val) {
                                          return DropdownMenuItem(
                                            value: val.name,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  Languages.of(context)
                                                              .labelSelectLanguage ==
                                                          "English"
                                                      ? (val.name).replaceAll('-', '')
                                                      : (val.nameAr).replaceAll('-', '') ??
                                                          (val.name).replaceAll('-', ''),
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Text(
                                                  val.services_count
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors
                                                          .red.shade900),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                        ),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_sharp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, top: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.4),
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: DropdownButtonFormField(
                                        hint: Text(
                                          Languages.of(context).serv,
                                          style: TextStyle(fontSize: 20.sp),
                                        ),
                                        isExpanded: true,
                                        onChanged: (value) {
                                          setState(() {
                                            serviceId = value;
                                          });
                                        },
                                        onSaved: (val) {
                                          service_filter.category = val;
                                          print('tttttttt  ${service_filter.category}');
                                        },
                                        items: _cats_service
                                            .map((CategoryModel val) {
                                          return DropdownMenuItem(
                                            value: val.name,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  Languages.of(context)
                                                              .labelSelectLanguage ==
                                                          "English"
                                                      ? val.name
                                                      : val.arabicName ??
                                                          val.name,
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                ),
                                                Text(
                                                  val.services_count
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors
                                                          .red.shade900),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                        decoration: InputDecoration(
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                        ),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down_sharp,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12.0, top: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          right: 8.0),
                                                  child: TextFormField(
                                                    inputFormatters: <
                                                        TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onSaved: (txt) {
                                                      service_filter
                                                              .minPrice =
                                                          int.tryParse(txt);
                                                    },
                                                    decoration:
                                                        InputDecoration(
                                                      isDense: true,
                                                      hintText: Languages.of(
                                                              context)
                                                          .minPrice,
                                                      border:
                                                          InputBorder.none,
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      focusedErrorBorder:
                                                          InputBorder.none,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                          SizedBox(width: 30.w),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.grey
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          right: 8.0),
                                                  child: TextFormField(
                                                    inputFormatters: <
                                                        TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .digitsOnly
                                                    ],
                                                    keyboardType:
                                                        TextInputType.number,
                                                    onSaved: (txt) {
                                                      service_filter
                                                              .maxPrice =
                                                          int.tryParse(txt);
                                                    },
                                                    decoration:
                                                        InputDecoration(
                                                      hintText: Languages.of(
                                                              context)
                                                          .maxPrice,
                                                      isDense: true,
                                                      border:
                                                          InputBorder.none,
                                                      disabledBorder:
                                                          InputBorder.none,
                                                      enabledBorder:
                                                          InputBorder.none,
                                                      errorBorder:
                                                          InputBorder.none,
                                                      focusedBorder:
                                                          InputBorder.none,
                                                      focusedErrorBorder:
                                                          InputBorder.none,
                                                    ),
                                                  )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ),
            // Message which will be pop up on the screen
            // Action widget which will provide the user to acknowledge the choice
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              isSelected == 'R'
                  ? InkWell(
                      onTap: () {
                        formKey.currentState.save();
                        Navigator.pop(context, filter);
                        print('youssef R${filter.category}');
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 6.0),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          Languages.of(context).search,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: () {
                        formKeyservice.currentState.save();
                        Navigator.pop(context, service_filter);
                        print('youssef S${service_filter.category}');
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(15.0, 6.0, 15.0, 6.0),
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          Languages.of(context).search,
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
            ],
            contentPadding: const EdgeInsets.all(0),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            insetPadding: EdgeInsets.zero,
          ),
        );
      },
    ).then((value) {

      if(isSelected=='R')

      if (value != null && !(value as PropertiesFilterModel).isNull) {
        _filterProducts(value);
        regionId = null;
        categoryId = null;
        rooms = null;
        baths = null;
        priceTo = null;
        priceFrom = null;
        furnished = null;
        cityId = null;
      } else
        setState(() {
          _productsSearch = null;
          filter = null;
          searchPage = 0;
        });

      else  {

      if (value != null && !(value as ServicesFilterModel).isNull) {
      _filterServices(value);
      region = null;
      serviceId = null;
      priceTo = null;
      priceFrom = null;
      city = null;
      } else {
      setState(() {
      _servicesSearch = null;
      filter = null;
      searchPage = 0;
      });
      }
      }
    }

    );
  }

  Future<void> _filterProducts(PropertiesFilterModel filter) async {
    this.filter = filter;
    pageProduct = 0;
    setState(() {
      _isFetching = true;
    });
    _productsSearch = await ProductsWebService().getTop10(filter: filter);
    setState(() {
      _isFetching = false;
      print('product issss youssef${_productsSearch}');
    });
  }

  Future<void> _filterServices(ServicesFilterModel service_filter) async {
    this.service_filter = service_filter;
    pageService = 0;
    setState(() {
      _isFetching = true;
    });
    _servicesSearch =
        await ProductsWebService().getServices(filter: service_filter);
    setState(() {
      _isFetching = false;
      print('service issss youssef${_servicesSearch}');
    });
  }

  Future<void> _loadImages() async {
    final images = <String>[];
    List.of(_banners).forEach((element) {
      images.add('https://bunyan.qa/images/sliders/${element.photo}');
    });
    List.of(_banners_services).forEach((element) {
      images.add('https://bunyan.qa/images/sliders/${element.photo}');
    });

    _productsPremium.forEach((element) {
      List.of(element.photos).forEach((e) {
        images.add('https://bunyan.qa/images/posts/$e');
      });
    });

    _servicesPremium.forEach((element) {
      List.of(element.photos).forEach((e) {
        images.add('https://bunyan.qa/images/posts/$e');
      });
    });
    await loadImages(listOfImageUrls: images);
  }

  Future<void> _getRealEstatesData() async {
    final futures = await Future.wait([
      // ProductsWebService().getRealEstateTypes(currentLang.toString()),
      ProductsWebService().getCategories(currentLang.toString()),
      AdvertisesWebService().getBanners(1),
      ProductsWebService().getTop10(page: 0),
      AdvertisesWebService().getCities(),
      ProductsWebService().getTop10(page: 0, filter: PropertiesFilterModel(promoted: true))
    ]);
    // Res.realEstateTypes = futures[0];
    final cats = futures[0];
    final banners = futures[1];
    final top10 = futures[2];
    final premium = futures[4];

    _realEstatesPassThrough = RealEstatesPassThrough(
        cats: cats,
        banners: banners,
        products: top10,
        cities: futures[3],
        premium: premium);
  }

  Future<void> _getServicesData() async {
    final futures = await Future.wait([
      ProductsWebService().getServicesCategories(currentLang.toString()),
      AdvertisesWebService().getBannersService(2),
      ProductsWebService()
          .getServices(filter: ServicesFilterModel(promoted: true)),
      ProductsWebService().getServices(page: 0),
    ]);
    _servicesPassThrough = ServicesPassThrough(
        banners: futures[1],
        services: futures[3],
        categories: futures[0],
        servicesPremium: futures[2]);
  }
}

class DrawTriangle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var path = Path();
    // path.moveTo(size.width, size.height);
    path.lineTo(size.height / 2, size.height / 1.2);
    path.lineTo(size.width, 0);
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

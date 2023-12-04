import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/banner.dart';
import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/furnish.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/models/service.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/models/service_filter.dart';
import 'package:bunyan/models/services_filter.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/addresses.dart';
import 'package:bunyan/tools/webservices/advertises.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/common/card_item_ser.dart';
import 'package:bunyan/ui/common/premium_ads.dart';
import 'package:bunyan/ui/common/premium_services.dart';
import 'package:bunyan/ui/common/top_ad_banner.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:bunyan/ui/real_estates/real_estates_screen.dart';
import 'package:bunyan/ui/services/service_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class ServicesScreen extends StatefulWidget {
  ServicesScreen({Key key, this.data}) : super(key: key);

  final ServicesPassThrough data;

  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends State<ServicesScreen>
    with TickerProviderStateMixin, RouteAware, RouteObserverMixin {
  bool _showFilter = false;
  bool _isFetching = true;

  List<ProductListModel> services = [];
  List<ProductListModel> servicesSearch = null;
  ServicesFilter _filter = ServicesFilter();

  ServicesFilterModel filter;


  CategoryModel _selectedCategory;

  List<ProductListModel> _top10 = [];
  List<BannerModel> _banners = [];
  List<ServiceModel> _servicesPremium = [];
  List<CategoryModel> _cats = [];
  ScrollController _scrollController = ScrollController();
  bool _stillFetch = true;
  bool isLoading = true;
  Locale currentLang;
  int _currentIndex = 0;
  int servicesLength = 9;
  bool showMoreStatus = false;
  int page = 0;
  int _searchPage = 0;
  List<RegionModel> regions = [];
  List<CityModel> cities = [];
  List<Furnish> furnishes = [
    Furnish(name: "Furnished", id: true),
    Furnish(name: "Unfurnished", id: false)
  ];
  Locale _locale;
  String region;
  String city;
  String category;
  int priceFrom;
  int priceTo;
  bool furnished;
  String serviceId;
  bool isLoadingSearch = false;
  String query = '';
  TextEditingController _searchController = TextEditingController();

  GlobalKey<FormFieldState> _key = new GlobalKey();

  int searchPage = 0;

  @override
  void initState() {
    AddressesWebService().getRegions().then((rgs) {
      setState(() {
        regions = rgs;
        print(regions.length);
      });
    });

    if (widget.data == null) {
      _stillFetch = true;
      isLoading = true;
      getData();
    } else {
      _isFetching = false;
      _banners = widget.data.banners;
      services = widget.data.services;
      Res.catgories = widget.data.categories;
      _cats = widget.data.categories;
      _servicesPremium = widget.data.servicesPremium;
    }

    //getCurrentLang();
    super.initState();

    _filter.page = 1;

    //_scrollController.addListener(_scrollListener);
  }

  getCities(int regionSelected) async {
    AddressesWebService().getCities(regionSelected).then((cts) {
      setState(() {
        Provider.of<CityBasket>(context, listen: false).affectCities(cts);
        cities = cts;
      });
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

  getData() async {
    final futures = await Future.wait([
      ProductsWebService().getServicesCategories(currentLang.toString()),
      AdvertisesWebService().getBannersService(2),
      ProductsWebService().getServices(filter: ServicesFilterModel(promoted: true)),
    ]);
    setState(() {
      Res.servicesCategories = futures[0];
      _banners = futures[1];
      _servicesPremium = futures[2];
    });
    _getData();
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
      _getData();
    }
  }

  @override
  void dispose() {
    //_scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  @override
  void didPopNext() {
    Res.titleStream.add('عقارات');
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
          icon: Icon(Icons.arrow_back_ios,
              color: Colors.black,
              size: 30.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          Languages.of(context).services,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 22.0.sp,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (filter != null) {
            setState(() {
              servicesSearch = null;
              filter = null;
              searchPage = 0;
            });
            return false;
          }
          return true;
      },
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: CustomScrollView(
                    controller: _scrollController,
                    cacheExtent: 10000.0,
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
                    shrinkWrap: true,
                    slivers: [
                      SliverList(
                          delegate: SliverChildListDelegate([
                        Column(
                          textDirection: TextDirection.rtl,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    bottom: 10.h, left: 0.h, right: 20.h),
                                child: Row(
                                  children: [
                                    Expanded(flex: 9, child: _searchWidget()),

                                  ],
                                )),
                            Padding(
                              padding: EdgeInsets.only(left: 12.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Premium Banner',
                                    style: GoogleFonts.cairo
                                      (color: Color(0xFF750606,),fontWeight:
                                    FontWeight.bold,fontSize: 25.sp),),
                                ],
                              ),
                            ),
                            if (_banners.length > 0)
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: TopAdBanner(
                                  banners: _banners,
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.only(left: 12.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Premium Services',
                                    style: GoogleFonts.cairo
                                      (color: Color(0xFF750606,),fontWeight:
                                    FontWeight.bold,fontSize: 25.sp),),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: PremiumSrv(
                                ads: _servicesPremium,
                              ),
                            ),
                            if (_top10.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: SizedBox(
                                  height: .15.sh,
                                  child: PremiumAds(
                                    ads: _top10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ]
                          )
                      ),
                      SliverPadding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: Divider(
                                  color: Color(0xFF750606),
                                  thickness: 2,
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 12.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text('Services Category',
                                    style: GoogleFonts.cairo
                                      (color: Color(0xFF750606,),fontWeight:
                                    FontWeight.bold,fontSize: 25.sp),),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10.h, left: 0.h, right: 20.h),
                            ),
                          ]),
                        ),
                      ),

                      // if (_filter.category == null)
                      SliverPadding(
                        padding: EdgeInsets.only(bottom: 5.h),
                        sliver: _cats != null
                            ? _categories()
                            : SliverList(
                                delegate:
                                    SliverChildListDelegate([Container()]),
                              ),
                      ),

                      SliverPadding(
                          padding: EdgeInsets.only(
                              right: .02.sw,
                              left: .02.sw,
                              ),
                          sliver: _isFetching
                          ? SliverList(delegate: SliverChildListDelegate([_loadingWidget()]))
                          : !_isFetching
                          ? servicesSearch != null && servicesSearch.isEmpty
                          ? SliverList(
                            delegate: SliverChildListDelegate([
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: .15.sh),
                                  child: Text(
                                    Languages.of(context).noAds,
                                    style: GoogleFonts.cairo(
                                        color: Colors.grey,
                                        fontSize: 40.sp,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              )
                            ]),
                          )
                          : services.isEmpty
                              ? SliverList(
                                  delegate: SliverChildListDelegate([
                                    Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: .15.sh),
                                        child: Text(
                                          Languages.of(context).noAds,
                                          style: GoogleFonts.cairo(
                                              color: Colors.grey,
                                              fontSize: 40.sp,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    )
                                  ]),
                                ) : SliverStaggeredGrid.countBuilder(
                                      crossAxisCount: 2,
                                      itemCount: (servicesSearch?.isNotEmpty ?? false)
                                          ? servicesSearch.length
                                          : services.length,
                                      staggeredTileBuilder: (index) =>
                                          StaggeredTile.fit(1),
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                            onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ServiceScreen(
                                                          service: servicesSearch
                                                                      ?.isNotEmpty ?? false
                                                              ? servicesSearch[
                                                                  index]
                                                              : services[index],
                                                        ))),
                                            child: CardItemService(
                                                service:
                                                    (servicesSearch?.isNotEmpty ?? false)
                                                        ? servicesSearch[index]
                                                        : services[index]));
                                      },
                                    ) : Container()
                      ),
                      if (!_isFetching)
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 30.h),
                          sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            showMoreStatus ? Center(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )) : TextButton(
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius:
                                      BorderRadius.circular(20)),
                                  child: Text(
                                    Languages.of(context).showMore,
                                    style: TextStyle(
                                        color: Color(0xFF750606),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 30.sp),
                                  )),
                              onPressed: () {
                                setState(() {
                                  if (filter != null)
                                    searchPage++;
                                  else
                                    page ++;
                                  showMoreData(filter != null ? searchPage : page);
                                });
                              },
                            )
                          ]),
                      ),
                        ),


                    ]),
              ),
            ],
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

  Widget _categories() {
    return SliverList(
      delegate: SliverChildListDelegate([
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: _cats
                  .map((cat) => InkWell(
                        onTap: () {
                          setState(() {
                            /*_stillFetch = true;
                            _filter.page = 1;
                            _filter.category = cat;
                            services.clear();*/
                            if (_selectedCategory == cat) {
                              setState(() {
                                servicesSearch = null;
                                filter = null;
                                _selectedCategory = null;
                                searchPage = 0;
                              });
                            } else {
                              _selectedCategory = cat;
                              _filterServices(
                                  ServicesFilterModel(category: cat.name));
                            }
                          });
                          _getData();
                          _stillFetch = false;
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              Container(
                                  width: 110,
                                  height: 105,
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
                                                (_, __, ___) =>
                                                _shimmer(
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
                                  )
                              ),
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
                                          Languages
                                              .of(context)
                                              .labelSelectLanguage ==
                                              "English"
                                              ? cat.name
                                              : cat.arabicName,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                              fontSize: 16.w),
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
                                              fontSize: 16.w),
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
        )
      ]),
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

  void _getData() {
    if (_stillFetch) {
      setState(() {
        _isFetching = true;
      });
      ProductsWebService().getServices(page: 0).then((value) {
        print(value.length.toString() + 'mllmk');
        setState(() {
          services.addAll(value);
          // if(services.length > 10 && services.length > servicesLength){
          //   servicesLength = servicesLength + 2;
          // }
          _isFetching = false;
          _stillFetch = false;
        });
      }).catchError((err) {
        _isFetching = false;
        _stillFetch = false;
      });
    }
  }

  void showMoreData(int page) {
    setState(() {
      showMoreStatus = true;
    });
    ProductsWebService().getServices(page: page, filter: filter).then((value) {
      setState(() {
        if (filter != null)
          servicesSearch.addAll(value);
        else
          services.addAll(value);
        showMoreStatus = false;
      });
    }).catchError((err) {

    });
  }


  // void _getDataServiceCategorie() {
  //   if (_stillFetch && !_isFetching) {
  //     setState(() {
  //       _isFetching = true;
  //     });
  //     ProductsWebService().getServicesCategories(currentLang.toString()).then((value) {
  //       setState(() {
  //
  //         _isFetching = false;
  //         if (value.length < Res.PAGE_SIZE) _stillFetch = false;
  //       });
  //       print('services_categories {$_cats}');
  //     }).catchError((err) {
  //       _isFetching = false;
  //       _stillFetch = false;
  //     });
  //   }
  // }

  _searchServices() {
    servicesSearch.clear();

    if (Languages.of(context).labelSelectLanguage == 'English') {
      setState(() {
        servicesSearch = services.where((service) {
          final titleLower = service.title.toLowerCase();

          return titleLower.contains(this.query.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        servicesSearch = services.where((service) {
          final titleLower = service.titleAr.toLowerCase();

          return titleLower.contains(this.query.toLowerCase());
        }).toList();
      });
    }
  }

  Widget _searchWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: SizedBox(
        height: 50.h,
        child: Padding(
          padding: EdgeInsets.all(1.0),
          child: Row(
            children: [
              Expanded(
                flex: 9,
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      final fil = ServicesFilterModel(search: value);
                      _selectedCategory = null;
                      _filterServices(fil);
                      region = null;
                      serviceId = null;
                      priceTo = null;
                      priceFrom = null;
                      city = null;
                    } else {
                      setState(() {
                        servicesSearch = null;
                        filter = null;
                        searchPage = 0;
                      });
                    }
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
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  servicesSearch.clear();
                                  query = '';
                                  _searchController.text = '';
                                    servicesSearch = null;
                                    filter = null;
                                    searchPage = 0;
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
                                    // color: Colors.black,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.black87,
                                    size: 24,
                                  )),
                            )
                          : Container(),
                      suffixIconConstraints: BoxConstraints(
                          minWidth: 60, minHeight: 40, maxWidth: 60),
                      contentPadding:
                          EdgeInsets.only(top: 0, left: 20.w, right: 20),
                      hintStyle: GoogleFonts.cairo(
                          color: Colors.black38, fontSize: 25.sp),
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
                    padding: EdgeInsets.all(4.0),
                    child: Image.asset(
                        "assets/filter.png"),
                  )))

            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final formKey = GlobalKey<FormState>();
    showDialog(
      barrierDismissible: true,
      context: context,
      builder:
          (BuildContext context) {
            final filter = ServicesFilterModel();
        return AlertDialog(
          content:
          SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(
                  context)
                  .size
                  .width -
                  35,
              child: Form(
                key:formKey,
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                      EdgeInsets
                          .all(8),
                      decoration: BoxDecoration(
                          color: Colors
                              .grey
                              .withOpacity(
                              0.4),
                          borderRadius: BorderRadius.only(
                              topRight:
                              Radius.circular(
                                  5),
                              topLeft: Radius
                                  .circular(
                                  5))),
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceBetween,
                        children: [
                          Text(
                            Languages.of(
                                context)
                                .advsearoption,
                            style: TextStyle(
                                fontSize:
                                17,
                                fontWeight:
                                FontWeight.bold),
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
                    Padding(
                      padding:
                      const EdgeInsets
                          .only(
                          left:
                          12.0,
                          right:
                          12.0,
                          top:
                          20.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors
                                .grey
                                .withOpacity(
                                0.4),
                            borderRadius:
                            BorderRadius.circular(
                                8)),
                        child:
                        DropdownButtonFormField(
                          hint: Text(
                            Languages.of(
                                context)
                                .regions,
                            style: TextStyle(
                                fontSize:
                                20.sp),
                          ),
                          isExpanded:
                          true,
                          onChanged:
                              (value) {
                            setState(
                                    () {
                                  region =
                                      value;
                                  _key.currentState
                                      .reset();
                                  getCities(
                                      value);
                                });
                          },
                          onSaved:
                              (value) {
                            filter.city = value;
                          },
                          items: regions.map(
                                  (RegionModel
                              val) {
                                return DropdownMenuItem(
                                  value: val
                                      .name,
                                  child:
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Languages.of(context).labelSelectLanguage == "English"
                                            ? val.name
                                            : val.nameAr ?? val.name,
                                        style:
                                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        val.services_count.toString(),
                                        style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.red.shade900),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          decoration:
                          InputDecoration(
                            floatingLabelBehavior:
                            FloatingLabelBehavior
                                .always,
                            border:
                            InputBorder
                                .none,
                            contentPadding: EdgeInsets.only(
                                left:
                                10.0,
                                right:
                                10.0),
                          ),
                          icon: Icon(
                            Icons
                                .keyboard_arrow_down_sharp,
                            color: Colors
                                .black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets
                          .only(
                          left:
                          12.0,
                          right:
                          12.0,
                          top:
                          20.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors
                                .grey
                                .withOpacity(
                                0.4),
                            borderRadius:
                            BorderRadius.circular(
                                8)),
                        child:
                        DropdownButtonFormField(
                          hint: Text(
                            Languages.of(
                                context)
                                .serv,
                            style: TextStyle(
                                fontSize:
                                20.sp),
                          ),
                          isExpanded:
                          true,
                          onChanged:
                              (value) {
                            setState(
                                    () {
                                  serviceId =
                                      value;
                                });
                          },
                          onSaved: (val) {
                            filter.category = val;
                          },
                          items: _cats.map(
                                  (CategoryModel
                              val) {
                                return DropdownMenuItem(
                                  value: val
                                      .name,
                                  child:
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Languages.of(context).labelSelectLanguage == "English"
                                            ? val.name
                                            : val.arabicName ?? val.name,
                                        style:
                                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        val.services_count.toString(),
                                        style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.red.shade900),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                          decoration:
                          InputDecoration(
                            floatingLabelBehavior:
                            FloatingLabelBehavior
                                .always,
                            border:
                            InputBorder
                                .none,
                            contentPadding: EdgeInsets.only(
                                left:
                                10.0,
                                right:
                                10.0),
                          ),
                          icon: Icon(
                            Icons
                                .keyboard_arrow_down_sharp,
                            color: Colors
                                .black,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets
                          .only(
                          left:
                          12.0,
                          right:
                          12.0,
                          top:
                          20.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius:
                            BorderRadius.circular(
                                8)),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(
                                        0.4),
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                child:
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left:
                                        8.0,
                                        right:
                                        8.0),
                                    child: TextFormField(
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      onSaved: (txt) {
                                        filter.minPrice = int.tryParse(txt);
                                      },
                                      decoration: InputDecoration(
                                        isDense: true,
                                        hintText: Languages.of(context).minPrice,
                                        border: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                      ),
                                    )
                                ),
                              ),
                            ),
                            SizedBox(width: 30.w),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(
                                        0.4),
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                child:
                                Padding(
                                    padding: const EdgeInsets.only(
                                        left:
                                        8.0,
                                        right:
                                        8.0),
                                    child: TextFormField(
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      keyboardType: TextInputType.number,
                                      onSaved: (txt) {
                                        filter.maxPrice = int.tryParse(txt);
                                      },
                                      decoration: InputDecoration(
                                        hintText: Languages.of(context).maxPrice,
                                        isDense: true,
                                        border: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                      ),
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Message which will be pop up on the screen
          // Action widget which will provide the user to acknowledge the choice
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            InkWell(
              onTap: () {
                formKey.currentState.save();
                Navigator.pop(
                    context, filter);
              },
              child: Container(
                padding: EdgeInsets
                    .fromLTRB(
                    15.0,
                    6.0,
                    15.0,
                    6.0),
                decoration: BoxDecoration(
                    color:
                    Colors.black,
                    borderRadius:
                    BorderRadius
                        .circular(
                        15)),
                child: Text(
                  Languages.of(
                      context)
                      .search,
                  style: TextStyle(
                      color: Colors
                          .white,
                      fontWeight:
                      FontWeight
                          .bold),
                ),
              ),
            )
          ],
          contentPadding:
          EdgeInsets.all(0),
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.all(
                  Radius.circular(
                      10.0))),
          insetPadding:
          EdgeInsets.zero,
        );
      },
    ).then((value) {
      print('callled:    ${value.category}');
      if (value != null && !(value as ServicesFilterModel).isNull) {
            _filterServices(value);
            region = null;
            serviceId = null;
            priceTo = null;
            priceFrom = null;
            city = null;
      } else {
        setState(() {
          servicesSearch = null;
          filter = null;
          searchPage = 0;
        });
      }
    });
  }

  Future<void> _filterServices(ServicesFilterModel filter) async {
    this.filter = filter;
    searchPage = 0;
    setState(() {
      _isFetching = true;
    });

    servicesSearch = await ProductsWebService().getServices(filter: filter);

    setState(() {
      _isFetching = false;
    });
  }
}

class ServiceProvider extends ChangeNotifier {
  SfRangeValues _valuesService = SfRangeValues(.0, 100000.0);

  updatePriceService(SfRangeValues values) {
    _valuesService = values;
    notifyListeners();
  }
}

class ServicesPassThrough {
  List<ServiceModel> services;
  List<BannerModel> banners;
  List<ServiceModel> servicesPremium;
  List<CategoryModel> categories;

  ServicesPassThrough(
      {this.services, this.banners, this.servicesPremium, this.categories});
}

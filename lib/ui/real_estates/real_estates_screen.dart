import 'package:another_xlider/another_xlider.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/Furnish.dart';
import 'package:bunyan/models/banner.dart';
import 'package:bunyan/models/category.dart';
import 'package:bunyan/models/city.dart';
import 'package:bunyan/models/product.dart';
import 'package:bunyan/models/product_list.dart';
import 'package:bunyan/models/properties_filter.dart';
import 'package:bunyan/models/real_estate_filter.dart';
import 'package:bunyan/models/real_estate_type.dart';
import 'package:bunyan/models/region.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/addresses.dart';
import 'package:bunyan/tools/webservices/advertises.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/common/card_item.dart';
import 'package:bunyan/ui/common/premium_ads.dart';
import 'package:bunyan/ui/common/search_widget.dart';
import 'package:bunyan/ui/common/top_ad_banner.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:bunyan/ui/product/product_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shimmer/shimmer.dart';

class RealEstatesScreen extends StatefulWidget {
  RealEstatesScreen({Key key, this.data}) : super(key: key);

  final RealEstatesPassThrough data;

  @override
  _RealEstatesScreenState createState() => _RealEstatesScreenState();
}

class _RealEstatesScreenState extends State<RealEstatesScreen>
    with TickerProviderStateMixin, RouteAware, RouteObserverMixin {
  bool _showFilter = false;
  bool _isFetching = true;
  List<ProductListModel> _realEstates = [];
  List<RealEstateTypeModel> _realstateType = [];
  List<ProductListModel> _realEstatesSearch;
  RealEstateTypeModel _type;
  int realEstatesLength = 9;
  List<ProductListModel> _productsPremium = [];
  CategoryModel _selectedCategory;

  List<ProductListModel> _top10 = [];
  List<BannerModel> _banners = [];
  List<CategoryModel> _cats = [];
  ScrollController _scrollController = ScrollController();
  RealEstateFilterModel _filter = RealEstateFilterModel();
  bool _stillFetch = true;
  bool isLoading = true;
  Locale currentLang;
  int _currentIndex = 0;
  int page = 0;
  int searchPage = 0;
  PropertiesFilterModel filter;
  bool showMoreStatus = false;
  List<RegionModel> regions = [];
  List<CityModel> cities = [];
  List<Furnish> furnishes = [
    Furnish(name: "Fully Furnished", id: true, name_ar: 'جميع المفروشات'),
    Furnish(name: "Semi Furnished", id: false, name_ar: 'مفروش جزئيا'),
    Furnish(name: "Unfurnished", id: true, name_ar: 'غير مفروش'),
  ];

  String regionId;
  String cityId;
  String categoryId;
  int rooms;
  int baths;
  double priceFrom;
  double priceTo;
  String furnished;
  String query = '';
  Locale _locale;
  TextEditingController _searchController = TextEditingController();

  GlobalKey<FormFieldState> _key = new GlobalKey();

  @override
  void initState() {
    AddressesWebService().getRegions().then((rgs) {
      setState(() {
        regions = rgs;
        print('regions is youssef  ${regions.length}');
      });
    });
    if (widget.data == null) {
      getData();
      _stillFetch = true;
      isLoading = true;
    } else {
      setState(() {
        _cats = widget.data.cats;
        _banners = widget.data.banners;
        _realEstates = widget.data.products;
        _isFetching = false;
        _productsPremium = widget.data.premium;
      });
      Provider.of<CityBasket>(context, listen: false).cities =
          widget.data.cities;
    }
    //getCurrentLang();
    super.initState();

    _filter.page = 1;
  }

  getCities(int regionSelected) async {
    AddressesWebService().getCities(regionSelected).then((cts) {
      setState(() {
        Provider.of<CityBasket>(context, listen: false).affectCities(cts);
        cities = cts;
        print("youssef cities here ${cities}");
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
      // ProductsWebService().getRealEstateTypes(currentLang.toString()),
      ProductsWebService().getCategories(currentLang.toString()),
      AdvertisesWebService().getBanners(1),
      ProductsWebService().getTop10(page: 0),
      AdvertisesWebService().getCities(),
      ProductsWebService()
          .getTop10(page: 0, filter: PropertiesFilterModel(promoted: true))
    ]);
    setState(() {
      // Res.realEstateTypes = futures[0];
      _cats = futures[0];
      _banners = futures[1];
      _top10 = futures[2];
      print(_top10.length.toString() + 'fezfz');
      isLoading = false;
      _productsPremium = futures[4];
    });
    Provider.of<CityBasket>(context, listen: false).cities = futures[3];
    _getData(0);
  }

  @override
  void didPopNext() {
    Res.titleStream.add(Languages.of(context).realEstate);
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black,
              size: 30.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          Languages.of(context).realEstate,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 22.sp,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (filter != null) {
            setState(() {
              _realEstatesSearch = null;
              filter = null;
              searchPage = 0;
            });
            return false;
          }
          return true;
        },
        child: Container(
          child: SafeArea(
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: CustomScrollView(
                      controller: _scrollController,
                      cacheExtent: 10000.0,
                      physics: AlwaysScrollableScrollPhysics(),
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
                                    Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                            onTap: () {
                                              _showFilterDialog();
                                            },
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(left: 6.0),
                                              child: Image.asset(
                                                  "assets/filter.png",height: 60.sp,),
                                            )))
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 12.h, bottom: 20.h),
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
                              if (_banners.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: TopAdBanner(
                                    banners: _banners,
                                  ),
                                ),

                              Padding(
                                padding:
                                    EdgeInsets.only(left: 12.h, bottom: 20.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Premium Properties',
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
                                child: PremiumAds(
                                  ads: _productsPremium.isNotEmpty
                                      ? _productsPremium
                                      : List.generate(10, (index) => null),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 1.h),
                                child: AnimatedSize(
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  //height: !_showFilter ? .0 : .45.sh,
                                  vsync: this,
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 10.h),
                                    child: _showFilter || _filter.type != null
                                        ? SearchWidget(
                                            showDropDown: false,
                                            onSearch: (filter) {
                                              _realEstates.clear();
                                              _stillFetch = true;
                                              filter.type = _filter.type;
                                              filter._page = 1;
                                              _filter = RealEstateFilterModel
                                                  .fromJson(filter.toJson());
                                              _getData(0);
                                            },
                                            filter: _filter,
                                          )
                                        : Container(),
                                  ),
                                ),
                              ),
                              if (_top10.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: PremiumAds(
                                    ads: _top10,
                                  ),
                                ),
                              // Padding(
                              //   padding: EdgeInsets.only(bottom: 10),
                              //   child: _searchWidget(),
                              //   ),
                            ],
                          ),
                        ])),

                        //categories

                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Divider(
                                    color: Color(0xFF750606),
                                    thickness: 2,
                                  )),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 12.h, bottom: 20.h),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Real Estate Category',
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
                                padding: EdgeInsets.only(
                                    bottom: 10.h, left: 0.h, right: 20.h),
                              ),
                            ]),
                          ),
                        ),
                        // if (_filter.category == null)

                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          sliver: _cats != null
                              ? _categories()
                              : SliverList(
                                  delegate: SliverChildListDelegate([
                                    Container(),
                                  ]),
                                ),
                        ),
                        SliverPadding(
                            padding: EdgeInsets.only(
                              right: .02.sw,
                              left: .02.sw,
                            ),
                            sliver: _isFetching
                                ? SliverList(
                                    delegate: SliverChildListDelegate([
                                    _loadingWidget(),
                                  ]))
                                : !_isFetching
                                    ? _realEstatesSearch != null &&
                                            _realEstatesSearch.isEmpty
                                        ? SliverPadding(
                                            padding: EdgeInsets.only(top: 6),
                                            sliver: SliverList(
                                              delegate:
                                                  SliverChildListDelegate([
                                                Center(
                                                    child: Text(
                                                        Languages.of(context)
                                                            .noAds))
                                              ]),
                                            ),
                                          )
                                        : _realEstates.isEmpty
                                            ? SliverPadding(
                                                padding:
                                                    EdgeInsets.only(top: 6),
                                                sliver: SliverList(
                                                  delegate:
                                                      SliverChildListDelegate([
                                                    Center(
                                                        child: Text(
                                                            Languages.of(
                                                                    context)
                                                                .noAds))
                                                  ]),
                                                ),
                                              )
                                            : SliverStaggeredGrid.countBuilder(
                                                crossAxisCount: 2,
                                                itemCount: (_realEstatesSearch
                                                            ?.isNotEmpty ??
                                                        false)
                                                    ? _realEstatesSearch.length
                                                    : _realEstates.length,
                                                staggeredTileBuilder: (index) =>
                                                    StaggeredTile.fit(1),
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                      onTap: () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        ProductScreen(
                                                                          product: _realEstatesSearch?.isNotEmpty ?? false
                                                                              ? _realEstatesSearch[index]
                                                                              : _realEstates[index],
                                                                        )));
                                                        setState(() {
                                                          if (_realEstatesSearch
                                                              .isNotEmpty)
                                                            _realEstatesSearch[
                                                                        index]
                                                                    .views =
                                                                (int.tryParse(_realEstatesSearch[index]
                                                                            .views) +
                                                                        1)
                                                                    .toString();
                                                          else
                                                            _realEstates[index]
                                                                    .views =
                                                                (int.tryParse(_realEstates[index]
                                                                            .views) +
                                                                        1)
                                                                    .toString();
                                                        });
                                                      },
                                                      child: CardItem(
                                                          product: (_realEstatesSearch
                                                                      ?.isNotEmpty ??
                                                                  false)
                                                              ? _realEstatesSearch[
                                                                  index]
                                                              : _realEstates[
                                                                  index]));
                                                },
                                              )
                                    : Container()),
                        //if (!_stillFetch)
                        SliverPadding(
                          padding: EdgeInsets.only(bottom: 30.h),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              showMoreStatus
                                  ? Center(
                                      child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CircularProgressIndicator(),
                                    ))
                                  : TextButton(
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
                                            page++;
                                          showMoreData(filter != null
                                              ? searchPage
                                              : page);
                                        });
                                      },
                                    )
                            ]),
                          ),
                        )
                      ]),
                ),
              ],
            ),
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
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: _cats
                  .map((cat) => InkWell(
                        onTap: () {
                          setState(() {
                            /*_stillFetch = true;
                            _filter.page = 1;
                            _filter.category = cat;
                            _realEstates.clear();*/
                            if (_selectedCategory == cat) {
                              setState(() {
                                _realEstatesSearch = null;
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
                          _getData(0);
                          _stillFetch = false;
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              Container(
                                  width: 110.w,
                                  height: 105.w,
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
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                'https://bunyan.qa/images/categories/' +
                                                    cat.photo,
                                            progressIndicatorBuilder:
                                                (_, __, ___) => _shimmer(
                                                    width: 160.w,
                                                    height: 150.w),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
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
                                          cat.properties_count.toString(),
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

  Widget _searchWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.0.sp, horizontal: 20),
      child: SizedBox(
        height: 50.h,
        child: Padding(
          padding: EdgeInsets.all(1.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _selectedCategory = null;
                      _filterProducts(PropertiesFilterModel(search: value));
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
                        _realEstatesSearch = null;
                        filter = null;
                        searchPage = 0;
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
                      suffixIcon: _searchController.text.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  _realEstatesSearch = null;
                                  query = '';
                                  _searchController.text = '';
                                  _realEstatesSearch = null;
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
            ],
          ),
        ),
      ),
    );
  }

  _searchRealEstate() {
    _realEstatesSearch.clear();

    if (Languages.of(context).labelSelectLanguage == 'English') {
      setState(() {
        _realEstatesSearch = _realEstates.where((product) {
          final titleLower = product.title.toLowerCase();

          return titleLower.contains(this.query.toLowerCase());
        }).toList();
      });
    } else {
      setState(() {
        _realEstatesSearch = _realEstates.where((product) {
          final titleLower = product.titleAr.toLowerCase();

          return titleLower.contains(this.query.toLowerCase());
        }).toList();
      });
    }
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

  void _getData(int page) {
    if (_stillFetch) {
      setState(() {
        _isFetching = true;
      });
      ProductsWebService().getTop10(page: page).then((value) {
        setState(() {
          _realEstates.addAll(value);
          // if(_realEstates.length > 10 && _realEstates.length > realEstatesLength){
          //   realEstatesLength = realEstatesLength + 2;
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
    ProductsWebService().getTop10(page: page, filter: filter).then((value) {
      setState(() {
        _isFetching = false;
        if (filter != null)
          _realEstatesSearch.addAll(value);
        else
          _realEstates.addAll(value);
        showMoreStatus = false;
      });
    }).catchError((err) {
      _isFetching = false;
      _stillFetch = false;
    });
  }

  void _showFilterDialog() {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        final filter = PropertiesFilterModel();
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            content: SingleChildScrollView(
              child: SizedBox(
                width: 600.w,
                child: Form(
                  key: formKey,
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
                                  fontSize: 25.sp, fontWeight: FontWeight.bold),
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
                                    size: 30.sp,
                                  )),
                            ),
                          ],
                        ),
                      ),
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
                                borderRadius: BorderRadius.circular(8)),
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
                                  .map((CityModel val) {
                                return DropdownMenuItem(
                                  value: val.name,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        Languages.of(context)
                                                    .labelSelectLanguage ==
                                                "English"
                                            ? val.name
                                            : val.arabicName ?? val.name,
                                        style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      Text(
                                        val.propertiesNumber.toString(),
                                        style: TextStyle(
                                            fontSize: 20.sp,
                                            fontWeight: FontWeight.w300,
                                            color: Colors.red.shade900),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.only(left: 10.0, right: 10.0),
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
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonFormField(
                            hint: Text(
                              Languages.of(context).categorie,
                              style: TextStyle(
                                  fontSize: 20.sp, fontWeight: FontWeight.w300),
                            ),
                            isExpanded: true,
                            onSaved: (value) {
                              filter.category = value;
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
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Languages.of(context)
                                                  .labelSelectLanguage ==
                                              "English"
                                          ? val.name
                                          : val.arabicName ?? val.name,
                                      style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w300),
                                    ),
                                    Text(
                                      val.properties_count.toString(),
                                      style: TextStyle(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.red.shade900),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.only(left: 10.0, right: 10.0),
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
                                  left: 12.0, right: 12.0, top: 20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: TextFormField(
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  onSaved: (txt) {
                                    filter.rooms = int.tryParse(txt);
                                  },
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    hintText: Languages.of(context).rooms,
                                    isDense: true,
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 12.0, right: 12.0, top: 20.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(8)),
                                padding: EdgeInsets.symmetric(horizontal: 30.w),
                                child: TextFormField(
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  onSaved: (txt) {
                                    filter.baths = int.tryParse(txt);
                                  },
                                  decoration: InputDecoration(
                                    hintText: Languages.of(context).baths,
                                    isDense: true,
                                    border: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
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
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 60,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.w),
                                  child: TextFormField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    onSaved: (txt) {
                                      filter.minPrice = int.tryParse(txt);
                                    },
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    decoration: InputDecoration(
                                      hintText: Languages.of(context).minPrice,
                                      isDense: true,
                                      border: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      focusedErrorBorder: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 30.w,
                              ),
                              Expanded(
                                child: Container(
                                  width: MediaQuery.of(context).size.width - 60,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(10)),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 30.w),
                                  child: TextFormField(
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    onSaved: (txt) {
                                      filter.maxPrice = int.tryParse(txt);
                                    },
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
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
                              borderRadius: BorderRadius.circular(8)),
                          child: DropdownButtonFormField(
                            hint: Text(
                              Languages.of(context).furnishing,
                              style: TextStyle(
                                  fontSize: 20.sp, fontWeight: FontWeight.w300),
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
                                value:
                                    Languages.of(context).labelSelectLanguage ==
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
                              contentPadding:
                                  EdgeInsets.only(left: 10.0, right: 10.0),
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
              ),
            ),
            // Message which will be pop up on the screen
            // Action widget which will provide the user to acknowledge the choice
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              InkWell(
                onTap: () {
                  formKey.currentState.save();
                  Navigator.pop(context, filter);
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
          _realEstatesSearch = null;
          filter = null;
          searchPage = 0;
        });
    });
  }

  Future<void> _filterProducts(PropertiesFilterModel filter) async {
    this.filter = filter;
    searchPage = 0;
    setState(() {
      _isFetching = true;
    });
    _realEstatesSearch = await ProductsWebService().getTop10(filter: filter);
    setState(() {
      _isFetching = false;
    });
  }
}

class CityBasket extends ChangeNotifier {
  List<CityModel> cities = [];
  double min = 0.0;
  double max = 2000000.0;

  void affectCities(List<CityModel> citiesSelected) {
    cities = citiesSelected;
    notifyListeners();
  }

  void addCity(CityModel city) {
    cities.add(city);
    notifyListeners();
  }

  updatePrice(min, max) {
    this.min = min;
    this.max = max;
    notifyListeners();
  }
}

class RealEstatesPassThrough {
  List<ProductListModel> products;
  List<BannerModel> banners;
  List<CategoryModel> cats;
  List<CityModel> cities;
  List<ProductListModel> premium;

  RealEstatesPassThrough(
      {this.products, this.banners, this.cats, this.cities, this.premium});
}

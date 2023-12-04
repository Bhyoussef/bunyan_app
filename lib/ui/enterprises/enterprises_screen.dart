import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/enterprise.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/products.dart';
import 'package:bunyan/ui/enterprises/enterprise.dart';
import 'package:bunyan/ui/enterprises/search_entreprise.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../entreprise_chat/entreprise_list.dart';
import '../../models/businessesmodel.dart';
import '../../tools/webservices/entreprise/entreprise_api.dart';
import 'entreprise_test.dart';

class EnterprisesScreen extends StatefulWidget {
  final String category_id;
  final String type;

  EnterprisesScreen({Key key, this.category_id, this.type,}) : super(key: key);

  @override
  _EnterprisesScreenState createState() => _EnterprisesScreenState();
}

class _EnterprisesScreenState extends State<EnterprisesScreen>
    with RouteAware, RouteObserverMixin {
  List<EnterpriseModel> _enterprises = [];
  List<EnterpriseModel> _enterprisesreal = [];
  List<Busnisscategory> businesses = [];
  List<EnterpriseModel> _enterprisesSearch = null;
  bool showMoreStatus = false;
  int _page = 0;
  int _searchPage = 0;

  //EnterpriseModel _filter=EnterpriseModel();

  ScrollController _scrollController = ScrollController();
  bool isLoadingSearch = false;
  Locale _locale;
  Locale currentLang;
  String query;
  int _currentIndex = 0;
  TextEditingController _searchController = TextEditingController();
  bool _isFetching = true;
  bool _isLoading = false;

  //bool fetchingMoreEnterprises = false;
  //int enterprisesLength = 1;

  @override
  void initState() {
    super.initState();
    Res.titleStream.add('شركات');
    _scrollController.addListener(_scrollListener);
    _isFetching = true;

  ProductsWebService().getEnterprises(0,category: widget.category_id,type:widget.type).then((entrs) {
      setState(() {
        _isFetching = false;
        _enterprises = entrs;
        print('no real$_enterprises');
      });
    });
  ProductsWebService().getEnterprisesreal(0,type:widget.type).then((entrs) {
    setState(() {
      _isFetching = false;
      _enterprisesreal = entrs;
      print('here youssef$_enterprisesreal');
    });
  });

  }
  EnterpriseModel _selectedEnterprise;
  void _onEnterpriseSelected(EnterpriseModel enterprise) {
    setState(() {
      _selectedEnterprise = enterprise;
    });
  }

  void showMoreData() {
    setState(() {
      showMoreStatus = true;
      _isLoading = true;
    });
    ProductsWebService().getEnterprises(query != null ?
    _searchPage : _page, query: query,).then((entrs) {
      setState(() {
        showMoreStatus = false;
        _enterprises.addAll(entrs);
        _isLoading = false;
      });
    });
  }

  _searchEnterprises() async {
    _enterprisesSearch = null;
    _enterprisesSearch = await ProductsWebService().getEnterprises(0, query: query);
    setState(() {
      _isFetching = false;
      print("here the search$_enterprisesSearch");
    });
  }

  _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        print("comes to bottom zz");
      });
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

  @override
  void didPopNext() {
    Res.titleStream.add('شركات');
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Show Snackbar',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Search_Entreprise()));
            },
          ),

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
        //title:Text(widget.type),


        centerTitle: true,
      ),
      body:_enterprisesreal.isEmpty?!_isFetching
          ? (_enterprisesSearch != null && query != null )
              ? Center(child: Text("No company found"))
           :
      Padding(
        padding: EdgeInsets.only(
            bottom: 10.h, left: 0.h, right: 0.h),
        child: Padding(
          padding: EdgeInsets.only(bottom: 10.h, left: 2.h, right: 2.h),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h, left: 0.h, right: 0.h),
            child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount:  _enterprisesSearch != null
                  ? _enterprisesSearch.length
                  : _enterprises.length,
              itemBuilder: (context, index) {
                return _enterprises.length > 0
                    ?InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnterpriseScreen(
                        enterprise:
                        _enterprisesSearch !=
                            null
                            ? _enterprisesSearch[
                        index]
                            : _enterprises[
                        index],

                      ),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
                      height: 150.h,
                      width: 25.w,
                      decoration: BoxDecoration(
                        color: Colors.white10.withOpacity(0.80),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1.5,
                            blurRadius: 1.5,
                          ),
                        ],
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(

                                    _enterprisesSearch !=
                                        null
                                        ? (_enterprisesSearch[index].image !=
                                        ''
                                        ? 'https://bunyan.qa/images/agencies/' +
                                        _enterprisesSearch[index]
                                            .image
                                        : '')
                                        : (_enterprises[index].image !=
                                        ''
                                        ? 'https://bunyan.qa/images/agencies/' +
                                        _enterprises[index].image
                                        : ''),
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.w,),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 2.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(

                                          _enterprisesSearch !=
                                        null
                                        ? _enterprisesSearch[index]
                                            .name
                                            : _enterprises[index]
                                          .name,

                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                            fontSize: 18.0,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 4.h,),
                                      Row(
                                        children: [
                                          Icon(Icons.email,size: 30.sp,),
                                          SizedBox(width: 10.w,),
                                          Flexible(
                                            child: Text(
                                              _enterprisesSearch !=
                                                  null
                                                  ? _enterprisesSearch[index]
                                                  .email
                                                  : _enterprises[index]
                                                  .email,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14.0,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h,),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,size: 30.sp,),
                                          SizedBox(width: 10.w,),
                                          Text(
                                            _enterprisesSearch !=
                                                null
                                                ? _enterprisesSearch[index]
                                                .phone.toString()
                                                : _enterprises[index]
                                                .phone.toString(),
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14.0,
                                              height: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.0),
                                      _enterprises[index].address == null || _enterprisesSearch == null  ?Row():Row(
                                        children: [
                                          Icon(Icons.place,size: 30.sp,),
                                          SizedBox(width: 10.w,),
                                          Flexible(
                                            child: Text(
                                              _enterprisesSearch !=
                                                  null
                                                  ? _enterprisesSearch[index]
                                                  .address
                                                  : _enterprises[index]
                                                  .address,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14.0,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
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
                  ),
                ):Container();

              },
            ),
          ),

        ),

      ):
      Center(
              child: _loadingWidget(),
            ):!_isFetching
          ? (_enterprisesSearch != null && query != null )
          ? Center(child: Text("No company found"))
          :
      Padding(
        padding: EdgeInsets.only(
            bottom: 10.h, left: 0.h, right: 0.h),
        child: Padding(
          padding: EdgeInsets.only(bottom: 10.h, left: 2.h, right: 2.h),
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h, left: 0.h, right: 0.h),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount:  _enterprisesSearch != null
                  ? _enterprisesSearch.length
                  : _enterprisesreal.length,
              itemBuilder: (context, index) {
                return _enterprisesreal.length > 0
                    ?InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EnterpriseScreen(
                        enterprise:
                        _enterprisesSearch !=
                            null
                            ? _enterprisesSearch[
                        index]
                            : _enterprisesreal[
                        index],

                      ),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container(
                      height: 150.h,
                      width: 25.w,
                      decoration: BoxDecoration(
                        color: Colors.white10.withOpacity(0.80),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 2),
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1.5,
                            blurRadius: 1.5,
                          ),
                        ],
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 0,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(

                                    _enterprisesSearch !=
                                        null
                                        ? (_enterprisesSearch[index].image !=
                                        ''
                                        ? 'https://bunyan.qa/images/agencies/' +
                                        _enterprisesSearch[index]
                                            .image
                                        : '')
                                        : (_enterprisesreal[index].image !=
                                        ''
                                        ? 'https://bunyan.qa/images/agencies/' +
                                        _enterprisesreal[index].image
                                        : ''),
                                    width: 100.0,
                                    height: 100.0,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.w,),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 2.h,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(

                                          _enterprisesSearch !=
                                              null
                                              ? _enterprisesSearch[index]
                                              .name
                                              : _enterprisesreal[index]
                                              .name,

                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                            fontSize: 18.0,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: 4.h,),
                                      Row(
                                        children: [
                                          Icon(Icons.email,size: 30.sp,),
                                          SizedBox(width: 10.w,),
                                          Flexible(
                                            child: Text(
                                              _enterprisesSearch !=
                                                  null
                                                  ? _enterprisesSearch[index]
                                                  .email
                                                  : _enterprisesreal[index]
                                                  .email,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14.0,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.h,),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,size: 30.sp,),
                                          SizedBox(width: 10.w,),
                                          Text(
                                            _enterprisesSearch !=
                                                null
                                                ? _enterprisesSearch[index]
                                                .phone.toString()
                                                : _enterprisesreal[index]
                                                .phone.toString(),
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14.0,
                                              height: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4.0),
                                      _enterprisesreal[index].address == null || _enterprisesSearch == null  ?Row():Row(
                                        children: [
                                          Icon(Icons.place,size: 30.sp,),
                                          SizedBox(width: 10.w,),
                                          Flexible(
                                            child: Text(
                                              _enterprisesSearch !=
                                                  null
                                                  ? _enterprisesSearch[index]
                                                  .address
                                                  : _enterprisesreal[index]
                                                  .address,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                                fontSize: 14.0,
                                                height: 1.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
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
                  ),
                ):Container();

              },
            ),
          ),

        ),

      ):
      Center(
        child: _loadingWidget(),
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

  Widget _searchWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SizedBox(
        height: 65.sp,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onSubmitted: (value) {
                  setState(() {
                    if (value.isNotEmpty) {
                      _isFetching = true;
                      query = value;
                      _searchEnterprises();
                    } else {
                      setState(() {
                        _enterprisesSearch = null;
                        query = null;
                        _searchPage = 0;
                        _searchController.text = '';
                      });
                    }
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
                    suffixIcon: query != null
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _enterprisesSearch = null;
                                query = null;
                                _searchPage = 0;
                                _searchController.text = '';
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
                        color: Colors.black38, fontSize: 30.sp),
                    hintText: Languages.of(context).search),
              ),
            ),
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

  String _removeAllHtmlTags(String htmlText) {
    if (htmlText == null) return 'N/A';
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  void _sendMail(String email) {
    launch('mailto:$email');
  }

  void _call(String phone) {
    launch('tel:$phone');
  }
}

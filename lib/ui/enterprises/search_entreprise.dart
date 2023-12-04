import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../entreprise_chat/entreprise_list.dart';
import '../../localization/language/languages.dart';
import '../../localization/locale_constant.dart';
import '../../models/enterprise.dart';
import '../../tools/webservices/products.dart';
import '../main/main_screen.dart';
import '../notifications/notifications_screen.dart';
import 'enterprise.dart';

class Search_Entreprise extends StatefulWidget {
  const Search_Entreprise({Key key}) : super(key: key);

  @override
  State<Search_Entreprise> createState() => _Search_EntrepriseState();
}

class _Search_EntrepriseState extends State<Search_Entreprise> {

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
  bool _isSearchEmpty = false;

  _searchEnterprises() async {
    _enterprisesSearch = null;
    _enterprisesSearch = await ProductsWebService().getEnterprises(0, query: query);
    setState(() {
      _isFetching = false;
      print("here the search$_enterprisesSearch");
    });
    if (_enterprisesSearch.isEmpty) {
      setState(() {
        _isSearchEmpty = true;
      });
    } else {
      setState(() {
        _isSearchEmpty = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 30.sp),
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

      body: SingleChildScrollView(
        child: Column(
          children: [
            _enterprisesSearch == null ? _searchWidget() : _searchWidget(),

             Padding(
              padding: EdgeInsets.only(
                  bottom: 10.h, left: 8.h, right: 8.h),
              child:  _enterprisesSearch == null || _enterprisesSearch.isEmpty
                  ? Center(
                child: _isSearchEmpty
                    ? Text('No results found')
                    : Text('Search here'),
              )
                  :StaggeredGridView.countBuilder(
                  controller: _scrollController,
                  shrinkWrap: true,
                  crossAxisCount: 1,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  staggeredTileBuilder: (index) =>
                      StaggeredTile.fit(1),
                  itemCount: _enterprisesSearch.length,

                  itemBuilder: (context, index) {
                    return  InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EnterpriseScreen(
                            enterprise:
                            _enterprisesSearch !=
                                null
                                ? _enterprisesSearch[
                            index]
                                : _enterprisesSearch[
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

                                        'https://bunyan.qa/images/agencies/' +
                                            _enterprisesSearch[index]
                                                .image,

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

                                            _enterprisesSearch[index]
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
                                                 _enterprisesSearch[index]
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
                                               _enterprisesSearch[index]
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
                                          _enterprisesSearch[index].address == null || _enterprisesSearch == null  ?Row():Row(
                                            children: [
                                              Icon(Icons.place,size: 30.sp,),
                                              SizedBox(width: 10.w,),
                                              Flexible(
                                                child: Text(
                                                 _enterprisesSearch[index]
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
                    );

                  }),
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
  Widget _searchWidget() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      child: SizedBox(
        height: 50.h,
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
                          _isSearchEmpty = false;

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
}


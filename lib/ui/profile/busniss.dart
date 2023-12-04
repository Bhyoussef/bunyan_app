import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../localization/language/languages.dart';
import '../../localization/locale_constant.dart';
import '../../models/pakage.dart';
import '../../tools/webservices/addresses.dart';
import '../main/main_screen.dart';
import '../notifications/notifications_screen.dart';

class Business_Bakage extends StatefulWidget {
  const Business_Bakage({Key key}) : super(key: key);

  @override
  State<Business_Bakage> createState() => _Business_BakageState();
}

class _Business_BakageState extends State<Business_Bakage> {
  int _currentIndex = 0;
  List<Pakage> pakage = [];
  bool _isFetching = true;

  @override
  void initState() {
    getpakage();
    super.initState();
  }

  getpakage() async {
    final data = await AddressesWebService().getpakage();
    setState(() {
      pakage.addAll(data);
      print(pakage);
      _isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications_outlined,
              size: 40.sp,
            ),
            tooltip: 'Show Notifications',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NotificationsScreen()));
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.language_outlined,
              size: 40.sp,
            ),
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
          'Business',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 22.0.sp,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              color: Color(0xFF750606),
              child: Center(
                  child: Text(
                'Select Your Pakage',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              )),
            ),
            Container(
              height: 300,
              child: ListView.builder(
                itemCount: pakage.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    trailing: Text(pakage[index].price.toString()),
                    title: Text(pakage[index].name),
                    leading: Text(pakage[index].name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _bottomAppBar(),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
          ? FloatingActionButton(
              mini: true,
              backgroundColor: Colors.black,
              child: Icon(FontAwesome.plus),
              onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainScreen(
                            menu_index: 2,
                          )),
                  (route) => false),
            )
          : Container(),
    );
  }

  _bottomAppBar() {
    return BottomAppBar(
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
                print('indexx isssss:    $index');
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
    );
  }
}

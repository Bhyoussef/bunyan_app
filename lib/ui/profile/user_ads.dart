import 'package:bunyan/models/service.dart';
import 'package:bunyan/ui/profile/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../localization/locale_constant.dart';
import '../../models/person.dart';
import '../../models/product_list.dart';
import '../../tools/res.dart';
import '../../tools/webservices/advertises.dart';
import '../common/list_card_item.dart';
import '../common/list_card_item_service.dart';
import '../notifications/notifications_screen.dart';

class User_Ads extends StatefulWidget {
  final int userid;
  User_Ads({Key key, this.isMine, this.profile, this.product, this.userid, this.service})
      : super(key: key);
  final bool isMine;
  final PersonModel profile;

  List<ProductListModel> product = [];
  List<ServiceModel>service=[];

  @override
  State<User_Ads> createState() => _User_AdsState();
}

class _User_AdsState extends State<User_Ads> {


  void intState() {
    super.initState();
    setState(() {});
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
      body: SingleChildScrollView(
        child:Column(
          children: [
            widget.product==null?Center(child: Text('No data'),):Padding(
              padding: const EdgeInsets.all(8.0),
              child: _listView(),
            ),
           widget.service == null ?Center(child: Text('No data'),): Padding(
              padding: const EdgeInsets.all(8.0),
              child: _listViewServices(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.product.length,
      itemBuilder: (context, index) {
        final product = widget.product.length;
        return product == null
            ? Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: _shimmer(width: double.infinity, height: 300.0)),
              )
            : ListCardItem(product: widget.product[index]);
      },
    );
  }
  Widget _listViewServices() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: widget.service.length,
      itemBuilder: (context, index) {
        final product = widget.service.length;
        return product == null
            ? Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: _shimmer(width: double.infinity, height: 300.0)),
        )
            : ListCardItemService(service: widget.service[index]);
      },
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
}

import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/chat.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/chat/conversation_screen.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:shimmer/shimmer.dart';

import '../redirect_to_auth.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key key}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<ChatScreen> with RouteAware, RouteObserverMixin {
  List<ChatModel> _chats;

  @override
  void initState() {
    super.initState();
    Res.titleStream.add('الدردشة');


  }
 void getchat(){
    UsersWebService().getChats().then((value) {
      setState(() {
        _chats = value;
      });
    });
  }

  @override
  void didPopNext() {
    Res.titleStream.add('الدردشة');
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    print(_chats == null
        ? 2
        : _chats.isEmpty
            ? 0
            : 1);
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
        body: Res.USER != null
            ? true
                ? Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mode_comment_outlined,
                          color: Color(0xffd6d6d6),
                          size: 90.sp,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: ClayText(
                            Languages.of(context).noChats,
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
                : Stack(
                    //index: _chats == null ? 2 : _chats.isEmpty ? 0 : 1,
                    children: [
                      if (_chats == null)
                        Center(child: _loadingWidget())
                      else if (_chats.isEmpty)
                        Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mode_comment_outlined,
                                color: Color(0xffd6d6d6),
                                size: 90.sp,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: ClayText(
                                  Languages.of(context).noChats,
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
                        ListView.builder(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.h, vertical: 30.h),
                          itemCount: _chats.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ConversationScreen(
                                            chat: _chats[index],
                                            senderName:
                                                _chats[index].sender.name,
                                          ))),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: .045.sh),
                                    child: Card(
                                      elevation: 5.0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        child: Container(
                                          height: .15.sh,
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15.h),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: .07.sh,
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${_chats[index].sender.name} ارسل لك رسالة',
                                                    style: GoogleFonts.cairo(
                                                        fontSize: 25.sp,
                                                        color: Colors.black),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 22.w,
                                                    ),
                                                    child: Text(
                                                      _chats[index]
                                                          .date
                                                          .toIso8601String(),
                                                      style: GoogleFonts.cairo(
                                                          color: Colors.grey,
                                                          fontSize: 20.sp),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: .0,
                                    child: SizedBox(
                                      height: .15.sh,
                                      child: Center(
                                        child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(500.0)),
                                          elevation: 3.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(500.0),
                                            child: CachedNetworkImage(
                                                imageUrl:
                                                    _chats[index].sender.photo,
                                                progressIndicatorBuilder:
                                                    (_, __, ___) {
                                                  return _shimmer(
                                                      width: .1.sh,
                                                      height: .1.sh);
                                                },
                                                errorWidget: (_, __, ___) =>
                                                    Container(
                                                      width: .1.sh,
                                                      height: .1.sh,
                                                      child: Image.asset(
                                                          "assets/icons/avatar.png"),
                                                      color: Colors.white,
                                                    ),
                                                height: .1.sh,
                                                fit: BoxFit.cover,
                                                width: .1.sh),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  )
            : RedirectToAuth(
                destination: 'chats',
              ));
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

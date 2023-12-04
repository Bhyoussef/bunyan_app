import 'dart:async';

import 'package:bubble/bubble.dart';
import 'package:bunyan/localization/language/languages.dart';
import 'package:bunyan/localization/locale_constant.dart';
import 'package:bunyan/models/chat.dart';
import 'package:bunyan/models/person.dart';
import 'package:bunyan/tools/res.dart';
import 'package:bunyan/tools/webservices/users.dart';
import 'package:bunyan/ui/main/main_screen.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class ConversationScreen extends StatefulWidget {
  ConversationScreen({Key key, @required this.chat, this.senderName})
      : super(key: key);

  final ChatModel chat;
  final String senderName;

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen>
    with RouteAware, RouteObserverMixin {
  List<ChatModel> _chats;
  String _senderName;
  final _textToSend = TextEditingController();
  final _textEditStream = StreamController<String>.broadcast();
  final _scrollController = ScrollController();
  final _autoScrollController = AutoScrollController(axis: Axis.vertical);
  PersonModel _otherPerson;

  @override
  void initState() {
    print('getting chats');
    super.initState();
    _senderName = (widget.senderName) ?? 'الدردشة';
    Res.titleStream.add(_senderName);
    Res.bottomNavBarAnimStream.add(false);
    _otherPerson = widget.chat.receiver.id == Res.USER.id
        ? widget.chat.sender
        : widget.chat.receiver;
    UsersWebService().getConversation(widget.chat).then((value) {
      setState(() {
        print('got chats   $value');
        _chats = value;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    Res.bottomNavBarAnimStream.add(true);
  }

  @override
  void didPopNext() {
    Res.titleStream.add(_senderName);
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
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
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back_ios,
                color: Colors.black,
                size: 20.00,),
            ),
          ),
          title: Text(
              "",
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 22.0.sp,)
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),

     body: Container(
      child: _chats == null
          ? Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Color(0xffd6d6d6),size: 100.sp,
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _chats?.length ?? 0,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 20.h),
                      itemBuilder: (context, index) {
                        final chat = _chats[index];
                        return AutoScrollTag(
                          index: index,
                          key: ValueKey(index),
                          controller: _autoScrollController,
                          child: Bubble(
                            child: Text(
                              chat.message,
                              style: GoogleFonts.cairo(
                                  color: chat.sender.id == Res.USER.id
                                      ? Colors.white
                                      : Colors.black),
                            ),
                            margin: BubbleEdges.only(top: 20.h),
                            nip: chat.sender.id == Res.USER.id
                                ? BubbleNip.rightTop
                                : BubbleNip.leftBottom,
                            alignment: chat.sender.id == Res.USER.id
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            color: chat.sender.id == Res.USER.id
                                ? Colors.green
                                : Color(0xffcecece),
                            elevation: 3.0,
                          ),
                        );
                      }),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 20.h, horizontal: 30.w),
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(50000.0)),
                          child: TextField(
                            maxLines: 1,
                            controller: _textToSend,
                            onChanged: (txt) {
                              _textEditStream.add(txt);
                            },
                            keyboardType: TextInputType.text,
                            onSubmitted: (txt) {
                              if (txt.isNotEmpty) _sendMessage();
                            },
                            textInputAction: TextInputAction.send,
                            style: GoogleFonts.cairo(color: Colors.black),
                            decoration: InputDecoration(
                              hintText: Languages.of(context).yourmessage,
                              isDense: true,
                              isCollapsed: true,
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              hintStyle: GoogleFonts.cairo(
                                  color: Colors.black45, fontSize: 22.sp),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      StreamBuilder<String>(
                          stream: _textEditStream.stream,
                          builder: (context, snapshot) {
                            return InkWell(
                              onTap: (snapshot.data ?? "").isEmpty
                                  ? null
                                  : _sendMessage,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                                foregroundDecoration: BoxDecoration(
                                  color: (snapshot.data ?? '').isEmpty
                                      ? Colors.black26
                                      : null,
                                  shape: BoxShape.circle,
                                ),
                                padding: EdgeInsets.all(20.sp),
                                child: Icon(
                                  Icons.send_outlined,
                                  color: Colors.white,
                                  size: 40.sp,
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                ),
              ],
            ),
      )
    );
  }

  Future<void> _sendMessage() async {
    final chat = ChatModel(message: _textToSend.text, sender: Res.USER);
    setState(() {
      _chats.add(chat);
      _textEditStream.add('');
      _textToSend.clear();
    });
    Future.delayed(Duration(milliseconds: 10)).then((value) =>
        _scrollController.position
            .jumpTo(_scrollController.position.maxScrollExtent));
    try {
      await UsersWebService()
          .sendMessage(text: chat.message, receiver: _otherPerson.id);
    } on DioError catch (e) {
      setState(() {
        _chats.remove(chat);
      });
      _showErrorDialog();
    }
  }

  void _showErrorDialog({String text}) {
    showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
              content: SingleChildScrollView(
                child: Text(
                  text?? Languages.of(context).servererror,
                  style: GoogleFonts.cairo(),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      Languages.of(context).agreeon,
                      style: GoogleFonts.cairo(color: Colors.teal),
                    ))
              ],
            ));
  }

}

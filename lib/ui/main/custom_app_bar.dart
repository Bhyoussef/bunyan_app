import 'package:bunyan/tools/res.dart';
import 'package:bunyan/ui/notifications/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final double height;
  final BuildContext ctx;
  final String title;
  final bool showNotif;

  const CustomAppBar(
      {Key key, this.height, this.ctx, this.title, this.showNotif = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            //drawer
            Scaffold.of(context).hasDrawer
                ? InkWell(
                    onTap: () {
                      if (Scaffold.of(context).hasDrawer) {
                        Scaffold.of(context).openDrawer();
                      }
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 13.0, horizontal: 20.0),
                      child: Icon(Icons.menu),
                    ),
                  )
                : Container(),

            //title
            title != null
                ? Text(
                    title,
                    style: GoogleFonts.cairo(
                        fontSize: 30.sp, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )
                : Container(),

            //leading
            InkWell(
              onTap: () {
                if (Navigator.of(ctx).canPop())
                  Navigator.of(ctx).maybePop();
                else if (showNotif) {
                  Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (context) => NotificationsScreen())).then((value) => Res.bottomNavBarAnimStream.add(true));
                  Res.bottomNavBarAnimStream.add(false);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 13.0, horizontal: 20.0),
                child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Navigator.of(ctx).canPop() || showNotif
                        ? Icon(
                            Navigator.of(ctx).canPop()
                                ? Icons.arrow_back_ios
                                : Icons.notifications_none,
                            color: Colors.black,
                          )
                        : Container()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size(double.infinity, height);
}

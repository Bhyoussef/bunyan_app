import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProfileInfo extends StatefulWidget {
  final String imagePath;
  final bool isMyProfile;

  ProfileInfo(this.imagePath, this.isMyProfile);

  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  String image;
  @override
  void initState() {
    setState(() {
      print(image);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).primaryColor;

    return Center(
      child: Stack(
        children: [
          buildImage(),
              widget.isMyProfile ? Positioned(
                  bottom: 0,
                  right: 4,
                  child: buildEditIcon(color)
                ): Container(),

        ],
      ),
    );
  }

  Widget buildImage() {
    return ClipOval(
      child: Container(
        width: 129.0,
        height: 129.0,
        decoration: new BoxDecoration(
          color: const Color(0xff7c94b6),
          borderRadius: new BorderRadius.all(new Radius.circular(99999)),
          border: Border.all(color: Colors.white, width: 1.0),
          boxShadow: [
            BoxShadow(
              offset: Offset(0.7, 1.2),
              blurRadius: 6,
              color: Color.fromRGBO(0, 0, 0, 0.45),
            ),
          ],
        ),
        child: ClipRRect(
          child: CachedNetworkImage(
            imageUrl: widget.imagePath,
              progressIndicatorBuilder: (_, __, ___) {
                return Shimmer.fromColors(
                  baseColor: const Color(0xFFf3f3f3),
                  highlightColor: const Color(0xFFE8E8E8),
                  child: Container(
                    height: 129,
                    width: 129,
                    color: Colors.grey,
                  ),
                );
              },
              errorWidget: (_, __, ___) => Container(
                width: 129,
                height: 129,
                child:
                Image.asset("assets/icons/avatar.png"),
                color: Colors.white,
              ),
              height: 129,
              fit: BoxFit.fill,
              width: 129
          )
        ),
      ),
    );
  }

  Widget buildEditIcon(Color color) => buildCircle(
        color: Colors.white,
        all: 3,
        child: buildCircle(
          color: color,
          all: 8,
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 20,
          ),
        ),
      );

  Widget buildCircle({
    Widget child,
    double all,
    Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );
}

import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String title;
  final IconData leftIcon;
  final Widget rightWidget;
  final Color color;
  ActionButton(this.title, this.leftIcon, this.rightWidget, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.5, color: Color(0XFFE8E8E8)),
        ),
      ),
      child: Container(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(
                    leftIcon,
                    color: color,
                    size: 28,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            rightWidget
          ],
        ),
      ),
    );
  }
}

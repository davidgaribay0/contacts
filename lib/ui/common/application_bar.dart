import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ApplicationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const ApplicationBar(this.title, {Key? key, this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // leading: Icon(Icons.close),
      elevation: 0,
      iconTheme: const IconThemeData(
        color: Colors.black, //change your color here
      ),
      actions: actions,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark),
    );
  }

  @override
  Size get preferredSize =>
      new Size.fromHeight(new AppBar().preferredSize.height);
}

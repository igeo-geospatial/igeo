import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class IgeoAppbar {
  const IgeoAppbar();

  static getBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context); // Goes back to the previous screen
        },
      ),
      title: const Text(
        "iGeo",
        style: TextStyle(color: Colors.white),
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }

  static getBarWithoutBack(BuildContext context) {
    return AppBar(
      title: const Text(
        "iGeo",
        style: TextStyle(color: Colors.white),
      ),
      automaticallyImplyLeading: false,
      centerTitle: true,
    );
  }
}

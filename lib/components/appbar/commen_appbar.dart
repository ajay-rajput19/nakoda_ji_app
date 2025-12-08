import 'package:flutter/material.dart';
import 'package:nakoda_ji/data/static/asset_exports.dart';
import 'package:nakoda_ji/data/static/color_export.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const CommonAppBar({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: CustomColors.clrBtnBg,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      automaticallyImplyActions: false,
      automaticallyImplyLeading: false,

      title: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Image.asset(AssetExports.loginImg, height: 45),
      ),

      actions: [
        IconButton(
          icon: const Icon(Icons.menu, size: 30, color: Colors.white),
          onPressed: () {
            scaffoldKey?.currentState?.openEndDrawer();
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

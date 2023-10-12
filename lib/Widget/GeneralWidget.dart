import 'dart:math';

import 'package:flutter/material.dart';

import '../Database/Database.dart';
import 'AppColor.dart';
import 'AppIcons.dart';
import 'AppSize.dart';
import 'AppText.dart';

class AppWidget {
//scroll body===========================================================
  static Widget body({required Widget? child}) {
    return LayoutBuilder(builder: ((context, constraints) {
      return NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (OverscrollIndicatorNotification? overscroll) {
            overscroll!.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
              child: ConstrainedBox(
            constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
                minHeight: constraints.maxHeight),
            child: IntrinsicHeight(child: child),
          )));
// AppText(text: LocaleKeys.myTeam.tr(), fontSize: WidgetSize.titleTextSize);
    }));
  }

  //===============================================================================================
  static List<PopupMenuItem> itemList({required action}) {
    return [
      PopupMenuItem(
        padding: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(
            AppIcons.profile,
            color: AppColor.white,
          ),
          title: AppText(
            text: 'Hello Admin',
            fontSize: AppSize.subTextSize,
            color: AppColor.white,
          ),
        ),
      ),
      PopupMenuItem(
          child: Divider(
        color: AppColor.white,
        thickness: 1,
      )),
      //====================================
      PopupMenuItem(
        child: ListTile(
          onTap: action,
          leading: Icon(
            AppIcons.logout,
            color: AppColor.white,
          ),
          title: AppText(
            text: 'Log out',
            fontSize: AppSize.subTextSize,
            color: AppColor.white,
          ),
        ),
      ),
    ];
  }

  //======================random number=======================================
  static String randomNumber(int length) {
    const characters = '0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

//==================random upper char=============================================
  static String randomUpper(int length) {
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

//==================random lower char=============================================
  static String randomLower(int length) {
    const characters = 'abcdefghijklmnopqrstuvwxyz';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }

//==================random char=============================================
  static String randomCode(int length) {
    const characters = '#%^*_-!';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length,
        (_) => characters.codeUnitAt(random.nextInt(characters.length))));
  }
}


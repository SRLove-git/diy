import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13981.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13995.dart';

class CustomWidget_6_14044 extends StatelessWidget {
 CustomWidget_6_14044({super.key});
    late final ImageProvider _image_tbbn6_14013 = MemoryImage(imageStr_byvr6_14013.decodeBase64Image());
  late final ImageProvider _image_qjaa6_14017 = MemoryImage(imageStr_ufoi6_14017.decodeBase64Image());
  late final ImageProvider _image_bmfh6_14021 = MemoryImage(imageStr_jlip6_14021.decodeBase64Image());
  late final ImageProvider _image_glch6_14025 = MemoryImage(imageStr_gmcx6_14025.decodeBase64Image());
  late final ImageProvider _image_sigi6_14029 = MemoryImage(imageStr_lznm6_14029.decodeBase64Image());
  late final ImageProvider _image_cygu6_14033 = MemoryImage(imageStr_yrul6_14033.decodeBase64Image());
  late final ImageProvider _image_kooq6_14044 = MemoryImage(imageStr_detq6_14044.decodeBase64Image());
  late final ImageProvider _image_ntna6_14045 = MemoryImage(imageStr_kekt6_14045.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 169.h,
          left: 0.w,
          top: 120.h,
          child: Container(
            decoration: BoxDecoration(image: DecorationImage(image: _image_kooq6_14044, fit: BoxFit.fill),borderRadius: BorderRadius.only(  bottomLeft: Radius.circular(24.h), bottomRight: Radius.circular(24.h),),),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              key: ValueKey("6:14044"),
              children: [
                Positioned(
                  width: 440.w,
                  height: 169.h,
                  left: 0.w,
                  top: 0.h,
                  child: Container(
                    key: ValueKey("6:14045"),
                    decoration: BoxDecoration(image: DecorationImage(image: _image_ntna6_14045, fit: BoxFit.fill),),),),
                Positioned(
                  width: 176.39.w,
                  height: 55.h,
                  left: 18.w,
                  top: 98.h,
                  child: Stack(
                    key: ValueKey("6:14046"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        width: 176.39.w,
                        height: 32.h,
                        left: 0.w,
                        top: 0.h,
                        child: Stack(
                          key: ValueKey("6:14047"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 178.w,
                              height: 28.h,
                              left: 0.w,
                              top: 1.h,
                              child: Text("# 芙宁娜的后花园",
                                key: ValueKey("6:14048"),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                          ],),),
                      Positioned(
                        width: 176.39.w,
                        height: 23.h,
                        left: 0.w,
                        top: 32.h,
                        child: SingleChildScrollView(
                          clipBehavior: Clip.none,
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(minWidth: 176.39.w, minHeight: 23.h),
                            padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 4.h,bottom: 0.h),
                            child: Column(
                              key: ValueKey("6:14049"),
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 176.39.w,
                                  height: 19.h,
                                  child: Opacity(
                                    opacity: 0.85,
                                    child: Stack(
                                      key: ValueKey("6:14050"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 138.w,
                                          height: 17.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("3.2k 帖子 · 1.8w 关注",
                                            key: ValueKey("6:14051"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),),
                              ],),),),),
                    ],),),
              ],),),);
  }
}

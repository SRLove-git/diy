import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14762.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_6_14783 extends StatelessWidget {
 CustomWidget_6_14783({super.key});
    late final ImageProvider _image_ldxe6_14785 = MemoryImage(imageStr_pgwh6_14785.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 749.h,
          left: 0.w,
          top: 120.h,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(minWidth: 440.w, minHeight: 749.h),
              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 16.h,bottom: 16.h),
              child: Column(
                key: ValueKey("6:14783"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.h,
                children: [
                  SizedBox(
                    width: 403.9.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 45.h),
                        child: Row(
                          key: ValueKey("6:14784"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8.w,
                          children: [
                            SizedBox(
                              width: 36.1.w,
                              child: SingleChildScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 36.1.w, minHeight: 36.h),
                                  decoration: BoxDecoration(image: DecorationImage(image: _image_ldxe6_14785, fit: BoxFit.fill),borderRadius: BorderRadius.circular(16.h),),
                                  clipBehavior: Clip.hardEdge,
                                  child: Row(
                                    key: ValueKey("6:14785"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 36.1.w,
                                        height: 17.h,
                                        child: Text("豆",
                                          key: ValueKey("6:14786"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                    ],),),),),
                            Container(
                              width: 129.9.w,
                              height: 45.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(4.h), bottomRight: Radius.circular(16.h),),),
                              child: Stack(
                                key: ValueKey("6:14787"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 100.w,
                                    height: 20.h,
                                    left: 16.w,
                                    top: 11.h,
                                    child: Text("哈哈 太好笑了",
                                      key: ValueKey("6:14788"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 403.9.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 45.h),
                        child: Row(
                          key: ValueKey("6:14789"),
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 173.74.w,
                              height: 45.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(16.h), bottomRight: Radius.circular(4.h),),),
                              child: Stack(
                                key: ValueKey("6:14790"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 144.w,
                                    height: 20.h,
                                    left: 16.w,
                                    top: 12.h,
                                    child: Text("真的吗？我拍给你看",
                                      key: ValueKey("6:14791"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                ],),),),);
  }
}

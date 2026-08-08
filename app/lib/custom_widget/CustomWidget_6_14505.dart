import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_6_14505 extends StatelessWidget {
 CustomWidget_6_14505({super.key});
    late final ImageProvider _image_hcny6_14506 = MemoryImage(imageStr_ohte6_14506.decodeBase64Image());
  late final ImageProvider _image_nmsr6_14507 = MemoryImage(imageStr_vmpp6_14507.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 952.h,
          left: 0.w,
          top: 0.h,
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(13, 13, 15,1),),
            child: Stack(
              key: ValueKey("6:14505"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 394.87.w,
                  height: 451.h,
                  left: 23.w,
                  top: 203.h,
                  child: Container(
                    decoration: BoxDecoration(image: DecorationImage(image: _image_hcny6_14506, fit: BoxFit.fill),borderRadius: BorderRadius.circular(16.h),),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      key: ValueKey("6:14506"),
                      children: [
                        Positioned(
                          width: 394.87.w,
                          height: 451.h,
                          left: 0.w,
                          top: 0.h,
                          child: Container(
                            key: ValueKey("6:14507"),
                            decoration: BoxDecoration(image: DecorationImage(image: _image_nmsr6_14507, fit: BoxFit.fill),),),),
                      ],),),),
                Positioned(
                  width: 440.w,
                  height: 70.h,
                  left: 0.w,
                  top: 0.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 440.w, minHeight: 70.h),
                      padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                      child: Row(
                        key: ValueKey("6:14508"),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 38.36.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 38.36.w, minHeight: 38.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.16),borderRadius: BorderRadius.circular(17.h),),
                                child: Row(
                                  key: ValueKey("6:14509"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("6:14510"),
                                      width: 20.31.w,
                                      height: 20.h,),
                                  ],),),),),
                          Container(
                            width: 49.66.w,
                            height: 26.h,
                            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0,0.35),borderRadius: BorderRadius.circular(10.h),),
                            child: Stack(
                              key: ValueKey("6:14511"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 29.w,
                                  height: 17.h,
                                  left: 11.w,
                                  top: 4.h,
                                  child: Text("图片",
                                    key: ValueKey("6:14512"),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                              ],),),
                          SizedBox(
                            width: 38.36.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 38.36.w, minHeight: 38.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.16),borderRadius: BorderRadius.circular(17.h),),
                                child: Row(
                                  key: ValueKey("6:14513"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("6:14514"),
                                      width: 20.31.w,
                                      height: 20.h,),
                                  ],),),),),
                        ],),),),),
              ],),),);
  }
}

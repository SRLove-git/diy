import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_5_54874 extends StatelessWidget {
 CustomWidget_5_54874({super.key});
    late final ImageProvider _image_degp5_54875 = MemoryImage(imageStr_imageStr_iidv5_54875.decodeBase64Image());
  late final ImageProvider _image_reyk5_54876 = MemoryImage(imageStr_imageStr_doqs5_54876.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 844.h,
          left: 0.w,
          top: 0.h,
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(13, 13, 15,1),),
            child: Stack(
              key: ValueKey("5:54874"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 350.w,
                  height: 400.h,
                  left: 20.w,
                  top: 180.h,
                  child: Container(
                    decoration: BoxDecoration(image: DecorationImage(image: _image_degp5_54875, fit: BoxFit.fill),borderRadius: BorderRadius.circular(16.h),),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      key: ValueKey("5:54875"),
                      children: [
                        Positioned(
                          width: 350.w,
                          height: 400.h,
                          left: 0.w,
                          top: 0.h,
                          child: Container(
                            key: ValueKey("5:54876"),
                            decoration: BoxDecoration(image: DecorationImage(image: _image_reyk5_54876, fit: BoxFit.fill),),),),
                      ],),),),
                Positioned(
                  width: 390.w,
                  height: 62.h,
                  left: 0.w,
                  top: 0.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 390.w, minHeight: 62.h),
                      padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                      child: Row(
                        key: ValueKey("5:54877"),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 34.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.16),borderRadius: BorderRadius.circular(17.h),),
                                child: Row(
                                  key: ValueKey("5:54878"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:54879"),
                                      width: 18.w,
                                      height: 18.h,),
                                  ],),),),),
                          Container(
                            width: 44.02.w,
                            height: 23.h,
                            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0,0.35),borderRadius: BorderRadius.circular(10.h),),
                            child: Stack(
                              key: ValueKey("5:54880"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 26.w,
                                  height: 17.h,
                                  left: 10.w,
                                  top: 2.h,
                                  child: Text("图片",
                                    key: ValueKey("5:54881"),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                              ],),),
                          SizedBox(
                            width: 34.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.16),borderRadius: BorderRadius.circular(17.h),),
                                child: Row(
                                  key: ValueKey("5:54882"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:54883"),
                                      width: 18.w,
                                      height: 18.h,),
                                  ],),),),),
                        ],),),),),
              ],),),);
  }
}

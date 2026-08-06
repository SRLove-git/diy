import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_55216.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_55237.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_55246.dart';

class Frame_5_55215 extends StatefulWidget {

  Frame_5_55215({super.key,});
  @override
  State<Frame_5_55215> createState() => _Frame_5_55215State();
}

class _Frame_5_55215State extends State<Frame_5_55215> {
  late final ImageProvider _image_oxol5_55239 = MemoryImage(imageStr_imageStr_iqkj5_55239.decodeBase64Image());

  @override
  void initState() {
    super.initState();
  
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil().rootSize = Size(390, 844);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: SizedBox(
            width: 390.w,
            height: 844.h,
            child: ListView(
              children: [
                Container(
                width: 390.w,
                height: 844.h,
                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  key: ValueKey("5:55215"),
                  children: [
                    CustomWidget_5_55216(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:55230"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 40.w,
                            height: 40.h,
                            left: 8.w,
                            top: 2.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                                child: Row(
                                  key: ValueKey("5:55231"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:55232"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:55233"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 53.w,
                                  height: 23.h,
                                  left: 170.w,
                                  top: 0.h,
                                  child: Text("小豆子",
                                    key: ValueKey("5:55234"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 8.w,
                            height: 8.h,
                            left: 370.w,
                            top: 18.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 8.w, minHeight: 8.h),
                                child: Row(
                                  key: ValueKey("5:55235"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 16.w,
                                  children: [
                                    Container(
                                      key: ValueKey("5:55236"),
                                      width: 8.w,
                                      height: 8.h,
                                      decoration: BoxDecoration(color: Color.fromRGBO(52, 199, 89,1),borderRadius: BorderRadius.circular(4.h),),),
                                  ],),),),),
                        ],),),
                    CustomWidget_5_55237(),
                    CustomWidget_5_55246(),
                    Positioned(
                      width: 145.39.w,
                      height: 33.h,
                      left: 122.w,
                      top: 118.h,
                      child: Container(
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.88),borderRadius: BorderRadius.circular(18.h),),
                        child: Stack(
                          key: ValueKey("5:55257"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 115.w,
                              height: 17.h,
                              left: 16.w,
                              top: 7.h,
                              child: Text("松开发送 · 上滑取消",
                                key: ValueKey("5:55258"),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                          ],),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

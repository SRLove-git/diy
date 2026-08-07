import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14472.dart';

class Frame_6_14465 extends StatefulWidget {

  Frame_6_14465({super.key,});
  @override
  State<Frame_6_14465> createState() => _Frame_6_14465State();
}

class _Frame_6_14465State extends State<Frame_6_14465> {
  late final ImageProvider _image_ncji6_14468 = MemoryImage(imageStr_mcmx6_14468.decodeBase64Image());
  late final ImageProvider _image_soou6_14469 = MemoryImage(imageStr_same6_14469.decodeBase64Image());
  late final ImageProvider _image_oujv6_14472 = MemoryImage(imageStr_ujwl6_14472.decodeBase64Image());

  @override
  void initState() {
    super.initState();
  
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil().rootSize = Size(440, 956);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: SizedBox(
            width: 440.w,
            height: 956.h,
            child: ListView(
              children: [
                Container(
                width: 440.w,
                height: 956.h,
                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  key: ValueKey("6:14465"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:14466"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 440.w,
                            height: 952.h,
                            left: 0.w,
                            top: 0.h,
                            child: Container(
                              decoration: BoxDecoration(color: Color.fromRGBO(13, 13, 15,1),),
                              child: Stack(
                                key: ValueKey("6:14467"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 394.87.w,
                                    height: 451.h,
                                    left: 23.w,
                                    top: 203.h,
                                    child: Container(
                                      decoration: BoxDecoration(image: DecorationImage(image: _image_ncji6_14468, fit: BoxFit.fill),borderRadius: BorderRadius.circular(16.h),),
                                      clipBehavior: Clip.hardEdge,
                                      child: Stack(
                                        key: ValueKey("6:14468"),
                                        children: [
                                          Positioned(
                                            width: 394.87.w,
                                            height: 451.h,
                                            left: 0.w,
                                            top: 0.h,
                                            child: Container(
                                              key: ValueKey("6:14469"),
                                              decoration: BoxDecoration(image: DecorationImage(image: _image_soou6_14469, fit: BoxFit.fill),),),),
                                          Positioned(
                                            width: 195.3.w,
                                            height: 17.h,
                                            left: 11.w,
                                            top: 423.h,
                                            child: Stack(
                                              key: ValueKey("6:14470"),
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  width: 197.w,
                                                  height: 15.h,
                                                  left: 0.w,
                                                  top: 0.h,
                                                  child: Text("新到的星空拼豆配色 · 08-06 14:20",
                                                    key: ValueKey("6:14471"),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                              ],),),
                                        ],),),),
                                  CustomWidget_6_14472(),
                                  Positioned(
                                    width: 175.94.w,
                                    height: 25.h,
                                    left: 121.w,
                                    top: 122.h,
                                    child: Container(
                                      decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.14),borderRadius: BorderRadius.circular(14.h),),
                                      child: Stack(
                                        key: ValueKey("6:14494"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 169.w,
                                            height: 15.h,
                                            left: 16.w,
                                            top: 6.h,
                                            child: Text("双击放大 · 长按弹出操作菜单",
                                              key: ValueKey("6:14495"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
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
                                          key: ValueKey("6:14496"),
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
                                                    key: ValueKey("6:14497"),
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        key: ValueKey("6:14498"),
                                                        width: 20.31.w,
                                                        height: 20.h,),
                                                    ],),),),),
                                            Container(
                                              width: 49.66.w,
                                              height: 26.h,
                                              decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0,0.35),borderRadius: BorderRadius.circular(10.h),),
                                              child: Stack(
                                                key: ValueKey("6:14499"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 29.w,
                                                    height: 17.h,
                                                    left: 11.w,
                                                    top: 4.h,
                                                    child: Text("图片",
                                                      key: ValueKey("6:14500"),
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
                                                    key: ValueKey("6:14501"),
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        key: ValueKey("6:14502"),
                                                        width: 20.31.w,
                                                        height: 20.h,),
                                                    ],),),),),
                                          ],),),),),
                                ],),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

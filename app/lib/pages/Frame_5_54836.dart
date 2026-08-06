import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54842.dart';

class Frame_5_54836 extends StatefulWidget {

  Frame_5_54836({super.key,});
  @override
  State<Frame_5_54836> createState() => _Frame_5_54836State();
}

class _Frame_5_54836State extends State<Frame_5_54836> {
  late final ImageProvider _image_wwkr5_54838 = MemoryImage(imageStr_imageStr_jsbq5_54838.decodeBase64Image());
  late final ImageProvider _image_tipw5_54839 = MemoryImage(imageStr_imageStr_crmx5_54839.decodeBase64Image());
  late final ImageProvider _image_pydy5_54842 = MemoryImage(imageStr_imageStr_rped5_54842.decodeBase64Image());

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
                  key: ValueKey("5:54836"),
                  children: [
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        decoration: BoxDecoration(color: Color.fromRGBO(13, 13, 15,1),),
                        child: Stack(
                          key: ValueKey("5:54837"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 350.w,
                              height: 400.h,
                              left: 20.w,
                              top: 180.h,
                              child: Container(
                                decoration: BoxDecoration(image: DecorationImage(image: _image_wwkr5_54838, fit: BoxFit.fill),borderRadius: BorderRadius.circular(16.h),),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  key: ValueKey("5:54838"),
                                  children: [
                                    Positioned(
                                      width: 350.w,
                                      height: 400.h,
                                      left: 0.w,
                                      top: 0.h,
                                      child: Container(
                                        key: ValueKey("5:54839"),
                                        decoration: BoxDecoration(image: DecorationImage(image: _image_tipw5_54839, fit: BoxFit.fill),),),),
                                    Positioned(
                                      width: 173.11.w,
                                      height: 15.h,
                                      left: 10.w,
                                      top: 375.h,
                                      child: Stack(
                                        key: ValueKey("5:54840"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 175.w,
                                            height: 15.h,
                                            left: 0.w,
                                            top: -1.h,
                                            child: Text("新到的星空拼豆配色 · 08-06 14:20",
                                              key: ValueKey("5:54841"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                        ],),),
                                  ],),),),
                            CustomWidget_5_54842(),
                            Positioned(
                              width: 175.94.w,
                              height: 25.h,
                              left: 107.w,
                              top: 108.h,
                              child: Container(
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.14),borderRadius: BorderRadius.circular(14.h),),
                                child: Stack(
                                  key: ValueKey("5:54864"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 150.w,
                                      height: 15.h,
                                      left: 14.w,
                                      top: 4.h,
                                      child: Text("双击放大 · 长按弹出操作菜单",
                                        key: ValueKey("5:54865"),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
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
                                    key: ValueKey("5:54866"),
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
                                              key: ValueKey("5:54867"),
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  key: ValueKey("5:54868"),
                                                  width: 18.w,
                                                  height: 18.h,),
                                              ],),),),),
                                      Container(
                                        width: 44.02.w,
                                        height: 23.h,
                                        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0,0.35),borderRadius: BorderRadius.circular(10.h),),
                                        child: Stack(
                                          key: ValueKey("5:54869"),
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              width: 26.w,
                                              height: 17.h,
                                              left: 10.w,
                                              top: 2.h,
                                              child: Text("图片",
                                                key: ValueKey("5:54870"),
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
                                              key: ValueKey("5:54871"),
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  key: ValueKey("5:54872"),
                                                  width: 18.w,
                                                  height: 18.h,),
                                              ],),),),),
                                    ],),),),),
                          ],),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14438.dart';

class Frame_6_14429 extends StatefulWidget {

  Frame_6_14429({super.key,});
  @override
  State<Frame_6_14429> createState() => _Frame_6_14429State();
}

class _Frame_6_14429State extends State<Frame_6_14429> {
  late final ImageProvider _image_twec6_14432 = MemoryImage(imageStr_ctra6_14432.decodeBase64Image());
  late final ImageProvider _image_jpua6_14433 = MemoryImage(imageStr_qefs6_14433.decodeBase64Image());
  late final ImageProvider _image_pxya6_14438 = MemoryImage(imageStr_tdgy6_14438.decodeBase64Image());

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
                  key: ValueKey("6:14429"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:14430"),
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
                                key: ValueKey("6:14431"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 440.w,
                                    height: 844.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Container(
                                      decoration: BoxDecoration(image: DecorationImage(image: _image_twec6_14432, fit: BoxFit.fill),),
                                      clipBehavior: Clip.hardEdge,
                                      child: Stack(
                                        key: ValueKey("6:14432"),
                                        children: [
                                          Positioned(
                                            width: 440.w,
                                            height: 844.h,
                                            left: 0.w,
                                            top: 0.h,
                                            child: Container(
                                              key: ValueKey("6:14433"),
                                              decoration: BoxDecoration(image: DecorationImage(image: _image_jpua6_14433, fit: BoxFit.fill),),),),
                                          Positioned(
                                            width: 64.w,
                                            height: 64.h,
                                            left: 184.w,
                                            top: 386.h,
                                            child: Container(
                                              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.92),borderRadius: BorderRadius.circular(32.h),),
                                              child: Stack(
                                                key: ValueKey("6:14434"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 29.33.w,
                                                    height: 29.h,
                                                    left: 8.w,
                                                    top: 4.h,
                                                    child: Container(
                                                      key: ValueKey("6:14435"),
                                                      decoration: BoxDecoration(border: Border(left: BorderSide(width: 11.w,color: Color.fromRGBO(20, 20, 20,1),),bottom: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),top: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),),),),),
                                                ],),),),
                                        ],),),),
                                  Positioned(
                                    width: 280.68.w,
                                    height: 19.h,
                                    left: 14.w,
                                    top: 800.h,
                                    child: Opacity(
                                      opacity: 0.9,
                                      child: Stack(
                                        key: ValueKey("6:14436"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 283.w,
                                            height: 17.h,
                                            left: 0.w,
                                            top: 0.h,
                                            child: Text("@手作阿周 · 3 分钟学会渐变拼豆 #拼豆 #教程",
                                              key: ValueKey("6:14437"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                        ],),),),
                                  CustomWidget_6_14438(),
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
                                          key: ValueKey("6:14458"),
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
                                                    key: ValueKey("6:14459"),
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        key: ValueKey("6:14460"),
                                                        width: 20.31.w,
                                                        height: 20.h,),
                                                    ],),),),),
                                            Container(
                                              width: 126.36.w,
                                              height: 22.h,
                                              child: Stack(
                                                key: ValueKey("6:14461"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 128.w,
                                                    height: 20.h,
                                                    left: 0.w,
                                                    top: 0.h,
                                                    child: Text("渐变拼豆新手教程",
                                                      key: ValueKey("6:14462"),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
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
                                                    key: ValueKey("6:14463"),
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        key: ValueKey("6:14464"),
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

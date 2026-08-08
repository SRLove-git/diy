import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9517.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9531.dart';

class Frame_6_9515 extends StatefulWidget {

  Frame_6_9515({super.key,});
  @override
  State<Frame_6_9515> createState() => _Frame_6_9515State();
}

class _Frame_6_9515State extends State<Frame_6_9515> {
  late final ImageProvider _image_pnyu6_9564 = MemoryImage(imageStr_zkwk6_9564.decodeBase64Image());
  late final ImageProvider _image_itvz6_9578 = MemoryImage(imageStr_rpmk6_9578.decodeBase64Image());
  late final ImageProvider _image_ttqw6_9597 = MemoryImage(imageStr_imqi6_9597.decodeBase64Image());

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
                  key: ValueKey("6:9515"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:9516"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_9517(),
                          CustomWidget_6_9531(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:9590"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 45.13.w,
                                  height: 45.h,
                                  left: 8.w,
                                  top: 2.5.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 45.13.w, minHeight: 45.h),
                                      child: Row(
                                        key: ValueKey("6:9591"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:9592"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:9593"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 79.w,
                                        height: 23.h,
                                        left: 182.w,
                                        top: 1.h,
                                        child: Text("作品详情",
                                          key: ValueKey("6:9594"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 24.82.w,
                                  height: 30.h,
                                  left: 397.w,
                                  top: 10.h,
                                  child: Stack(
                                    key: ValueKey("6:9595"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 24.82.w,
                                        height: 25.h,
                                        left: 0.w,
                                        top: 0.h,
                                        child: Container(
                                          key: ValueKey("6:9596"),),),
                                    ],),),
                              ],),),
                          Positioned(
                            width: 440.w,
                            height: 338.h,
                            left: 0.w,
                            top: 120.h,
                            child: Container(
                              decoration: BoxDecoration(image: DecorationImage(image: _image_ttqw6_9597, fit: BoxFit.fill),borderRadius: BorderRadius.only(  bottomLeft: Radius.circular(20.h), bottomRight: Radius.circular(20.h),),),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                key: ValueKey("6:9597"),
                                children: [
                                  Positioned(
                                    width: 139.3.w,
                                    height: 17.h,
                                    left: 11.w,
                                    top: 309.h,
                                    child: Stack(
                                      key: ValueKey("6:9598"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 141.w,
                                          height: 15.h,
                                          left: 0.w,
                                          top: 1.h,
                                          child: Text("作品 · 星空拼豆 2000 颗",
                                            key: ValueKey("6:9599"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),),
                          Positioned(
                            width: 440.w,
                            height: 77.h,
                            left: 0.w,
                            top: 875.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 440.w, minHeight: 77.h),
                                padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 1.h,bottom: 0.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
                                child: Row(
                                  key: ValueKey("6:9600"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 12.w,
                                  children: [
                                    SizedBox(
                                      width: 329.42.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 329.42.w, minHeight: 47.h),
                                          padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(21.h),),
                                          child: Row(
                                            key: ValueKey("6:9601"),
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 8.w,
                                            children: [
                                              Container(
                                                width: 73.35.w,
                                                height: 21.h,
                                                child: Stack(
                                                  key: ValueKey("6:9602"),
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      width: 75.w,
                                                      height: 18.h,
                                                      left: 0.w,
                                                      top: 1.h,
                                                      child: Text("说点什么…",
                                                        key: ValueKey("6:9603"),
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                  ],),),
                                            ],),),),),
                                    SizedBox(
                                      width: 60.94.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 60.94.w, minHeight: 43.h),
                                          padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                                          child: Row(
                                            key: ValueKey("6:9604"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 32.94.w,
                                                height: 18.h,
                                                child: Text("发送",
                                                  key: ValueKey("6:9605"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),),),
                                  ],),),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

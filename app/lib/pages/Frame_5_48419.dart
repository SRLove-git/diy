import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48420.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48434.dart';

class Frame_5_48419 extends StatefulWidget {

  Frame_5_48419({super.key,});
  @override
  State<Frame_5_48419> createState() => _Frame_5_48419State();
}

class _Frame_5_48419State extends State<Frame_5_48419> {
  late final ImageProvider _image_gqaa5_48532 = MemoryImage(imageStr_imageStr_uzah5_48532.decodeBase64Image());

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
                  key: ValueKey("5:48419"),
                  children: [
                    CustomWidget_5_48420(),
                    CustomWidget_5_48434(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:48535"),
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
                                  key: ValueKey("5:48536"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:48537"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:48538"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 70.w,
                                  height: 23.h,
                                  left: 161.w,
                                  top: 0.h,
                                  child: Text("门店详情",
                                    key: ValueKey("5:48539"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                        ],),),
                    Positioned(
                      width: 358.w,
                      height: 78.h,
                      left: 16.w,
                      top: 746.h,
                      child: Stack(
                        key: ValueKey("5:48540"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 358.w,
                            height: 26.h,
                            left: 0.w,
                            top: 0.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              child: Container(
                                constraints: BoxConstraints(minWidth: 358.w, minHeight: 26.h),
                                padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                child: Column(
                                  key: ValueKey("5:48541"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 358.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 358.w, minHeight: 18.h),
                                          child: Row(
                                            key: ValueKey("5:48542"),
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 215.61.w,
                                                height: 18.h,
                                                child: Stack(
                                                  key: ValueKey("5:48543"),
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      width: 218.w,
                                                      height: 18.h,
                                                      left: 0.w,
                                                      top: -1.h,
                                                      child: Text("已选：08-07 周五 15:00-16:30 · 2 人",
                                                        key: ValueKey("5:48544"),
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                  ],),),
                                            ],),),),),
                                  ],),),),),
                          Positioned(
                            width: 358.w,
                            height: 52.h,
                            left: 0.w,
                            top: 26.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 358.w, minHeight: 52.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                                child: Row(
                                  key: ValueKey("5:48545"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 358.w,
                                      height: 22.h,
                                      child: Text("下一步 · 选择桌位",
                                        key: ValueKey("5:48546"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
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

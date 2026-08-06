import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49532.dart';

class Frame_5_49531 extends StatefulWidget {

  Frame_5_49531({super.key,});
  @override
  State<Frame_5_49531> createState() => _Frame_5_49531State();
}

class _Frame_5_49531State extends State<Frame_5_49531> {


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
                  key: ValueKey("5:49531"),
                  children: [
                    CustomWidget_5_49532(),
                    Positioned(
                      width: 390.w,
                      height: 585.h,
                      left: 0.w,
                      top: 106.h,
                      child: Stack(
                        key: ValueKey("5:49546"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 358.w,
                            height: 31.h,
                            left: 16.w,
                            top: 8.h,
                            child: Stack(
                              key: ValueKey("5:49547"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 66.48.w,
                                  height: 14.h,
                                  left: 147.w,
                                  top: 12.h,
                                  child: Text("· 接上一页 ·",
                                    key: ValueKey("5:49548"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 358.w,
                            height: 247.h,
                            left: 16.w,
                            top: 39.h,
                            child: Image(
                              key: ValueKey("5:49549"),
                              image: AssetImage("assets/margin_wrapper154.png"),),),
                          Positioned(
                            width: 358.w,
                            height: 247.h,
                            left: 16.w,
                            top: 286.h,
                            child: Image(
                              key: ValueKey("5:49571"),
                              image: AssetImage("assets/margin_wrapper157.png"),),),
                          Positioned(
                            width: 358.w,
                            height: 52.h,
                            left: 16.w,
                            top: 533.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 358.w, minHeight: 52.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                child: Row(
                                  key: ValueKey("5:49593"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 358.w,
                                      height: 22.h,
                                      child: Text("查看更多活动",
                                        key: ValueKey("5:49594"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                  ],),),),),
                        ],),),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:49595"),
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
                                  key: ValueKey("5:49596"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:49597"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:49598"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 70.w,
                                  height: 23.h,
                                  left: 161.w,
                                  top: 0.h,
                                  child: Text("活动专区",
                                    key: ValueKey("5:49599"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

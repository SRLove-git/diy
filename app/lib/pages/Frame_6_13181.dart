import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13183.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13197.dart';

class Frame_6_13181 extends StatefulWidget {

  Frame_6_13181({super.key,});
  @override
  State<Frame_6_13181> createState() => _Frame_6_13181State();
}

class _Frame_6_13181State extends State<Frame_6_13181> {


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
                  key: ValueKey("6:13181"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:13182"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_13183(),
                          CustomWidget_6_13197(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:13285"),
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
                                        key: ValueKey("6:13286"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:13287"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:13288"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 79.w,
                                        height: 23.h,
                                        left: 182.w,
                                        top: 1.h,
                                        child: Text("预约详情",
                                          key: ValueKey("6:13289"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                              ],),),
                          Positioned(
                            width: 403.9.w,
                            height: 56.h,
                            left: 18.w,
                            top: 873.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 56.h),
                                child: Row(
                                  key: ValueKey("6:13290"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 12.w,
                                  children: [
                                    SizedBox(
                                      width: 195.18.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 195.18.w, minHeight: 56.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                          child: Row(
                                            key: ValueKey("6:13291"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 195.18.w,
                                                height: 22.h,
                                                child: Text("取消预约",
                                                  key: ValueKey("6:13292"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(255, 59, 48,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                            ],),),),),
                                    SizedBox(
                                      width: 195.18.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 195.18.w, minHeight: 56.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                                          child: Row(
                                            key: ValueKey("6:13293"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 195.18.w,
                                                height: 22.h,
                                                child: Text("去核销",
                                                  key: ValueKey("6:13294"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
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

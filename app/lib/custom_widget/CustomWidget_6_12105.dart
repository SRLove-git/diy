import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12091.dart';

class CustomWidget_6_12105 extends StatelessWidget {
 CustomWidget_6_12105({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 360.h,
          left: 0.w,
          top: 120.h,
          child: Stack(
            key: ValueKey("6:12105"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 35.h,
                left: 18.w,
                top: 9.h,
                child: Stack(
                  key: ValueKey("6:12106"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 74.75.w,
                      height: 14.h,
                      left: 166.w,
                      top: 13.h,
                      child: Text("· 接上一页 ·",
                        key: ValueKey("6:12107"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 403.9.w,
                height: 35.h,
                left: 18.w,
                top: 44.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 35.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("6:12108"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 27.h,
                          child: Stack(
                            key: ValueKey("6:12109"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 40.w,
                                height: 23.h,
                                left: 0.w,
                                top: 1.h,
                                child: Text("关于",
                                  key: ValueKey("6:12110"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 194.h,
                left: 18.w,
                top: 79.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("6:12111"),
                    image: AssetImage("assets/divcardcardpad1.png"),),),),
              Positioned(
                width: 403.9.w,
                height: 83.h,
                left: 18.w,
                top: 277.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 83.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 24.h,bottom: 0.h),
                    child: Column(
                      key: ValueKey("6:12129"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 403.9.w,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 59.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                              child: Row(
                                key: ValueKey("6:12130"),
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 403.9.w,
                                    height: 22.h,
                                    child: Text("退出登录",
                                      key: ValueKey("6:12131"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color.fromRGBO(255, 59, 48,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                ],),),),),
                      ],),),),),
            ],),);
  }
}

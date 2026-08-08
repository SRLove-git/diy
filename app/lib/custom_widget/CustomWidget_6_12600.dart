import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12586.dart';

class CustomWidget_6_12600 extends StatelessWidget {
 CustomWidget_6_12600({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 575.h,
          left: 0.w,
          top: 120.h,
          child: Stack(
            key: ValueKey("6:12600"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 35.h,
                left: 18.w,
                top: 9.h,
                child: Stack(
                  key: ValueKey("6:12601"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 74.75.w,
                      height: 14.h,
                      left: 166.w,
                      top: 13.h,
                      child: Text("· 接上一页 ·",
                        key: ValueKey("6:12602"),
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
                      key: ValueKey("6:12603"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 27.h,
                          child: Stack(
                            key: ValueKey("6:12604"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 59.w,
                                height: 23.h,
                                left: 0.w,
                                top: 1.h,
                                child: Text("微交互",
                                  key: ValueKey("6:12605"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 395.h,
                left: 18.w,
                top: 79.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("6:12606"),
                    image: AssetImage("assets/divcardcardpad0.png"),),),),
              Positioned(
                width: 403.9.w,
                height: 98.h,
                left: 18.w,
                top: 476.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 98.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 16.h,bottom: 0.h),
                    child: Column(
                      key: ValueKey("6:12681"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 82.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(246, 246, 248,1),borderRadius: BorderRadius.circular(16.h),),
                          child: Stack(
                            key: ValueKey("6:12682"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 367.79.w,
                                height: 46.h,
                                left: 18.w,
                                top: 18.h,
                                child: Stack(
                                  key: ValueKey("6:12683"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 327.w,
                                      height: 40.h,
                                      left: 0.w,
                                      top: 2.h,
                                      child: Text("动效曲线：标准 cubic-bezier(0.2,0,0,1) · 弹性 cubic-bezier(0.34,1.56,0.64,1) · 线性 linear",
                                        key: ValueKey("6:12684"),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.7, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

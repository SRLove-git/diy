import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52980.dart';

class CustomWidget_5_52994 extends StatelessWidget {
 CustomWidget_5_52994({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 510.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:52994"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 31.h,
                left: 16.w,
                top: 8.h,
                child: Stack(
                  key: ValueKey("5:52995"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 66.48.w,
                      height: 14.h,
                      left: 147.w,
                      top: 12.h,
                      child: Text("· 接上一页 ·",
                        key: ValueKey("5:52996"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 358.w,
                height: 32.h,
                left: 16.w,
                top: 39.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 32.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:52997"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 24.h,
                          child: Stack(
                            key: ValueKey("5:52998"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 52.w,
                                height: 23.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("微交互",
                                  key: ValueKey("5:52999"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 350.h,
                left: 16.w,
                top: 71.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:53000"),
                    image: AssetImage("assets/divcardcardpad0.png"),),),),
              Positioned(
                width: 358.w,
                height: 89.h,
                left: 16.w,
                top: 421.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 89.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 16.h,bottom: 0.h),
                    child: Column(
                      key: ValueKey("5:53075"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 73.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(246, 246, 248,1),borderRadius: BorderRadius.circular(16.h),),
                          child: Stack(
                            key: ValueKey("5:53076"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 326.w,
                                height: 41.h,
                                left: 16.w,
                                top: 16.h,
                                child: Stack(
                                  key: ValueKey("5:53077"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 290.w,
                                      height: 40.h,
                                      left: 0.w,
                                      top: 1.h,
                                      child: Text("动效曲线：标准 cubic-bezier(0.2,0,0,1) · 弹性 cubic-bezier(0.34,1.56,0.64,1) · 线性 linear",
                                        key: ValueKey("5:53078"),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.7, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

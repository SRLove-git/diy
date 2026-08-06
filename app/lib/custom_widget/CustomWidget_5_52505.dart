import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52491.dart';

class CustomWidget_5_52505 extends StatelessWidget {
 CustomWidget_5_52505({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 319.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:52505"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 31.h,
                left: 16.w,
                top: 8.h,
                child: Stack(
                  key: ValueKey("5:52506"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 66.48.w,
                      height: 14.h,
                      left: 147.w,
                      top: 12.h,
                      child: Text("· 接上一页 ·",
                        key: ValueKey("5:52507"),
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
                      key: ValueKey("5:52508"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 24.h,
                          child: Stack(
                            key: ValueKey("5:52509"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 36.w,
                                height: 23.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("关于",
                                  key: ValueKey("5:52510"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 172.h,
                left: 16.w,
                top: 71.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:52511"),
                    image: AssetImage("assets/divcardcardpad1.png"),),),),
              Positioned(
                width: 358.w,
                height: 76.h,
                left: 16.w,
                top: 243.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 76.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 24.h,bottom: 0.h),
                    child: Column(
                      key: ValueKey("5:52529"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 52.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                              child: Row(
                                key: ValueKey("5:52530"),
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 358.w,
                                    height: 22.h,
                                    child: Text("退出登录",
                                      key: ValueKey("5:52531"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color.fromRGBO(255, 59, 48,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                ],),),),),
                      ],),),),),
            ],),);
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52393.dart';

class CustomWidget_5_52407 extends StatelessWidget {
 CustomWidget_5_52407({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 669.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:52407"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 32.h,
                left: 16.w,
                top: 8.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 32.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:52408"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 24.h,
                          child: Stack(
                            key: ValueKey("5:52409"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 86.w,
                                height: 23.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("账号与安全",
                                  key: ValueKey("5:52410"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 339.h,
                left: 16.w,
                top: 40.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:52411"),
                    image: AssetImage("assets/divcardcardpad3.png"),),),),
              Positioned(
                width: 358.w,
                height: 56.h,
                left: 16.w,
                top: 379.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 56.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 24.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:52451"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 24.h,
                          child: Stack(
                            key: ValueKey("5:52452"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 36.w,
                                height: 23.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("通用",
                                  key: ValueKey("5:52453"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 207.h,
                left: 16.w,
                top: 435.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:52454"),
                    image: AssetImage("assets/divcardcardpad2.png"),),),),
              Positioned(
                width: 358.w,
                height: 27.h,
                left: 16.w,
                top: 641.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 27.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 10.h,bottom: 2.h),
                    child: Row(
                      key: ValueKey("5:52482"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          width: 121.w,
                          height: 15.h,
                          child: Stack(
                            key: ValueKey("5:52483"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 123.w,
                                height: 15.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("下拉查看关于与退出登录",
                                  key: ValueKey("5:52484"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

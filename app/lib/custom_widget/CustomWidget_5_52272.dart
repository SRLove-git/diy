import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52258.dart';

class CustomWidget_5_52272 extends StatelessWidget {
 CustomWidget_5_52272({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 609.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:52272"),
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
                      key: ValueKey("5:52273"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 24.h),
                              child: Row(
                                key: ValueKey("5:52274"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12.w,
                                children: [
                                  Container(
                                    width: 33.61.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("5:52275"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 36.w,
                                          height: 23.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("互动",
                                            key: ValueKey("5:52276"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                      ],),),
                                  SizedBox(
                                    width: 18.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 18.w),
                                        padding: EdgeInsets.only(left: 5.w,right: 5.w, top: 0.h,bottom: 0.h),
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 59, 48,1),borderRadius: BorderRadius.circular(9.h),),
                                        child: Row(
                                          key: ValueKey("5:52277"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 8.w,
                                              height: 15.h,
                                              child: Text("3",
                                                key: ValueKey("5:52278"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 292.h,
                left: 16.w,
                top: 40.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:52279"),
                    image: AssetImage("assets/divcardcardpad5.png"),),),),
              Positioned(
                width: 358.w,
                height: 56.h,
                left: 16.w,
                top: 332.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 56.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 20.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:52338"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 24.h),
                              child: Row(
                                key: ValueKey("5:52339"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 67.2.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("5:52340"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 69.w,
                                          height: 23.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("系统消息",
                                            key: ValueKey("5:52341"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 221.h,
                left: 16.w,
                top: 388.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:52342"),
                    image: AssetImage("assets/divcardcardpad4.png"),),),),
            ],),);
  }
}

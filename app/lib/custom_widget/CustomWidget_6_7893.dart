import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7861.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7875.dart';

class CustomWidget_6_7893 extends StatelessWidget {
 CustomWidget_6_7893({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 718.h,
          left: 0.w,
          top: 228.h,
          child: Stack(
            key: ValueKey("6:7893"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 35.h,
                left: 18.w,
                top: 271.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 35.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("6:7894"),
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
                              constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 27.h),
                              child: Row(
                                key: ValueKey("6:7895"),
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 91.05.w,
                                    height: 27.h,
                                    child: Stack(
                                      key: ValueKey("6:7896"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 93.w,
                                          height: 23.h,
                                          left: 0.w,
                                          top: 1.h,
                                          child: Text("搜索结果 3",
                                            key: ValueKey("6:7897"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                      ],),),
                                  Container(
                                    width: 76.59.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("6:7898"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 79.w,
                                          height: 21.h,
                                          left: 0.w,
                                          top: 2.h,
                                          child: Text("地图模式 ›",
                                            key: ValueKey("6:7899"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 188.h,
                left: 18.w,
                top: 307.h,
                child: Image(
                  key: ValueKey("6:7900"),
                  image: AssetImage("assets/margin_wrapper40.png"),),),
              Positioned(
                width: 403.9.w,
                height: 188.h,
                left: 18.w,
                top: 497.h,
                child: Image(
                  key: ValueKey("6:7931"),
                  image: AssetImage("assets/margin_wrapper44.png"),),),
              Positioned(
                width: 403.9.w,
                height: 31.h,
                left: 18.w,
                top: 686.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 31.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 10.h,bottom: 2.h),
                    child: Row(
                      key: ValueKey("6:7962"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          width: 129.71.w,
                          height: 17.h,
                          child: Stack(
                            key: ValueKey("6:7963"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 132.w,
                                height: 15.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("共 3 条结果 · 查看更多",
                                  key: ValueKey("6:7964"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

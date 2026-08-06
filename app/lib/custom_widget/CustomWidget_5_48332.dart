import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48300.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48314.dart';

class CustomWidget_5_48332 extends StatelessWidget {
 CustomWidget_5_48332({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 636.h,
          left: 0.w,
          top: 202.h,
          child: Stack(
            key: ValueKey("5:48332"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 32.h,
                left: 16.w,
                top: 240.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 32.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:48333"),
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
                                key: ValueKey("5:48334"),
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80.7.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("5:48335"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 83.w,
                                          height: 23.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("搜索结果 3",
                                            key: ValueKey("5:48336"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                      ],),),
                                  Container(
                                    width: 67.89.w,
                                    height: 21.h,
                                    child: Stack(
                                      key: ValueKey("5:48337"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 70.w,
                                          height: 21.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("地图模式 ›",
                                            key: ValueKey("5:48338"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 168.h,
                left: 16.w,
                top: 272.h,
                child: Image(
                  key: ValueKey("5:48339"),
                  image: AssetImage("assets/margin_wrapper40.png"),),),
              Positioned(
                width: 358.w,
                height: 168.h,
                left: 16.w,
                top: 440.h,
                child: Image(
                  key: ValueKey("5:48370"),
                  image: AssetImage("assets/margin_wrapper44.png"),),),
              Positioned(
                width: 358.w,
                height: 27.h,
                left: 16.w,
                top: 609.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 27.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 10.h,bottom: 2.h),
                    child: Row(
                      key: ValueKey("5:48401"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          width: 114.97.w,
                          height: 15.h,
                          child: Stack(
                            key: ValueKey("5:48402"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 117.w,
                                height: 15.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("共 3 条结果 · 查看更多",
                                  key: ValueKey("5:48403"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

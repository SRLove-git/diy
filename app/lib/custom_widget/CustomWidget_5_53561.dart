import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53462.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53476.dart';

class CustomWidget_5_53561 extends StatelessWidget {
 CustomWidget_5_53561({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 44.h,
          left: 0.w,
          top: 62.h,
          child: Stack(
            key: ValueKey("5:53561"),
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
                      key: ValueKey("5:53562"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("5:53563"),
                          width: 22.w,
                          height: 22.h,),
                      ],),),),),
              Positioned(
                width: 390.w,
                height: 24.h,
                left: 0.w,
                top: 10.h,
                child: Stack(
                  key: ValueKey("5:53564"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 70.w,
                      height: 23.h,
                      left: 161.w,
                      top: 0.h,
                      child: Text("观看历史",
                        key: ValueKey("5:53565"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 26.02.w,
                height: 18.h,
                left: 352.w,
                top: 13.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 26.02.w, minHeight: 18.h),
                    child: Row(
                      key: ValueKey("5:53566"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          width: 26.02.w,
                          height: 18.h,
                          child: Stack(
                            key: ValueKey("5:53567"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 28.w,
                                height: 18.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("清空",
                                  key: ValueKey("5:53568"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

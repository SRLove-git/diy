import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13074.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13088.dart';

class CustomWidget_6_13173 extends StatelessWidget {
 CustomWidget_6_13173({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 50.h,
          left: 0.w,
          top: 70.h,
          child: Stack(
            key: ValueKey("6:13173"),
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
                      key: ValueKey("6:13174"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("6:13175"),
                          width: 24.82.w,
                          height: 25.h,),
                      ],),),),),
              Positioned(
                width: 440.w,
                height: 27.h,
                left: 0.w,
                top: 11.h,
                child: Stack(
                  key: ValueKey("6:13176"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 79.w,
                      height: 23.h,
                      left: 182.w,
                      top: 1.h,
                      child: Text("观看历史",
                        key: ValueKey("6:13177"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 29.35.w,
                height: 21.h,
                left: 397.w,
                top: 15.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 29.35.w, minHeight: 21.h),
                    child: Row(
                      key: ValueKey("6:13178"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          width: 29.35.w,
                          height: 21.h,
                          child: Stack(
                            key: ValueKey("6:13179"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 31.w,
                                height: 18.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("清空",
                                  key: ValueKey("6:13180"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

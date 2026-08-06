import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48548.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48562.dart';

class CustomWidget_5_48623 extends StatelessWidget {
 CustomWidget_5_48623({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 358.w,
          height: 82.h,
          left: 16.w,
          top: 742.h,
          child: Stack(
            key: ValueKey("5:48623"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 30.h,
                left: 0.w,
                top: 0.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 30.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:48624"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 22.h),
                              child: Row(
                                key: ValueKey("5:48625"),
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 124.36.w,
                                    height: 18.h,
                                    child: Stack(
                                      key: ValueKey("5:48626"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 126.w,
                                          height: 18.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("会员价 ¥29.9 / 人 × 2",
                                            key: ValueKey("5:48627"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                      ],),),
                                  Container(
                                    width: 42.97.w,
                                    height: 22.h,
                                    child: Stack(
                                      key: ValueKey("5:48628"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 45.w,
                                          height: 22.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("¥59.8",
                                            key: ValueKey("5:48629"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 52.h,
                left: 0.w,
                top: 30.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 52.h),
                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                    child: Row(
                      key: ValueKey("5:48630"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 358.w,
                          height: 22.h,
                          child: Text("确认预约",
                            key: ValueKey("5:48631"),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                      ],),),),),
            ],),);
  }
}

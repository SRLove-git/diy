import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10302.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10316.dart';

class CustomWidget_6_10433 extends StatelessWidget {
 CustomWidget_6_10433({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 81.h,
          left: 0.w,
          top: 871.h,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(minWidth: 440.w, minHeight: 81.h),
              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 1.h,bottom: 0.h),
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
              child: Row(
                key: ValueKey("6:10433"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12.w,
                children: [
                  SizedBox(
                    width: 300.08.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 300.08.w, minHeight: 39.h),
                        child: Row(
                          key: ValueKey("6:10434"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 12.w,
                          children: [
                            Container(
                              key: ValueKey("6:10435"),
                              width: 24.82.w,
                              height: 25.h,),
                            Container(
                              width: 78.97.w,
                              height: 39.h,
                              child: Stack(
                                key: ValueKey("6:10436"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 78.97.w,
                                    height: 22.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Stack(
                                      key: ValueKey("6:10437"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 81.w,
                                          height: 20.h,
                                          left: 0.w,
                                          top: 1.h,
                                          child: Text("夏日小夜曲",
                                            key: ValueKey("6:10438"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),
                                  Positioned(
                                    width: 78.97.w,
                                    height: 17.h,
                                    left: 0.w,
                                    top: 23.h,
                                    child: Stack(
                                      key: ValueKey("6:10439"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 52.w,
                                          height: 15.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("手作星球",
                                            key: ValueKey("6:10440"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 90.27.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 90.27.w, minHeight: 43.h),
                        padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                        child: Row(
                          key: ValueKey("6:10441"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 62.27.w,
                              height: 18.h,
                              child: Text("使用配乐",
                                key: ValueKey("6:10442"),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                          ],),),),),
                ],),),),);
  }
}

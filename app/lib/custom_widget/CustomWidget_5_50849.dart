import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50718.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50732.dart';

class CustomWidget_5_50849 extends StatelessWidget {
 CustomWidget_5_50849({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 72.h,
          left: 0.w,
          top: 772.h,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(minWidth: 390.w, minHeight: 72.h),
              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 1.h,bottom: 0.h),
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
              child: Row(
                key: ValueKey("5:50849"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12.w,
                children: [
                  SizedBox(
                    width: 265.98.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 265.98.w, minHeight: 35.h),
                        child: Row(
                          key: ValueKey("5:50850"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 12.w,
                          children: [
                            Container(
                              key: ValueKey("5:50851"),
                              width: 22.w,
                              height: 22.h,),
                            Container(
                              width: 70.w,
                              height: 35.h,
                              child: Stack(
                                key: ValueKey("5:50852"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 70.w,
                                    height: 20.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Stack(
                                      key: ValueKey("5:50853"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 72.w,
                                          height: 20.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("夏日小夜曲",
                                            key: ValueKey("5:50854"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),
                                  Positioned(
                                    width: 70.w,
                                    height: 15.h,
                                    left: 0.w,
                                    top: 20.h,
                                    child: Stack(
                                      key: ValueKey("5:50855"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 46.w,
                                          height: 15.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("手作星球",
                                            key: ValueKey("5:50856"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 80.02.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 80.02.w, minHeight: 38.h),
                        padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                        child: Row(
                          key: ValueKey("5:50857"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 52.02.w,
                              height: 18.h,
                              child: Text("使用配乐",
                                key: ValueKey("5:50858"),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                          ],),),),),
                ],),),),);
  }
}

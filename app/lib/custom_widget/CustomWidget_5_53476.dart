import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53462.dart';

class CustomWidget_5_53476 extends StatelessWidget {
 CustomWidget_5_53476({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 526.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:53476"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 56.h,
                left: 16.w,
                top: 8.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 56.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 16.h),
                    child: Column(
                      key: ValueKey("5:53477"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 40.h),
                              padding: EdgeInsets.only(left: 3.w,right: 3.w, top: 3.h,bottom: 3.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(20.h),),
                              child: Row(
                                key: ValueKey("5:53478"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 176.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 176.w, minHeight: 34.h),
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(17.h),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.08),offset: Offset(0.w, 1.w),blurRadius: 4.w,)],),
                                        child: Row(
                                          key: ValueKey("5:53479"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 176.w,
                                              height: 18.h,
                                              child: Text("作品",
                                                key: ValueKey("5:53480"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                  SizedBox(
                                    width: 176.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 176.w, minHeight: 34.h),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                        child: Row(
                                          key: ValueKey("5:53481"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 176.w,
                                              height: 18.h,
                                              child: Text("视频",
                                                key: ValueKey("5:53482"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 394.h,
                left: 16.w,
                top: 64.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:53483"),
                    image: AssetImage("assets/divcardcardpad.png"),),),),
              Positioned(
                width: 358.w,
                height: 68.h,
                left: 16.w,
                top: 458.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 68.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 16.h,bottom: 0.h),
                    child: Column(
                      key: ValueKey("5:53558"),
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
                                key: ValueKey("5:53559"),
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 358.w,
                                    height: 22.h,
                                    child: Text("清空观看历史",
                                      key: ValueKey("5:53560"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color.fromRGBO(255, 59, 48,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                ],),),),),
                      ],),),),),
            ],),);
  }
}

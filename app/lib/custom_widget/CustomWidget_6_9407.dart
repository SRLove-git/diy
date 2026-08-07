import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9393.dart';

class CustomWidget_6_9407 extends StatelessWidget {
 CustomWidget_6_9407({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 589.h,
          left: 0.w,
          top: 120.h,
          child: Stack(
            key: ValueKey("6:9407"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 35.h,
                left: 18.w,
                top: 9.h,
                child: Stack(
                  key: ValueKey("6:9408"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 74.75.w,
                      height: 14.h,
                      left: 166.w,
                      top: 13.h,
                      child: Text("· 接上一页 ·",
                        key: ValueKey("6:9409"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 403.9.w,
                height: 61.h,
                left: 18.w,
                top: 44.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 61.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 16.h),
                    child: Column(
                      key: ValueKey("6:9410"),
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
                              constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 45.h),
                              padding: EdgeInsets.only(left: 3.w,right: 3.w, top: 3.h,bottom: 3.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(20.h),),
                              child: Row(
                                key: ValueKey("6:9411"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 132.37.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 132.37.w, minHeight: 38.h),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                        child: Row(
                                          key: ValueKey("6:9412"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 132.37.w,
                                              height: 18.h,
                                              child: Text("关注",
                                                key: ValueKey("6:9413"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                  SizedBox(
                                    width: 132.39.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 132.39.w, minHeight: 38.h),
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(17.h),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.08),offset: Offset(0.w, 1.w),blurRadius: 4.w,)],),
                                        child: Row(
                                          key: ValueKey("6:9414"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 132.39.w,
                                              height: 18.h,
                                              child: Text("最新",
                                                key: ValueKey("6:9415"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                  SizedBox(
                                    width: 132.37.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 132.37.w, minHeight: 38.h),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                        child: Row(
                                          key: ValueKey("6:9416"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 132.37.w,
                                              height: 18.h,
                                              child: Text("热门",
                                                key: ValueKey("6:9417"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 260.h,
                left: 18.w,
                top: 107.h,
                child: Image(
                  key: ValueKey("6:9418"),
                  image: AssetImage("assets/margin_wrapper177.png"),),),
              Positioned(
                width: 403.9.w,
                height: 233.h,
                left: 18.w,
                top: 368.h,
                child: Image(
                  key: ValueKey("6:9453"),
                  image: AssetImage("assets/margin_wrapper181.png"),),),
            ],),);
  }
}

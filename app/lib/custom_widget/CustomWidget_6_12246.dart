import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12232.dart';

class CustomWidget_6_12246 extends StatelessWidget {
 CustomWidget_6_12246({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 306.h,
          left: 0.w,
          top: 120.h,
          child: Opacity(
            opacity: 0.5,
            child: Stack(
              key: ValueKey("6:12246"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 403.9.w,
                  height: 61.h,
                  left: 18.w,
                  top: 9.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 61.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 16.h),
                      child: Column(
                        key: ValueKey("6:12247"),
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
                                  key: ValueKey("6:12248"),
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
                                          decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(17.h),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.08),offset: Offset(0.w, 1.w),blurRadius: 4.w,)],),
                                          child: Row(
                                            key: ValueKey("6:12249"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 132.37.w,
                                                height: 18.h,
                                                child: Text("全部",
                                                  key: ValueKey("6:12250"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),),),
                                    SizedBox(
                                      width: 132.39.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 132.39.w, minHeight: 38.h),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                          child: Row(
                                            key: ValueKey("6:12251"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 132.39.w,
                                                height: 18.h,
                                                child: Text("待核销",
                                                  key: ValueKey("6:12252"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
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
                                            key: ValueKey("6:12253"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 132.37.w,
                                                height: 18.h,
                                                child: Text("已完成",
                                                  key: ValueKey("6:12254"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),),),
                                  ],),),),),
                        ],),),),),
                Positioned(
                  width: 403.9.w,
                  height: 122.h,
                  left: 18.w,
                  top: 72.h,
                  child: Image(
                    key: ValueKey("6:12255"),
                    image: AssetImage("assets/margin_wrapper335.png"),),),
                Positioned(
                  width: 403.9.w,
                  height: 110.h,
                  left: 18.w,
                  top: 195.h,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(),
                    child: Image(
                      key: ValueKey("6:12267"),
                      image: AssetImage("assets/divcardcardpad.png"),),),),
              ],),),);
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52630.dart';

class CustomWidget_5_52644 extends StatelessWidget {
 CustomWidget_5_52644({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 271.h,
          left: 0.w,
          top: 106.h,
          child: Opacity(
            opacity: 0.5,
            child: Stack(
              key: ValueKey("5:52644"),
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
                        key: ValueKey("5:52645"),
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
                                  key: ValueKey("5:52646"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 117.33.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 117.33.w, minHeight: 34.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(17.h),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.08),offset: Offset(0.w, 1.w),blurRadius: 4.w,)],),
                                          child: Row(
                                            key: ValueKey("5:52647"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 117.33.w,
                                                height: 18.h,
                                                child: Text("全部",
                                                  key: ValueKey("5:52648"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),),),
                                    SizedBox(
                                      width: 117.34.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 117.34.w, minHeight: 34.h),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                          child: Row(
                                            key: ValueKey("5:52649"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 117.34.w,
                                                height: 18.h,
                                                child: Text("待核销",
                                                  key: ValueKey("5:52650"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),),),
                                    SizedBox(
                                      width: 117.33.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 117.33.w, minHeight: 34.h),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                          child: Row(
                                            key: ValueKey("5:52651"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 117.33.w,
                                                height: 18.h,
                                                child: Text("已完成",
                                                  key: ValueKey("5:52652"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),),),
                                  ],),),),),
                        ],),),),),
                Positioned(
                  width: 358.w,
                  height: 110.h,
                  left: 16.w,
                  top: 64.h,
                  child: Image(
                    key: ValueKey("5:52653"),
                    image: AssetImage("assets/margin_wrapper335.png"),),),
                Positioned(
                  width: 358.w,
                  height: 98.h,
                  left: 16.w,
                  top: 174.h,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(),
                    child: Image(
                      key: ValueKey("5:52665"),
                      image: AssetImage("assets/divcardcardpad.png"),),),),
              ],),),);
  }
}

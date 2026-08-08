import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13626.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13640.dart';

class CustomWidget_6_13689 extends StatelessWidget {
 CustomWidget_6_13689({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 50.h,
          left: 0.w,
          top: 70.h,
          child: Stack(
            key: ValueKey("6:13689"),
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
                      key: ValueKey("6:13690"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("6:13691"),
                          width: 24.82.w,
                          height: 25.h,),
                      ],),),),),
              Positioned(
                width: 313.64.w,
                height: 41.h,
                left: 54.w,
                top: 4.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 313.64.w, minHeight: 41.h),
                    padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                    decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(18.h),),
                    child: Row(
                      key: ValueKey("6:13692"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          key: ValueKey("6:13693"),
                          width: 20.31.w,
                          height: 20.h,),
                        Container(
                          width: 29.35.w,
                          height: 21.h,
                          child: Stack(
                            key: ValueKey("6:13694"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 31.w,
                                height: 18.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("拼豆",
                                  key: ValueKey("6:13695"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 31.59.w,
                height: 22.h,
                left: 395.w,
                top: 14.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 31.59.w, minHeight: 22.h),
                    child: Row(
                      key: ValueKey("6:13696"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          width: 31.59.w,
                          height: 20.h,
                          child: Text("搜索",
                            key: ValueKey("6:13697"),
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                      ],),),),),
            ],),);
  }
}

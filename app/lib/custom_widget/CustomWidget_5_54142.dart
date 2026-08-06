import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54081.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54095.dart';

class CustomWidget_5_54142 extends StatelessWidget {
 CustomWidget_5_54142({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 44.h,
          left: 0.w,
          top: 62.h,
          child: Stack(
            key: ValueKey("5:54142"),
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
                      key: ValueKey("5:54143"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("5:54144"),
                          width: 22.w,
                          height: 22.h,),
                      ],),),),),
              Positioned(
                width: 278.w,
                height: 36.h,
                left: 48.w,
                top: 4.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 278.w, minHeight: 36.h),
                    padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                    decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(18.h),),
                    child: Row(
                      key: ValueKey("5:54145"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          key: ValueKey("5:54146"),
                          width: 18.w,
                          height: 18.h,),
                        Container(
                          width: 26.02.w,
                          height: 18.h,
                          child: Stack(
                            key: ValueKey("5:54147"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 28.w,
                                height: 18.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("拼豆",
                                  key: ValueKey("5:54148"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 28.w,
                height: 20.h,
                left: 350.w,
                top: 12.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 28.w, minHeight: 20.h),
                    child: Row(
                      key: ValueKey("5:54149"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          width: 28.w,
                          height: 20.h,
                          child: Text("搜索",
                            key: ValueKey("5:54150"),
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                      ],),),),),
            ],),);
  }
}

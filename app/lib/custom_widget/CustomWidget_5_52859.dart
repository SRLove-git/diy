import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52845.dart';

class CustomWidget_5_52859 extends StatelessWidget {
 CustomWidget_5_52859({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 616.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:52859"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 32.h,
                left: 16.w,
                top: 8.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 32.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:52860"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 24.h,
                          child: Stack(
                            key: ValueKey("5:52861"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 69.w,
                                height: 23.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("页面转场",
                                  key: ValueKey("5:52862"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 212.h,
                left: 16.w,
                top: 40.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:52863"),
                    image: AssetImage("assets/divcardcardpad2.png"),),),),
              Positioned(
                width: 358.w,
                height: 56.h,
                left: 16.w,
                top: 252.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 56.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 24.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:52908"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 24.h,
                          child: Stack(
                            key: ValueKey("5:52909"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 86.w,
                                height: 23.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("弹窗与菜单",
                                  key: ValueKey("5:52910"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 281.h,
                left: 16.w,
                top: 308.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:52911"),
                    image: AssetImage("assets/divcardcardpad1.png"),),),),
              Positioned(
                width: 358.w,
                height: 27.h,
                left: 16.w,
                top: 589.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 27.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 10.h,bottom: 2.h),
                    child: Row(
                      key: ValueKey("5:52971"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          width: 132.w,
                          height: 15.h,
                          child: Stack(
                            key: ValueKey("5:52972"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 134.w,
                                height: 15.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("下拉查看微交互与动效曲线",
                                  key: ValueKey("5:52973"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

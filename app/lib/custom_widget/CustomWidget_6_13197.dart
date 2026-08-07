import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13183.dart';

class CustomWidget_6_13197 extends StatelessWidget {
 CustomWidget_6_13197({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 625.h,
          left: 0.w,
          top: 120.h,
          child: Stack(
            key: ValueKey("6:13197"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 223.h,
                left: 18.w,
                top: 9.h,
                child: Image(
                  key: ValueKey("6:13198"),
                  image: AssetImage("assets/margin_wrapper396.png"),),),
              Positioned(
                width: 403.9.w,
                height: 35.h,
                left: 18.w,
                top: 233.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 35.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("6:13221"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 27.h,
                          child: Stack(
                            key: ValueKey("6:13222"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 78.w,
                                height: 23.h,
                                left: 0.w,
                                top: 1.h,
                                child: Text("预约进度",
                                  key: ValueKey("6:13223"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 89.h,
                left: 18.w,
                top: 269.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("6:13224"),
                    image: AssetImage("assets/divcardcardpad2.png"),),),),
              Positioned(
                width: 403.9.w,
                height: 59.h,
                left: 18.w,
                top: 361.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 59.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 24.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("6:13250"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 27.h,
                          child: Stack(
                            key: ValueKey("6:13251"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 78.w,
                                height: 23.h,
                                left: 0.w,
                                top: 1.h,
                                child: Text("订单信息",
                                  key: ValueKey("6:13252"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 203.h,
                left: 18.w,
                top: 421.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("6:13253"),
                    image: AssetImage("assets/divcardcardpad1.png"),),),),
            ],),);
  }
}

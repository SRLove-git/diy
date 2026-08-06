import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53570.dart';

class CustomWidget_5_53584 extends StatelessWidget {
 CustomWidget_5_53584({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 554.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:53584"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 199.h,
                left: 16.w,
                top: 8.h,
                child: Image(
                  key: ValueKey("5:53585"),
                  image: AssetImage("assets/margin_wrapper396.png"),),),
              Positioned(
                width: 358.w,
                height: 32.h,
                left: 16.w,
                top: 207.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 32.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:53608"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 24.h,
                          child: Stack(
                            key: ValueKey("5:53609"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 69.w,
                                height: 23.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("预约进度",
                                  key: ValueKey("5:53610"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 79.h,
                left: 16.w,
                top: 239.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:53611"),
                    image: AssetImage("assets/divcardcardpad2.png"),),),),
              Positioned(
                width: 358.w,
                height: 56.h,
                left: 16.w,
                top: 318.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 56.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 24.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:53637"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 24.h,
                          child: Stack(
                            key: ValueKey("5:53638"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 69.w,
                                height: 23.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("订单信息",
                                  key: ValueKey("5:53639"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 180.h,
                left: 16.w,
                top: 374.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:53640"),
                    image: AssetImage("assets/divcardcardpad1.png"),),),),
            ],),);
  }
}

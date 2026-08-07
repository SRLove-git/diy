import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12450.dart';

class CustomWidget_6_12464 extends StatelessWidget {
 CustomWidget_6_12464({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 695.h,
          left: 0.w,
          top: 120.h,
          child: Stack(
            key: ValueKey("6:12464"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 35.h,
                left: 18.w,
                top: 9.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 35.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("6:12465"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 27.h,
                          child: Stack(
                            key: ValueKey("6:12466"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 78.w,
                                height: 23.h,
                                left: 0.w,
                                top: 1.h,
                                child: Text("页面转场",
                                  key: ValueKey("6:12467"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 239.h,
                left: 18.w,
                top: 44.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("6:12468"),
                    image: AssetImage("assets/divcardcardpad2.png"),),),),
              Positioned(
                width: 403.9.w,
                height: 59.h,
                left: 18.w,
                top: 287.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 59.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 24.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("6:12513"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 27.h,
                          child: Stack(
                            key: ValueKey("6:12514"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 97.w,
                                height: 23.h,
                                left: 0.w,
                                top: 1.h,
                                child: Text("弹窗与菜单",
                                  key: ValueKey("6:12515"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 317.h,
                left: 18.w,
                top: 347.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("6:12516"),
                    image: AssetImage("assets/divcardcardpad1.png"),),),),
              Positioned(
                width: 403.9.w,
                height: 31.h,
                left: 18.w,
                top: 664.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 31.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 10.h,bottom: 2.h),
                    child: Row(
                      key: ValueKey("6:12576"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          width: 148.92.w,
                          height: 17.h,
                          child: Stack(
                            key: ValueKey("6:12577"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 151.w,
                                height: 15.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("下拉查看微交互与动效曲线",
                                  key: ValueKey("6:12578"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

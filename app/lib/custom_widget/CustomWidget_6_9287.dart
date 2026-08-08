import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9174.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9188.dart';

class CustomWidget_6_9287 extends StatelessWidget {
 CustomWidget_6_9287({super.key});
    late final ImageProvider _image_abdp6_9277 = MemoryImage(imageStr_oezc6_9277.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 403.9.w,
          height: 93.h,
          left: 18.w,
          top: 837.h,
          child: Stack(
            key: ValueKey("6:9287"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 33.h,
                left: 0.w,
                top: 0.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 33.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("6:9288"),
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
                              constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 25.h),
                              child: Row(
                                key: ValueKey("6:9289"),
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 109.29.w,
                                    height: 21.h,
                                    child: Stack(
                                      key: ValueKey("6:9290"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 111.w,
                                          height: 18.h,
                                          left: 0.w,
                                          top: 1.h,
                                          child: Text("会员 2 人 · 免费",
                                            key: ValueKey("6:9291"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                      ],),),
                                  Container(
                                    width: 21.31.w,
                                    height: 25.h,
                                    child: Stack(
                                      key: ValueKey("6:9292"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 23.w,
                                          height: 22.h,
                                          left: 0.w,
                                          top: 1.h,
                                          child: Text("¥0",
                                            key: ValueKey("6:9293"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 59.h,
                left: 0.w,
                top: 34.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 59.h),
                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                    child: Row(
                      key: ValueKey("6:9294"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 22.h,
                          child: Text("立即预约",
                            key: ValueKey("6:9295"),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                      ],),),),),
            ],),);
  }
}

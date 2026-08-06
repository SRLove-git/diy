import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49601.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49615.dart';

class CustomWidget_5_49714 extends StatelessWidget {
 CustomWidget_5_49714({super.key});
    late final ImageProvider _image_vbjt5_49704 = MemoryImage(imageStr_imageStr_bziy5_49704.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 358.w,
          height: 82.h,
          left: 16.w,
          top: 742.h,
          child: Stack(
            key: ValueKey("5:49714"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 30.h,
                left: 0.w,
                top: 0.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 30.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                    child: Column(
                      key: ValueKey("5:49715"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 22.h),
                              child: Row(
                                key: ValueKey("5:49716"),
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 96.88.w,
                                    height: 18.h,
                                    child: Stack(
                                      key: ValueKey("5:49717"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 99.w,
                                          height: 18.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("会员 2 人 · 免费",
                                            key: ValueKey("5:49718"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                      ],),),
                                  Container(
                                    width: 18.89.w,
                                    height: 22.h,
                                    child: Stack(
                                      key: ValueKey("5:49719"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 21.w,
                                          height: 22.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("¥0",
                                            key: ValueKey("5:49720"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 52.h,
                left: 0.w,
                top: 30.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 52.h),
                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                    child: Row(
                      key: ValueKey("5:49721"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 358.w,
                          height: 22.h,
                          child: Text("立即预约",
                            key: ValueKey("5:49722"),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                      ],),),),),
            ],),);
  }
}

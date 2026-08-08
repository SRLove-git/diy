import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10116.dart';

class CustomWidget_6_10131 extends StatelessWidget {
 CustomWidget_6_10131({super.key});
    late final ImageProvider _image_cmpc6_10115 = MemoryImage(imageStr_eqki6_10115.decodeBase64Image());
  late final ImageProvider _image_luci6_10130 = MemoryImage(imageStr_gxrr6_10130.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 50.h,
          left: 0.w,
          top: 70.h,
          child: Stack(
            key: ValueKey("6:10131"),
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
                      key: ValueKey("6:10132"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("6:10133"),
                          width: 24.82.w,
                          height: 25.h,),
                      ],),),),),
              Positioned(
                width: 440.w,
                height: 25.h,
                left: 0.w,
                top: 12.h,
                child: Stack(
                  key: ValueKey("6:10134"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 38.w,
                      height: 22.h,
                      left: 202.w,
                      top: 1.h,
                      child: Text("拍摄",
                        key: ValueKey("6:10135"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 97.03.w,
                height: 20.h,
                left: 329.w,
                top: 15.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 97.03.w, minHeight: 20.h),
                    child: Row(
                      key: ValueKey("6:10136"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          key: ValueKey("6:10137"),
                          width: 20.31.w,
                          height: 20.h,),
                        Container(
                          key: ValueKey("6:10138"),
                          width: 20.31.w,
                          height: 20.h,),
                        Container(
                          key: ValueKey("6:10139"),
                          width: 20.31.w,
                          height: 20.h,),
                      ],),),),),
            ],),);
  }
}

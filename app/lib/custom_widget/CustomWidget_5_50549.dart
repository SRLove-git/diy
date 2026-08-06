import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50534.dart';

class CustomWidget_5_50549 extends StatelessWidget {
 CustomWidget_5_50549({super.key});
    late final ImageProvider _image_sipm5_50533 = MemoryImage(imageStr_imageStr_amju5_50533.decodeBase64Image());
  late final ImageProvider _image_zdrz5_50548 = MemoryImage(imageStr_imageStr_ngyz5_50548.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 44.h,
          left: 0.w,
          top: 62.h,
          child: Stack(
            key: ValueKey("5:50549"),
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
                      key: ValueKey("5:50550"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("5:50551"),
                          width: 22.w,
                          height: 22.h,),
                      ],),),),),
              Positioned(
                width: 390.w,
                height: 22.h,
                left: 0.w,
                top: 11.h,
                child: Stack(
                  key: ValueKey("5:50552"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 34.w,
                      height: 22.h,
                      left: 179.w,
                      top: 0.h,
                      child: Text("拍摄",
                        key: ValueKey("5:50553"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 86.w,
                height: 18.h,
                left: 292.w,
                top: 13.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 86.w, minHeight: 18.h),
                    child: Row(
                      key: ValueKey("5:50554"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          key: ValueKey("5:50555"),
                          width: 18.w,
                          height: 18.h,),
                        Container(
                          key: ValueKey("5:50556"),
                          width: 18.w,
                          height: 18.h,),
                        Container(
                          key: ValueKey("5:50557"),
                          width: 18.w,
                          height: 18.h,),
                      ],),),),),
            ],),);
  }
}

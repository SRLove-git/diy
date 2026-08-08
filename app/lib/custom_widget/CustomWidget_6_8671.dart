import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_8528.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_8542.dart';

class CustomWidget_6_8671 extends StatelessWidget {
 CustomWidget_6_8671({super.key});
    late final ImageProvider _image_gsup6_8553 = MemoryImage(imageStr_nxje6_8553.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 50.h,
          left: 0.w,
          top: 70.h,
          child: Stack(
            key: ValueKey("6:8671"),
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
                      key: ValueKey("6:8672"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("6:8673"),
                          width: 24.82.w,
                          height: 25.h,),
                      ],),),),),
              Positioned(
                width: 440.w,
                height: 27.h,
                left: 0.w,
                top: 11.h,
                child: Stack(
                  key: ValueKey("6:8674"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 79.w,
                      height: 23.h,
                      left: 182.w,
                      top: 1.h,
                      child: Text("到店核销",
                        key: ValueKey("6:8675"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 58.68.w,
                height: 21.h,
                left: 368.w,
                top: 15.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 58.68.w, minHeight: 21.h),
                    child: Row(
                      key: ValueKey("6:8676"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          width: 58.68.w,
                          height: 21.h,
                          child: Stack(
                            key: ValueKey("6:8677"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 61.w,
                                height: 18.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("调亮屏幕",
                                  key: ValueKey("6:8678"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

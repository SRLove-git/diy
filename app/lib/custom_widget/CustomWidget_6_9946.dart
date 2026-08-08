import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9931.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';

class CustomWidget_6_9946 extends StatelessWidget {
 CustomWidget_6_9946({super.key});
    late final ImageProvider _image_cmep6_9930 = MemoryImage(imageStr_pjkc6_9930.decodeBase64Image());
  late final ImageProvider _image_iotp6_9945 = MemoryImage(imageStr_izal6_9945.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 50.h,
          left: 0.w,
          top: 70.h,
          child: Stack(
            key: ValueKey("6:9946"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 440.w,
                height: 25.h,
                left: 0.w,
                top: 12.h,
                child: Stack(
                  key: ValueKey("6:9947"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 132.w,
                      left: 155.w,
                      top: 1.h,
                      child: PixTextRich(
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          PixTextItem(
                            margin: EdgeInsets.only(top: 0.h),
                            key: ValueKey("6:9948_0"),
                            children: [
                              TextSpan(
                                text: "关",
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375),),
                              TextSpan(
                                text: "注",
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 10.w),),
                              TextSpan(
                                text: "推",
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375),),
                              TextSpan(
                                text: "荐",
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 10.w),),
                              TextSpan(
                                text: "本地",
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375),),
                            ],),
                        ],),),
                  ],),),
              Positioned(
                width: 20.31.w,
                height: 20.h,
                left: 406.w,
                top: 15.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 20.31.w, minHeight: 20.h),
                    child: Row(
                      key: ValueKey("6:9949"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          key: ValueKey("6:9950"),
                          width: 20.31.w,
                          height: 20.h,),
                      ],),),),),
            ],),);
  }
}

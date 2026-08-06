import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50351.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';

class CustomWidget_5_50366 extends StatelessWidget {
 CustomWidget_5_50366({super.key});
    late final ImageProvider _image_zyke5_50350 = MemoryImage(imageStr_imageStr_zyel5_50350.decodeBase64Image());
  late final ImageProvider _image_vrvl5_50365 = MemoryImage(imageStr_imageStr_tjmg5_50365.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 44.h,
          left: 0.w,
          top: 62.h,
          child: Stack(
            key: ValueKey("5:50366"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 390.w,
                height: 22.h,
                left: 0.w,
                top: 11.h,
                child: Stack(
                  key: ValueKey("5:50367"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 118.w,
                      left: 137.w,
                      top: 0.h,
                      child: PixTextRich(
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          PixTextItem(
                            margin: EdgeInsets.only(top: 0.h),
                            key: ValueKey("5:50368_0"),
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
                width: 18.w,
                height: 18.h,
                left: 360.w,
                top: 13.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                    child: Row(
                      key: ValueKey("5:50369"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          key: ValueKey("5:50370"),
                          width: 18.w,
                          height: 18.h,),
                      ],),),),),
            ],),);
  }
}

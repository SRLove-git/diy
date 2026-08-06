import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48103.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48117.dart';

class CustomWidget_5_48188 extends StatelessWidget {
 CustomWidget_5_48188({super.key});
    late final ImageProvider _image_nwzn5_48123 = MemoryImage(imageStr_imageStr_jokg5_48123.decodeBase64Image());
  late final ImageProvider _image_ygul5_48182 = MemoryImage(imageStr_imageStr_krhc5_48182.decodeBase64Image());
  late final ImageProvider _image_hxas5_48185 = MemoryImage(imageStr_imageStr_plyt5_48185.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 44.h,
          left: 0.w,
          top: 62.h,
          child: Stack(
            key: ValueKey("5:48188"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 390.w,
                height: 28.h,
                left: 0.w,
                top: 8.h,
                child: Stack(
                  key: ValueKey("5:48189"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 82.w,
                      height: 28.h,
                      left: 155.w,
                      top: 0.h,
                      child: Text("手作星球",
                        key: ValueKey("5:48190"),
                        textAlign: TextAlign.center,
                        style: TextStyle(foreground: Paint()..shader = LinearGradient(begin: Alignment(0,0.5), end: Alignment(1,0.5), colors: [Color.fromRGBO(51, 51, 51,1), Color.fromRGBO(20, 20, 20,1)], stops: [0, 1]).createShader(Rect.fromLTWH(155.w, 0.h, 82.w, 28.h)), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 62.w,
                height: 22.h,
                left: 316.w,
                top: 11.h,
                child: Stack(
                  key: ValueKey("5:48191"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 22.w,
                      height: 22.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        key: ValueKey("5:48192"),),),
                    Positioned(
                      width: 22.w,
                      height: 22.h,
                      left: 40.w,
                      top: 0.h,
                      child: Container(
                        key: ValueKey("5:48193"),),),
                    Positioned(
                      width: 18.w,
                      height: 18.h,
                      left: 38.w,
                      top: 2.h,
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          constraints: BoxConstraints(minWidth: 18.w),
                          padding: EdgeInsets.only(left: 5.w,right: 5.w, top: 0.h,bottom: 0.h),
                          decoration: BoxDecoration(color: Color.fromRGBO(255, 59, 48,1),borderRadius: BorderRadius.circular(9.h),),
                          child: Row(
                            key: ValueKey("5:48194"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 8.w,
                                height: 15.h,
                                child: Text("3",
                                  key: ValueKey("5:48195"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                            ],),),),),
                  ],),),
            ],),);
  }
}

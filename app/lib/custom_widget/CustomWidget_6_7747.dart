import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7662.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7676.dart';

class CustomWidget_6_7747 extends StatelessWidget {
 CustomWidget_6_7747({super.key});
    late final ImageProvider _image_xyfo6_7682 = MemoryImage(imageStr_hdzp6_7682.decodeBase64Image());
  late final ImageProvider _image_ymze6_7741 = MemoryImage(imageStr_rrho6_7741.decodeBase64Image());
  late final ImageProvider _image_cqqx6_7744 = MemoryImage(imageStr_mjsl6_7744.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 50.h,
          left: 0.w,
          top: 70.h,
          child: Stack(
            key: ValueKey("6:7747"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 440.w,
                height: 32.h,
                left: 0.w,
                top: 9.h,
                child: Stack(
                  key: ValueKey("6:7748"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 92.26.w,
                      height: 28.h,
                      left: 175.w,
                      top: 1.h,
                      child: Text("手作星球",
                        key: ValueKey("6:7749"),
                        textAlign: TextAlign.center,
                        style: TextStyle(foreground: Paint()..shader = LinearGradient(begin: Alignment(0,0.5), end: Alignment(1,0.5), colors: [Color.fromRGBO(51, 51, 51,1), Color.fromRGBO(20, 20, 20,1)], stops: [0, 1]).createShader(Rect.fromLTWH(175.w, 1.h, 92.26.w, 28.h)), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 69.95.w,
                height: 25.h,
                left: 357.w,
                top: 12.h,
                child: Stack(
                  key: ValueKey("6:7750"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 24.82.w,
                      height: 25.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        key: ValueKey("6:7751"),),),
                    Positioned(
                      width: 24.82.w,
                      height: 25.h,
                      left: 42.82.w,
                      top: 0.h,
                      child: Container(
                        key: ValueKey("6:7752"),),),
                    Positioned(
                      width: 20.31.w,
                      height: 20.h,
                      left: 42.w,
                      top: 3.h,
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          constraints: BoxConstraints(minWidth: 18.w),
                          padding: EdgeInsets.only(left: 5.w,right: 5.w, top: 0.h,bottom: 0.h),
                          decoration: BoxDecoration(color: Color.fromRGBO(255, 59, 48,1),borderRadius: BorderRadius.circular(9.h),),
                          child: Row(
                            key: ValueKey("6:7753"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 10.31.w,
                                height: 15.h,
                                child: Text("3",
                                  key: ValueKey("6:7754"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                            ],),),),),
                  ],),),
            ],),);
  }
}

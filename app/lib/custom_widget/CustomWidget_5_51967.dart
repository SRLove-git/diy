import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51902.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51916.dart';

class CustomWidget_5_51967 extends StatelessWidget {
 CustomWidget_5_51967({super.key});
    late final ImageProvider _image_xcpt5_51919 = MemoryImage(imageStr_imageStr_jzul5_51919.decodeBase64Image());
  late final ImageProvider _image_sgxt5_51921 = MemoryImage(imageStr_imageStr_zgim5_51921.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 44.h,
          left: 0.w,
          top: 62.h,
          child: Stack(
            key: ValueKey("5:51967"),
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
                      key: ValueKey("5:51968"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("5:51969"),
                          width: 22.w,
                          height: 22.h,),
                      ],),),),),
              Positioned(
                width: 390.w,
                height: 24.h,
                left: 0.w,
                top: 10.h,
                child: Stack(
                  key: ValueKey("5:51970"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 70.w,
                      height: 23.h,
                      left: 161.w,
                      top: 0.h,
                      child: Text("编辑资料",
                        key: ValueKey("5:51971"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 54.02.w,
                height: 32.h,
                left: 324.w,
                top: 6.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 54.02.w, minHeight: 32.h),
                    child: Row(
                      key: ValueKey("5:51972"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        SizedBox(
                          width: 54.02.w,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 54.02.w, minHeight: 32.h),
                              padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                              child: Row(
                                key: ValueKey("5:51973"),
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 26.02.w,
                                    height: 18.h,
                                    child: Text("保存",
                                      key: ValueKey("5:51974"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                ],),),),),
                      ],),),),),
            ],),);
  }
}

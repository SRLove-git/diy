import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13874.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13888.dart';

class CustomWidget_6_13970 extends StatelessWidget {
 CustomWidget_6_13970({super.key});
    late final ImageProvider _image_onoa6_13899 = MemoryImage(imageStr_qpmf6_13899.decodeBase64Image());
  late final ImageProvider _image_gsuu6_13917 = MemoryImage(imageStr_mmdk6_13917.decodeBase64Image());
  late final ImageProvider _image_hqnu6_13935 = MemoryImage(imageStr_mxzb6_13935.decodeBase64Image());
  late final ImageProvider _image_rlfy6_13953 = MemoryImage(imageStr_fddp6_13953.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 50.h,
          left: 0.w,
          top: 70.h,
          child: Stack(
            key: ValueKey("6:13970"),
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
                      key: ValueKey("6:13971"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("6:13972"),
                          width: 24.82.w,
                          height: 25.h,),
                      ],),),),),
              Positioned(
                width: 313.64.w,
                height: 41.h,
                left: 54.w,
                top: 4.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 313.64.w, minHeight: 41.h),
                    padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                    decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(18.h),),
                    child: Row(
                      key: ValueKey("6:13973"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 8.w,
                      children: [
                        Container(
                          key: ValueKey("6:13974"),
                          width: 20.31.w,
                          height: 20.h,),
                        Container(
                          width: 29.35.w,
                          height: 21.h,
                          child: Stack(
                            key: ValueKey("6:13975"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 31.w,
                                height: 18.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("拼豆",
                                  key: ValueKey("6:13976"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 31.59.w,
                height: 22.h,
                left: 395.w,
                top: 14.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 31.59.w, minHeight: 22.h),
                    child: Row(
                      key: ValueKey("6:13977"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          width: 31.59.w,
                          height: 20.h,
                          child: Text("搜索",
                            key: ValueKey("6:13978"),
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                      ],),),),),
            ],),);
  }
}

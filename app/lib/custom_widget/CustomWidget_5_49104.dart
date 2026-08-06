import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48961.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48975.dart';

class CustomWidget_5_49104 extends StatelessWidget {
 CustomWidget_5_49104({super.key});
    late final ImageProvider _image_qkxd5_48986 = MemoryImage(imageStr_imageStr_ckwa5_48986.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 44.h,
          left: 0.w,
          top: 62.h,
          child: Stack(
            key: ValueKey("5:49104"),
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
                      key: ValueKey("5:49105"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          key: ValueKey("5:49106"),
                          width: 22.w,
                          height: 22.h,),
                      ],),),),),
              Positioned(
                width: 390.w,
                height: 24.h,
                left: 0.w,
                top: 10.h,
                child: Stack(
                  key: ValueKey("5:49107"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 70.w,
                      height: 23.h,
                      left: 161.w,
                      top: 0.h,
                      child: Text("到店核销",
                        key: ValueKey("5:49108"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 52.02.w,
                height: 18.h,
                left: 326.w,
                top: 13.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 52.02.w, minHeight: 18.h),
                    child: Row(
                      key: ValueKey("5:49109"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 16.w,
                      children: [
                        Container(
                          width: 52.02.w,
                          height: 18.h,
                          child: Stack(
                            key: ValueKey("5:49110"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 54.w,
                                height: 18.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("调亮屏幕",
                                  key: ValueKey("5:49111"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

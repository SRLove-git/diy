import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12871.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_6_12885 extends StatelessWidget {
 CustomWidget_6_12885({super.key});
    late final ImageProvider _image_esnl6_12894 = MemoryImage(imageStr_zlpx6_12894.decodeBase64Image());
  late final ImageProvider _image_motj6_12895 = MemoryImage(imageStr_yvuw6_12895.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 219.h,
          left: 0.w,
          top: 120.h,
          child: Opacity(
            opacity: 0.5,
            child: Stack(
              key: ValueKey("6:12885"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 403.9.w,
                  height: 91.h,
                  left: 18.w,
                  top: 9.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 91.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                      child: Column(
                        key: ValueKey("6:12886"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 403.9.w,
                            height: 79.h,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.h),),
                            child: Stack(
                              key: ValueKey("6:12887"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 103.56.w,
                                  height: 21.h,
                                  left: 0.w,
                                  top: 10.h,
                                  child: Text("分享新鲜事…",
                                    key: ValueKey("6:12888"),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                        ],),),),),
                Positioned(
                  width: 403.9.w,
                  height: 117.h,
                  left: 18.w,
                  top: 101.h,
                  child: Stack(
                    key: ValueKey("6:12889"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        width: 131.61.w,
                        height: 117.h,
                        left: 0.w,
                        top: 0.h,
                        child: SingleChildScrollView(
                          clipBehavior: Clip.none,
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(minWidth: 131.61.w, minHeight: 117.h),
                            decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(12.h),),
                            child: Column(
                              key: ValueKey("6:12890"),
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 5.h,
                              children: [
                                Container(
                                  key: ValueKey("6:12891"),
                                  width: 20.31.w,
                                  height: 20.h,),
                                Container(
                                  width: 54.61.w,
                                  height: 16.h,
                                  child: Stack(
                                    key: ValueKey("6:12892"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 57.w,
                                        height: 14.h,
                                        left: 0.w,
                                        top: 0.h,
                                        child: Text("拍摄 / 相册",
                                          key: ValueKey("6:12893"),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                    ],),),
                              ],),),),),
                      Positioned(
                        width: 131.63.w,
                        height: 117.h,
                        left: 136.w,
                        top: 0.h,
                        child: Container(
                          key: ValueKey("6:12894"),
                          decoration: BoxDecoration(image: DecorationImage(image: _image_esnl6_12894, fit: BoxFit.fill),borderRadius: BorderRadius.circular(12.h),),),),
                      Positioned(
                        width: 131.61.w,
                        height: 117.h,
                        left: 272.w,
                        top: 0.h,
                        child: Container(
                          key: ValueKey("6:12895"),
                          decoration: BoxDecoration(image: DecorationImage(image: _image_motj6_12895, fit: BoxFit.fill),borderRadius: BorderRadius.circular(12.h),),),),
                    ],),),
              ],),),);
  }
}

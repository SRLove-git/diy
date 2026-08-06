import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53261.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_5_53275 extends StatelessWidget {
 CustomWidget_5_53275({super.key});
    late final ImageProvider _image_bgvb5_53284 = MemoryImage(imageStr_imageStr_xshj5_53284.decodeBase64Image());
  late final ImageProvider _image_nxdi5_53285 = MemoryImage(imageStr_imageStr_ikri5_53285.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 194.h,
          left: 0.w,
          top: 106.h,
          child: Opacity(
            opacity: 0.5,
            child: Stack(
              key: ValueKey("5:53275"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 358.w,
                  height: 82.h,
                  left: 16.w,
                  top: 8.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 358.w, minHeight: 82.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                      child: Column(
                        key: ValueKey("5:53276"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 358.w,
                            height: 70.h,
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.h),),
                            child: Stack(
                              key: ValueKey("5:53277"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 92.02.w,
                                  height: 21.h,
                                  left: 0.w,
                                  top: 8.h,
                                  child: Text("分享新鲜事…",
                                    key: ValueKey("5:53278"),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                        ],),),),),
                Positioned(
                  width: 358.w,
                  height: 104.h,
                  left: 16.w,
                  top: 90.h,
                  child: Stack(
                    key: ValueKey("5:53279"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        width: 116.66.w,
                        height: 104.h,
                        left: 0.w,
                        top: 0.h,
                        child: SingleChildScrollView(
                          clipBehavior: Clip.none,
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(minWidth: 116.66.w, minHeight: 104.h),
                            decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(12.h),),
                            child: Column(
                              key: ValueKey("5:53280"),
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 5.h,
                              children: [
                                Container(
                                  key: ValueKey("5:53281"),
                                  width: 18.w,
                                  height: 18.h,),
                                Container(
                                  width: 48.41.w,
                                  height: 14.h,
                                  child: Stack(
                                    key: ValueKey("5:53282"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 50.w,
                                        height: 14.h,
                                        left: 0.w,
                                        top: -1.h,
                                        child: Text("拍摄 / 相册",
                                          key: ValueKey("5:53283"),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                    ],),),
                              ],),),),),
                      Positioned(
                        width: 116.67.w,
                        height: 104.h,
                        left: 121.w,
                        top: 0.h,
                        child: Container(
                          key: ValueKey("5:53284"),
                          decoration: BoxDecoration(image: DecorationImage(image: _image_bgvb5_53284, fit: BoxFit.fill),borderRadius: BorderRadius.circular(12.h),),),),
                      Positioned(
                        width: 116.66.w,
                        height: 104.h,
                        left: 241.w,
                        top: 0.h,
                        child: Container(
                          key: ValueKey("5:53285"),
                          decoration: BoxDecoration(image: DecorationImage(image: _image_nxdi5_53285, fit: BoxFit.fill),borderRadius: BorderRadius.circular(12.h),),),),
                    ],),),
              ],),),);
  }
}

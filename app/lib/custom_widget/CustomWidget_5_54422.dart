import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54359.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54373.dart';

class CustomWidget_5_54422 extends StatelessWidget {
 CustomWidget_5_54422({super.key});
    late final ImageProvider _image_zrli5_54391 = MemoryImage(imageStr_imageStr_oqrn5_54391.decodeBase64Image());
  late final ImageProvider _image_bqrx5_54395 = MemoryImage(imageStr_imageStr_gvqx5_54395.decodeBase64Image());
  late final ImageProvider _image_shue5_54399 = MemoryImage(imageStr_imageStr_bodk5_54399.decodeBase64Image());
  late final ImageProvider _image_qdrz5_54403 = MemoryImage(imageStr_imageStr_rkwg5_54403.decodeBase64Image());
  late final ImageProvider _image_eirw5_54407 = MemoryImage(imageStr_imageStr_lert5_54407.decodeBase64Image());
  late final ImageProvider _image_aedd5_54411 = MemoryImage(imageStr_imageStr_vtbb5_54411.decodeBase64Image());
  late final ImageProvider _image_ohwj5_54422 = MemoryImage(imageStr_imageStr_qrbw5_54422.decodeBase64Image());
  late final ImageProvider _image_ymwl5_54423 = MemoryImage(imageStr_imageStr_bgvj5_54423.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 150.h,
          left: 0.w,
          top: 106.h,
          child: Container(
            decoration: BoxDecoration(image: DecorationImage(image: _image_ohwj5_54422, fit: BoxFit.fill),borderRadius: BorderRadius.only(  bottomLeft: Radius.circular(24.h), bottomRight: Radius.circular(24.h),),),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              key: ValueKey("5:54422"),
              children: [
                Positioned(
                  width: 390.w,
                  height: 150.h,
                  left: 0.w,
                  top: 0.h,
                  child: Container(
                    key: ValueKey("5:54423"),
                    decoration: BoxDecoration(image: DecorationImage(image: _image_ymwl5_54423, fit: BoxFit.fill),),),),
                Positioned(
                  width: 156.34.w,
                  height: 49.h,
                  left: 16.w,
                  top: 87.h,
                  child: Stack(
                    key: ValueKey("5:54424"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        width: 156.34.w,
                        height: 28.h,
                        left: 0.w,
                        top: 0.h,
                        child: Stack(
                          key: ValueKey("5:54425"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 158.w,
                              height: 28.h,
                              left: 0.w,
                              top: 0.h,
                              child: Text("# 芙宁娜的后花园",
                                key: ValueKey("5:54426"),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                          ],),),
                      Positioned(
                        width: 156.34.w,
                        height: 21.h,
                        left: 0.w,
                        top: 28.h,
                        child: SingleChildScrollView(
                          clipBehavior: Clip.none,
                          physics: NeverScrollableScrollPhysics(),
                          child: Container(
                            constraints: BoxConstraints(minWidth: 156.34.w, minHeight: 21.h),
                            padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 4.h,bottom: 0.h),
                            child: Column(
                              key: ValueKey("5:54427"),
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 156.34.w,
                                  height: 17.h,
                                  child: Opacity(
                                    opacity: 0.85,
                                    child: Stack(
                                      key: ValueKey("5:54428"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 122.w,
                                          height: 17.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("3.2k 帖子 · 1.8w 关注",
                                            key: ValueKey("5:54429"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),),
                              ],),),),),
                    ],),),
              ],),),);
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51067.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51081.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51094.dart';

class CustomWidget_5_51120 extends StatelessWidget {
 CustomWidget_5_51120({super.key});
    late final ImageProvider _image_epwb5_51088 = MemoryImage(imageStr_imageStr_dchf5_51088.decodeBase64Image());
  late final ImageProvider _image_utzn5_51090 = MemoryImage(imageStr_imageStr_nrny5_51090.decodeBase64Image());
  late final ImageProvider _image_xedw5_51092 = MemoryImage(imageStr_imageStr_rhdn5_51092.decodeBase64Image());
  late final ImageProvider _image_tmun5_51101 = MemoryImage(imageStr_imageStr_pokw5_51101.decodeBase64Image());
  late final ImageProvider _image_efxi5_51110 = MemoryImage(imageStr_imageStr_xuds5_51110.decodeBase64Image());
  late final ImageProvider _image_mbjn5_51113 = MemoryImage(imageStr_imageStr_evtn5_51113.decodeBase64Image());
  late final ImageProvider _image_mvug5_51128 = MemoryImage(imageStr_imageStr_lpzd5_51128.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 74.h,
          left: 0.w,
          top: 770.h,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(minWidth: 390.w, minHeight: 74.h),
              padding: EdgeInsets.only(left: 12.w,right: 12.w, top: 1.h,bottom: 0.h),
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
              child: Row(
                key: ValueKey("5:51120"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10.w,
                children: [
                  Container(
                    width: 22.w,
                    height: 26.h,
                    child: Stack(
                      key: ValueKey("5:51121"),
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 22.w,
                          height: 22.h,
                          left: 0.w,
                          top: 0.h,
                          child: Container(
                            key: ValueKey("5:51122"),),),
                      ],),),
                  SizedBox(
                    width: 237.98.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 237.98.w, minHeight: 42.h),
                        padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(21.h),),
                        child: Row(
                          key: ValueKey("5:51123"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8.w,
                          children: [
                            Container(
                              width: 80.22.w,
                              height: 18.h,
                              child: Stack(
                                key: ValueKey("5:51124"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 82.w,
                                    height: 18.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Text("@ 提及成员…",
                                      key: ValueKey("5:51125"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                  Container(
                    width: 22.w,
                    height: 26.h,
                    child: Stack(
                      key: ValueKey("5:51126"),
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 22.w,
                          height: 22.h,
                          left: 0.w,
                          top: 0.h,
                          child: Container(
                            key: ValueKey("5:51127"),),),
                      ],),),
                  SizedBox(
                    width: 54.02.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 54.02.w, minHeight: 38.h),
                        padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(image: DecorationImage(image: _image_mvug5_51128, fit: BoxFit.fill),borderRadius: BorderRadius.circular(18.h),),
                        child: Row(
                          key: ValueKey("5:51128"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 26.02.w,
                              height: 18.h,
                              child: Text("发送",
                                key: ValueKey("5:51129"),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                          ],),),),),
                ],),),),);
  }
}

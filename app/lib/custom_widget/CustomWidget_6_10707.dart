import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10654.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10668.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10681.dart';

class CustomWidget_6_10707 extends StatelessWidget {
 CustomWidget_6_10707({super.key});
    late final ImageProvider _image_mkcl6_10675 = MemoryImage(imageStr_reca6_10675.decodeBase64Image());
  late final ImageProvider _image_xkwv6_10677 = MemoryImage(imageStr_hlop6_10677.decodeBase64Image());
  late final ImageProvider _image_czsh6_10679 = MemoryImage(imageStr_sxhl6_10679.decodeBase64Image());
  late final ImageProvider _image_cttm6_10688 = MemoryImage(imageStr_ullh6_10688.decodeBase64Image());
  late final ImageProvider _image_rpkr6_10697 = MemoryImage(imageStr_yjmu6_10697.decodeBase64Image());
  late final ImageProvider _image_nsnr6_10700 = MemoryImage(imageStr_xrpl6_10700.decodeBase64Image());
  late final ImageProvider _image_rpem6_10715 = MemoryImage(imageStr_mqki6_10715.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 83.h,
          left: 0.w,
          top: 869.h,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(minWidth: 440.w, minHeight: 83.h),
              padding: EdgeInsets.only(left: 12.w,right: 12.w, top: 1.h,bottom: 0.h),
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
              child: Row(
                key: ValueKey("6:10707"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 10.w,
                children: [
                  Container(
                    width: 24.82.w,
                    height: 29.h,
                    child: Stack(
                      key: ValueKey("6:10708"),
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 24.82.w,
                          height: 25.h,
                          left: 0.w,
                          top: 0.h,
                          child: Container(
                            key: ValueKey("6:10709"),),),
                      ],),),
                  SizedBox(
                    width: 268.5.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 268.5.w, minHeight: 47.h),
                        padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(21.h),),
                        child: Row(
                          key: ValueKey("6:10710"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8.w,
                          children: [
                            Container(
                              width: 90.5.w,
                              height: 21.h,
                              child: Stack(
                                key: ValueKey("6:10711"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 93.w,
                                    height: 18.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Text("@ 提及成员…",
                                      key: ValueKey("6:10712"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                  Container(
                    width: 24.82.w,
                    height: 29.h,
                    child: Stack(
                      key: ValueKey("6:10713"),
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 24.82.w,
                          height: 25.h,
                          left: 0.w,
                          top: 0.h,
                          child: Container(
                            key: ValueKey("6:10714"),),),
                      ],),),
                  SizedBox(
                    width: 60.94.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 60.94.w, minHeight: 43.h),
                        padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(image: DecorationImage(image: _image_rpem6_10715, fit: BoxFit.fill),borderRadius: BorderRadius.circular(18.h),),
                        child: Row(
                          key: ValueKey("6:10715"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32.94.w,
                              height: 18.h,
                              child: Text("发送",
                                key: ValueKey("6:10716"),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                          ],),),),),
                ],),),),);
  }
}

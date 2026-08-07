import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14675.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14696.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14705.dart';

class CustomWidget_6_14750 extends StatelessWidget {
 CustomWidget_6_14750({super.key});
    late final ImageProvider _image_qhaf6_14698 = MemoryImage(imageStr_wvjk6_14698.decodeBase64Image());
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
              padding: EdgeInsets.only(left: 10.w,right: 10.w, top: 1.h,bottom: 0.h),
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
              child: Row(
                key: ValueKey("6:14750"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 6.w,
                children: [
                  SizedBox(
                    width: 38.36.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 38.36.w, minHeight: 20.h),
                        child: Row(
                          key: ValueKey("6:14751"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              key: ValueKey("6:14752"),
                              width: 20.31.w,
                              height: 20.h,),
                          ],),),),),
                  SizedBox(
                    width: 259.47.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 259.47.w, minHeight: 47.h),
                        padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(21.h),),
                        child: Row(
                          key: ValueKey("6:14753"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8.w,
                          children: [
                            Container(
                              width: 117.35.w,
                              height: 21.h,
                              child: Stack(
                                key: ValueKey("6:14754"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 119.w,
                                    height: 18.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Text("晚上一起吃饭吗？",
                                      key: ValueKey("6:14755"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 38.36.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 38.36.w, minHeight: 20.h),
                        child: Row(
                          key: ValueKey("6:14756"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              key: ValueKey("6:14757"),
                              width: 20.31.w,
                              height: 20.h,),
                          ],),),),),
                  SizedBox(
                    width: 60.94.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 60.94.w, minHeight: 41.h),
                        padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                        child: Row(
                          key: ValueKey("6:14758"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 32.94.w,
                              height: 18.h,
                              child: Text("发送",
                                key: ValueKey("6:14759"),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                          ],),),),),
                ],),),),);
  }
}

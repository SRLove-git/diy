import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_55216.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_55237.dart';

class CustomWidget_5_55246 extends StatelessWidget {
 CustomWidget_5_55246({super.key});
    late final ImageProvider _image_oxol5_55239 = MemoryImage(imageStr_imageStr_iqkj5_55239.decodeBase64Image());
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
              padding: EdgeInsets.only(left: 10.w,right: 10.w, top: 1.h,bottom: 0.h),
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
              child: Row(
                key: ValueKey("5:55246"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 6.w,
                children: [
                  SizedBox(
                    width: 34.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(17.h),),
                        child: Row(
                          key: ValueKey("5:55247"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              key: ValueKey("5:55248"),
                              width: 18.w,
                              height: 18.h,),
                          ],),),),),
                  SizedBox(
                    width: 250.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 250.w, minHeight: 42.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(21.h),),
                        child: Row(
                          key: ValueKey("5:55249"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8.w,
                          children: [
                            Container(
                              key: ValueKey("5:55250"),
                              width: 18.w,
                              height: 18.h,),
                            Container(
                              width: 59.17.w,
                              height: 20.h,
                              child: Stack(
                                key: ValueKey("5:55251"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 61.w,
                                    height: 20.h,
                                    left: 0.w,
                                    top: -1.h,
                                    child: Text("按住 说话",
                                      key: ValueKey("5:55252"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 34.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 34.w, minHeight: 18.h),
                        child: Row(
                          key: ValueKey("5:55253"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              key: ValueKey("5:55254"),
                              width: 18.w,
                              height: 18.h,),
                          ],),),),),
                  SizedBox(
                    width: 34.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 34.w, minHeight: 18.h),
                        child: Row(
                          key: ValueKey("5:55255"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              key: ValueKey("5:55256"),
                              width: 18.w,
                              height: 18.h,),
                          ],),),),),
                ],),),),);
  }
}

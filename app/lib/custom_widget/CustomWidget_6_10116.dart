import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_6_10116 extends StatelessWidget {
 CustomWidget_6_10116({super.key});
    late final ImageProvider _image_cmpc6_10115 = MemoryImage(imageStr_eqki6_10115.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 70.h,
          left: 0.w,
          top: 0.h,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            child: Container(
              constraints: BoxConstraints(minWidth: 440.w, minHeight: 70.h),
              padding: EdgeInsets.only(left: 32.w,right: 28.w, top: 0.h,bottom: 0.h),
              child: Row(
                key: ValueKey("6:10116"),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36.14.w,
                    height: 25.h,
                    child: Stack(
                      key: ValueKey("6:10117"),
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 38.w,
                          height: 22.h,
                          left: 0.w,
                          top: 2.h,
                          child: Text("9:41",
                            key: ValueKey("6:10118"),
                            textAlign: TextAlign.left,
                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: -0.2.w),),),
                      ],),),
                  SizedBox(
                    width: 81.23.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 81.23.w, minHeight: 14.h),
                        child: Row(
                          key: ValueKey("6:10119"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 7.w,
                          children: [
                            SizedBox(
                              width: 20.31.w,
                              child: SingleChildScrollView(
                                clipBehavior: Clip.none,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 20.31.w, minHeight: 12.h),
                                  child: Row(
                                    key: ValueKey("6:10120"),
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    spacing: 2.w,
                                    children: [
                                      Container(
                                        key: ValueKey("6:10121"),
                                        width: 3.38.w,
                                        height: 5.h,
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(1.h),),),
                                      Container(
                                        key: ValueKey("6:10122"),
                                        width: 3.38.w,
                                        height: 7.h,
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(1.h),),),
                                      Container(
                                        key: ValueKey("6:10123"),
                                        width: 3.38.w,
                                        height: 9.h,
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(1.h),),),
                                      Container(
                                        key: ValueKey("6:10124"),
                                        width: 3.38.w,
                                        height: 12.h,
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(1.h),),),
                                    ],),),),),
                            Container(
                              width: 18.05.w,
                              height: 12.h,
                              decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(8.h), topRight: Radius.circular(8.h),  ),border: Border(left: BorderSide(width: 1.w,color: Color.fromRGBO(255, 255, 255,1),),right: BorderSide(width: 1.w,color: Color.fromRGBO(255, 255, 255,1),),top: BorderSide(width: 1.w,color: Color.fromRGBO(255, 255, 255,1),),),),
                              child: Stack(
                                key: ValueKey("6:10125"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 2.w,
                                    height: 3.h,
                                    left: 7.w,
                                    top: 10.h,
                                    child: Container(
                                      key: ValueKey("6:10126"),
                                      decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(1.h),),),),
                                ],),),
                            Container(
                              width: 27.08.w,
                              height: 14.h,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.h),border: Border.all(width: 1.w, color: Color.fromRGBO(255, 255, 255,1), ),),
                              child: Stack(
                                key: ValueKey("6:10127"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 2.w,
                                    height: 4.h,
                                    left: 24.w,
                                    top: 4.h,
                                    child: Container(
                                      key: ValueKey("6:10128"),
                                      decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.only( topRight: Radius.circular(1.h),  bottomRight: Radius.circular(1.h),),),),),
                                  Positioned(
                                    width: 11.w,
                                    height: 6.h,
                                    left: 3.w,
                                    top: 3.h,
                                    child: Container(
                                      key: ValueKey("6:10129"),
                                      decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(1.5.h),),),),
                                ],),),
                          ],),),),),
                ],),),),);
  }
}

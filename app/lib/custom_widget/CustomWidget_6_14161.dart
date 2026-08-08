import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14147.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_6_14161 extends StatelessWidget {
 CustomWidget_6_14161({super.key});
    late final ImageProvider _image_uvhh6_14164 = MemoryImage(imageStr_woxy6_14164.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 338.h,
          left: 0.w,
          top: 120.h,
          child: Stack(
            key: ValueKey("6:14161"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 97.h,
                left: 18.w,
                top: 9.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 97.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 16.h),
                    child: Column(
                      key: ValueKey("6:14162"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 403.9.w,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 81.h),
                              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 16.h,bottom: 16.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                              child: Row(
                                key: ValueKey("6:14163"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12.w,
                                children: [
                                  SizedBox(
                                    width: 45.13.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 45.13.w, minHeight: 45.h),
                                        decoration: BoxDecoration(image: DecorationImage(image: _image_uvhh6_14164, fit: BoxFit.fill),borderRadius: BorderRadius.circular(12.h),),
                                        child: Row(
                                          key: ValueKey("6:14164"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              key: ValueKey("6:14165"),
                                              width: 20.31.w,
                                              height: 20.h,),
                                          ],),),),),
                                  Container(
                                    width: 186.21.w,
                                    height: 39.h,
                                    child: Stack(
                                      key: ValueKey("6:14166"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 186.21.w,
                                          height: 22.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Stack(
                                            key: ValueKey("6:14167"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 176.w,
                                                height: 20.h,
                                                left: 0.w,
                                                top: 1.h,
                                                child: Text("拉黑后对方无法与你互动",
                                                  key: ValueKey("6:14168"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                            ],),),
                                        Positioned(
                                          width: 186.21.w,
                                          height: 17.h,
                                          left: 0.w,
                                          top: 23.h,
                                          child: Stack(
                                            key: ValueKey("6:14169"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 188.w,
                                                height: 15.h,
                                                left: 0.w,
                                                top: 0.h,
                                                child: Text("不能发消息、评论和关注，共 3 人",
                                                  key: ValueKey("6:14170"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                            ],),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 230.h,
                left: 18.w,
                top: 108.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("6:14171"),
                    image: AssetImage("assets/divcardcardpad.png"),),),),
            ],),);
  }
}

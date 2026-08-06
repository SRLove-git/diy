import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54523.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_5_54537 extends StatelessWidget {
 CustomWidget_5_54537({super.key});
    late final ImageProvider _image_zugk5_54540 = MemoryImage(imageStr_imageStr_npyl5_54540.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 300.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:54537"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 88.h,
                left: 16.w,
                top: 8.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 88.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 16.h),
                    child: Column(
                      key: ValueKey("5:54538"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 358.w,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 72.h),
                              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 16.h,bottom: 16.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                              child: Row(
                                key: ValueKey("5:54539"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12.w,
                                children: [
                                  SizedBox(
                                    width: 40.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                                        decoration: BoxDecoration(image: DecorationImage(image: _image_zugk5_54540, fit: BoxFit.fill),borderRadius: BorderRadius.circular(12.h),),
                                        child: Row(
                                          key: ValueKey("5:54540"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              key: ValueKey("5:54541"),
                                              width: 18.w,
                                              height: 18.h,),
                                          ],),),),),
                                  Container(
                                    width: 165.05.w,
                                    height: 35.h,
                                    child: Stack(
                                      key: ValueKey("5:54542"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 165.05.w,
                                          height: 20.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Stack(
                                            key: ValueKey("5:54543"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 156.w,
                                                height: 20.h,
                                                left: 0.w,
                                                top: -1.h,
                                                child: Text("拉黑后对方无法与你互动",
                                                  key: ValueKey("5:54544"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                            ],),),
                                        Positioned(
                                          width: 165.05.w,
                                          height: 15.h,
                                          left: 0.w,
                                          top: 19.h,
                                          child: Stack(
                                            key: ValueKey("5:54545"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 167.w,
                                                height: 15.h,
                                                left: 0.w,
                                                top: -1.h,
                                                child: Text("不能发消息、评论和关注，共 3 人",
                                                  key: ValueKey("5:54546"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                            ],),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 204.h,
                left: 16.w,
                top: 96.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:54547"),
                    image: AssetImage("assets/divcardcardpad.png"),),),),
            ],),);
  }
}

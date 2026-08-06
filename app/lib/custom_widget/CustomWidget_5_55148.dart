import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_55127.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_5_55148 extends StatelessWidget {
 CustomWidget_5_55148({super.key});
    late final ImageProvider _image_bvhi5_55150 = MemoryImage(imageStr_imageStr_vtzz5_55150.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 664.h,
          left: 0.w,
          top: 106.h,
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            physics: NeverScrollableScrollPhysics(),
            child: Container(
              constraints: BoxConstraints(minWidth: 390.w, minHeight: 664.h),
              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 16.h,bottom: 16.h),
              child: Column(
                key: ValueKey("5:55148"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.h,
                children: [
                  SizedBox(
                    width: 358.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 358.w, minHeight: 40.h),
                        child: Row(
                          key: ValueKey("5:55149"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8.w,
                          children: [
                            SizedBox(
                              width: 32.w,
                              child: SingleChildScrollView(
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.h),
                                  decoration: BoxDecoration(image: DecorationImage(image: _image_bvhi5_55150, fit: BoxFit.fill),borderRadius: BorderRadius.circular(16.h),),
                                  clipBehavior: Clip.hardEdge,
                                  child: Row(
                                    key: ValueKey("5:55150"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32.w,
                                        height: 17.h,
                                        child: Text("豆",
                                          key: ValueKey("5:55151"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                    ],),),),),
                            Container(
                              width: 115.14.w,
                              height: 40.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(4.h), bottomRight: Radius.circular(16.h),),),
                              child: Stack(
                                key: ValueKey("5:55152"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 89.w,
                                    height: 20.h,
                                    left: 14.w,
                                    top: 9.h,
                                    child: Text("哈哈 太好笑了",
                                      key: ValueKey("5:55153"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 358.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 358.w, minHeight: 40.h),
                        child: Row(
                          key: ValueKey("5:55154"),
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 154.w,
                              height: 40.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(16.h), bottomRight: Radius.circular(4.h),),),
                              child: Stack(
                                key: ValueKey("5:55155"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 128.w,
                                    height: 20.h,
                                    left: 14.w,
                                    top: 9.h,
                                    child: Text("真的吗？我拍给你看",
                                      key: ValueKey("5:55156"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                ],),),),);
  }
}

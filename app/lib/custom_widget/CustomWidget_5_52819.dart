import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52784.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52805.dart';

class CustomWidget_5_52819 extends StatelessWidget {
 CustomWidget_5_52819({super.key});
    late final ImageProvider _image_lcaq5_52807 = MemoryImage(imageStr_imageStr_fpwi5_52807.decodeBase64Image());
  late final ImageProvider _image_porm5_52815 = MemoryImage(imageStr_imageStr_kgge5_52815.decodeBase64Image());
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
                key: ValueKey("5:52819"),
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
                        constraints: BoxConstraints(minWidth: 34.w, minHeight: 18.h),
                        child: Row(
                          key: ValueKey("5:52820"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              key: ValueKey("5:52821"),
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
                        padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(21.h),),
                        child: Row(
                          key: ValueKey("5:52822"),
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 8.w,
                          children: [
                            Container(
                              width: 65.02.w,
                              height: 18.h,
                              child: Stack(
                                key: ValueKey("5:52823"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 67.w,
                                    height: 18.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Text("发送消息…",
                                      key: ValueKey("5:52824"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
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
                          key: ValueKey("5:52825"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              key: ValueKey("5:52826"),
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
                          key: ValueKey("5:52827"),
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              key: ValueKey("5:52828"),
                              width: 18.w,
                              height: 18.h,),
                          ],),),),),
                ],),),),);
  }
}

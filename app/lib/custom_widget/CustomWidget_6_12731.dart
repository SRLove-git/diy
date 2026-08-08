import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12692.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12706.dart';

class CustomWidget_6_12731 extends StatelessWidget {
 CustomWidget_6_12731({super.key});
    late final ImageProvider _image_jzln6_12724 = MemoryImage(imageStr_rokw6_12724.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 312.w,
          height: 191.h,
          left: 44.w,
          top: 311.h,
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(22.h),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.22),offset: Offset(0.w, 24.w),blurRadius: 64.w,)],),
            child: Stack(
              key: ValueKey("6:12731"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 302.36.w,
                  height: 27.h,
                  left: 25.w,
                  top: 29.h,
                  child: Stack(
                    key: ValueKey("6:12732"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        width: 78.w,
                        height: 23.h,
                        left: 113.w,
                        top: 1.h,
                        child: Text("删除作品",
                          key: ValueKey("6:12733"),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                    ],),),
                Positioned(
                  width: 302.36.w,
                  height: 57.h,
                  left: 25.w,
                  top: 57.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 302.36.w, minHeight: 57.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 10.h,bottom: 0.h),
                      child: Column(
                        key: ValueKey("6:12734"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 302.36.w,
                            height: 47.h,
                            child: Stack(
                              key: ValueKey("6:12735"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 295.w,
                                  height: 42.h,
                                  left: 4.w,
                                  top: 2.h,
                                  child: Text("删除后不可恢复，作品下的评论和点赞也会一并删除，确定删除吗？",
                                    key: ValueKey("6:12736"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.6, letterSpacing: 0.w),),),
                              ],),),
                        ],),),),),
                Positioned(
                  width: 352.w,
                  height: 99.h,
                  left: 0.w,
                  top: 117.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 352.w, minHeight: 99.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 22.h,bottom: 0.h),
                      child: Column(
                        key: ValueKey("6:12737"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 352.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 352.w, minHeight: 77.h),
                                padding: EdgeInsets.only(left: 22.w,right: 22.w, top: 0.h,bottom: 22.h),
                                child: Row(
                                  key: ValueKey("6:12738"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10.w,
                                  children: [
                                    SizedBox(
                                      width: 145.54.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 145.54.w, minHeight: 52.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(15.h),),
                                          child: Row(
                                            key: ValueKey("6:12739"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 145.54.w,
                                                height: 21.h,
                                                child: Text("取消",
                                                  key: ValueKey("6:12740"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                            ],),),),),
                                    SizedBox(
                                      width: 145.54.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 145.54.w, minHeight: 52.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(255, 59, 48,1),borderRadius: BorderRadius.circular(15.h),),
                                          child: Row(
                                            key: ValueKey("6:12741"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 145.54.w,
                                                height: 21.h,
                                                child: Text("删除",
                                                  key: ValueKey("6:12742"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                            ],),),),),
                                  ],),),),),
                        ],),),),),
              ],),),);
  }
}

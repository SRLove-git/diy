import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53085.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53099.dart';

class CustomWidget_5_53124 extends StatelessWidget {
 CustomWidget_5_53124({super.key});
    late final ImageProvider _image_ucdi5_53117 = MemoryImage(imageStr_imageStr_hvay5_53117.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 312.w,
          height: 191.h,
          left: 39.w,
          top: 276.h,
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(22.h),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.22),offset: Offset(0.w, 24.w),blurRadius: 64.w,)],),
            child: Stack(
              key: ValueKey("5:53124"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 268.w,
                  height: 24.h,
                  left: 22.w,
                  top: 26.h,
                  child: Stack(
                    key: ValueKey("5:53125"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        width: 69.w,
                        height: 23.h,
                        left: 100.w,
                        top: -1.h,
                        child: Text("删除作品",
                          key: ValueKey("5:53126"),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                    ],),),
                Positioned(
                  width: 268.w,
                  height: 52.h,
                  left: 22.w,
                  top: 49.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 268.w, minHeight: 52.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 10.h,bottom: 0.h),
                      child: Column(
                        key: ValueKey("5:53127"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 268.w,
                            height: 42.h,
                            child: Stack(
                              key: ValueKey("5:53128"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 262.w,
                                  height: 42.h,
                                  left: 4.w,
                                  top: 0.h,
                                  child: Text("删除后不可恢复，作品下的评论和点赞也会一并删除，确定删除吗？",
                                    key: ValueKey("5:53129"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.6, letterSpacing: 0.w),),),
                              ],),),
                        ],),),),),
                Positioned(
                  width: 312.w,
                  height: 90.h,
                  left: 0.w,
                  top: 101.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 312.w, minHeight: 90.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 22.h,bottom: 0.h),
                      child: Column(
                        key: ValueKey("5:53130"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 312.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 312.w, minHeight: 68.h),
                                padding: EdgeInsets.only(left: 22.w,right: 22.w, top: 0.h,bottom: 22.h),
                                child: Row(
                                  key: ValueKey("5:53131"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 10.w,
                                  children: [
                                    SizedBox(
                                      width: 129.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 129.w, minHeight: 46.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(15.h),),
                                          child: Row(
                                            key: ValueKey("5:53132"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 129.w,
                                                height: 21.h,
                                                child: Text("取消",
                                                  key: ValueKey("5:53133"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                            ],),),),),
                                    SizedBox(
                                      width: 129.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 129.w, minHeight: 46.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(255, 59, 48,1),borderRadius: BorderRadius.circular(15.h),),
                                          child: Row(
                                            key: ValueKey("5:53134"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 129.w,
                                                height: 21.h,
                                                child: Text("删除",
                                                  key: ValueKey("5:53135"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                            ],),),),),
                                  ],),),),),
                        ],),),),),
              ],),),);
  }
}

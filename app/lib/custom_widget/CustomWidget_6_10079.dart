import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10014.dart';

class CustomWidget_6_10079 extends StatelessWidget {
 CustomWidget_6_10079({super.key});
    late final ImageProvider _image_inrt6_10039 = MemoryImage(imageStr_mlpm6_10039.decodeBase64Image());
  late final ImageProvider _image_okql6_10053 = MemoryImage(imageStr_eprg6_10053.decodeBase64Image());
  late final ImageProvider _image_tlqn6_10067 = MemoryImage(imageStr_rvpe6_10067.decodeBase64Image());
  late final ImageProvider _image_nydp6_10079 = MemoryImage(imageStr_tant6_10079.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 429.h,
          left: 0.w,
          top: 0.h,
          child: Container(
            decoration: BoxDecoration(image: DecorationImage(image: _image_nydp6_10079, fit: BoxFit.fill),borderRadius: BorderRadius.only(  bottomLeft: Radius.circular(24.h), bottomRight: Radius.circular(24.h),),),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              key: ValueKey("6:10079"),
              children: [
                Positioned(
                  width: 440.w,
                  height: 429.h,
                  left: 0.w,
                  top: 0.h,
                  child: Container(
                    key: ValueKey("6:10080"),
                    decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0,0.25),),),),
                Positioned(
                  width: 440.w,
                  height: 120.h,
                  left: 0.w,
                  top: 0.h,
                  child: Stack(
                    key: ValueKey("6:10081"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
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
                              key: ValueKey("6:10082"),
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 36.14.w,
                                  height: 25.h,
                                  child: Stack(
                                    key: ValueKey("6:10083"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 38.w,
                                        height: 22.h,
                                        left: 0.w,
                                        top: 2.h,
                                        child: Text("9:41",
                                          key: ValueKey("6:10084"),
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
                                        key: ValueKey("6:10085"),
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
                                                  key: ValueKey("6:10086"),
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  spacing: 2.w,
                                                  children: [
                                                    Container(
                                                      key: ValueKey("6:10087"),
                                                      width: 3.38.w,
                                                      height: 5.h,
                                                      decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(1.h),),),
                                                    Container(
                                                      key: ValueKey("6:10088"),
                                                      width: 3.38.w,
                                                      height: 7.h,
                                                      decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(1.h),),),
                                                    Container(
                                                      key: ValueKey("6:10089"),
                                                      width: 3.38.w,
                                                      height: 9.h,
                                                      decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(1.h),),),
                                                    Container(
                                                      key: ValueKey("6:10090"),
                                                      width: 3.38.w,
                                                      height: 12.h,
                                                      decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(1.h),),),
                                                  ],),),),),
                                          Container(
                                            width: 18.05.w,
                                            height: 12.h,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.only(topLeft: Radius.circular(8.h), topRight: Radius.circular(8.h),  ),border: Border(left: BorderSide(width: 1.w,color: Color.fromRGBO(255, 255, 255,1),),right: BorderSide(width: 1.w,color: Color.fromRGBO(255, 255, 255,1),),top: BorderSide(width: 1.w,color: Color.fromRGBO(255, 255, 255,1),),),),
                                            child: Stack(
                                              key: ValueKey("6:10091"),
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  width: 2.w,
                                                  height: 3.h,
                                                  left: 7.w,
                                                  top: 10.h,
                                                  child: Container(
                                                    key: ValueKey("6:10092"),
                                                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(1.h),),),),
                                              ],),),
                                          Container(
                                            width: 27.08.w,
                                            height: 14.h,
                                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.h),border: Border.all(width: 1.w, color: Color.fromRGBO(255, 255, 255,1), ),),
                                            child: Stack(
                                              key: ValueKey("6:10093"),
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  width: 2.w,
                                                  height: 4.h,
                                                  left: 24.w,
                                                  top: 4.h,
                                                  child: Container(
                                                    key: ValueKey("6:10094"),
                                                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.only( topRight: Radius.circular(1.h),  bottomRight: Radius.circular(1.h),),),),),
                                                Positioned(
                                                  width: 11.w,
                                                  height: 6.h,
                                                  left: 3.w,
                                                  top: 3.h,
                                                  child: Container(
                                                    key: ValueKey("6:10095"),
                                                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(1.5.h),),),),
                                              ],),),
                                        ],),),),),
                              ],),),),),
                      Positioned(
                        width: 440.w,
                        height: 50.h,
                        left: 0.w,
                        top: 70.h,
                        child: Stack(
                          key: ValueKey("6:10096"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 45.13.w,
                              height: 45.h,
                              left: 8.w,
                              top: 2.5.h,
                              child: SingleChildScrollView(
                                clipBehavior: Clip.none,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 45.13.w, minHeight: 45.h),
                                  child: Row(
                                    key: ValueKey("6:10097"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        key: ValueKey("6:10098"),
                                        width: 24.82.w,
                                        height: 25.h,),
                                    ],),),),),
                            Positioned(
                              width: 440.w,
                              height: 27.h,
                              left: 0.w,
                              top: 11.h,
                              child: Stack(
                                key: ValueKey("6:10099"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 79.w,
                                    height: 23.h,
                                    left: 182.w,
                                    top: 1.h,
                                    child: Text("视频详情",
                                      key: ValueKey("6:10100"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                ],),),
                            Positioned(
                              width: 24.82.w,
                              height: 30.h,
                              left: 397.w,
                              top: 10.h,
                              child: Stack(
                                key: ValueKey("6:10101"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 24.82.w,
                                    height: 25.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Container(
                                      key: ValueKey("6:10102"),),),
                                ],),),
                          ],),),
                    ],),),
                Positioned(
                  width: 64.w,
                  height: 64.h,
                  left: 184.w,
                  top: 178.h,
                  child: Container(
                    decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.9),borderRadius: BorderRadius.circular(32.h),),
                    child: Stack(
                      key: ValueKey("6:10103"),
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 29.33.w,
                          height: 29.h,
                          left: 8.w,
                          top: 5.h,
                          child: Container(
                            key: ValueKey("6:10104"),
                            decoration: BoxDecoration(border: Border(left: BorderSide(width: 11.w,color: Color.fromRGBO(20, 20, 20,1),),bottom: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),top: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),),),),),
                      ],),),),
                Positioned(
                  width: 304.07.w,
                  height: 21.h,
                  left: 18.w,
                  top: 392.h,
                  child: Stack(
                    key: ValueKey("6:10105"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        width: 306.w,
                        height: 18.h,
                        left: 0.w,
                        top: 1.h,
                        child: Text("@手作阿周 · 3 分钟学会渐变拼豆 #拼豆 #手工",
                          key: ValueKey("6:10106"),
                          textAlign: TextAlign.left,
                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                    ],),),
              ],),),);
  }
}

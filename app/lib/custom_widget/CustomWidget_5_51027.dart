import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51006.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_5_51027 extends StatelessWidget {
 CustomWidget_5_51027({super.key});
    late final ImageProvider _image_clkc5_51031 = MemoryImage(imageStr_imageStr_pdad5_51031.decodeBase64Image());
  late final ImageProvider _image_rqvl5_51039 = MemoryImage(imageStr_imageStr_yxtp5_51039.decodeBase64Image());
  late final ImageProvider _image_olkz5_51044 = MemoryImage(imageStr_imageStr_yxrf5_51044.decodeBase64Image());
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
              decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),),
              child: Column(
                key: ValueKey("5:51027"),
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.h,
                children: [
                  Container(
                    width: 358.w,
                    height: 21.h,
                    child: Stack(
                      key: ValueKey("5:51028"),
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 53.95.w,
                          height: 15.h,
                          left: 153.w,
                          top: 4.h,
                          child: Text("今天 14:18",
                            key: ValueKey("5:51029"),
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                      ],),),
                  SizedBox(
                    width: 358.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 358.w, minHeight: 59.h),
                        child: Row(
                          key: ValueKey("5:51030"),
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
                                  decoration: BoxDecoration(image: DecorationImage(image: _image_clkc5_51031, fit: BoxFit.fill),borderRadius: BorderRadius.circular(16.h),),
                                  clipBehavior: Clip.hardEdge,
                                  child: Row(
                                    key: ValueKey("5:51031"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32.w,
                                        height: 17.h,
                                        child: Text("豆",
                                          key: ValueKey("5:51032"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                    ],),),),),
                            Container(
                              width: 250.w,
                              height: 59.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(4.h), bottomRight: Radius.circular(16.h),),),
                              child: Stack(
                                key: ValueKey("5:51033"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 212.w,
                                    height: 40.h,
                                    left: 14.w,
                                    top: 9.h,
                                    child: Text("今晚要一起拼豆吗？我买了新的星空材料包",
                                      key: ValueKey("5:51034"),
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
                          key: ValueKey("5:51035"),
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 196.w,
                              height: 40.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(16.h), bottomRight: Radius.circular(4.h),),),
                              child: Stack(
                                key: ValueKey("5:51036"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 170.w,
                                    height: 20.h,
                                    left: 14.w,
                                    top: 9.h,
                                    child: Text("好啊！几点？在万象城店吗",
                                      key: ValueKey("5:51037"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 358.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 358.w, minHeight: 155.h),
                        child: Row(
                          key: ValueKey("5:51038"),
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
                                  decoration: BoxDecoration(image: DecorationImage(image: _image_rqvl5_51039, fit: BoxFit.fill),borderRadius: BorderRadius.circular(16.h),),
                                  clipBehavior: Clip.hardEdge,
                                  child: Row(
                                    key: ValueKey("5:51039"),
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 32.w,
                                        height: 17.h,
                                        child: Text("豆",
                                          key: ValueKey("5:51040"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                    ],),),),),
                            Container(
                              width: 127.w,
                              height: 155.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(4.h), bottomRight: Radius.circular(16.h),),),
                              child: Stack(
                                key: ValueKey("5:51041"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 115.w,
                                    height: 23.h,
                                    left: 6.w,
                                    top: 126.h,
                                    child: Stack(
                                      key: ValueKey("5:51042"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 101.w,
                                          height: 15.h,
                                          left: 8.w,
                                          top: 5.h,
                                          child: Text("新到的配色，好看吧",
                                            key: ValueKey("5:51043"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                      ],),),
                                  Positioned(
                                    width: 115.w,
                                    height: 120.h,
                                    left: 6.w,
                                    top: 6.h,
                                    child: Container(
                                      key: ValueKey("5:51044"),
                                      decoration: BoxDecoration(image: DecorationImage(image: _image_olkz5_51044, fit: BoxFit.fill),borderRadius: BorderRadius.circular(12.h),),),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 358.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 358.w, minHeight: 36.h),
                        child: Row(
                          key: ValueKey("5:51045"),
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 81.31.w,
                              height: 36.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(16.h), bottomRight: Radius.circular(4.h),),),
                              child: Stack(
                                key: ValueKey("5:51046"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 18.w,
                                    height: 18.h,
                                    left: -286.w,
                                    top: -351.h,
                                    child: Container(
                                      key: ValueKey("5:51047"),
                                      decoration: BoxDecoration(border: Border(left: BorderSide(width: 11.w,color: Color.fromRGBO(20, 20, 20,1),),bottom: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),top: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),),),),),
                                  Positioned(
                                    width: 53.31.w,
                                    height: 20.h,
                                    left: 14.w,
                                    top: 8.h,
                                    child: Stack(
                                      key: ValueKey("5:51048"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 55.w,
                                          height: 20.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("语音 12″",
                                            key: ValueKey("5:51049"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),
                          ],),),),),
                  SizedBox(
                    width: 358.w,
                    child: SingleChildScrollView(
                      clipBehavior: Clip.none,
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        constraints: BoxConstraints(minWidth: 358.w, minHeight: 58.h),
                        child: Row(
                          key: ValueKey("5:51050"),
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 94.11.w,
                              height: 58.h,
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(16.h), topRight: Radius.circular(16.h), bottomLeft: Radius.circular(16.h), bottomRight: Radius.circular(4.h),),),
                              child: Stack(
                                key: ValueKey("5:51051"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 66.11.w,
                                    height: 18.h,
                                    left: 14.w,
                                    top: 10.h,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 66.11.w, minHeight: 18.h),
                                        padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 4.h),
                                        child: Column(
                                          key: ValueKey("5:51052"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 66.11.w,
                                              height: 14.h,
                                              child: Stack(
                                                key: ValueKey("5:51053"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 42.w,
                                                    height: 14.h,
                                                    left: 0.w,
                                                    top: -1.h,
                                                    child: Text("引用消息",
                                                      key: ValueKey("5:51054"),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,0.6), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                ],),),
                                          ],),),),),
                                  Positioned(
                                    width: 68.w,
                                    height: 20.h,
                                    left: 14.w,
                                    top: 27.h,
                                    child: Text("已读 14:21",
                                      key: ValueKey("5:51055"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),),
                ],),),),);
  }
}

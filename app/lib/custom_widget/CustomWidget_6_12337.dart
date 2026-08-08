import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12298.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12312.dart';

class CustomWidget_6_12337 extends StatelessWidget {
 CustomWidget_6_12337({super.key});
    late final ImageProvider _image_guyl6_12330 = MemoryImage(imageStr_uqbx6_12330.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 390.h,
          left: 0.w,
          top: 562.h,
          child: Container(
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(26.h), topRight: Radius.circular(26.h),  ),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.16),offset: Offset(0.w, -14.w),blurRadius: 44.w,)],),
            child: Stack(
              key: ValueKey("6:12337"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 350.87.w,
                  height: 21.h,
                  left: 45.w,
                  top: 14.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 350.87.w, minHeight: 21.h),
                      padding: EdgeInsets.only(left: 154.w,right: 154.w, top: 0.h,bottom: 16.h),
                      child: Column(
                        key: ValueKey("6:12338"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            key: ValueKey("6:12339"),
                            width: 42.87.w,
                            height: 5.h,
                            decoration: BoxDecoration(color: Color.fromRGBO(228, 228, 232,1),borderRadius: BorderRadius.circular(2.h),),),
                        ],),),),),
                Positioned(
                  width: 390.36.w,
                  height: 42.h,
                  left: 25.w,
                  top: 36.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 390.36.w, minHeight: 42.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 18.h),
                      child: Column(
                        key: ValueKey("6:12340"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 390.36.w,
                            height: 24.h,
                            child: Stack(
                              key: ValueKey("6:12341"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 53.w,
                                  height: 21.h,
                                  left: 170.w,
                                  top: 2.h,
                                  child: Text("分享到",
                                    key: ValueKey("6:12342"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                        ],),),),),
                Positioned(
                  width: 390.36.w,
                  height: 140.h,
                  left: 25.w,
                  top: 80.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 390.36.w, minHeight: 140.h),
                      child: Row(
                        key: ValueKey("6:12343"),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 140.h,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Container(
                                constraints: BoxConstraints(minWidth: 58.67.w, minHeight: 140.h),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Column(
                                  key: ValueKey("6:12344"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 7.h,
                                  children: [
                                    SizedBox(
                                      width: 54.15.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 54.15.w, minHeight: 54.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                          child: Row(
                                            key: ValueKey("6:12345"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                key: ValueKey("6:12346"),
                                                width: 24.82.w,
                                                height: 25.h,),
                                            ],),),),),
                                    Container(
                                      width: 24.82.w,
                                      height: 17.h,
                                      child: Stack(
                                        key: ValueKey("6:12347"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 27.w,
                                            height: 15.h,
                                            left: 0.w,
                                            top: 1.h,
                                            child: Text("微信",
                                              key: ValueKey("6:12348"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                        ],),),
                                  ],),),),),
                          SizedBox(
                            height: 140.h,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Container(
                                constraints: BoxConstraints(minWidth: 58.67.w, minHeight: 140.h),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Column(
                                  key: ValueKey("6:12349"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 7.h,
                                  children: [
                                    SizedBox(
                                      width: 54.15.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 54.15.w, minHeight: 54.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                          child: Row(
                                            key: ValueKey("6:12350"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                key: ValueKey("6:12351"),
                                                width: 24.82.w,
                                                height: 25.h,),
                                            ],),),),),
                                    Container(
                                      width: 37.23.w,
                                      height: 17.h,
                                      child: Stack(
                                        key: ValueKey("6:12352"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 39.w,
                                            height: 15.h,
                                            left: 0.w,
                                            top: 1.h,
                                            child: Text("朋友圈",
                                              key: ValueKey("6:12353"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                        ],),),
                                  ],),),),),
                          SizedBox(
                            height: 140.h,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Container(
                                constraints: BoxConstraints(minWidth: 58.67.w, minHeight: 140.h),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Column(
                                  key: ValueKey("6:12354"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 7.h,
                                  children: [
                                    SizedBox(
                                      width: 54.15.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 54.15.w, minHeight: 54.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                          child: Row(
                                            key: ValueKey("6:12355"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                key: ValueKey("6:12356"),
                                                width: 24.82.w,
                                                height: 25.h,),
                                            ],),),),),
                                    Container(
                                      width: 24.82.w,
                                      height: 17.h,
                                      child: Stack(
                                        key: ValueKey("6:12357"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 27.w,
                                            height: 15.h,
                                            left: 0.w,
                                            top: 1.h,
                                            child: Text("微博",
                                              key: ValueKey("6:12358"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                        ],),),
                                  ],),),),),
                          SizedBox(
                            height: 140.h,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Container(
                                constraints: BoxConstraints(minWidth: 58.67.w, minHeight: 140.h),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Column(
                                  key: ValueKey("6:12359"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 7.h,
                                  children: [
                                    SizedBox(
                                      width: 54.15.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 54.15.w, minHeight: 54.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                          child: Row(
                                            key: ValueKey("6:12360"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                key: ValueKey("6:12361"),
                                                width: 24.82.w,
                                                height: 25.h,),
                                            ],),),),),
                                    Container(
                                      width: 49.64.w,
                                      height: 17.h,
                                      child: Stack(
                                        key: ValueKey("6:12362"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 52.w,
                                            height: 15.h,
                                            left: 0.w,
                                            top: 1.h,
                                            child: Text("复制链接",
                                              key: ValueKey("6:12363"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                        ],),),
                                  ],),),),),
                          SizedBox(
                            height: 140.h,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Container(
                                constraints: BoxConstraints(minWidth: 58.67.w, minHeight: 140.h),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Column(
                                  key: ValueKey("6:12364"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 7.h,
                                  children: [
                                    SizedBox(
                                      width: 54.15.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 54.15.w, minHeight: 54.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                          child: Row(
                                            key: ValueKey("6:12365"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                key: ValueKey("6:12366"),
                                                width: 24.82.w,
                                                height: 25.h,),
                                            ],),),),),
                                    Container(
                                      width: 49.64.w,
                                      height: 17.h,
                                      child: Stack(
                                        key: ValueKey("6:12367"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 52.w,
                                            height: 15.h,
                                            left: 0.w,
                                            top: 1.h,
                                            child: Text("保存图片",
                                              key: ValueKey("6:12368"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                        ],),),
                                  ],),),),),
                          SizedBox(
                            height: 140.h,
                            child: SingleChildScrollView(
                              physics: NeverScrollableScrollPhysics(),
                              child: Container(
                                constraints: BoxConstraints(minWidth: 58.67.w, minHeight: 140.h),
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Column(
                                  key: ValueKey("6:12369"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 7.h,
                                  children: [
                                    SizedBox(
                                      width: 54.15.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 54.15.w, minHeight: 54.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                          child: Row(
                                            key: ValueKey("6:12370"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                key: ValueKey("6:12371"),
                                                width: 24.82.w,
                                                height: 25.h,),
                                            ],),),),),
                                    Container(
                                      width: 24.82.w,
                                      height: 17.h,
                                      child: Stack(
                                        key: ValueKey("6:12372"),
                                        clipBehavior: Clip.none,
                                        children: [
                                          Positioned(
                                            width: 27.w,
                                            height: 15.h,
                                            left: 0.w,
                                            top: 1.h,
                                            child: Text("更多",
                                              key: ValueKey("6:12373"),
                                              textAlign: TextAlign.left,
                                              style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                        ],),),
                                  ],),),),),
                        ],),),),),
                Positioned(
                  width: 390.36.w,
                  height: 27.h,
                  left: 25.w,
                  top: 223.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 390.36.w, minHeight: 27.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 20.h,bottom: 6.h),
                      child: Column(
                        key: ValueKey("6:12374"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            key: ValueKey("6:12375"),
                            width: 390.36.w,
                            height: 1.h,
                            decoration: BoxDecoration(color: Color.fromRGBO(239, 239, 239,1),),),
                        ],),),),),
                Positioned(
                  width: 390.36.w,
                  height: 49.h,
                  left: 25.w,
                  top: 251.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 390.36.w, minHeight: 49.h),
                      padding: EdgeInsets.only(left: 4.w,right: 4.w, top: 12.h,bottom: 12.h),
                      child: Row(
                        key: ValueKey("6:12376"),
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 63.18.w,
                            height: 22.h,
                            child: Stack(
                              key: ValueKey("6:12377"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 18.w,
                                  height: 18.h,
                                  left: -29.73.w,
                                  top: -264.73.h,
                                  child: Transform.rotate(
                                    angle: 0.7853981633974483,
                                    child: Container(
                                      key: ValueKey("6:12378"),
                                      decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(2.h),),),),),
                                Positioned(
                                  width: 63.18.w,
                                  height: 22.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Stack(
                                    key: ValueKey("6:12379"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 65.w,
                                        height: 20.h,
                                        left: 0.w,
                                        top: 1.h,
                                        child: Text("举报作品",
                                          key: ValueKey("6:12380"),
                                          textAlign: TextAlign.left,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                    ],),),
                              ],),),
                          Container(
                            width: 94.79.w,
                            height: 19.h,
                            child: Stack(
                              key: ValueKey("6:12381"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 97.w,
                                  height: 17.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Text("内容违规或侵权",
                                    key: ValueKey("6:12382"),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                              ],),),
                        ],),),),),
                Positioned(
                  width: 390.36.w,
                  height: 58.h,
                  left: 25.w,
                  top: 300.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    child: Container(
                      constraints: BoxConstraints(minWidth: 390.36.w, minHeight: 58.h),
                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 4.h,bottom: 0.h),
                      child: Column(
                        key: ValueKey("6:12383"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 390.36.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 390.36.w, minHeight: 54.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                child: Row(
                                  key: ValueKey("6:12384"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 390.36.w,
                                      height: 22.h,
                                      child: Text("取消",
                                        key: ValueKey("6:12385"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                  ],),),),),
                        ],),),),),
              ],),),);
  }
}

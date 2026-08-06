import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51902.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_5_51916 extends StatelessWidget {
 CustomWidget_5_51916({super.key});
    late final ImageProvider _image_xcpt5_51919 = MemoryImage(imageStr_imageStr_jzul5_51919.decodeBase64Image());
  late final ImageProvider _image_sgxt5_51921 = MemoryImage(imageStr_imageStr_zgim5_51921.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 516.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:51916"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 120.h,
                left: 16.w,
                top: 8.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 120.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 12.h,bottom: 20.h),
                    child: Row(
                      key: ValueKey("5:51917"),
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 88.w,
                          height: 88.h,
                          child: Stack(
                            key: ValueKey("5:51918"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 88.w,
                                height: 88.h,
                                left: 0.w,
                                top: 0.h,
                                child: Container(
                                  decoration: BoxDecoration(image: DecorationImage(image: _image_xcpt5_51919, fit: BoxFit.fill),borderRadius: BorderRadius.circular(44.h),),
                                  child: Stack(
                                    key: ValueKey("5:51919"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 84.w,
                                        height: 84.h,
                                        left: 2.w,
                                        top: 2.h,
                                        child: Container(
                                          decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(42.h),),
                                          child: Stack(
                                            key: ValueKey("5:51920"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 80.w,
                                                height: 80.h,
                                                left: 2.w,
                                                top: 2.h,
                                                child: SingleChildScrollView(
                                                  physics: NeverScrollableScrollPhysics(),
                                                  scrollDirection: Axis.horizontal,
                                                  child: Container(
                                                    constraints: BoxConstraints(minWidth: 80.w, minHeight: 80.h),
                                                    decoration: BoxDecoration(image: DecorationImage(image: _image_sgxt5_51921, fit: BoxFit.fill),borderRadius: BorderRadius.circular(40.h),),
                                                    clipBehavior: Clip.hardEdge,
                                                    child: Row(
                                                      key: ValueKey("5:51921"),
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: 80.w,
                                                          height: 37.h,
                                                          child: Text("我",
                                                            key: ValueKey("5:51922"),
                                                            textAlign: TextAlign.center,
                                                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 25.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                      ],),),),),
                                            ],),),),
                                    ],),),),
                              Positioned(
                                width: 30.w,
                                height: 30.h,
                                left: 60.w,
                                top: 60.h,
                                child: Image(
                                  key: ValueKey("5:51923"),
                                  image: AssetImage("assets/div.png"),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 64.h,
                left: 16.w,
                top: 128.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 64.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:51925"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 52.h),
                              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                              child: Row(
                                key: ValueKey("5:51926"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8.w,
                                children: [
                                  Container(
                                    width: 30.02.w,
                                    height: 21.h,
                                    child: Stack(
                                      key: ValueKey("5:51927"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 32.w,
                                          height: 21.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("昵称",
                                            key: ValueKey("5:51928"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                      ],),),
                                  SizedBox(
                                    width: 53.02.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 53.02.w, minHeight: 21.h),
                                        padding: EdgeInsets.only(left: 8.w,right: 0.w, top: 0.h,bottom: 0.h),
                                        child: Row(
                                          key: ValueKey("5:51929"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 45.02.w,
                                              height: 21.h,
                                              child: Stack(
                                                key: ValueKey("5:51930"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 47.w,
                                                    height: 21.h,
                                                    left: 0.w,
                                                    top: 0.h,
                                                    child: Text("小豆子",
                                                      key: ValueKey("5:51931"),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                ],),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 64.h,
                left: 16.w,
                top: 192.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 64.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:51932"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 52.h),
                              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                              child: Row(
                                key: ValueKey("5:51933"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8.w,
                                children: [
                                  Container(
                                    width: 45.02.w,
                                    height: 21.h,
                                    child: Stack(
                                      key: ValueKey("5:51934"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 47.w,
                                          height: 21.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("用户名",
                                            key: ValueKey("5:51935"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                      ],),),
                                  SizedBox(
                                    width: 75.89.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 75.89.w, minHeight: 21.h),
                                        padding: EdgeInsets.only(left: 8.w,right: 0.w, top: 0.h,bottom: 0.h),
                                        child: Row(
                                          key: ValueKey("5:51936"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 67.89.w,
                                              height: 21.h,
                                              child: Stack(
                                                key: ValueKey("5:51937"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 70.w,
                                                    height: 21.h,
                                                    left: 0.w,
                                                    top: 0.h,
                                                    child: Text("xiaodouzi",
                                                      key: ValueKey("5:51938"),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                ],),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 27.h,
                left: 16.w,
                top: 252.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 27.h),
                    padding: EdgeInsets.only(left: 4.w,right: 4.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:51939"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 350.w,
                          height: 15.h,
                          child: Stack(
                            key: ValueKey("5:51940"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 294.w,
                                height: 15.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("用户名一年内只能修改一次，设置后可用于用户名+密码登录",
                                  key: ValueKey("5:51941"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 92.h,
                left: 16.w,
                top: 279.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 92.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:51942"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 80.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:51943"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 242.02.w,
                                height: 21.h,
                                left: 16.w,
                                top: 14.h,
                                child: Text("简介：拼豆手作爱好者，治愈系手工",
                                  key: ValueKey("5:51944"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 157.h,
                left: 16.w,
                top: 371.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 157.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:51945"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 145.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                          child: Stack(
                            key: ValueKey("5:51946"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 326.w,
                                height: 33.h,
                                left: 16.w,
                                top: 16.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 33.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                                    child: Column(
                                      key: ValueKey("5:51947"),
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 326.w,
                                          child: SingleChildScrollView(
                                            clipBehavior: Clip.none,
                                            physics: NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              constraints: BoxConstraints(minWidth: 326.w, minHeight: 21.h),
                                              child: Row(
                                                key: ValueKey("5:51948"),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 30.02.w,
                                                    height: 21.h,
                                                    child: Stack(
                                                      key: ValueKey("5:51949"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 32.w,
                                                          height: 21.h,
                                                          left: 0.w,
                                                          top: 0.h,
                                                          child: Text("性别",
                                                            key: ValueKey("5:51950"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    width: 13.02.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:51951"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 15.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("女",
                                                            key: ValueKey("5:51952"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                      ],),),),),
                              Positioned(
                                width: 326.w,
                                height: 1.h,
                                left: 16.w,
                                top: 49.h,
                                child: Container(
                                  key: ValueKey("5:51953"),
                                  decoration: BoxDecoration(color: Color.fromRGBO(239, 239, 239,1),),),),
                              Positioned(
                                width: 326.w,
                                height: 45.h,
                                left: 16.w,
                                top: 50.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 45.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 12.h,bottom: 12.h),
                                    child: Column(
                                      key: ValueKey("5:51954"),
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 326.w,
                                          child: SingleChildScrollView(
                                            clipBehavior: Clip.none,
                                            physics: NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              constraints: BoxConstraints(minWidth: 326.w, minHeight: 21.h),
                                              child: Row(
                                                key: ValueKey("5:51955"),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 30.02.w,
                                                    height: 21.h,
                                                    child: Stack(
                                                      key: ValueKey("5:51956"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 32.w,
                                                          height: 21.h,
                                                          left: 0.w,
                                                          top: 0.h,
                                                          child: Text("生日",
                                                            key: ValueKey("5:51957"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    width: 66.75.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:51958"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 69.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("1999-08-06",
                                                            key: ValueKey("5:51959"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                      ],),),),),
                              Positioned(
                                width: 326.w,
                                height: 1.h,
                                left: 16.w,
                                top: 95.h,
                                child: Container(
                                  key: ValueKey("5:51960"),
                                  decoration: BoxDecoration(color: Color.fromRGBO(239, 239, 239,1),),),),
                              Positioned(
                                width: 326.w,
                                height: 33.h,
                                left: 16.w,
                                top: 96.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 33.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 12.h,bottom: 0.h),
                                    child: Column(
                                      key: ValueKey("5:51961"),
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 326.w,
                                          child: SingleChildScrollView(
                                            clipBehavior: Clip.none,
                                            physics: NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              constraints: BoxConstraints(minWidth: 326.w, minHeight: 21.h),
                                              child: Row(
                                                key: ValueKey("5:51962"),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 45.02.w,
                                                    height: 21.h,
                                                    child: Stack(
                                                      key: ValueKey("5:51963"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 47.w,
                                                          height: 21.h,
                                                          left: 0.w,
                                                          top: 0.h,
                                                          child: Text("所在地",
                                                            key: ValueKey("5:51964"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    width: 39.02.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:51965"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 41.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("上海市",
                                                            key: ValueKey("5:51966"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                      ],),),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

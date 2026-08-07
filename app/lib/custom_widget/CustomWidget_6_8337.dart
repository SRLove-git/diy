import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_8323.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_6_8337 extends StatelessWidget {
 CustomWidget_6_8337({super.key});
    late final ImageProvider _image_lehh6_8400 = MemoryImage(imageStr_rufv6_8400.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 758.h,
          left: 0.w,
          top: 120.h,
          child: Stack(
            key: ValueKey("6:8337"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 61.h,
                left: 18.w,
                top: 9.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 61.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 16.h),
                    child: Column(
                      key: ValueKey("6:8338"),
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
                              constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 45.h),
                              padding: EdgeInsets.only(left: 3.w,right: 3.w, top: 3.h,bottom: 3.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(20.h),),
                              child: Row(
                                key: ValueKey("6:8339"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 99.28.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 99.28.w, minHeight: 38.h),
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(17.h),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.08),offset: Offset(0.w, 1.w),blurRadius: 4.w,)],),
                                        child: Row(
                                          key: ValueKey("6:8340"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 99.28.w,
                                              height: 18.h,
                                              child: Text("全部",
                                                key: ValueKey("6:8341"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                  SizedBox(
                                    width: 99.28.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 99.28.w, minHeight: 38.h),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                        child: Row(
                                          key: ValueKey("6:8342"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 99.28.w,
                                              height: 18.h,
                                              child: Text("待核销",
                                                key: ValueKey("6:8343"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                  SizedBox(
                                    width: 99.28.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 99.28.w, minHeight: 38.h),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                        child: Row(
                                          key: ValueKey("6:8344"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 99.28.w,
                                              height: 18.h,
                                              child: Text("服务中",
                                                key: ValueKey("6:8345"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                  SizedBox(
                                    width: 99.28.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 99.28.w, minHeight: 38.h),
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(17.h),),
                                        child: Row(
                                          key: ValueKey("6:8346"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 99.28.w,
                                              height: 18.h,
                                              child: Text("已完成",
                                                key: ValueKey("6:8347"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 141.h,
                left: 18.w,
                top: 72.h,
                child: Image(
                  key: ValueKey("6:8348"),
                  image: AssetImage("assets/margin_wrapper78.png"),),),
              Positioned(
                width: 403.9.w,
                height: 115.h,
                left: 18.w,
                top: 215.h,
                child: Image(
                  key: ValueKey("6:8364"),
                  image: AssetImage("assets/margin_wrapper80.png"),),),
              Positioned(
                width: 403.9.w,
                height: 141.h,
                left: 18.w,
                top: 331.h,
                child: Image(
                  key: ValueKey("6:8374"),
                  image: AssetImage("assets/margin_wrapper84.png"),),),
              Positioned(
                width: 403.9.w,
                height: 153.h,
                left: 18.w,
                top: 474.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 153.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("6:8390"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 141.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(246, 246, 248,1),borderRadius: BorderRadius.circular(16.h),),
                          child: Stack(
                            key: ValueKey("6:8391"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 367.79.w,
                                height: 43.h,
                                left: 18.w,
                                top: 18.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 367.79.w, minHeight: 43.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                    child: Column(
                                      key: ValueKey("6:8392"),
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 367.79.w,
                                          child: SingleChildScrollView(
                                            clipBehavior: Clip.none,
                                            physics: NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              constraints: BoxConstraints(minWidth: 367.79.w, minHeight: 35.h),
                                              child: Row(
                                                key: ValueKey("6:8393"),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 50.79.w,
                                                    height: 24.h,
                                                    child: Stack(
                                                      key: ValueKey("6:8394"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 53.w,
                                                          height: 21.h,
                                                          left: 0.w,
                                                          top: 2.h,
                                                          child: Text("计时中",
                                                            key: ValueKey("6:8395"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    width: 104.01.w,
                                                    height: 35.h,
                                                    child: Stack(
                                                      key: ValueKey("6:8396"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 106.w,
                                                          height: 31.h,
                                                          left: 0.w,
                                                          top: 1.h,
                                                          child: Text("00:45:12",
                                                            key: ValueKey("6:8397"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 21.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                      ],),),),),
                              Positioned(
                                width: 367.79.w,
                                height: 13.h,
                                left: 18.w,
                                top: 61.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 367.79.w, minHeight: 13.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                    child: Column(
                                      key: ValueKey("6:8398"),
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 367.79.w,
                                          height: 5.h,
                                          decoration: BoxDecoration(color: Color.fromRGBO(240, 240, 240,1),borderRadius: BorderRadius.circular(2.h),),
                                          clipBehavior: Clip.hardEdge,
                                          child: Stack(
                                            key: ValueKey("6:8399"),
                                            children: [
                                              Positioned(
                                                width: 228.02.w,
                                                height: 5.h,
                                                left: 0.w,
                                                top: 0.h,
                                                child: Container(
                                                  key: ValueKey("6:8400"),
                                                  decoration: BoxDecoration(image: DecorationImage(image: _image_lehh6_8400, fit: BoxFit.fill),borderRadius: BorderRadius.circular(2.h),),),),
                                            ],),),
                                      ],),),),),
                              Positioned(
                                width: 367.79.w,
                                height: 47.h,
                                left: 18.w,
                                top: 75.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 367.79.w, minHeight: 47.h),
                                    child: Row(
                                      key: ValueKey("6:8401"),
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 12.w,
                                      children: [
                                        SizedBox(
                                          width: 367.79.w,
                                          child: SingleChildScrollView(
                                            clipBehavior: Clip.none,
                                            physics: NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              constraints: BoxConstraints(minWidth: 367.79.w, minHeight: 47.h),
                                              padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                                              child: Row(
                                                key: ValueKey("6:8402"),
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 339.79.w,
                                                    height: 18.h,
                                                    child: Text("下钟结束",
                                                      key: ValueKey("6:8403"),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                ],),),),),
                                      ],),),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 141.h,
                left: 18.w,
                top: 628.h,
                child: Image(
                  key: ValueKey("6:8404"),
                  image: AssetImage("assets/margin_wrapper91.png"),),),
            ],),);
  }
}

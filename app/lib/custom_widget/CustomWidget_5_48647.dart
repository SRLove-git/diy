import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48633.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/utils/pix_dashed_border.dart';

class CustomWidget_5_48647 extends StatelessWidget {
 CustomWidget_5_48647({super.key});
    late final ImageProvider _image_whlh5_48689 = MemoryImage(imageStr_imageStr_wste5_48689.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 645.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:48647"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 193.h,
                left: 16.w,
                top: 8.h,
                child: Image(
                  key: ValueKey("5:48648"),
                  image: AssetImage("assets/margin_wrapper64.png"),),),
              Positioned(
                width: 358.w,
                height: 36.h,
                left: 16.w,
                top: 201.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 36.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:48681"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 24.h),
                              child: Row(
                                key: ValueKey("5:48682"),
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50.41.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("5:48683"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 52.w,
                                          height: 23.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("优惠券",
                                            key: ValueKey("5:48684"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                      ],),),
                                  Container(
                                    width: 54.36.w,
                                    height: 17.h,
                                    child: Stack(
                                      key: ValueKey("5:48685"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 56.w,
                                          height: 17.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("可用 3 张 ›",
                                            key: ValueKey("5:48686"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 66.h,
                left: 16.w,
                top: 237.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 66.h),
                    child: Row(
                      key: ValueKey("5:48687"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 12.w,
                      children: [
                        SizedBox(
                          width: 170.w,
                          child: SingleChildScrollView(
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 170.w, minHeight: 66.h),
                              padding: EdgeInsets.only(left: 1.w,right: 0.w, top: 1.h,bottom: 0.h),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.h),border: Border.all(width: 1.w, color: Color.fromRGBO(239, 239, 239,1), ),),
                              clipBehavior: Clip.hardEdge,
                              child: Row(
                                key: ValueKey("5:48688"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 64.h,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 64.w, minHeight: 64.h),
                                        decoration: BoxDecoration(image: DecorationImage(image: _image_whlh5_48689, fit: BoxFit.fill),),
                                        child: Column(
                                          key: ValueKey("5:48689"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 30.09.w,
                                              height: 24.h,
                                              child: Stack(
                                                key: ValueKey("5:48690"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 32.w,
                                                    height: 23.h,
                                                    left: 0.w,
                                                    top: 0.h,
                                                    child: Text("¥10",
                                                      key: ValueKey("5:48691"),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                                ],),),
                                          ],),),),),
                                  Container(
                                    width: 104.w,
                                    height: 64.h,
                                    child: Stack(
                                      key: ValueKey("5:48692"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 84.w,
                                          height: 17.h,
                                          left: 10.w,
                                          top: 8.h,
                                          child: Stack(
                                            key: ValueKey("5:48693"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 57.w,
                                                height: 17.h,
                                                left: 0.w,
                                                top: -1.h,
                                                child: Text("满 39 可用",
                                                  key: ValueKey("5:48694"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                            ],),),
                                        Positioned(
                                          width: 84.w,
                                          height: 14.h,
                                          left: 10.w,
                                          top: 25.h,
                                          child: Stack(
                                            key: ValueKey("5:48695"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 50.w,
                                                height: 14.h,
                                                left: 0.w,
                                                top: -1.h,
                                                child: Text("08-20 到期",
                                                  key: ValueKey("5:48696"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                            ],),),
                                      ],),),
                                ],),),),),
                        SizedBox(
                          width: 170.w,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 170.w, minHeight: 66.h),
                              padding: EdgeInsets.only(left: 1.w,right: 0.w, top: 1.h,bottom: 0.h),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14.h),),
                              child: PixDashedBorder(
                                strokeWidth: 1,
                                dashLength: 6.h,
                                gapLength: 6.h,
                                borderRadius: BorderRadius.circular(14.h),
                                child: Row(
                                  key: ValueKey("5:48697"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 167.w,
                                      height: 17.h,
                                      child: Text("不使用",
                                        key: ValueKey("5:48698"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                  ],),),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 52.h,
                left: 16.w,
                top: 303.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 52.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 16.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:48699"),
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
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 24.h),
                              child: Row(
                                key: ValueKey("5:48700"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 67.2.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("5:48701"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 69.w,
                                          height: 23.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("支付方式",
                                            key: ValueKey("5:48702"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 127.h,
                left: 16.w,
                top: 355.h,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(),
                  child: Image(
                    key: ValueKey("5:48703"),
                    image: AssetImage("assets/divcardcardpad.png"),),),),
              Positioned(
                width: 358.w,
                height: 164.h,
                left: 16.w,
                top: 482.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 164.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 16.h,bottom: 0.h),
                    child: Column(
                      key: ValueKey("5:48722"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 148.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                          child: Stack(
                            key: ValueKey("5:48723"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 326.w,
                                height: 26.h,
                                left: 16.w,
                                top: 16.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 26.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                    child: Column(
                                      key: ValueKey("5:48724"),
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
                                              constraints: BoxConstraints(minWidth: 326.w, minHeight: 18.h),
                                              child: Row(
                                                key: ValueKey("5:48725"),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 26.02.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:48726"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 28.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("原价",
                                                            key: ValueKey("5:48727"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    width: 32.48.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:48728"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 34.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("¥79.8",
                                                            key: ValueKey("5:48729"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                      ],),),),),
                              Positioned(
                                width: 326.w,
                                height: 26.h,
                                left: 16.w,
                                top: 42.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 26.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                    child: Column(
                                      key: ValueKey("5:48730"),
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
                                              constraints: BoxConstraints(minWidth: 326.w, minHeight: 18.h),
                                              child: Row(
                                                key: ValueKey("5:48731"),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 52.02.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:48732"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 54.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("会员优惠",
                                                            key: ValueKey("5:48733"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    width: 37.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:48734"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 39.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("-¥20.0",
                                                            key: ValueKey("5:48735"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(52, 199, 89,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                      ],),),),),
                              Positioned(
                                width: 326.w,
                                height: 26.h,
                                left: 16.w,
                                top: 68.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 26.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                    child: Column(
                                      key: ValueKey("5:48736"),
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
                                              constraints: BoxConstraints(minWidth: 326.w, minHeight: 18.h),
                                              child: Row(
                                                key: ValueKey("5:48737"),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 39.02.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:48738"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 41.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: 0.h,
                                                          child: Text("优惠券",
                                                            key: ValueKey("5:48739"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    width: 37.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:48740"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 39.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: 0.h,
                                                          child: Text("-¥10.0",
                                                            key: ValueKey("5:48741"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(52, 199, 89,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                      ],),),),),
                              Positioned(
                                width: 326.w,
                                height: 1.h,
                                left: 16.w,
                                top: 94.h,
                                child: Container(
                                  key: ValueKey("5:48742"),
                                  decoration: BoxDecoration(color: Color.fromRGBO(239, 239, 239,1),),),),
                              Positioned(
                                width: 326.w,
                                height: 36.h,
                                left: 16.w,
                                top: 95.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 36.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 8.h,bottom: 0.h),
                                    child: Column(
                                      key: ValueKey("5:48743"),
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
                                              constraints: BoxConstraints(minWidth: 326.w, minHeight: 28.h),
                                              child: Row(
                                                key: ValueKey("5:48744"),
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: 60.02.w,
                                                    height: 21.h,
                                                    child: Stack(
                                                      key: ValueKey("5:48745"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 62.w,
                                                          height: 21.h,
                                                          left: 0.w,
                                                          top: 0.h,
                                                          child: Text("应付金额",
                                                            key: ValueKey("5:48746"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    width: 53.7.w,
                                                    height: 28.h,
                                                    child: Stack(
                                                      key: ValueKey("5:48747"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 56.w,
                                                          height: 28.h,
                                                          left: 0.w,
                                                          top: 0.h,
                                                          child: Text("¥49.8",
                                                            key: ValueKey("5:48748"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                      ],),),),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54809.dart';

class Frame_5_54801 extends StatefulWidget {

  Frame_5_54801({super.key,});
  @override
  State<Frame_5_54801> createState() => _Frame_5_54801State();
}

class _Frame_5_54801State extends State<Frame_5_54801> {
  late final ImageProvider _image_rhqm5_54803 = MemoryImage(imageStr_imageStr_vzdd5_54803.decodeBase64Image());
  late final ImageProvider _image_csoa5_54804 = MemoryImage(imageStr_imageStr_fxml5_54804.decodeBase64Image());
  late final ImageProvider _image_bztv5_54809 = MemoryImage(imageStr_imageStr_lxhp5_54809.decodeBase64Image());

  @override
  void initState() {
    super.initState();
  
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil().rootSize = Size(390, 844);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: SizedBox(
            width: 390.w,
            height: 844.h,
            child: ListView(
              children: [
                Container(
                width: 390.w,
                height: 844.h,
                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  key: ValueKey("5:54801"),
                  children: [
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        decoration: BoxDecoration(color: Color.fromRGBO(13, 13, 15,1),),
                        child: Stack(
                          key: ValueKey("5:54802"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 390.w,
                              height: 748.h,
                              left: 0.w,
                              top: 0.h,
                              child: Container(
                                decoration: BoxDecoration(image: DecorationImage(image: _image_rhqm5_54803, fit: BoxFit.fill),),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  key: ValueKey("5:54803"),
                                  children: [
                                    Positioned(
                                      width: 390.w,
                                      height: 748.h,
                                      left: 0.w,
                                      top: 0.h,
                                      child: Container(
                                        key: ValueKey("5:54804"),
                                        decoration: BoxDecoration(image: DecorationImage(image: _image_csoa5_54804, fit: BoxFit.fill),),),),
                                    Positioned(
                                      width: 64.w,
                                      height: 64.h,
                                      left: 163.w,
                                      top: 342.h,
                                      child: Container(
                                        decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.92),borderRadius: BorderRadius.circular(32.h),),
                                        child: Stack(
                                          key: ValueKey("5:54805"),
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              width: 26.w,
                                              height: 26.h,
                                              left: 7.w,
                                              top: 4.h,
                                              child: Container(
                                                key: ValueKey("5:54806"),
                                                decoration: BoxDecoration(border: Border(left: BorderSide(width: 11.w,color: Color.fromRGBO(20, 20, 20,1),),bottom: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),top: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),),),),),
                                          ],),),),
                                  ],),),),
                            Positioned(
                              width: 248.78.w,
                              height: 17.h,
                              left: 12.w,
                              top: 709.h,
                              child: Opacity(
                                opacity: 0.9,
                                child: Stack(
                                  key: ValueKey("5:54807"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 251.w,
                                      height: 17.h,
                                      left: 0.w,
                                      top: -1.h,
                                      child: Text("@手作阿周 · 3 分钟学会渐变拼豆 #拼豆 #教程",
                                        key: ValueKey("5:54808"),
                                        textAlign: TextAlign.left,
                                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                  ],),),),
                            CustomWidget_5_54809(),
                            Positioned(
                              width: 390.w,
                              height: 62.h,
                              left: 0.w,
                              top: 0.h,
                              child: SingleChildScrollView(
                                clipBehavior: Clip.none,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 390.w, minHeight: 62.h),
                                  padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                  child: Row(
                                    key: ValueKey("5:54829"),
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 34.w,
                                        child: SingleChildScrollView(
                                          clipBehavior: Clip.none,
                                          physics: NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
                                            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.16),borderRadius: BorderRadius.circular(17.h),),
                                            child: Row(
                                              key: ValueKey("5:54830"),
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  key: ValueKey("5:54831"),
                                                  width: 18.w,
                                                  height: 18.h,),
                                              ],),),),),
                                      Container(
                                        width: 112.w,
                                        height: 20.h,
                                        child: Stack(
                                          key: ValueKey("5:54832"),
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              width: 114.w,
                                              height: 20.h,
                                              left: 0.w,
                                              top: -1.h,
                                              child: Text("渐变拼豆新手教程",
                                                key: ValueKey("5:54833"),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                          ],),),
                                      SizedBox(
                                        width: 34.w,
                                        child: SingleChildScrollView(
                                          clipBehavior: Clip.none,
                                          physics: NeverScrollableScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
                                            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.16),borderRadius: BorderRadius.circular(17.h),),
                                            child: Row(
                                              key: ValueKey("5:54834"),
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  key: ValueKey("5:54835"),
                                                  width: 18.w,
                                                  height: 18.h,),
                                              ],),),),),
                                    ],),),),),
                          ],),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

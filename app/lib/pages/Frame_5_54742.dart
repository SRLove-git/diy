import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54748.dart';

class Frame_5_54742 extends StatefulWidget {

  Frame_5_54742({super.key,});
  @override
  State<Frame_5_54742> createState() => _Frame_5_54742State();
}

class _Frame_5_54742State extends State<Frame_5_54742> {
  late final ImageProvider _image_wpcd5_54744 = MemoryImage(imageStr_imageStr_llym5_54744.decodeBase64Image());
  late final ImageProvider _image_mkko5_54745 = MemoryImage(imageStr_imageStr_hplq5_54745.decodeBase64Image());
  late final ImageProvider _image_mzeh5_54748 = MemoryImage(imageStr_imageStr_tjts5_54748.decodeBase64Image());
  late final ImageProvider _image_wdge5_54750 = MemoryImage(imageStr_imageStr_hzxg5_54750.decodeBase64Image());
  late final ImageProvider _image_ovhi5_54752 = MemoryImage(imageStr_imageStr_qaqb5_54752.decodeBase64Image());

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
                  key: ValueKey("5:54742"),
                  children: [
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        decoration: BoxDecoration(color: Color.fromRGBO(13, 13, 15,1),),
                        child: Stack(
                          key: ValueKey("5:54743"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 390.w,
                              height: 560.h,
                              left: 0.w,
                              top: 0.h,
                              child: Container(
                                decoration: BoxDecoration(image: DecorationImage(image: _image_wpcd5_54744, fit: BoxFit.fill),),
                                clipBehavior: Clip.hardEdge,
                                child: Stack(
                                  key: ValueKey("5:54744"),
                                  children: [
                                    Positioned(
                                      width: 390.w,
                                      height: 560.h,
                                      left: 0.w,
                                      top: 0.h,
                                      child: Container(
                                        key: ValueKey("5:54745"),
                                        decoration: BoxDecoration(image: DecorationImage(image: _image_mkko5_54745, fit: BoxFit.fill),),),),
                                    Positioned(
                                      width: 143.69.w,
                                      height: 15.h,
                                      left: 12.w,
                                      top: 535.h,
                                      child: Opacity(
                                        opacity: 0.85,
                                        child: Stack(
                                          key: ValueKey("5:54746"),
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              width: 146.w,
                                              height: 15.h,
                                              left: 0.w,
                                              top: -1.h,
                                              child: Text("@小豆子 · 星空拼豆 2000 颗",
                                                key: ValueKey("5:54747"),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                          ],),),),
                                  ],),),),
                            CustomWidget_5_54748(),
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
                                    key: ValueKey("5:54794"),
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
                                              key: ValueKey("5:54795"),
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  key: ValueKey("5:54796"),
                                                  width: 18.w,
                                                  height: 18.h,),
                                              ],),),),),
                                      Container(
                                        width: 43.41.w,
                                        height: 23.h,
                                        decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0,0.35),borderRadius: BorderRadius.circular(10.h),),
                                        child: Stack(
                                          key: ValueKey("5:54797"),
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              width: 25.w,
                                              height: 17.h,
                                              left: 10.w,
                                              top: 2.h,
                                              child: Text("2 / 9",
                                                key: ValueKey("5:54798"),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
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
                                              key: ValueKey("5:54799"),
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  key: ValueKey("5:54800"),
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

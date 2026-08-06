import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49941.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49955.dart';

class Frame_5_49940 extends StatefulWidget {

  Frame_5_49940({super.key,});
  @override
  State<Frame_5_49940> createState() => _Frame_5_49940State();
}

class _Frame_5_49940State extends State<Frame_5_49940> {
  late final ImageProvider _image_sbpm5_49988 = MemoryImage(imageStr_imageStr_zikb5_49988.decodeBase64Image());
  late final ImageProvider _image_hdgs5_50002 = MemoryImage(imageStr_imageStr_rqve5_50002.decodeBase64Image());
  late final ImageProvider _image_nbtw5_50021 = MemoryImage(imageStr_imageStr_smuh5_50021.decodeBase64Image());

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
                  key: ValueKey("5:49940"),
                  children: [
                    CustomWidget_5_49941(),
                    CustomWidget_5_49955(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:50014"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 40.w,
                            height: 40.h,
                            left: 8.w,
                            top: 2.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                                child: Row(
                                  key: ValueKey("5:50015"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:50016"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:50017"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 70.w,
                                  height: 23.h,
                                  left: 161.w,
                                  top: 0.h,
                                  child: Text("作品详情",
                                    key: ValueKey("5:50018"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 22.w,
                            height: 27.h,
                            left: 352.w,
                            top: 9.h,
                            child: Stack(
                              key: ValueKey("5:50019"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 22.w,
                                  height: 22.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Container(
                                    key: ValueKey("5:50020"),),),
                              ],),),
                        ],),),
                    Positioned(
                      width: 390.w,
                      height: 300.h,
                      left: 0.w,
                      top: 106.h,
                      child: Container(
                        decoration: BoxDecoration(image: DecorationImage(image: _image_nbtw5_50021, fit: BoxFit.fill),borderRadius: BorderRadius.only(  bottomLeft: Radius.circular(20.h), bottomRight: Radius.circular(20.h),),),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          key: ValueKey("5:50021"),
                          children: [
                            Positioned(
                              width: 123.47.w,
                              height: 15.h,
                              left: 10.w,
                              top: 275.h,
                              child: Stack(
                                key: ValueKey("5:50022"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 125.w,
                                    height: 15.h,
                                    left: 0.w,
                                    top: -1.h,
                                    child: Text("作品 · 星空拼豆 2000 颗",
                                      key: ValueKey("5:50023"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),
                    Positioned(
                      width: 390.w,
                      height: 68.h,
                      left: 0.w,
                      top: 776.h,
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          constraints: BoxConstraints(minWidth: 390.w, minHeight: 68.h),
                          padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 1.h,bottom: 0.h),
                          decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
                          child: Row(
                            key: ValueKey("5:50024"),
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 12.w,
                            children: [
                              SizedBox(
                                width: 291.98.w,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 291.98.w, minHeight: 42.h),
                                    padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                                    decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(21.h),),
                                    child: Row(
                                      key: ValueKey("5:50025"),
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      spacing: 8.w,
                                      children: [
                                        Container(
                                          width: 65.02.w,
                                          height: 18.h,
                                          child: Stack(
                                            key: ValueKey("5:50026"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 67.w,
                                                height: 18.h,
                                                left: 0.w,
                                                top: 0.h,
                                                child: Text("说点什么…",
                                                  key: ValueKey("5:50027"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),
                                      ],),),),),
                              SizedBox(
                                width: 54.02.w,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 54.02.w, minHeight: 38.h),
                                    padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                                    child: Row(
                                      key: ValueKey("5:50028"),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 26.02.w,
                                          height: 18.h,
                                          child: Text("发送",
                                            key: ValueKey("5:50029"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                      ],),),),),
                            ],),),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

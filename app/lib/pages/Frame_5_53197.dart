import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53198.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53244.dart';

class Frame_5_53197 extends StatefulWidget {

  Frame_5_53197({super.key,});
  @override
  State<Frame_5_53197> createState() => _Frame_5_53197State();
}

class _Frame_5_53197State extends State<Frame_5_53197> {
  late final ImageProvider _image_gcow5_53247 = MemoryImage(imageStr_imageStr_mbcv5_53247.decodeBase64Image());

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
                  key: ValueKey("5:53197"),
                  children: [
                    CustomWidget_5_53198(),
                    Positioned(
                      width: 390.w,
                      height: 179.h,
                      left: 0.w,
                      top: 106.h,
                      child: Opacity(
                        opacity: 0.5,
                        child: Stack(
                          key: ValueKey("5:53212"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 358.w,
                              height: 32.h,
                              left: 16.w,
                              top: 8.h,
                              child: SingleChildScrollView(
                                clipBehavior: Clip.none,
                                physics: NeverScrollableScrollPhysics(),
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 358.w, minHeight: 32.h),
                                  padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                  child: Column(
                                    key: ValueKey("5:53213"),
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 358.w,
                                        height: 24.h,
                                        child: Stack(
                                          key: ValueKey("5:53214"),
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              width: 76.w,
                                              height: 23.h,
                                              left: 0.w,
                                              top: 0.h,
                                              child: Text("群成员 12",
                                                key: ValueKey("5:53215"),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                          ],),),
                                    ],),),),),
                            Positioned(
                              width: 358.w,
                              height: 139.h,
                              left: 16.w,
                              top: 40.h,
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Image(
                                  key: ValueKey("5:53216"),
                                  image: AssetImage("assets/divcardcardpad0.png"),),),),
                          ],),),),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:53238"),
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
                                  key: ValueKey("5:53239"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:53240"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:53241"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 70.w,
                                  height: 23.h,
                                  left: 161.w,
                                  top: 0.h,
                                  child: Text("群聊设置",
                                    key: ValueKey("5:53242"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                        ],),),
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        key: ValueKey("5:53243"),
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.42),),),),
                    CustomWidget_5_53244(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

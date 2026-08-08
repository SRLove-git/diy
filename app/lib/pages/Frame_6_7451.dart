import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_event_handler.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7453.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7467.dart';

class Frame_6_7451 extends StatefulWidget {

  Frame_6_7451({super.key,});
  @override
  State<Frame_6_7451> createState() => _Frame_6_7451State();
}

class _Frame_6_7451State extends State<Frame_6_7451> {
  late final ImageProvider _image_uyua6_7490 = MemoryImage(imageStr_mzpl6_7490.decodeBase64Image());

  @override
  void initState() {
    super.initState();
  
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil().rootSize = Size(440, 956);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: SizedBox(
            width: 440.w,
            height: 956.h,
            child: ListView(
              children: [
                Container(
                width: 440.w,
                height: 956.h,
                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),),
                clipBehavior: Clip.hardEdge,
                child: Stack(
                  key: ValueKey("6:7451"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: GestureDetector(
                        child: Stack(
                          key: ValueKey("6:7452"),
                          clipBehavior: Clip.none,
                          children: [
                            CustomWidget_6_7453(),
                            CustomWidget_6_7467(),
                            Positioned(
                              width: 440.w,
                              height: 17.h,
                              left: 0.w,
                              top: 906.h,
                              child: Stack(
                                key: ValueKey("6:7498"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 250.w,
                                    height: 15.h,
                                    left: 96.w,
                                    top: 0.h,
                                    child: Text("登录即代表同意《用户协议》和《隐私政策》",
                                      key: ValueKey("6:7499"),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                ],),),
                          ],),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

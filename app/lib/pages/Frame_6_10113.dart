import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10116.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10131.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10140.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10161.dart';

class Frame_6_10113 extends StatefulWidget {

  Frame_6_10113({super.key,});
  @override
  State<Frame_6_10113> createState() => _Frame_6_10113State();
}

class _Frame_6_10113State extends State<Frame_6_10113> {
  late final ImageProvider _image_cmpc6_10115 = MemoryImage(imageStr_eqki6_10115.decodeBase64Image());
  late final ImageProvider _image_luci6_10130 = MemoryImage(imageStr_gxrr6_10130.decodeBase64Image());
  late final ImageProvider _image_grce6_10161 = MemoryImage(imageStr_djxt6_10161.decodeBase64Image());

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
                  key: ValueKey("6:10113"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:10114"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 440.w,
                            height: 952.h,
                            left: 0.w,
                            top: 0.h,
                            child: Container(
                              decoration: BoxDecoration(image: DecorationImage(image: _image_cmpc6_10115, fit: BoxFit.fill),),
                              child: Stack(
                                key: ValueKey("6:10115"),
                                clipBehavior: Clip.none,
                                children: [
                                  CustomWidget_6_10116(),
                                  Positioned(
                                    width: 440.w,
                                    height: 952.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Container(
                                      key: ValueKey("6:10130"),
                                      decoration: BoxDecoration(image: DecorationImage(image: _image_luci6_10130, fit: BoxFit.fill),),),),
                                  CustomWidget_6_10131(),
                                  CustomWidget_6_10140(),
                                  CustomWidget_6_10161(),
                                ],),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

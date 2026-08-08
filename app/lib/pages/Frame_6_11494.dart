import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11496.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11510.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11561.dart';

class Frame_6_11494 extends StatefulWidget {

  Frame_6_11494({super.key,});
  @override
  State<Frame_6_11494> createState() => _Frame_6_11494State();
}

class _Frame_6_11494State extends State<Frame_6_11494> {
  late final ImageProvider _image_qrjd6_11513 = MemoryImage(imageStr_xjsr6_11513.decodeBase64Image());
  late final ImageProvider _image_rxmg6_11515 = MemoryImage(imageStr_vzyj6_11515.decodeBase64Image());

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
                  key: ValueKey("6:11494"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:11495"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_11496(),
                          CustomWidget_6_11510(),
                          CustomWidget_6_11561(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

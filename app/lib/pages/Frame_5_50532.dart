import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50534.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50549.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50558.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50579.dart';

class Frame_5_50532 extends StatefulWidget {

  Frame_5_50532({super.key,});
  @override
  State<Frame_5_50532> createState() => _Frame_5_50532State();
}

class _Frame_5_50532State extends State<Frame_5_50532> {
  late final ImageProvider _image_sipm5_50533 = MemoryImage(imageStr_imageStr_amju5_50533.decodeBase64Image());
  late final ImageProvider _image_zdrz5_50548 = MemoryImage(imageStr_imageStr_ngyz5_50548.decodeBase64Image());
  late final ImageProvider _image_kuwc5_50579 = MemoryImage(imageStr_imageStr_rkgj5_50579.decodeBase64Image());

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
                  key: ValueKey("5:50532"),
                  children: [
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        decoration: BoxDecoration(image: DecorationImage(image: _image_sipm5_50533, fit: BoxFit.fill),),
                        child: Stack(
                          key: ValueKey("5:50533"),
                          clipBehavior: Clip.none,
                          children: [
                            CustomWidget_5_50534(),
                            Positioned(
                              width: 390.w,
                              height: 844.h,
                              left: 0.w,
                              top: 0.h,
                              child: Container(
                                key: ValueKey("5:50548"),
                                decoration: BoxDecoration(image: DecorationImage(image: _image_zdrz5_50548, fit: BoxFit.fill),),),),
                            CustomWidget_5_50549(),
                            CustomWidget_5_50558(),
                            CustomWidget_5_50579(),
                          ],),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

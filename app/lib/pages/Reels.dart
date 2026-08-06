import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50351.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50366.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50371.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50385.dart';

class Reels extends StatefulWidget {

  Reels({super.key,});
  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  late final ImageProvider _image_zyke5_50350 = MemoryImage(imageStr_imageStr_zyel5_50350.decodeBase64Image());
  late final ImageProvider _image_vrvl5_50365 = MemoryImage(imageStr_imageStr_tjmg5_50365.decodeBase64Image());
  late final ImageProvider _image_fjmv5_50374 = MemoryImage(imageStr_imageStr_jlme5_50374.decodeBase64Image());
  late final ImageProvider _image_znsn5_50376 = MemoryImage(imageStr_imageStr_yfdb5_50376.decodeBase64Image());
  late final ImageProvider _image_ivhq5_50387 = MemoryImage(imageStr_imageStr_bkcu5_50387.decodeBase64Image());
  late final ImageProvider _image_rfdt5_50389 = MemoryImage(imageStr_imageStr_tudc5_50389.decodeBase64Image());

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
                  key: ValueKey("5:50349"),
                  children: [
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        decoration: BoxDecoration(image: DecorationImage(image: _image_zyke5_50350, fit: BoxFit.fill),),
                        clipBehavior: Clip.hardEdge,
                        child: Stack(
                          key: ValueKey("5:50350"),
                          children: [
                            CustomWidget_5_50351(),
                            Positioned(
                              width: 390.w,
                              height: 844.h,
                              left: 0.w,
                              top: 0.h,
                              child: Container(
                                key: ValueKey("5:50365"),
                                decoration: BoxDecoration(image: DecorationImage(image: _image_vrvl5_50365, fit: BoxFit.fill),),),),
                            CustomWidget_5_50366(),
                            CustomWidget_5_50371(),
                            CustomWidget_5_50385(),
                            Positioned(
                              width: 390.w,
                              height: 96.h,
                              left: 0.w,
                              top: 748.h,
                              child: Image(
                                key: ValueKey("5:50410"),
                                image: AssetImage("assets/divtabwrap.png"),),),
                          ],),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

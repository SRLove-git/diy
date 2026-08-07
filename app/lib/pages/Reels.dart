import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9931.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9946.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9951.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9965.dart';

class Reels extends StatefulWidget {

  Reels({super.key,});
  @override
  State<Reels> createState() => _ReelsState();
}

class _ReelsState extends State<Reels> {
  late final ImageProvider _image_cmep6_9930 = MemoryImage(imageStr_pjkc6_9930.decodeBase64Image());
  late final ImageProvider _image_iotp6_9945 = MemoryImage(imageStr_izal6_9945.decodeBase64Image());
  late final ImageProvider _image_hxws6_9954 = MemoryImage(imageStr_rdiw6_9954.decodeBase64Image());
  late final ImageProvider _image_mnke6_9956 = MemoryImage(imageStr_nlfw6_9956.decodeBase64Image());
  late final ImageProvider _image_mjqa6_9967 = MemoryImage(imageStr_aiim6_9967.decodeBase64Image());
  late final ImageProvider _image_pmis6_9969 = MemoryImage(imageStr_oxnk6_9969.decodeBase64Image());

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
                  key: ValueKey("6:9928"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:9929"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 440.w,
                            height: 952.h,
                            left: 0.w,
                            top: 0.h,
                            child: Container(
                              decoration: BoxDecoration(image: DecorationImage(image: _image_cmep6_9930, fit: BoxFit.fill),),
                              clipBehavior: Clip.hardEdge,
                              child: Stack(
                                key: ValueKey("6:9930"),
                                children: [
                                  CustomWidget_6_9931(),
                                  Positioned(
                                    width: 440.w,
                                    height: 952.h,
                                    left: 0.w,
                                    top: 0.h,
                                    child: Container(
                                      key: ValueKey("6:9945"),
                                      decoration: BoxDecoration(image: DecorationImage(image: _image_iotp6_9945, fit: BoxFit.fill),),),),
                                  CustomWidget_6_9946(),
                                  CustomWidget_6_9951(),
                                  CustomWidget_6_9965(),
                                  Positioned(
                                    width: 440.w,
                                    height: 108.h,
                                    left: 0.w,
                                    top: 844.h,
                                    child: Image(
                                      key: ValueKey("6:9990"),
                                      image: AssetImage("assets/divtabwrap-reels.png"),),),
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

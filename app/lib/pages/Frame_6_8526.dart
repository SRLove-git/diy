import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_8528.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_8542.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_8671.dart';

class Frame_6_8526 extends StatefulWidget {

  Frame_6_8526({super.key,});
  @override
  State<Frame_6_8526> createState() => _Frame_6_8526State();
}

class _Frame_6_8526State extends State<Frame_6_8526> {
  late final ImageProvider _image_gsup6_8553 = MemoryImage(imageStr_nxje6_8553.decodeBase64Image());

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
                  key: ValueKey("6:8526"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:8527"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_8528(),
                          CustomWidget_6_8542(),
                          CustomWidget_6_8671(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

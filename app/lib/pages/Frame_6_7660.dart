import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7662.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7676.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7747.dart';

class Frame_6_7660 extends StatefulWidget {

  Frame_6_7660({super.key,});
  @override
  State<Frame_6_7660> createState() => _Frame_6_7660State();
}

class _Frame_6_7660State extends State<Frame_6_7660> {
  late final ImageProvider _image_xyfo6_7682 = MemoryImage(imageStr_hdzp6_7682.decodeBase64Image());
  late final ImageProvider _image_ymze6_7741 = MemoryImage(imageStr_rrho6_7741.decodeBase64Image());
  late final ImageProvider _image_cqqx6_7744 = MemoryImage(imageStr_mjsl6_7744.decodeBase64Image());

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
                  key: ValueKey("6:7660"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:7661"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_7662(),
                          CustomWidget_6_7676(),
                          CustomWidget_6_7747(),
                          Positioned(
                            width: 451.9.w,
                            height: 115.h,
                            left: 0.w,
                            top: 844.h,
                            child: Image(
                              key: ValueKey("6:7755"),
                              image: AssetImage("assets/divtabwrap-home.png"),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

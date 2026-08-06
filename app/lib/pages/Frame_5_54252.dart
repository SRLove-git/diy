import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54253.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54267.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54349.dart';

class Frame_5_54252 extends StatefulWidget {

  Frame_5_54252({super.key,});
  @override
  State<Frame_5_54252> createState() => _Frame_5_54252State();
}

class _Frame_5_54252State extends State<Frame_5_54252> {
  late final ImageProvider _image_xloz5_54278 = MemoryImage(imageStr_imageStr_vmpa5_54278.decodeBase64Image());
  late final ImageProvider _image_zbha5_54296 = MemoryImage(imageStr_imageStr_mawz5_54296.decodeBase64Image());
  late final ImageProvider _image_tgqc5_54314 = MemoryImage(imageStr_imageStr_bvtn5_54314.decodeBase64Image());
  late final ImageProvider _image_bfyy5_54332 = MemoryImage(imageStr_imageStr_mvjn5_54332.decodeBase64Image());

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
                  key: ValueKey("5:54252"),
                  children: [
                    CustomWidget_5_54253(),
                    CustomWidget_5_54267(),
                    CustomWidget_5_54349(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

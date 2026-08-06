import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51902.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51916.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51967.dart';

class Frame_5_51901 extends StatefulWidget {

  Frame_5_51901({super.key,});
  @override
  State<Frame_5_51901> createState() => _Frame_5_51901State();
}

class _Frame_5_51901State extends State<Frame_5_51901> {
  late final ImageProvider _image_xcpt5_51919 = MemoryImage(imageStr_imageStr_jzul5_51919.decodeBase64Image());
  late final ImageProvider _image_sgxt5_51921 = MemoryImage(imageStr_imageStr_zgim5_51921.decodeBase64Image());

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
                  key: ValueKey("5:51901"),
                  children: [
                    CustomWidget_5_51902(),
                    CustomWidget_5_51916(),
                    CustomWidget_5_51967(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

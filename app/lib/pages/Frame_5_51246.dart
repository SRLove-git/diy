import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51247.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51261.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51398.dart';

class Frame_5_51246 extends StatefulWidget {

  Frame_5_51246({super.key,});
  @override
  State<Frame_5_51246> createState() => _Frame_5_51246State();
}

class _Frame_5_51246State extends State<Frame_5_51246> {
  late final ImageProvider _image_amut5_51264 = MemoryImage(imageStr_imageStr_geyf5_51264.decodeBase64Image());
  late final ImageProvider _image_cwvc5_51266 = MemoryImage(imageStr_imageStr_mukz5_51266.decodeBase64Image());

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
                  key: ValueKey("5:51246"),
                  children: [
                    CustomWidget_5_51247(),
                    CustomWidget_5_51261(),
                    CustomWidget_5_51398(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

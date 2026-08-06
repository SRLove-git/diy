import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48103.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48117.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48188.dart';

class Frame_5_48102 extends StatefulWidget {

  Frame_5_48102({super.key,});
  @override
  State<Frame_5_48102> createState() => _Frame_5_48102State();
}

class _Frame_5_48102State extends State<Frame_5_48102> {
  late final ImageProvider _image_nwzn5_48123 = MemoryImage(imageStr_imageStr_jokg5_48123.decodeBase64Image());
  late final ImageProvider _image_ygul5_48182 = MemoryImage(imageStr_imageStr_krhc5_48182.decodeBase64Image());
  late final ImageProvider _image_hxas5_48185 = MemoryImage(imageStr_imageStr_plyt5_48185.decodeBase64Image());

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
                  key: ValueKey("5:48102"),
                  children: [
                    CustomWidget_5_48103(),
                    CustomWidget_5_48117(),
                    CustomWidget_5_48188(),
                    Positioned(
                      width: 406.w,
                      height: 104.h,
                      left: 0.w,
                      top: 748.h,
                      child: Image(
                        key: ValueKey("5:48196"),
                        image: AssetImage("assets/divtabwrap.png"),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

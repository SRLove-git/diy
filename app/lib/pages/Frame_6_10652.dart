import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10654.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10668.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10681.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10707.dart';

class Frame_6_10652 extends StatefulWidget {

  Frame_6_10652({super.key,});
  @override
  State<Frame_6_10652> createState() => _Frame_6_10652State();
}

class _Frame_6_10652State extends State<Frame_6_10652> {
  late final ImageProvider _image_mkcl6_10675 = MemoryImage(imageStr_reca6_10675.decodeBase64Image());
  late final ImageProvider _image_xkwv6_10677 = MemoryImage(imageStr_hlop6_10677.decodeBase64Image());
  late final ImageProvider _image_czsh6_10679 = MemoryImage(imageStr_sxhl6_10679.decodeBase64Image());
  late final ImageProvider _image_cttm6_10688 = MemoryImage(imageStr_ullh6_10688.decodeBase64Image());
  late final ImageProvider _image_rpkr6_10697 = MemoryImage(imageStr_yjmu6_10697.decodeBase64Image());
  late final ImageProvider _image_nsnr6_10700 = MemoryImage(imageStr_xrpl6_10700.decodeBase64Image());
  late final ImageProvider _image_rpem6_10715 = MemoryImage(imageStr_mqki6_10715.decodeBase64Image());

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
                  key: ValueKey("6:10652"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:10653"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_10654(),
                          CustomWidget_6_10668(),
                          CustomWidget_6_10681(),
                          CustomWidget_6_10707(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

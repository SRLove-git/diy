import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54874.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54885.dart';

class Frame_5_54873 extends StatefulWidget {

  Frame_5_54873({super.key,});
  @override
  State<Frame_5_54873> createState() => _Frame_5_54873State();
}

class _Frame_5_54873State extends State<Frame_5_54873> {
  late final ImageProvider _image_degp5_54875 = MemoryImage(imageStr_imageStr_iidv5_54875.decodeBase64Image());
  late final ImageProvider _image_reyk5_54876 = MemoryImage(imageStr_imageStr_doqs5_54876.decodeBase64Image());
  late final ImageProvider _image_umus5_54892 = MemoryImage(imageStr_imageStr_cfaw5_54892.decodeBase64Image());
  late final ImageProvider _image_hcac5_54902 = MemoryImage(imageStr_imageStr_kquk5_54902.decodeBase64Image());
  late final ImageProvider _image_prfv5_54912 = MemoryImage(imageStr_imageStr_dquy5_54912.decodeBase64Image());
  late final ImageProvider _image_zfxe5_54922 = MemoryImage(imageStr_imageStr_zlpk5_54922.decodeBase64Image());
  late final ImageProvider _image_wbnd5_54932 = MemoryImage(imageStr_imageStr_nkxa5_54932.decodeBase64Image());

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
                  key: ValueKey("5:54873"),
                  children: [
                    CustomWidget_5_54874(),
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        key: ValueKey("5:54884"),
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.42),),),),
                    CustomWidget_5_54885(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

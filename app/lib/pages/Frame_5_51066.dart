import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51067.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51081.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51094.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51120.dart';

class Frame_5_51066 extends StatefulWidget {

  Frame_5_51066({super.key,});
  @override
  State<Frame_5_51066> createState() => _Frame_5_51066State();
}

class _Frame_5_51066State extends State<Frame_5_51066> {
  late final ImageProvider _image_epwb5_51088 = MemoryImage(imageStr_imageStr_dchf5_51088.decodeBase64Image());
  late final ImageProvider _image_utzn5_51090 = MemoryImage(imageStr_imageStr_nrny5_51090.decodeBase64Image());
  late final ImageProvider _image_xedw5_51092 = MemoryImage(imageStr_imageStr_rhdn5_51092.decodeBase64Image());
  late final ImageProvider _image_tmun5_51101 = MemoryImage(imageStr_imageStr_pokw5_51101.decodeBase64Image());
  late final ImageProvider _image_efxi5_51110 = MemoryImage(imageStr_imageStr_xuds5_51110.decodeBase64Image());
  late final ImageProvider _image_mbjn5_51113 = MemoryImage(imageStr_imageStr_evtn5_51113.decodeBase64Image());
  late final ImageProvider _image_mvug5_51128 = MemoryImage(imageStr_imageStr_lpzd5_51128.decodeBase64Image());

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
                  key: ValueKey("5:51066"),
                  children: [
                    CustomWidget_5_51067(),
                    CustomWidget_5_51081(),
                    CustomWidget_5_51094(),
                    CustomWidget_5_51120(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

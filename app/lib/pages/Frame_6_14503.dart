import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14505.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14516.dart';

class Frame_6_14503 extends StatefulWidget {

  Frame_6_14503({super.key,});
  @override
  State<Frame_6_14503> createState() => _Frame_6_14503State();
}

class _Frame_6_14503State extends State<Frame_6_14503> {
  late final ImageProvider _image_hcny6_14506 = MemoryImage(imageStr_ohte6_14506.decodeBase64Image());
  late final ImageProvider _image_nmsr6_14507 = MemoryImage(imageStr_vmpp6_14507.decodeBase64Image());
  late final ImageProvider _image_xzpu6_14523 = MemoryImage(imageStr_okmp6_14523.decodeBase64Image());
  late final ImageProvider _image_ufss6_14533 = MemoryImage(imageStr_bjqu6_14533.decodeBase64Image());
  late final ImageProvider _image_ekpe6_14543 = MemoryImage(imageStr_kylc6_14543.decodeBase64Image());
  late final ImageProvider _image_xeye6_14553 = MemoryImage(imageStr_serp6_14553.decodeBase64Image());
  late final ImageProvider _image_lokp6_14563 = MemoryImage(imageStr_pvxd6_14563.decodeBase64Image());

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
                  key: ValueKey("6:14503"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:14504"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_14505(),
                          Positioned(
                            width: 440.w,
                            height: 952.h,
                            left: 0.w,
                            top: 0.h,
                            child: Container(
                              key: ValueKey("6:14515"),
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.42),),),),
                          CustomWidget_6_14516(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

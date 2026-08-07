import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13874.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13888.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13970.dart';

class Frame_6_13872 extends StatefulWidget {

  Frame_6_13872({super.key,});
  @override
  State<Frame_6_13872> createState() => _Frame_6_13872State();
}

class _Frame_6_13872State extends State<Frame_6_13872> {
  late final ImageProvider _image_onoa6_13899 = MemoryImage(imageStr_qpmf6_13899.decodeBase64Image());
  late final ImageProvider _image_gsuu6_13917 = MemoryImage(imageStr_mmdk6_13917.decodeBase64Image());
  late final ImageProvider _image_hqnu6_13935 = MemoryImage(imageStr_mxzb6_13935.decodeBase64Image());
  late final ImageProvider _image_rlfy6_13953 = MemoryImage(imageStr_fddp6_13953.decodeBase64Image());

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
                  key: ValueKey("6:13872"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:13873"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_13874(),
                          CustomWidget_6_13888(),
                          CustomWidget_6_13970(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

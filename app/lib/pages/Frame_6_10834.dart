import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10836.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10850.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10987.dart';

class Frame_6_10834 extends StatefulWidget {

  Frame_6_10834({super.key,});
  @override
  State<Frame_6_10834> createState() => _Frame_6_10834State();
}

class _Frame_6_10834State extends State<Frame_6_10834> {
  late final ImageProvider _image_srmy6_10853 = MemoryImage(imageStr_sfdp6_10853.decodeBase64Image());
  late final ImageProvider _image_kxzp6_10855 = MemoryImage(imageStr_ftgd6_10855.decodeBase64Image());

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
                  key: ValueKey("6:10834"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:10835"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_10836(),
                          CustomWidget_6_10850(),
                          CustomWidget_6_10987(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48961.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_48975.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49104.dart';

class Frame_5_48960 extends StatefulWidget {

  Frame_5_48960({super.key,});
  @override
  State<Frame_5_48960> createState() => _Frame_5_48960State();
}

class _Frame_5_48960State extends State<Frame_5_48960> {
  late final ImageProvider _image_qkxd5_48986 = MemoryImage(imageStr_imageStr_ckwa5_48986.decodeBase64Image());

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
                  key: ValueKey("5:48960"),
                  children: [
                    CustomWidget_5_48961(),
                    CustomWidget_5_48975(),
                    CustomWidget_5_49104(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

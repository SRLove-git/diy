import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_47898.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_47912.dart';

class Frame_5_47897 extends StatefulWidget {

  Frame_5_47897({super.key,});
  @override
  State<Frame_5_47897> createState() => _Frame_5_47897State();
}

class _Frame_5_47897State extends State<Frame_5_47897> {
  late final ImageProvider _image_sxkp5_47935 = MemoryImage(imageStr_imageStr_jkdf5_47935.decodeBase64Image());

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
                  key: ValueKey("5:47897"),
                  children: [
                    CustomWidget_5_47898(),
                    CustomWidget_5_47912(),
                    Positioned(
                      width: 390.w,
                      height: 15.h,
                      left: 0.w,
                      top: 803.h,
                      child: Stack(
                        key: ValueKey("5:47943"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 222.w,
                            height: 15.h,
                            left: 85.w,
                            top: -1.h,
                            child: Text("登录即代表同意《用户协议》和《隐私政策》",
                              key: ValueKey("5:47944"),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

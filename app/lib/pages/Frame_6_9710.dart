import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9712.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9726.dart';

class Frame_6_9710 extends StatefulWidget {

  Frame_6_9710({super.key,});
  @override
  State<Frame_6_9710> createState() => _Frame_6_9710State();
}

class _Frame_6_9710State extends State<Frame_6_9710> {
  late final ImageProvider _image_pjpa6_9728 = MemoryImage(imageStr_crsl6_9728.decodeBase64Image());
  late final ImageProvider _image_dcod6_9730 = MemoryImage(imageStr_doej6_9730.decodeBase64Image());
  late final ImageProvider _image_xedg6_9773 = MemoryImage(imageStr_fttl6_9773.decodeBase64Image());
  late final ImageProvider _image_yyof6_9777 = MemoryImage(imageStr_ujrm6_9777.decodeBase64Image());
  late final ImageProvider _image_waxx6_9792 = MemoryImage(imageStr_dzua6_9792.decodeBase64Image());
  late final ImageProvider _image_zlim6_9796 = MemoryImage(imageStr_earx6_9796.decodeBase64Image());
  late final ImageProvider _image_djje6_9800 = MemoryImage(imageStr_xwft6_9800.decodeBase64Image());
  late final ImageProvider _image_bxrs6_9804 = MemoryImage(imageStr_uerb6_9804.decodeBase64Image());

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
                  key: ValueKey("6:9710"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:9711"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_9712(),
                          CustomWidget_6_9726(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:9808"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 45.13.w,
                                  height: 45.h,
                                  left: 8.w,
                                  top: 2.5.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 45.13.w, minHeight: 45.h),
                                      child: Row(
                                        key: ValueKey("6:9809"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:9810"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:9811"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 60.w,
                                        height: 23.h,
                                        left: 191.w,
                                        top: 1.h,
                                        child: Text("小豆子",
                                          key: ValueKey("6:9812"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 24.82.w,
                                  height: 30.h,
                                  left: 397.w,
                                  top: 10.h,
                                  child: Stack(
                                    key: ValueKey("6:9813"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 24.82.w,
                                        height: 25.h,
                                        left: 0.w,
                                        top: 0.h,
                                        child: Container(
                                          key: ValueKey("6:9814"),),),
                                    ],),),
                              ],),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

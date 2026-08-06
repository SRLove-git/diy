import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54359.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54373.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54422.dart';

class Frame_5_54358 extends StatefulWidget {

  Frame_5_54358({super.key,});
  @override
  State<Frame_5_54358> createState() => _Frame_5_54358State();
}

class _Frame_5_54358State extends State<Frame_5_54358> {
  late final ImageProvider _image_zrli5_54391 = MemoryImage(imageStr_imageStr_oqrn5_54391.decodeBase64Image());
  late final ImageProvider _image_bqrx5_54395 = MemoryImage(imageStr_imageStr_gvqx5_54395.decodeBase64Image());
  late final ImageProvider _image_shue5_54399 = MemoryImage(imageStr_imageStr_bodk5_54399.decodeBase64Image());
  late final ImageProvider _image_qdrz5_54403 = MemoryImage(imageStr_imageStr_rkwg5_54403.decodeBase64Image());
  late final ImageProvider _image_eirw5_54407 = MemoryImage(imageStr_imageStr_lert5_54407.decodeBase64Image());
  late final ImageProvider _image_aedd5_54411 = MemoryImage(imageStr_imageStr_vtbb5_54411.decodeBase64Image());
  late final ImageProvider _image_ohwj5_54422 = MemoryImage(imageStr_imageStr_qrbw5_54422.decodeBase64Image());
  late final ImageProvider _image_ymwl5_54423 = MemoryImage(imageStr_imageStr_bgvj5_54423.decodeBase64Image());

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
                  key: ValueKey("5:54358"),
                  children: [
                    CustomWidget_5_54359(),
                    CustomWidget_5_54373(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:54415"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 40.w,
                            height: 40.h,
                            left: 8.w,
                            top: 2.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 40.w, minHeight: 40.h),
                                child: Row(
                                  key: ValueKey("5:54416"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:54417"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:54418"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 70.w,
                                  height: 23.h,
                                  left: 161.w,
                                  top: 0.h,
                                  child: Text("话题详情",
                                    key: ValueKey("5:54419"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 22.w,
                            height: 27.h,
                            left: 352.w,
                            top: 9.h,
                            child: Stack(
                              key: ValueKey("5:54420"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 22.w,
                                  height: 22.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Container(
                                    key: ValueKey("5:54421"),),),
                              ],),),
                        ],),),
                    CustomWidget_5_54422(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

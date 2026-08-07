import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13981.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13995.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14044.dart';

class Frame_6_13979 extends StatefulWidget {

  Frame_6_13979({super.key,});
  @override
  State<Frame_6_13979> createState() => _Frame_6_13979State();
}

class _Frame_6_13979State extends State<Frame_6_13979> {
  late final ImageProvider _image_tbbn6_14013 = MemoryImage(imageStr_byvr6_14013.decodeBase64Image());
  late final ImageProvider _image_qjaa6_14017 = MemoryImage(imageStr_ufoi6_14017.decodeBase64Image());
  late final ImageProvider _image_bmfh6_14021 = MemoryImage(imageStr_jlip6_14021.decodeBase64Image());
  late final ImageProvider _image_glch6_14025 = MemoryImage(imageStr_gmcx6_14025.decodeBase64Image());
  late final ImageProvider _image_sigi6_14029 = MemoryImage(imageStr_lznm6_14029.decodeBase64Image());
  late final ImageProvider _image_cygu6_14033 = MemoryImage(imageStr_yrul6_14033.decodeBase64Image());
  late final ImageProvider _image_kooq6_14044 = MemoryImage(imageStr_detq6_14044.decodeBase64Image());
  late final ImageProvider _image_ntna6_14045 = MemoryImage(imageStr_kekt6_14045.decodeBase64Image());

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
                  key: ValueKey("6:13979"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:13980"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_13981(),
                          CustomWidget_6_13995(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:14037"),
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
                                        key: ValueKey("6:14038"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:14039"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:14040"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 79.w,
                                        height: 23.h,
                                        left: 182.w,
                                        top: 1.h,
                                        child: Text("话题详情",
                                          key: ValueKey("6:14041"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 24.82.w,
                                  height: 30.h,
                                  left: 397.w,
                                  top: 10.h,
                                  child: Stack(
                                    key: ValueKey("6:14042"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 24.82.w,
                                        height: 25.h,
                                        left: 0.w,
                                        top: 0.h,
                                        child: Container(
                                          key: ValueKey("6:14043"),),),
                                    ],),),
                              ],),),
                          CustomWidget_6_14044(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51976.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51990.dart';

class Frame_5_51975 extends StatefulWidget {

  Frame_5_51975({super.key,});
  @override
  State<Frame_5_51975> createState() => _Frame_5_51975State();
}

class _Frame_5_51975State extends State<Frame_5_51975> {
  late final ImageProvider _image_nleg5_52004 = MemoryImage(imageStr_imageStr_iwmd5_52004.decodeBase64Image());
  late final ImageProvider _image_mmco5_52008 = MemoryImage(imageStr_imageStr_fkei5_52008.decodeBase64Image());
  late final ImageProvider _image_ymub5_52012 = MemoryImage(imageStr_imageStr_roqu5_52012.decodeBase64Image());
  late final ImageProvider _image_isvx5_52016 = MemoryImage(imageStr_imageStr_favw5_52016.decodeBase64Image());
  late final ImageProvider _image_lges5_52020 = MemoryImage(imageStr_imageStr_hanq5_52020.decodeBase64Image());
  late final ImageProvider _image_exvw5_52024 = MemoryImage(imageStr_imageStr_lxuq5_52024.decodeBase64Image());
  late final ImageProvider _image_srjn5_52028 = MemoryImage(imageStr_imageStr_rnlj5_52028.decodeBase64Image());
  late final ImageProvider _image_tdsy5_52032 = MemoryImage(imageStr_imageStr_pqsb5_52032.decodeBase64Image());
  late final ImageProvider _image_lkub5_52036 = MemoryImage(imageStr_imageStr_gpqp5_52036.decodeBase64Image());

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
                  key: ValueKey("5:51975"),
                  children: [
                    CustomWidget_5_51976(),
                    CustomWidget_5_51990(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:52043"),
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
                                  key: ValueKey("5:52044"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:52045"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:52046"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 70.w,
                                  height: 23.h,
                                  left: 161.w,
                                  top: 0.h,
                                  child: Text("我的内容",
                                    key: ValueKey("5:52047"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
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

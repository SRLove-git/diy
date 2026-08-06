import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50134.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50148.dart';

class Frame_5_50133 extends StatefulWidget {

  Frame_5_50133({super.key,});
  @override
  State<Frame_5_50133> createState() => _Frame_5_50133State();
}

class _Frame_5_50133State extends State<Frame_5_50133> {
  late final ImageProvider _image_vrie5_50150 = MemoryImage(imageStr_imageStr_ghkz5_50150.decodeBase64Image());
  late final ImageProvider _image_ctgf5_50152 = MemoryImage(imageStr_imageStr_hoyc5_50152.decodeBase64Image());
  late final ImageProvider _image_psch5_50195 = MemoryImage(imageStr_imageStr_szhr5_50195.decodeBase64Image());
  late final ImageProvider _image_whmi5_50199 = MemoryImage(imageStr_imageStr_zmzi5_50199.decodeBase64Image());
  late final ImageProvider _image_ekvx5_50214 = MemoryImage(imageStr_imageStr_jcsu5_50214.decodeBase64Image());
  late final ImageProvider _image_svdb5_50218 = MemoryImage(imageStr_imageStr_vsey5_50218.decodeBase64Image());
  late final ImageProvider _image_pyjl5_50222 = MemoryImage(imageStr_imageStr_kgip5_50222.decodeBase64Image());
  late final ImageProvider _image_taaf5_50226 = MemoryImage(imageStr_imageStr_rhtu5_50226.decodeBase64Image());

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
                  key: ValueKey("5:50133"),
                  children: [
                    CustomWidget_5_50134(),
                    CustomWidget_5_50148(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:50230"),
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
                                  key: ValueKey("5:50231"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:50232"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:50233"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 53.w,
                                  height: 23.h,
                                  left: 170.w,
                                  top: 0.h,
                                  child: Text("小豆子",
                                    key: ValueKey("5:50234"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 22.w,
                            height: 27.h,
                            left: 352.w,
                            top: 9.h,
                            child: Stack(
                              key: ValueKey("5:50235"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 22.w,
                                  height: 22.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Container(
                                    key: ValueKey("5:50236"),),),
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

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51639.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51653.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51763.dart';

class Frame_5_51638 extends StatefulWidget {

  Frame_5_51638({super.key,});
  @override
  State<Frame_5_51638> createState() => _Frame_5_51638State();
}

class _Frame_5_51638State extends State<Frame_5_51638> {
  late final ImageProvider _image_nfac5_51655 = MemoryImage(imageStr_imageStr_zrne5_51655.decodeBase64Image());
  late final ImageProvider _image_xump5_51657 = MemoryImage(imageStr_imageStr_pioz5_51657.decodeBase64Image());
  late final ImageProvider _image_fkcf5_51700 = MemoryImage(imageStr_imageStr_vbbc5_51700.decodeBase64Image());
  late final ImageProvider _image_cayg5_51704 = MemoryImage(imageStr_imageStr_jtoc5_51704.decodeBase64Image());
  late final ImageProvider _image_yttd5_51719 = MemoryImage(imageStr_imageStr_qfdt5_51719.decodeBase64Image());
  late final ImageProvider _image_xvdz5_51723 = MemoryImage(imageStr_imageStr_swrd5_51723.decodeBase64Image());
  late final ImageProvider _image_pdsx5_51727 = MemoryImage(imageStr_imageStr_luei5_51727.decodeBase64Image());
  late final ImageProvider _image_nshr5_51731 = MemoryImage(imageStr_imageStr_wlkh5_51731.decodeBase64Image());
  late final ImageProvider _image_jzwc5_51770 = MemoryImage(imageStr_imageStr_ffov5_51770.decodeBase64Image());
  late final ImageProvider _image_wsqj5_51781 = MemoryImage(imageStr_imageStr_cqaa5_51781.decodeBase64Image());
  late final ImageProvider _image_vrso5_51792 = MemoryImage(imageStr_imageStr_oeam5_51792.decodeBase64Image());
  late final ImageProvider _image_qutf5_51804 = MemoryImage(imageStr_imageStr_ivop5_51804.decodeBase64Image());
  late final ImageProvider _image_hnwa5_51815 = MemoryImage(imageStr_imageStr_betr5_51815.decodeBase64Image());

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
                  key: ValueKey("5:51638"),
                  children: [
                    CustomWidget_5_51639(),
                    CustomWidget_5_51653(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:51735"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 390.w,
                            height: 28.h,
                            left: 0.w,
                            top: 8.h,
                            child: Stack(
                              key: ValueKey("5:51736"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 42.w,
                                  height: 28.h,
                                  left: 175.w,
                                  top: 0.h,
                                  child: Text("我的",
                                    key: ValueKey("5:51737"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 22.w,
                            height: 22.h,
                            left: 356.w,
                            top: 11.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 22.w, minHeight: 22.h),
                                child: Row(
                                  key: ValueKey("5:51738"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 16.w,
                                  children: [
                                    Container(
                                      key: ValueKey("5:51739"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                        ],),),
                    Positioned(
                      width: 406.w,
                      height: 104.h,
                      left: 0.w,
                      top: 748.h,
                      child: Image(
                        key: ValueKey("5:51740"),
                        image: AssetImage("assets/divtabwrap.png"),),),
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        key: ValueKey("5:51762"),
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.35),),),),
                    CustomWidget_5_51763(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

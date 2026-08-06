import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53336.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53350.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53446.dart';

class Frame_5_53335 extends StatefulWidget {

  Frame_5_53335({super.key,});
  @override
  State<Frame_5_53335> createState() => _Frame_5_53335State();
}

class _Frame_5_53335State extends State<Frame_5_53335> {
  late final ImageProvider _image_lypg5_53358 = MemoryImage(imageStr_imageStr_kicg5_53358.decodeBase64Image());
  late final ImageProvider _image_tqiz5_53360 = MemoryImage(imageStr_imageStr_vnii5_53360.decodeBase64Image());
  late final ImageProvider _image_cfxc5_53379 = MemoryImage(imageStr_imageStr_lqwk5_53379.decodeBase64Image());
  late final ImageProvider _image_jlkv5_53381 = MemoryImage(imageStr_imageStr_gbih5_53381.decodeBase64Image());
  late final ImageProvider _image_ciyh5_53400 = MemoryImage(imageStr_imageStr_zzkk5_53400.decodeBase64Image());
  late final ImageProvider _image_ioxp5_53402 = MemoryImage(imageStr_imageStr_oaim5_53402.decodeBase64Image());

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
                  key: ValueKey("5:53335"),
                  children: [
                    CustomWidget_5_53336(),
                    CustomWidget_5_53350(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:53417"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 390.w,
                            height: 28.h,
                            left: 0.w,
                            top: 8.h,
                            child: Stack(
                              key: ValueKey("5:53418"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 42.w,
                                  height: 28.h,
                                  left: 175.w,
                                  top: 0.h,
                                  child: Text("聊天",
                                    key: ValueKey("5:53419"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 18.w,
                            height: 18.h,
                            left: 360.w,
                            top: 13.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                                child: Row(
                                  key: ValueKey("5:53420"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 16.w,
                                  children: [
                                    Container(
                                      key: ValueKey("5:53421"),
                                      width: 18.w,
                                      height: 18.h,),
                                  ],),),),),
                        ],),),
                    Positioned(
                      width: 174.09.w,
                      height: 33.h,
                      left: 108.w,
                      top: 118.h,
                      child: Container(
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.88),borderRadius: BorderRadius.circular(18.h),),
                        child: Stack(
                          key: ValueKey("5:53422"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 144.w,
                              height: 17.h,
                              left: 16.w,
                              top: 7.h,
                              child: Text("长按会话可置顶 / 标记未读",
                                key: ValueKey("5:53423"),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                          ],),),),
                    Positioned(
                      width: 406.w,
                      height: 104.h,
                      left: 0.w,
                      top: 748.h,
                      child: Image(
                        key: ValueKey("5:53424"),
                        image: AssetImage("assets/divtabwrap.png"),),),
                    CustomWidget_5_53446(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

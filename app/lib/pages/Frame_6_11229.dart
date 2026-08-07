import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11231.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11245.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11355.dart';

class Frame_6_11229 extends StatefulWidget {

  Frame_6_11229({super.key,});
  @override
  State<Frame_6_11229> createState() => _Frame_6_11229State();
}

class _Frame_6_11229State extends State<Frame_6_11229> {
  late final ImageProvider _image_qlxv6_11247 = MemoryImage(imageStr_amrx6_11247.decodeBase64Image());
  late final ImageProvider _image_pssn6_11249 = MemoryImage(imageStr_kubb6_11249.decodeBase64Image());
  late final ImageProvider _image_adgg6_11292 = MemoryImage(imageStr_ogeg6_11292.decodeBase64Image());
  late final ImageProvider _image_bwtr6_11296 = MemoryImage(imageStr_zszw6_11296.decodeBase64Image());
  late final ImageProvider _image_irpe6_11311 = MemoryImage(imageStr_sjbs6_11311.decodeBase64Image());
  late final ImageProvider _image_cnuj6_11315 = MemoryImage(imageStr_czgo6_11315.decodeBase64Image());
  late final ImageProvider _image_fgji6_11319 = MemoryImage(imageStr_dctg6_11319.decodeBase64Image());
  late final ImageProvider _image_okww6_11323 = MemoryImage(imageStr_xstk6_11323.decodeBase64Image());
  late final ImageProvider _image_xdot6_11362 = MemoryImage(imageStr_ktie6_11362.decodeBase64Image());
  late final ImageProvider _image_wlno6_11373 = MemoryImage(imageStr_iket6_11373.decodeBase64Image());
  late final ImageProvider _image_httm6_11384 = MemoryImage(imageStr_vsge6_11384.decodeBase64Image());
  late final ImageProvider _image_pxxf6_11396 = MemoryImage(imageStr_vapf6_11396.decodeBase64Image());
  late final ImageProvider _image_slrq6_11407 = MemoryImage(imageStr_abao6_11407.decodeBase64Image());

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
                  key: ValueKey("6:11229"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:11230"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_11231(),
                          CustomWidget_6_11245(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:11327"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 440.w,
                                  height: 32.h,
                                  left: 0.w,
                                  top: 9.h,
                                  child: Stack(
                                    key: ValueKey("6:11328"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 47.w,
                                        height: 28.h,
                                        left: 197.w,
                                        top: 1.h,
                                        child: Text("我的",
                                          key: ValueKey("6:11329"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 24.82.w,
                                  height: 25.h,
                                  left: 402.w,
                                  top: 12.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 24.82.w, minHeight: 25.h),
                                      child: Row(
                                        key: ValueKey("6:11330"),
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 16.w,
                                        children: [
                                          Container(
                                            key: ValueKey("6:11331"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                              ],),),
                          Positioned(
                            width: 451.9.w,
                            height: 115.h,
                            left: 0.w,
                            top: 844.h,
                            child: Image(
                              key: ValueKey("6:11332"),
                              image: AssetImage("assets/divtabwrap-profile.png"),),),
                          Positioned(
                            width: 440.w,
                            height: 952.h,
                            left: 0.w,
                            top: 0.h,
                            child: Container(
                              key: ValueKey("6:11354"),
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.35),),),),
                          CustomWidget_6_11355(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10445.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10459.dart';

class Frame_6_10443 extends StatefulWidget {

  Frame_6_10443({super.key,});
  @override
  State<Frame_6_10443> createState() => _Frame_6_10443State();
}

class _Frame_6_10443State extends State<Frame_6_10443> {
  late final ImageProvider _image_mzxj6_10467 = MemoryImage(imageStr_ouze6_10467.decodeBase64Image());
  late final ImageProvider _image_tdmn6_10469 = MemoryImage(imageStr_aest6_10469.decodeBase64Image());
  late final ImageProvider _image_fkxl6_10488 = MemoryImage(imageStr_suwz6_10488.decodeBase64Image());
  late final ImageProvider _image_gkjn6_10490 = MemoryImage(imageStr_skup6_10490.decodeBase64Image());
  late final ImageProvider _image_ryjs6_10509 = MemoryImage(imageStr_xjuz6_10509.decodeBase64Image());
  late final ImageProvider _image_eccj6_10511 = MemoryImage(imageStr_ifxc6_10511.decodeBase64Image());
  late final ImageProvider _image_eulw6_10528 = MemoryImage(imageStr_ciqf6_10528.decodeBase64Image());
  late final ImageProvider _image_nftt6_10530 = MemoryImage(imageStr_ssln6_10530.decodeBase64Image());
  late final ImageProvider _image_vdwx6_10545 = MemoryImage(imageStr_atsg6_10545.decodeBase64Image());
  late final ImageProvider _image_lfck6_10547 = MemoryImage(imageStr_ynto6_10547.decodeBase64Image());

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
                  key: ValueKey("6:10443"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:10444"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_10445(),
                          CustomWidget_6_10459(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:10563"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 440.w,
                                  height: 32.h,
                                  left: 0.w,
                                  top: 9.h,
                                  child: Stack(
                                    key: ValueKey("6:10564"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 47.w,
                                        height: 28.h,
                                        left: 197.w,
                                        top: 1.h,
                                        child: Text("聊天",
                                          key: ValueKey("6:10565"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 20.31.w,
                                  height: 20.h,
                                  left: 406.w,
                                  top: 15.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 20.31.w, minHeight: 20.h),
                                      child: Row(
                                        key: ValueKey("6:10566"),
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 16.w,
                                        children: [
                                          Container(
                                            key: ValueKey("6:10567"),
                                            width: 20.31.w,
                                            height: 20.h,),
                                        ],),),),),
                              ],),),
                          Positioned(
                            width: 451.9.w,
                            height: 115.h,
                            left: 0.w,
                            top: 844.h,
                            child: Image(
                              key: ValueKey("6:10568"),
                              image: AssetImage("assets/divtabwrap-chat.png"),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

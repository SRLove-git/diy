import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11106.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11120.dart';

class Frame_6_11104 extends StatefulWidget {

  Frame_6_11104({super.key,});
  @override
  State<Frame_6_11104> createState() => _Frame_6_11104State();
}

class _Frame_6_11104State extends State<Frame_6_11104> {
  late final ImageProvider _image_htwj6_11122 = MemoryImage(imageStr_smor6_11122.decodeBase64Image());
  late final ImageProvider _image_pvvk6_11124 = MemoryImage(imageStr_jbhv6_11124.decodeBase64Image());
  late final ImageProvider _image_plbt6_11167 = MemoryImage(imageStr_kyud6_11167.decodeBase64Image());
  late final ImageProvider _image_inkf6_11171 = MemoryImage(imageStr_peys6_11171.decodeBase64Image());
  late final ImageProvider _image_ncqy6_11186 = MemoryImage(imageStr_mrws6_11186.decodeBase64Image());
  late final ImageProvider _image_gqxf6_11190 = MemoryImage(imageStr_onqc6_11190.decodeBase64Image());
  late final ImageProvider _image_whwm6_11194 = MemoryImage(imageStr_qzmo6_11194.decodeBase64Image());
  late final ImageProvider _image_izbr6_11198 = MemoryImage(imageStr_qctf6_11198.decodeBase64Image());

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
                  key: ValueKey("6:11104"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:11105"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_11106(),
                          CustomWidget_6_11120(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:11202"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 440.w,
                                  height: 32.h,
                                  left: 0.w,
                                  top: 9.h,
                                  child: Stack(
                                    key: ValueKey("6:11203"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 47.w,
                                        height: 28.h,
                                        left: 197.w,
                                        top: 1.h,
                                        child: Text("我的",
                                          key: ValueKey("6:11204"),
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
                                        key: ValueKey("6:11205"),
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 16.w,
                                        children: [
                                          Container(
                                            key: ValueKey("6:11206"),
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
                              key: ValueKey("6:11207"),
                              image: AssetImage("assets/divtabwrap-profile.png"),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

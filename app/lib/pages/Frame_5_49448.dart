import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49449.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49463.dart';

class Frame_5_49448 extends StatefulWidget {

  Frame_5_49448({super.key,});
  @override
  State<Frame_5_49448> createState() => _Frame_5_49448State();
}

class _Frame_5_49448State extends State<Frame_5_49448> {
  late final ImageProvider _image_tjxa5_49519 = MemoryImage(imageStr_imageStr_kqdu5_49519.decodeBase64Image());

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
                  key: ValueKey("5:49448"),
                  children: [
                    CustomWidget_5_49449(),
                    CustomWidget_5_49463(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:49526"),
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
                                  key: ValueKey("5:49527"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:49528"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:49529"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 70.w,
                                  height: 23.h,
                                  left: 161.w,
                                  top: 0.h,
                                  child: Text("活动专区",
                                    key: ValueKey("5:49530"),
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

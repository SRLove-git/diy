import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50031.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50045.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50111.dart';

class Frame_5_50030 extends StatefulWidget {

  Frame_5_50030({super.key,});
  @override
  State<Frame_5_50030> createState() => _Frame_5_50030State();
}

class _Frame_5_50030State extends State<Frame_5_50030> {
  late final ImageProvider _image_smrf5_50059 = MemoryImage(imageStr_imageStr_fett5_50059.decodeBase64Image());
  late final ImageProvider _image_vaig5_50062 = MemoryImage(imageStr_imageStr_ikic5_50062.decodeBase64Image());
  late final ImageProvider _image_zdea5_50063 = MemoryImage(imageStr_imageStr_siah5_50063.decodeBase64Image());
  late final ImageProvider _image_lipa5_50064 = MemoryImage(imageStr_imageStr_otac5_50064.decodeBase64Image());
  late final ImageProvider _image_vrur5_50065 = MemoryImage(imageStr_imageStr_hvyj5_50065.decodeBase64Image());

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
                  key: ValueKey("5:50030"),
                  children: [
                    CustomWidget_5_50031(),
                    CustomWidget_5_50045(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:50104"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 56.w,
                            height: 40.h,
                            left: 8.w,
                            top: 2.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 56.w, minHeight: 40.h),
                                padding: EdgeInsets.only(left: 12.w,right: 0.w, top: 0.h,bottom: 0.h),
                                child: Row(
                                  key: ValueKey("5:50105"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44.w,
                                      height: 20.h,
                                      child: Text("取消",
                                        key: ValueKey("5:50106"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 22.h,
                            left: 0.w,
                            top: 11.h,
                            child: Stack(
                              key: ValueKey("5:50107"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 50.w,
                                  height: 22.h,
                                  left: 171.w,
                                  top: 0.h,
                                  child: Text("发微博",
                                    key: ValueKey("5:50108"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 54.02.w,
                            height: 32.h,
                            left: 324.w,
                            top: 6.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 54.02.w, minHeight: 32.h),
                                padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                                child: Row(
                                  key: ValueKey("5:50109"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 26.02.w,
                                      height: 18.h,
                                      child: Text("发布",
                                        key: ValueKey("5:50110"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                  ],),),),),
                        ],),),
                    CustomWidget_5_50111(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

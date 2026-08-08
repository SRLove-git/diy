import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9608.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9622.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9688.dart';

class Frame_6_9606 extends StatefulWidget {

  Frame_6_9606({super.key,});
  @override
  State<Frame_6_9606> createState() => _Frame_6_9606State();
}

class _Frame_6_9606State extends State<Frame_6_9606> {
  late final ImageProvider _image_hfyy6_9636 = MemoryImage(imageStr_kxtx6_9636.decodeBase64Image());
  late final ImageProvider _image_odqa6_9639 = MemoryImage(imageStr_jost6_9639.decodeBase64Image());
  late final ImageProvider _image_rjzy6_9640 = MemoryImage(imageStr_drxd6_9640.decodeBase64Image());
  late final ImageProvider _image_bjma6_9641 = MemoryImage(imageStr_vahz6_9641.decodeBase64Image());
  late final ImageProvider _image_qged6_9642 = MemoryImage(imageStr_mozl6_9642.decodeBase64Image());

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
                  key: ValueKey("6:9606"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:9607"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_9608(),
                          CustomWidget_6_9622(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:9681"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 63.18.w,
                                  height: 45.h,
                                  left: 8.w,
                                  top: 2.5.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 63.18.w, minHeight: 45.h),
                                      padding: EdgeInsets.only(left: 10.w,right: 0.w, top: 0.h,bottom: 0.h),
                                      child: Row(
                                        key: ValueKey("6:9682"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 51.18.w,
                                            height: 20.h,
                                            child: Text("取消",
                                              key: ValueKey("6:9683"),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 25.h,
                                  left: 0.w,
                                  top: 12.h,
                                  child: Stack(
                                    key: ValueKey("6:9684"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 56.w,
                                        height: 22.h,
                                        left: 193.w,
                                        top: 1.h,
                                        child: Text("发微博",
                                          key: ValueKey("6:9685"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 60.94.w,
                                  height: 36.h,
                                  left: 366.w,
                                  top: 7.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 60.94.w, minHeight: 36.h),
                                      padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                      decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                                      child: Row(
                                        key: ValueKey("6:9686"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 32.94.w,
                                            height: 18.h,
                                            child: Text("发布",
                                              key: ValueKey("6:9687"),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                        ],),),),),
                              ],),),
                          CustomWidget_6_9688(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/utils/pix_text_rich.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10014.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10079.dart';

class Frame_6_10012 extends StatefulWidget {

  Frame_6_10012({super.key,});
  @override
  State<Frame_6_10012> createState() => _Frame_6_10012State();
}

class _Frame_6_10012State extends State<Frame_6_10012> {
  late final ImageProvider _image_inrt6_10039 = MemoryImage(imageStr_mlpm6_10039.decodeBase64Image());
  late final ImageProvider _image_okql6_10053 = MemoryImage(imageStr_eprg6_10053.decodeBase64Image());
  late final ImageProvider _image_tlqn6_10067 = MemoryImage(imageStr_rvpe6_10067.decodeBase64Image());
  late final ImageProvider _image_nydp6_10079 = MemoryImage(imageStr_tant6_10079.decodeBase64Image());

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
                  key: ValueKey("6:10012"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:10013"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_10014(),
                          CustomWidget_6_10079(),
                          Positioned(
                            width: 440.w,
                            height: 77.h,
                            left: 0.w,
                            top: 875.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 440.w, minHeight: 77.h),
                                padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 1.h,bottom: 0.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),border: Border(top: BorderSide(width: 1.w,color: Color.fromRGBO(239, 239, 239,1),),),),
                                child: Row(
                                  key: ValueKey("6:10107"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 12.w,
                                  children: [
                                    SizedBox(
                                      width: 329.42.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 329.42.w, minHeight: 47.h),
                                          padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 0.h,bottom: 0.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(21.h),),
                                          child: Row(
                                            key: ValueKey("6:10108"),
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 8.w,
                                            children: [
                                              Container(
                                                width: 73.35.w,
                                                height: 21.h,
                                                child: Stack(
                                                  key: ValueKey("6:10109"),
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      width: 75.w,
                                                      height: 18.h,
                                                      left: 0.w,
                                                      top: 1.h,
                                                      child: Text("说点什么…",
                                                        key: ValueKey("6:10110"),
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                  ],),),
                                            ],),),),),
                                    SizedBox(
                                      width: 60.94.w,
                                      child: SingleChildScrollView(
                                        clipBehavior: Clip.none,
                                        physics: NeverScrollableScrollPhysics(),
                                        scrollDirection: Axis.horizontal,
                                        child: Container(
                                          constraints: BoxConstraints(minWidth: 60.94.w, minHeight: 43.h),
                                          padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                          decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                                          child: Row(
                                            key: ValueKey("6:10111"),
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 32.94.w,
                                                height: 18.h,
                                                child: Text("发送",
                                                  key: ValueKey("6:10112"),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),),),
                                  ],),),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

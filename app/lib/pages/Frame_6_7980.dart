import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7982.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_7996.dart';

class Frame_6_7980 extends StatefulWidget {

  Frame_6_7980({super.key,});
  @override
  State<Frame_6_7980> createState() => _Frame_6_7980State();
}

class _Frame_6_7980State extends State<Frame_6_7980> {
  late final ImageProvider _image_ktyn6_8094 = MemoryImage(imageStr_pfrt6_8094.decodeBase64Image());

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
                  key: ValueKey("6:7980"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:7981"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_7982(),
                          CustomWidget_6_7996(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:8097"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 45.13.w,
                                  height: 45.h,
                                  left: 8.w,
                                  top: 2.5.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 45.13.w, minHeight: 45.h),
                                      child: Row(
                                        key: ValueKey("6:8098"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:8099"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:8100"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 79.w,
                                        height: 23.h,
                                        left: 182.w,
                                        top: 1.h,
                                        child: Text("门店详情",
                                          key: ValueKey("6:8101"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                              ],),),
                          Positioned(
                            width: 403.9.w,
                            height: 88.h,
                            left: 18.w,
                            top: 841.h,
                            child: Stack(
                              key: ValueKey("6:8102"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 403.9.w,
                                  height: 29.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 29.h),
                                      padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                      child: Column(
                                        key: ValueKey("6:8103"),
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: 403.9.w,
                                            child: SingleChildScrollView(
                                              clipBehavior: Clip.none,
                                              physics: NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              child: Container(
                                                constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 21.h),
                                                child: Row(
                                                  key: ValueKey("6:8104"),
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 243.25.w,
                                                      height: 21.h,
                                                      child: Stack(
                                                        key: ValueKey("6:8105"),
                                                        clipBehavior: Clip.none,
                                                        children: [
                                                          Positioned(
                                                            width: 245.w,
                                                            height: 18.h,
                                                            left: 0.w,
                                                            top: 1.h,
                                                            child: Text("已选：08-07 周五 15:00-16:30 · 2 人",
                                                              key: ValueKey("6:8106"),
                                                              textAlign: TextAlign.left,
                                                              style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                        ],),),
                                                  ],),),),),
                                        ],),),),),
                                Positioned(
                                  width: 403.9.w,
                                  height: 59.h,
                                  left: 0.w,
                                  top: 30.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 59.h),
                                      decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                                      child: Row(
                                        key: ValueKey("6:8107"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 403.9.w,
                                            height: 22.h,
                                            child: Text("下一步 · 选择桌位",
                                              key: ValueKey("6:8108"),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                        ],),),),),
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

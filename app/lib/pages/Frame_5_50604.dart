import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50605.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50619.dart';

class Frame_5_50604 extends StatefulWidget {

  Frame_5_50604({super.key,});
  @override
  State<Frame_5_50604> createState() => _Frame_5_50604State();
}

class _Frame_5_50604State extends State<Frame_5_50604> {
  late final ImageProvider _image_gmqj5_50622 = MemoryImage(imageStr_imageStr_qqlm5_50622.decodeBase64Image());
  late final ImageProvider _image_hjxz5_50623 = MemoryImage(imageStr_imageStr_gutm5_50623.decodeBase64Image());

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
                  key: ValueKey("5:50604"),
                  children: [
                    CustomWidget_5_50605(),
                    CustomWidget_5_50619(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:50705"),
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
                                  key: ValueKey("5:50706"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:50707"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 22.h,
                            left: 0.w,
                            top: 11.h,
                            child: Stack(
                              key: ValueKey("5:50708"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 66.w,
                                  height: 22.h,
                                  left: 163.w,
                                  top: 0.h,
                                  child: Text("发布视频",
                                    key: ValueKey("5:50709"),
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
                                  key: ValueKey("5:50710"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 26.02.w,
                                      height: 18.h,
                                      child: Text("发布",
                                        key: ValueKey("5:50711"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                  ],),),),),
                        ],),),
                    Positioned(
                      width: 358.w,
                      height: 50.h,
                      left: 16.w,
                      top: 774.h,
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          constraints: BoxConstraints(minWidth: 358.w, minHeight: 50.h),
                          child: Row(
                            key: ValueKey("5:50712"),
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.w,
                            children: [
                              SizedBox(
                                width: 173.w,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 173.w, minHeight: 50.h),
                                    decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                    child: Row(
                                      key: ValueKey("5:50713"),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 173.w,
                                          height: 22.h,
                                          child: Text("存草稿",
                                            key: ValueKey("5:50714"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                      ],),),),),
                              SizedBox(
                                width: 173.w,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 173.w, minHeight: 50.h),
                                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(16.h),),
                                    child: Row(
                                      key: ValueKey("5:50715"),
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 173.w,
                                          height: 22.h,
                                          child: Text("发布",
                                            key: ValueKey("5:50716"),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                      ],),),),),
                            ],),),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

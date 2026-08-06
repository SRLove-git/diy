import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52784.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52805.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52819.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52831.dart';

class Frame_5_52783 extends StatefulWidget {

  Frame_5_52783({super.key,});
  @override
  State<Frame_5_52783> createState() => _Frame_5_52783State();
}

class _Frame_5_52783State extends State<Frame_5_52783> {
  late final ImageProvider _image_lcaq5_52807 = MemoryImage(imageStr_imageStr_fpwi5_52807.decodeBase64Image());
  late final ImageProvider _image_porm5_52815 = MemoryImage(imageStr_imageStr_kgge5_52815.decodeBase64Image());

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
                  key: ValueKey("5:52783"),
                  children: [
                    CustomWidget_5_52784(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:52798"),
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
                                  key: ValueKey("5:52799"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:52800"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:52801"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 53.w,
                                  height: 23.h,
                                  left: 170.w,
                                  top: 0.h,
                                  child: Text("小豆子",
                                    key: ValueKey("5:52802"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 8.w,
                            height: 8.h,
                            left: 370.w,
                            top: 18.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 8.w, minHeight: 8.h),
                                child: Row(
                                  key: ValueKey("5:52803"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 16.w,
                                  children: [
                                    Container(
                                      key: ValueKey("5:52804"),
                                      width: 8.w,
                                      height: 8.h,
                                      decoration: BoxDecoration(color: Color.fromRGBO(52, 199, 89,1),borderRadius: BorderRadius.circular(4.h),),),
                                  ],),),),),
                        ],),),
                    CustomWidget_5_52805(),
                    CustomWidget_5_52819(),
                    Positioned(
                      width: 188.02.w,
                      height: 33.h,
                      left: 101.w,
                      top: 118.h,
                      child: Container(
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.88),borderRadius: BorderRadius.circular(18.h),),
                        child: Stack(
                          key: ValueKey("5:52829"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 158.w,
                              height: 17.h,
                              left: 16.w,
                              top: 7.h,
                              child: Text("长按消息气泡可呼出操作菜单",
                                key: ValueKey("5:52830"),
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                          ],),),),
                    CustomWidget_5_52831(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12807.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12853.dart';

class Frame_6_12805 extends StatefulWidget {

  Frame_6_12805({super.key,});
  @override
  State<Frame_6_12805> createState() => _Frame_6_12805State();
}

class _Frame_6_12805State extends State<Frame_6_12805> {
  late final ImageProvider _image_ctcg6_12856 = MemoryImage(imageStr_uxyi6_12856.decodeBase64Image());

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
                  key: ValueKey("6:12805"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:12806"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_12807(),
                          Positioned(
                            width: 440.w,
                            height: 202.h,
                            left: 0.w,
                            top: 120.h,
                            child: Opacity(
                              opacity: 0.5,
                              child: Stack(
                                key: ValueKey("6:12821"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 403.9.w,
                                    height: 35.h,
                                    left: 18.w,
                                    top: 9.h,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 35.h),
                                        padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                        child: Column(
                                          key: ValueKey("6:12822"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 403.9.w,
                                              height: 27.h,
                                              child: Stack(
                                                key: ValueKey("6:12823"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 85.w,
                                                    height: 23.h,
                                                    left: 0.w,
                                                    top: 1.h,
                                                    child: Text("群成员 12",
                                                      key: ValueKey("6:12824"),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                                ],),),
                                          ],),),),),
                                  Positioned(
                                    width: 403.9.w,
                                    height: 157.h,
                                    left: 18.w,
                                    top: 44.h,
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(),
                                      child: Image(
                                        key: ValueKey("6:12825"),
                                        image: AssetImage("assets/divcardcardpad0.png"),),),),
                                ],),),),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:12847"),
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
                                        key: ValueKey("6:12848"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:12849"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:12850"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 79.w,
                                        height: 23.h,
                                        left: 182.w,
                                        top: 1.h,
                                        child: Text("群聊设置",
                                          key: ValueKey("6:12851"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                              ],),),
                          Positioned(
                            width: 440.w,
                            height: 952.h,
                            left: 0.w,
                            top: 0.h,
                            child: Container(
                              key: ValueKey("6:12852"),
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.42),),),),
                          CustomWidget_6_12853(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

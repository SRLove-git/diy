import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9817.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9831.dart';

class Frame_6_9815 extends StatefulWidget {

  Frame_6_9815({super.key,});
  @override
  State<Frame_6_9815> createState() => _Frame_6_9815State();
}

class _Frame_6_9815State extends State<Frame_6_9815> {
  late final ImageProvider _image_wztg6_9833 = MemoryImage(imageStr_fyda6_9833.decodeBase64Image());
  late final ImageProvider _image_nlyx6_9835 = MemoryImage(imageStr_hnuu6_9835.decodeBase64Image());

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
                  key: ValueKey("6:9815"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:9816"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_9817(),
                          CustomWidget_6_9831(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:9921"),
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
                                        key: ValueKey("6:9922"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:9923"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:9924"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 60.w,
                                        height: 23.h,
                                        left: 191.w,
                                        top: 1.h,
                                        child: Text("小豆子",
                                          key: ValueKey("6:9925"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 24.82.w,
                                  height: 30.h,
                                  left: 397.w,
                                  top: 10.h,
                                  child: Stack(
                                    key: ValueKey("6:9926"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 24.82.w,
                                        height: 25.h,
                                        left: 0.w,
                                        top: 0.h,
                                        child: Container(
                                          key: ValueKey("6:9927"),),),
                                    ],),),
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

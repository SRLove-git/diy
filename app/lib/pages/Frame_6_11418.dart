import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11420.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11434.dart';

class Frame_6_11418 extends StatefulWidget {

  Frame_6_11418({super.key,});
  @override
  State<Frame_6_11418> createState() => _Frame_6_11418State();
}

class _Frame_6_11418State extends State<Frame_6_11418> {
  late final ImageProvider _image_xdsl6_11450 = MemoryImage(imageStr_hdkq6_11450.decodeBase64Image());
  late final ImageProvider _image_eeee6_11454 = MemoryImage(imageStr_kdgz6_11454.decodeBase64Image());
  late final ImageProvider _image_jhod6_11458 = MemoryImage(imageStr_dwaz6_11458.decodeBase64Image());
  late final ImageProvider _image_yjer6_11462 = MemoryImage(imageStr_ypyt6_11462.decodeBase64Image());
  late final ImageProvider _image_xluy6_11466 = MemoryImage(imageStr_cheb6_11466.decodeBase64Image());
  late final ImageProvider _image_pqlf6_11470 = MemoryImage(imageStr_qbwg6_11470.decodeBase64Image());
  late final ImageProvider _image_peci6_11474 = MemoryImage(imageStr_ggqo6_11474.decodeBase64Image());
  late final ImageProvider _image_ebgn6_11478 = MemoryImage(imageStr_cloy6_11478.decodeBase64Image());
  late final ImageProvider _image_pqkd6_11482 = MemoryImage(imageStr_tevy6_11482.decodeBase64Image());

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
                  key: ValueKey("6:11418"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:11419"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_11420(),
                          CustomWidget_6_11434(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:11489"),
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
                                        key: ValueKey("6:11490"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:11491"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:11492"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 98.w,
                                        height: 23.h,
                                        left: 172.w,
                                        top: 1.h,
                                        child: Text("点赞与收藏",
                                          key: ValueKey("6:11493"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
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

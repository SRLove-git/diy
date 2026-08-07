import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14613.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14634.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14663.dart';

class Frame_6_14611 extends StatefulWidget {

  Frame_6_14611({super.key,});
  @override
  State<Frame_6_14611> createState() => _Frame_6_14611State();
}

class _Frame_6_14611State extends State<Frame_6_14611> {
  late final ImageProvider _image_wxdr6_14636 = MemoryImage(imageStr_ulge6_14636.decodeBase64Image());
  late final ImageProvider _image_hvvq6_14641 = MemoryImage(imageStr_gzfb6_14641.decodeBase64Image());
  late final ImageProvider _image_ygpt6_14657 = MemoryImage(imageStr_amjy6_14657.decodeBase64Image());
  late final ImageProvider _image_kxct6_14658 = MemoryImage(imageStr_rdpg6_14658.decodeBase64Image());

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
                  key: ValueKey("6:14611"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:14612"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_14613(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:14627"),
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
                                        key: ValueKey("6:14628"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:14629"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:14630"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 60.w,
                                        height: 23.h,
                                        left: 191.w,
                                        top: 1.h,
                                        child: Text("小豆子",
                                          key: ValueKey("6:14631"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 9.03.w,
                                  height: 9.h,
                                  left: 417.w,
                                  top: 20.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 9.03.w, minHeight: 9.h),
                                      child: Row(
                                        key: ValueKey("6:14632"),
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 16.w,
                                        children: [
                                          Container(
                                            key: ValueKey("6:14633"),
                                            width: 9.03.w,
                                            height: 9.h,
                                            decoration: BoxDecoration(color: Color.fromRGBO(52, 199, 89,1),borderRadius: BorderRadius.circular(4.h),),),
                                        ],),),),),
                              ],),),
                          CustomWidget_6_14634(),
                          CustomWidget_6_14663(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

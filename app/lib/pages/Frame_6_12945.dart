import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12947.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12961.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13057.dart';

class Frame_6_12945 extends StatefulWidget {

  Frame_6_12945({super.key,});
  @override
  State<Frame_6_12945> createState() => _Frame_6_12945State();
}

class _Frame_6_12945State extends State<Frame_6_12945> {
  late final ImageProvider _image_ekaz6_12969 = MemoryImage(imageStr_groo6_12969.decodeBase64Image());
  late final ImageProvider _image_xbvv6_12971 = MemoryImage(imageStr_ceiv6_12971.decodeBase64Image());
  late final ImageProvider _image_caxl6_12990 = MemoryImage(imageStr_jvfp6_12990.decodeBase64Image());
  late final ImageProvider _image_wyok6_12992 = MemoryImage(imageStr_puxi6_12992.decodeBase64Image());
  late final ImageProvider _image_cjqb6_13011 = MemoryImage(imageStr_byhs6_13011.decodeBase64Image());
  late final ImageProvider _image_edmz6_13013 = MemoryImage(imageStr_sivx6_13013.decodeBase64Image());

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
                  key: ValueKey("6:12945"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:12946"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_12947(),
                          CustomWidget_6_12961(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:13028"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 440.w,
                                  height: 32.h,
                                  left: 0.w,
                                  top: 9.h,
                                  child: Stack(
                                    key: ValueKey("6:13029"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 47.w,
                                        height: 28.h,
                                        left: 197.w,
                                        top: 1.h,
                                        child: Text("聊天",
                                          key: ValueKey("6:13030"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 20.31.w,
                                  height: 20.h,
                                  left: 406.w,
                                  top: 15.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 20.31.w, minHeight: 20.h),
                                      child: Row(
                                        key: ValueKey("6:13031"),
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 16.w,
                                        children: [
                                          Container(
                                            key: ValueKey("6:13032"),
                                            width: 20.31.w,
                                            height: 20.h,),
                                        ],),),),),
                              ],),),
                          Positioned(
                            width: 174.09.w,
                            height: 33.h,
                            left: 122.w,
                            top: 133.h,
                            child: Container(
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.88),borderRadius: BorderRadius.circular(18.h),),
                              child: Stack(
                                key: ValueKey("6:13033"),
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    width: 162.w,
                                    height: 17.h,
                                    left: 18.w,
                                    top: 9.h,
                                    child: Text("长按会话可置顶 / 标记未读",
                                      key: ValueKey("6:13034"),
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                ],),),),
                          Positioned(
                            width: 451.9.w,
                            height: 115.h,
                            left: 0.w,
                            top: 844.h,
                            child: Image(
                              key: ValueKey("6:13035"),
                              image: AssetImage("assets/divtabwrap-chat.png"),),),
                          CustomWidget_6_13057(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

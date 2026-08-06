import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49724.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_49738.dart';

class Frame_5_49723 extends StatefulWidget {

  Frame_5_49723({super.key,});
  @override
  State<Frame_5_49723> createState() => _Frame_5_49723State();
}

class _Frame_5_49723State extends State<Frame_5_49723> {


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
                  key: ValueKey("5:49723"),
                  children: [
                    CustomWidget_5_49724(),
                    CustomWidget_5_49738(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:49789"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 390.w,
                            height: 28.h,
                            left: 0.w,
                            top: 8.h,
                            child: Stack(
                              key: ValueKey("5:49790"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 42.w,
                                  height: 28.h,
                                  left: 175.w,
                                  top: 0.h,
                                  child: Text("社区",
                                    key: ValueKey("5:49791"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(foreground: Paint()..shader = LinearGradient(begin: Alignment(0,0.5), end: Alignment(1,0.5), colors: [Color.fromRGBO(51, 51, 51,1), Color.fromRGBO(20, 20, 20,1)], stops: [0, 1]).createShader(Rect.fromLTWH(175.w, 0.h, 42.w, 28.h)), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 62.w,
                            height: 22.h,
                            left: 316.w,
                            top: 11.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 62.w, minHeight: 22.h),
                                child: Row(
                                  key: ValueKey("5:49792"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 18.w,
                                  children: [
                                    Container(
                                      key: ValueKey("5:49793"),
                                      width: 22.w,
                                      height: 22.h,),
                                    Container(
                                      key: ValueKey("5:49794"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                        ],),),
                    Positioned(
                      width: 406.w,
                      height: 104.h,
                      left: 0.w,
                      top: 748.h,
                      child: Image(
                        key: ValueKey("5:49795"),
                        image: AssetImage("assets/divtabwrap0.png"),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

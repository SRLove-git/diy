import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9298.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9312.dart';

class Frame_6_9296 extends StatefulWidget {

  Frame_6_9296({super.key,});
  @override
  State<Frame_6_9296> createState() => _Frame_6_9296State();
}

class _Frame_6_9296State extends State<Frame_6_9296> {


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
                  key: ValueKey("6:9296"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:9297"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_9298(),
                          CustomWidget_6_9312(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:9363"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 440.w,
                                  height: 32.h,
                                  left: 0.w,
                                  top: 9.h,
                                  child: Stack(
                                    key: ValueKey("6:9364"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 47.13.w,
                                        height: 28.h,
                                        left: 197.w,
                                        top: 1.h,
                                        child: Text("社区",
                                          key: ValueKey("6:9365"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(foreground: Paint()..shader = LinearGradient(begin: Alignment(0,0.5), end: Alignment(1,0.5), colors: [Color.fromRGBO(51, 51, 51,1), Color.fromRGBO(20, 20, 20,1)], stops: [0, 1]).createShader(Rect.fromLTWH(197.w, 1.h, 47.13.w, 28.h)), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 69.95.w,
                                  height: 25.h,
                                  left: 357.w,
                                  top: 12.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 69.95.w, minHeight: 25.h),
                                      child: Row(
                                        key: ValueKey("6:9366"),
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        spacing: 18.w,
                                        children: [
                                          Container(
                                            key: ValueKey("6:9367"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                          Container(
                                            key: ValueKey("6:9368"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                              ],),),
                          Positioned(
                            width: 451.9.w,
                            height: 115.h,
                            left: 0.w,
                            top: 844.h,
                            child: Image(
                              key: ValueKey("6:9369"),
                              image: AssetImage("assets/divtabwrap-community.png"),),),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

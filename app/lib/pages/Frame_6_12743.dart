import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12745.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_12793.dart';

class Frame_6_12743 extends StatefulWidget {

  Frame_6_12743({super.key,});
  @override
  State<Frame_6_12743> createState() => _Frame_6_12743State();
}

class _Frame_6_12743State extends State<Frame_6_12743> {


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
                  key: ValueKey("6:12743"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:12744"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_12745(),
                          Positioned(
                            width: 440.w,
                            height: 278.h,
                            left: 0.w,
                            top: 120.h,
                            child: Opacity(
                              opacity: 0.5,
                              child: Stack(
                                key: ValueKey("6:12759"),
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
                                          key: ValueKey("6:12760"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 403.9.w,
                                              height: 27.h,
                                              child: Stack(
                                                key: ValueKey("6:12761"),
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Positioned(
                                                    width: 97.w,
                                                    height: 23.h,
                                                    left: 0.w,
                                                    top: 1.h,
                                                    child: Text("账号与安全",
                                                      key: ValueKey("6:12762"),
                                                      textAlign: TextAlign.left,
                                                      style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                                ],),),
                                          ],),),),),
                                  Positioned(
                                    width: 403.9.w,
                                    height: 233.h,
                                    left: 18.w,
                                    top: 44.h,
                                    child: Container(
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(),
                                      child: Image(
                                        key: ValueKey("6:12763"),
                                        image: AssetImage("assets/divcardcardpad.png"),),),),
                                ],),),),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:12787"),
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
                                        key: ValueKey("6:12788"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:12789"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:12790"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 40.w,
                                        height: 23.h,
                                        left: 201.w,
                                        top: 1.h,
                                        child: Text("设置",
                                          key: ValueKey("6:12791"),
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
                              key: ValueKey("6:12792"),
                              decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.42),),),),
                          CustomWidget_6_12793(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

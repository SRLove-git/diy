import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53137.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53185.dart';

class Frame_5_53136 extends StatefulWidget {

  Frame_5_53136({super.key,});
  @override
  State<Frame_5_53136> createState() => _Frame_5_53136State();
}

class _Frame_5_53136State extends State<Frame_5_53136> {


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
                  key: ValueKey("5:53136"),
                  children: [
                    CustomWidget_5_53137(),
                    Positioned(
                      width: 390.w,
                      height: 247.h,
                      left: 0.w,
                      top: 106.h,
                      child: Opacity(
                        opacity: 0.5,
                        child: Stack(
                          key: ValueKey("5:53151"),
                          clipBehavior: Clip.none,
                          children: [
                            Positioned(
                              width: 358.w,
                              height: 32.h,
                              left: 16.w,
                              top: 8.h,
                              child: SingleChildScrollView(
                                clipBehavior: Clip.none,
                                physics: NeverScrollableScrollPhysics(),
                                child: Container(
                                  constraints: BoxConstraints(minWidth: 358.w, minHeight: 32.h),
                                  padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 8.h),
                                  child: Column(
                                    key: ValueKey("5:53152"),
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 358.w,
                                        height: 24.h,
                                        child: Stack(
                                          key: ValueKey("5:53153"),
                                          clipBehavior: Clip.none,
                                          children: [
                                            Positioned(
                                              width: 86.w,
                                              height: 23.h,
                                              left: 0.w,
                                              top: 0.h,
                                              child: Text("账号与安全",
                                                key: ValueKey("5:53154"),
                                                textAlign: TextAlign.left,
                                                style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                          ],),),
                                    ],),),),),
                            Positioned(
                              width: 358.w,
                              height: 207.h,
                              left: 16.w,
                              top: 40.h,
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(),
                                child: Image(
                                  key: ValueKey("5:53155"),
                                  image: AssetImage("assets/divcardcardpad.png"),),),),
                          ],),),),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:53179"),
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
                                  key: ValueKey("5:53180"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:53181"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:53182"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 36.w,
                                  height: 23.h,
                                  left: 178.w,
                                  top: 0.h,
                                  child: Text("设置",
                                    key: ValueKey("5:53183"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                        ],),),
                    Positioned(
                      width: 390.w,
                      height: 844.h,
                      left: 0.w,
                      top: 0.h,
                      child: Container(
                        key: ValueKey("5:53184"),
                        decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,0.42),),),),
                    CustomWidget_5_53185(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_9104.dart';

class Frame_6_9102 extends StatefulWidget {

  Frame_6_9102({super.key,});
  @override
  State<Frame_6_9102> createState() => _Frame_6_9102State();
}

class _Frame_6_9102State extends State<Frame_6_9102> {


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
                  key: ValueKey("6:9102"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:9103"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_9104(),
                          Positioned(
                            width: 440.w,
                            height: 660.h,
                            left: 0.w,
                            top: 120.h,
                            child: Stack(
                              key: ValueKey("6:9118"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 403.9.w,
                                  height: 35.h,
                                  left: 18.w,
                                  top: 9.h,
                                  child: Stack(
                                    key: ValueKey("6:9119"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 74.75.w,
                                        height: 14.h,
                                        left: 166.w,
                                        top: 13.h,
                                        child: Text("· 接上一页 ·",
                                          key: ValueKey("6:9120"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 403.9.w,
                                  height: 277.h,
                                  left: 18.w,
                                  top: 44.h,
                                  child: Image(
                                    key: ValueKey("6:9121"),
                                    image: AssetImage("assets/margin_wrapper154.png"),),),
                                Positioned(
                                  width: 403.9.w,
                                  height: 277.h,
                                  left: 18.w,
                                  top: 322.h,
                                  child: Image(
                                    key: ValueKey("6:9143"),
                                    image: AssetImage("assets/margin_wrapper157.png"),),),
                                Positioned(
                                  width: 403.9.w,
                                  height: 59.h,
                                  left: 18.w,
                                  top: 601.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 59.h),
                                      decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                                      child: Row(
                                        key: ValueKey("6:9165"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 403.9.w,
                                            height: 22.h,
                                            child: Text("查看更多活动",
                                              key: ValueKey("6:9166"),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 15.6.sp, height: 1.375, letterSpacing: 0.w),),),
                                        ],),),),),
                              ],),),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:9167"),
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
                                        key: ValueKey("6:9168"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:9169"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:9170"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 79.w,
                                        height: 23.h,
                                        left: 182.w,
                                        top: 1.h,
                                        child: Text("活动专区",
                                          key: ValueKey("6:9171"),
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

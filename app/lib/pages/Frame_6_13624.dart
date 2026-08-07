import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13626.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13640.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13689.dart';

class Frame_6_13624 extends StatefulWidget {

  Frame_6_13624({super.key,});
  @override
  State<Frame_6_13624> createState() => _Frame_6_13624State();
}

class _Frame_6_13624State extends State<Frame_6_13624> {


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
                  key: ValueKey("6:13624"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:13625"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_13626(),
                          CustomWidget_6_13640(),
                          CustomWidget_6_13689(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

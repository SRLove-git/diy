import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13074.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13088.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_13173.dart';

class Frame_6_13072 extends StatefulWidget {

  Frame_6_13072({super.key,});
  @override
  State<Frame_6_13072> createState() => _Frame_6_13072State();
}

class _Frame_6_13072State extends State<Frame_6_13072> {


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
                  key: ValueKey("6:13072"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:13073"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_13074(),
                          CustomWidget_6_13088(),
                          CustomWidget_6_13173(),
                        ],),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

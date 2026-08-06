import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53462.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53476.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_53561.dart';

class Frame_5_53461 extends StatefulWidget {

  Frame_5_53461({super.key,});
  @override
  State<Frame_5_53461> createState() => _Frame_5_53461State();
}

class _Frame_5_53461State extends State<Frame_5_53461> {


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
                  key: ValueKey("5:53461"),
                  children: [
                    CustomWidget_5_53462(),
                    CustomWidget_5_53476(),
                    CustomWidget_5_53561(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

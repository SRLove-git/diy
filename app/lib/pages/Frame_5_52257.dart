import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52258.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52272.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_52384.dart';

class Frame_5_52257 extends StatefulWidget {

  Frame_5_52257({super.key,});
  @override
  State<Frame_5_52257> createState() => _Frame_5_52257State();
}

class _Frame_5_52257State extends State<Frame_5_52257> {


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
                  key: ValueKey("5:52257"),
                  children: [
                    CustomWidget_5_52258(),
                    CustomWidget_5_52272(),
                    CustomWidget_5_52384(),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

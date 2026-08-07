import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14581.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14593.dart';

class Frame_6_14574 extends StatefulWidget {

  Frame_6_14574({super.key,});
  @override
  State<Frame_6_14574> createState() => _Frame_6_14574State();
}

class _Frame_6_14574State extends State<Frame_6_14574> {
  late final ImageProvider _image_nulb6_14577 = MemoryImage(imageStr_lakd6_14577.decodeBase64Image());
  late final ImageProvider _image_waiu6_14578 = MemoryImage(imageStr_svgm6_14578.decodeBase64Image());
  late final ImageProvider _image_nhzk6_14593 = MemoryImage(imageStr_rdck6_14593.decodeBase64Image());

  @override
  void initState() {
    super.initState();
  
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil().rootSize = Size(956, 440);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: Container(
            width: 956.w,
            height: 440.h,
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              key: ValueKey("6:14574"),
              children: [
                Positioned(
                  width: 956.w,
                  height: 440.h,
                  left: 0.w,
                  top: 0.h,
                  child: Stack(
                    key: ValueKey("6:14575"),
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        width: 956.w,
                        height: 440.h,
                        left: 0.w,
                        top: 0.h,
                        child: Container(
                          decoration: BoxDecoration(color: Color.fromRGBO(13, 13, 15,1),),
                          child: Stack(
                            key: ValueKey("6:14576"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 956.w,
                                height: 440.h,
                                left: 0.w,
                                top: 0.h,
                                child: Container(
                                  decoration: BoxDecoration(image: DecorationImage(image: _image_nulb6_14577, fit: BoxFit.fill),),
                                  clipBehavior: Clip.hardEdge,
                                  child: Stack(
                                    key: ValueKey("6:14577"),
                                    children: [
                                      Positioned(
                                        width: 956.w,
                                        height: 440.h,
                                        left: 0.w,
                                        top: 0.h,
                                        child: Container(
                                          key: ValueKey("6:14578"),
                                          decoration: BoxDecoration(image: DecorationImage(image: _image_waiu6_14578, fit: BoxFit.fill),),),),
                                      Positioned(
                                        width: 52.w,
                                        height: 52.h,
                                        left: 449.w,
                                        top: 191.h,
                                        child: Container(
                                          decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.92),borderRadius: BorderRadius.circular(26.h),),
                                          child: Stack(
                                            key: ValueKey("6:14579"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 24.92.w,
                                                height: 25.h,
                                                left: 7.w,
                                                top: 4.h,
                                                child: Container(
                                                  key: ValueKey("6:14580"),
                                                  decoration: BoxDecoration(border: Border(left: BorderSide(width: 11.w,color: Color.fromRGBO(20, 20, 20,1),),bottom: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),top: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),),),),),
                                            ],),),),
                                    ],),),),
                              CustomWidget_6_14581(),
                              CustomWidget_6_14593(),
                            ],),),),
                    ],),),
              ],),),
      ),
      
      
    );
  }
}

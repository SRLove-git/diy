import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54949.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54961.dart';

class Frame_5_54943 extends StatefulWidget {

  Frame_5_54943({super.key,});
  @override
  State<Frame_5_54943> createState() => _Frame_5_54943State();
}

class _Frame_5_54943State extends State<Frame_5_54943> {
  late final ImageProvider _image_zwyz5_54945 = MemoryImage(imageStr_imageStr_npsk5_54945.decodeBase64Image());
  late final ImageProvider _image_nntq5_54946 = MemoryImage(imageStr_imageStr_odev5_54946.decodeBase64Image());
  late final ImageProvider _image_qolh5_54961 = MemoryImage(imageStr_imageStr_jmel5_54961.decodeBase64Image());

  @override
  void initState() {
    super.initState();
  
  }


  @override
  Widget build(BuildContext context) {
    ScreenUtil().rootSize = Size(844, 390);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: Container(
            width: 844.w,
            height: 390.h,
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              key: ValueKey("5:54943"),
              children: [
                Positioned(
                  width: 844.w,
                  height: 390.h,
                  left: 0.w,
                  top: 0.h,
                  child: Container(
                    decoration: BoxDecoration(color: Color.fromRGBO(13, 13, 15,1),),
                    child: Stack(
                      key: ValueKey("5:54944"),
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          width: 844.w,
                          height: 390.h,
                          left: 0.w,
                          top: 0.h,
                          child: Container(
                            decoration: BoxDecoration(image: DecorationImage(image: _image_zwyz5_54945, fit: BoxFit.fill),),
                            clipBehavior: Clip.hardEdge,
                            child: Stack(
                              key: ValueKey("5:54945"),
                              children: [
                                Positioned(
                                  width: 844.w,
                                  height: 390.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Container(
                                    key: ValueKey("5:54946"),
                                    decoration: BoxDecoration(image: DecorationImage(image: _image_nntq5_54946, fit: BoxFit.fill),),),),
                                Positioned(
                                  width: 52.w,
                                  height: 52.h,
                                  left: 396.w,
                                  top: 169.h,
                                  child: Container(
                                    decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.92),borderRadius: BorderRadius.circular(26.h),),
                                    child: Stack(
                                      key: ValueKey("5:54947"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 22.w,
                                          height: 22.h,
                                          left: 7.w,
                                          top: 4.h,
                                          child: Container(
                                            key: ValueKey("5:54948"),
                                            decoration: BoxDecoration(border: Border(left: BorderSide(width: 11.w,color: Color.fromRGBO(20, 20, 20,1),),bottom: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),top: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),),),),),
                                      ],),),),
                              ],),),),
                        CustomWidget_5_54949(),
                        CustomWidget_5_54961(),
                      ],),),),
              ],),),
      ),
      
      
    );
  }
}

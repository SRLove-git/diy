import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51131.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/utils/pix_dashed_border.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51145.dart';

class Frame_5_51130 extends StatefulWidget {

  Frame_5_51130({super.key,});
  @override
  State<Frame_5_51130> createState() => _Frame_5_51130State();
}

class _Frame_5_51130State extends State<Frame_5_51130> {
  late final ImageProvider _image_jhyb5_51147 = MemoryImage(imageStr_imageStr_cbmj5_51147.decodeBase64Image());
  late final ImageProvider _image_vkdw5_51149 = MemoryImage(imageStr_imageStr_jxua5_51149.decodeBase64Image());
  late final ImageProvider _image_rxrz5_51165 = MemoryImage(imageStr_imageStr_kysr5_51165.decodeBase64Image());
  late final ImageProvider _image_qubm5_51167 = MemoryImage(imageStr_imageStr_ypll5_51167.decodeBase64Image());
  late final ImageProvider _image_wzhk5_51172 = MemoryImage(imageStr_imageStr_srmu5_51172.decodeBase64Image());
  late final ImageProvider _image_xgsa5_51175 = MemoryImage(imageStr_imageStr_qske5_51175.decodeBase64Image());
  late final ImageProvider _image_lwmt5_51177 = MemoryImage(imageStr_imageStr_tylq5_51177.decodeBase64Image());
  late final ImageProvider _image_rcri5_51185 = MemoryImage(imageStr_imageStr_xlpe5_51185.decodeBase64Image());
  late final ImageProvider _image_gasf5_51187 = MemoryImage(imageStr_imageStr_fkga5_51187.decodeBase64Image());
  late final ImageProvider _image_vozn5_51193 = MemoryImage(imageStr_imageStr_ozmr5_51193.decodeBase64Image());
  late final ImageProvider _image_wpdn5_51195 = MemoryImage(imageStr_imageStr_cfxr5_51195.decodeBase64Image());
  late final ImageProvider _image_fbma5_51201 = MemoryImage(imageStr_imageStr_uuxx5_51201.decodeBase64Image());
  late final ImageProvider _image_tsju5_51203 = MemoryImage(imageStr_imageStr_kidj5_51203.decodeBase64Image());

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
                  key: ValueKey("5:51130"),
                  children: [
                    CustomWidget_5_51131(),
                    CustomWidget_5_51145(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:51239"),
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
                                  key: ValueKey("5:51240"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:51241"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:51242"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 70.w,
                                  height: 23.h,
                                  left: 161.w,
                                  top: 0.h,
                                  child: Text("群聊设置",
                                    key: ValueKey("5:51243"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 22.w,
                            height: 27.h,
                            left: 352.w,
                            top: 9.h,
                            child: Stack(
                              key: ValueKey("5:51244"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 22.w,
                                  height: 22.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Container(
                                    key: ValueKey("5:51245"),),),
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

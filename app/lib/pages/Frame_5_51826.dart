import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51827.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51841.dart';

class Frame_5_51826 extends StatefulWidget {

  Frame_5_51826({super.key,});
  @override
  State<Frame_5_51826> createState() => _Frame_5_51826State();
}

class _Frame_5_51826State extends State<Frame_5_51826> {
  late final ImageProvider _image_rbzq5_51857 = MemoryImage(imageStr_imageStr_bfre5_51857.decodeBase64Image());
  late final ImageProvider _image_hftx5_51861 = MemoryImage(imageStr_imageStr_qwfh5_51861.decodeBase64Image());
  late final ImageProvider _image_vrzs5_51865 = MemoryImage(imageStr_imageStr_iwzr5_51865.decodeBase64Image());
  late final ImageProvider _image_ukrf5_51869 = MemoryImage(imageStr_imageStr_iboq5_51869.decodeBase64Image());
  late final ImageProvider _image_glks5_51873 = MemoryImage(imageStr_imageStr_hmzm5_51873.decodeBase64Image());
  late final ImageProvider _image_tolk5_51877 = MemoryImage(imageStr_imageStr_axyu5_51877.decodeBase64Image());
  late final ImageProvider _image_fsgc5_51881 = MemoryImage(imageStr_imageStr_lnce5_51881.decodeBase64Image());
  late final ImageProvider _image_azth5_51885 = MemoryImage(imageStr_imageStr_jwjs5_51885.decodeBase64Image());
  late final ImageProvider _image_gssy5_51889 = MemoryImage(imageStr_imageStr_allh5_51889.decodeBase64Image());

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
                  key: ValueKey("5:51826"),
                  children: [
                    CustomWidget_5_51827(),
                    CustomWidget_5_51841(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:51896"),
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
                                  key: ValueKey("5:51897"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:51898"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                          Positioned(
                            width: 390.w,
                            height: 24.h,
                            left: 0.w,
                            top: 10.h,
                            child: Stack(
                              key: ValueKey("5:51899"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 87.w,
                                  height: 23.h,
                                  left: 153.w,
                                  top: 0.h,
                                  child: Text("点赞与收藏",
                                    key: ValueKey("5:51900"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
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

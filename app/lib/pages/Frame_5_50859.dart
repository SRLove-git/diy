import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50860.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50874.dart';

class Frame_5_50859 extends StatefulWidget {

  Frame_5_50859({super.key,});
  @override
  State<Frame_5_50859> createState() => _Frame_5_50859State();
}

class _Frame_5_50859State extends State<Frame_5_50859> {
  late final ImageProvider _image_ibou5_50882 = MemoryImage(imageStr_imageStr_faht5_50882.decodeBase64Image());
  late final ImageProvider _image_jxms5_50884 = MemoryImage(imageStr_imageStr_xyvk5_50884.decodeBase64Image());
  late final ImageProvider _image_wdym5_50903 = MemoryImage(imageStr_imageStr_zqmq5_50903.decodeBase64Image());
  late final ImageProvider _image_khdu5_50905 = MemoryImage(imageStr_imageStr_dyij5_50905.decodeBase64Image());
  late final ImageProvider _image_zhdw5_50924 = MemoryImage(imageStr_imageStr_soop5_50924.decodeBase64Image());
  late final ImageProvider _image_abqh5_50926 = MemoryImage(imageStr_imageStr_lwef5_50926.decodeBase64Image());
  late final ImageProvider _image_xfmt5_50943 = MemoryImage(imageStr_imageStr_orzy5_50943.decodeBase64Image());
  late final ImageProvider _image_qbee5_50945 = MemoryImage(imageStr_imageStr_ufdi5_50945.decodeBase64Image());
  late final ImageProvider _image_nqop5_50960 = MemoryImage(imageStr_imageStr_cswr5_50960.decodeBase64Image());
  late final ImageProvider _image_txns5_50962 = MemoryImage(imageStr_imageStr_imbj5_50962.decodeBase64Image());

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
                  key: ValueKey("5:50859"),
                  children: [
                    CustomWidget_5_50860(),
                    CustomWidget_5_50874(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:50978"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 390.w,
                            height: 28.h,
                            left: 0.w,
                            top: 8.h,
                            child: Stack(
                              key: ValueKey("5:50979"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 42.w,
                                  height: 28.h,
                                  left: 175.w,
                                  top: 0.h,
                                  child: Text("聊天",
                                    key: ValueKey("5:50980"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 18.w,
                            height: 18.h,
                            left: 360.w,
                            top: 13.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.h),
                                child: Row(
                                  key: ValueKey("5:50981"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 16.w,
                                  children: [
                                    Container(
                                      key: ValueKey("5:50982"),
                                      width: 18.w,
                                      height: 18.h,),
                                  ],),),),),
                        ],),),
                    Positioned(
                      width: 406.w,
                      height: 104.h,
                      left: 0.w,
                      top: 748.h,
                      child: Image(
                        key: ValueKey("5:50983"),
                        image: AssetImage("assets/divtabwrap.png"),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

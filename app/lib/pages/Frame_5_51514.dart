import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51515.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_51529.dart';

class Frame_5_51514 extends StatefulWidget {

  Frame_5_51514({super.key,});
  @override
  State<Frame_5_51514> createState() => _Frame_5_51514State();
}

class _Frame_5_51514State extends State<Frame_5_51514> {
  late final ImageProvider _image_enrn5_51531 = MemoryImage(imageStr_imageStr_abuz5_51531.decodeBase64Image());
  late final ImageProvider _image_dyqd5_51533 = MemoryImage(imageStr_imageStr_omsm5_51533.decodeBase64Image());
  late final ImageProvider _image_nutl5_51576 = MemoryImage(imageStr_imageStr_ecdw5_51576.decodeBase64Image());
  late final ImageProvider _image_qjiw5_51580 = MemoryImage(imageStr_imageStr_qobm5_51580.decodeBase64Image());
  late final ImageProvider _image_wter5_51595 = MemoryImage(imageStr_imageStr_nfuu5_51595.decodeBase64Image());
  late final ImageProvider _image_mhgx5_51599 = MemoryImage(imageStr_imageStr_pmnj5_51599.decodeBase64Image());
  late final ImageProvider _image_msry5_51603 = MemoryImage(imageStr_imageStr_sbck5_51603.decodeBase64Image());
  late final ImageProvider _image_qrbq5_51607 = MemoryImage(imageStr_imageStr_rlwx5_51607.decodeBase64Image());

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
                  key: ValueKey("5:51514"),
                  children: [
                    CustomWidget_5_51515(),
                    CustomWidget_5_51529(),
                    Positioned(
                      width: 390.w,
                      height: 44.h,
                      left: 0.w,
                      top: 62.h,
                      child: Stack(
                        key: ValueKey("5:51611"),
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            width: 390.w,
                            height: 28.h,
                            left: 0.w,
                            top: 8.h,
                            child: Stack(
                              key: ValueKey("5:51612"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 42.w,
                                  height: 28.h,
                                  left: 175.w,
                                  top: 0.h,
                                  child: Text("我的",
                                    key: ValueKey("5:51613"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 19.6.sp, height: 1.4, letterSpacing: 0.w),),),
                              ],),),
                          Positioned(
                            width: 22.w,
                            height: 22.h,
                            left: 356.w,
                            top: 11.h,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 22.w, minHeight: 22.h),
                                child: Row(
                                  key: ValueKey("5:51614"),
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 16.w,
                                  children: [
                                    Container(
                                      key: ValueKey("5:51615"),
                                      width: 22.w,
                                      height: 22.h,),
                                  ],),),),),
                        ],),),
                    Positioned(
                      width: 406.w,
                      height: 104.h,
                      left: 0.w,
                      top: 748.h,
                      child: Image(
                        key: ValueKey("5:51616"),
                        image: AssetImage("assets/divtabwrap0.png"),),),
                  ],),),
              ],
            )
          )
        
      ),
      
      
    );
  }
}

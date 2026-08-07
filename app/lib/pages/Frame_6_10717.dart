import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10719.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/utils/pix_dashed_border.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_10733.dart';

class Frame_6_10717 extends StatefulWidget {

  Frame_6_10717({super.key,});
  @override
  State<Frame_6_10717> createState() => _Frame_6_10717State();
}

class _Frame_6_10717State extends State<Frame_6_10717> {
  late final ImageProvider _image_yjiv6_10735 = MemoryImage(imageStr_vmya6_10735.decodeBase64Image());
  late final ImageProvider _image_sgnx6_10737 = MemoryImage(imageStr_pqek6_10737.decodeBase64Image());
  late final ImageProvider _image_tnct6_10753 = MemoryImage(imageStr_vsbm6_10753.decodeBase64Image());
  late final ImageProvider _image_kgtp6_10755 = MemoryImage(imageStr_dgzf6_10755.decodeBase64Image());
  late final ImageProvider _image_irar6_10760 = MemoryImage(imageStr_mfog6_10760.decodeBase64Image());
  late final ImageProvider _image_gzxw6_10763 = MemoryImage(imageStr_enas6_10763.decodeBase64Image());
  late final ImageProvider _image_nbzj6_10765 = MemoryImage(imageStr_pyrt6_10765.decodeBase64Image());
  late final ImageProvider _image_wtsz6_10773 = MemoryImage(imageStr_qegc6_10773.decodeBase64Image());
  late final ImageProvider _image_uybm6_10775 = MemoryImage(imageStr_egii6_10775.decodeBase64Image());
  late final ImageProvider _image_gvdo6_10781 = MemoryImage(imageStr_kuku6_10781.decodeBase64Image());
  late final ImageProvider _image_ikjd6_10783 = MemoryImage(imageStr_gkvo6_10783.decodeBase64Image());
  late final ImageProvider _image_tifl6_10789 = MemoryImage(imageStr_bixl6_10789.decodeBase64Image());
  late final ImageProvider _image_fewf6_10791 = MemoryImage(imageStr_ddac6_10791.decodeBase64Image());

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
                  key: ValueKey("6:10717"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:10718"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_10719(),
                          CustomWidget_6_10733(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:10827"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 45.13.w,
                                  height: 45.h,
                                  left: 8.w,
                                  top: 2.5.h,
                                  child: SingleChildScrollView(
                                    clipBehavior: Clip.none,
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.horizontal,
                                    child: Container(
                                      constraints: BoxConstraints(minWidth: 45.13.w, minHeight: 45.h),
                                      child: Row(
                                        key: ValueKey("6:10828"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:10829"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:10830"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 79.w,
                                        height: 23.h,
                                        left: 182.w,
                                        top: 1.h,
                                        child: Text("群聊设置",
                                          key: ValueKey("6:10831"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
                                    ],),),
                                Positioned(
                                  width: 24.82.w,
                                  height: 30.h,
                                  left: 397.w,
                                  top: 10.h,
                                  child: Stack(
                                    key: ValueKey("6:10832"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 24.82.w,
                                        height: 25.h,
                                        left: 0.w,
                                        top: 0.h,
                                        child: Container(
                                          key: ValueKey("6:10833"),),),
                                    ],),),
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

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11571.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_11585.dart';

class Frame_6_11569 extends StatefulWidget {

  Frame_6_11569({super.key,});
  @override
  State<Frame_6_11569> createState() => _Frame_6_11569State();
}

class _Frame_6_11569State extends State<Frame_6_11569> {
  late final ImageProvider _image_gvgq6_11599 = MemoryImage(imageStr_rqip6_11599.decodeBase64Image());
  late final ImageProvider _image_jgqe6_11603 = MemoryImage(imageStr_desu6_11603.decodeBase64Image());
  late final ImageProvider _image_sajn6_11607 = MemoryImage(imageStr_gyvb6_11607.decodeBase64Image());
  late final ImageProvider _image_zenx6_11611 = MemoryImage(imageStr_cwqg6_11611.decodeBase64Image());
  late final ImageProvider _image_msfw6_11615 = MemoryImage(imageStr_alia6_11615.decodeBase64Image());
  late final ImageProvider _image_xzjh6_11619 = MemoryImage(imageStr_oowl6_11619.decodeBase64Image());
  late final ImageProvider _image_vvtf6_11623 = MemoryImage(imageStr_qhmx6_11623.decodeBase64Image());
  late final ImageProvider _image_zuvn6_11627 = MemoryImage(imageStr_xywo6_11627.decodeBase64Image());
  late final ImageProvider _image_kpwh6_11631 = MemoryImage(imageStr_iztf6_11631.decodeBase64Image());

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
                  key: ValueKey("6:11569"),
                  children: [
                    Positioned(
                      width: 440.w,
                      height: 952.h,
                      left: 0.w,
                      top: 0.h,
                      child: Stack(
                        key: ValueKey("6:11570"),
                        clipBehavior: Clip.none,
                        children: [
                          CustomWidget_6_11571(),
                          CustomWidget_6_11585(),
                          Positioned(
                            width: 440.w,
                            height: 50.h,
                            left: 0.w,
                            top: 70.h,
                            child: Stack(
                              key: ValueKey("6:11638"),
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
                                        key: ValueKey("6:11639"),
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            key: ValueKey("6:11640"),
                                            width: 24.82.w,
                                            height: 25.h,),
                                        ],),),),),
                                Positioned(
                                  width: 440.w,
                                  height: 27.h,
                                  left: 0.w,
                                  top: 11.h,
                                  child: Stack(
                                    key: ValueKey("6:11641"),
                                    clipBehavior: Clip.none,
                                    children: [
                                      Positioned(
                                        width: 79.w,
                                        height: 23.h,
                                        left: 182.w,
                                        top: 1.h,
                                        child: Text("我的内容",
                                          key: ValueKey("6:11642"),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: 0.w),),),
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

import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54949.dart';

class CustomWidget_5_54961 extends StatelessWidget {
 CustomWidget_5_54961({super.key});
    late final ImageProvider _image_zwyz5_54945 = MemoryImage(imageStr_imageStr_npsk5_54945.decodeBase64Image());
  late final ImageProvider _image_nntq5_54946 = MemoryImage(imageStr_imageStr_odev5_54946.decodeBase64Image());
  late final ImageProvider _image_qolh5_54961 = MemoryImage(imageStr_imageStr_jmel5_54961.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 844.w,
          height: 72.h,
          left: 0.w,
          top: 318.h,
          child: Container(
            decoration: BoxDecoration(image: DecorationImage(image: _image_qolh5_54961, fit: BoxFit.fill),),
            child: Stack(
              key: ValueKey("5:54961"),
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  width: 844.w,
                  height: 72.h,
                  left: 0.w,
                  top: 0.h,
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 844.w, minHeight: 72.h),
                      padding: EdgeInsets.only(left: 18.w,right: 18.w, top: 0.h,bottom: 0.h),
                      child: Row(
                        key: ValueKey("5:54962"),
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 12.w,
                        children: [
                          SizedBox(
                            width: 34.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 34.w, minHeight: 34.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.14),borderRadius: BorderRadius.circular(17.h),),
                                child: Row(
                                  key: ValueKey("5:54963"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:54964"),
                                      width: 18.w,
                                      height: 18.h,),
                                  ],),),),),
                          Container(
                            width: 380.w,
                            height: 3.h,
                            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.25),borderRadius: BorderRadius.circular(2.h),),
                            child: Stack(
                              key: ValueKey("5:54965"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 144.39.w,
                                  height: 3.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Container(
                                    key: ValueKey("5:54966"),
                                    decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.45),borderRadius: BorderRadius.circular(2.h),),),),
                                Positioned(
                                  width: 114.w,
                                  height: 3.h,
                                  left: 0.w,
                                  top: 0.h,
                                  child: Container(
                                    key: ValueKey("5:54967"),
                                    decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(2.h),),),),
                                Positioned(
                                  width: 13.w,
                                  height: 13.h,
                                  left: 108.w,
                                  top: -5.h,
                                  child: Container(
                                    key: ValueKey("5:54968"),
                                    decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(6.5.h),boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0,0.4),offset: Offset(0.w, 1.w),blurRadius: 4.w,)],),),),
                              ],),),
                          Container(
                            width: 70.05.w,
                            height: 17.h,
                            child: Stack(
                              key: ValueKey("5:54969"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 72.w,
                                  height: 17.h,
                                  left: 0.w,
                                  top: -1.h,
                                  child: Text("00:24 / 01:30",
                                    key: ValueKey("5:54970"),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                              ],),),
                          Container(
                            width: 34.75.w,
                            height: 19.h,
                            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.14),borderRadius: BorderRadius.circular(8.h),),
                            child: Stack(
                              key: ValueKey("5:54971"),
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  width: 23.w,
                                  height: 15.h,
                                  left: 7.w,
                                  top: 2.h,
                                  child: Text("1.0x",
                                    key: ValueKey("5:54972"),
                                    textAlign: TextAlign.left,
                                    style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                              ],),),
                          SizedBox(
                            width: 30.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 30.w, minHeight: 30.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.14),borderRadius: BorderRadius.circular(15.h),),
                                child: Row(
                                  key: ValueKey("5:54973"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:54974"),
                                      width: 18.w,
                                      height: 18.h,),
                                  ],),),),),
                          SizedBox(
                            width: 30.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 30.w, minHeight: 30.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.14),borderRadius: BorderRadius.circular(15.h),),
                                child: Row(
                                  key: ValueKey("5:54975"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:54976"),
                                      width: 18.w,
                                      height: 18.h,),
                                  ],),),),),
                          SizedBox(
                            width: 30.w,
                            child: SingleChildScrollView(
                              clipBehavior: Clip.none,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                constraints: BoxConstraints(minWidth: 30.w, minHeight: 30.h),
                                decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.14),borderRadius: BorderRadius.circular(15.h),),
                                child: Row(
                                  key: ValueKey("5:54977"),
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      key: ValueKey("5:54978"),
                                      width: 18.w,
                                      height: 18.h,),
                                  ],),),),),
                        ],),),),),
              ],),),);
  }
}

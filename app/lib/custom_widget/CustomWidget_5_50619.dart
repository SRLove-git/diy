import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_50605.dart';
import 'package:diy_ui_app/utils/pix_extensions.dart';
import 'package:diy_ui_app/utils/pix_base64_string.dart';

class CustomWidget_5_50619 extends StatelessWidget {
 CustomWidget_5_50619({super.key});
    late final ImageProvider _image_gmqj5_50622 = MemoryImage(imageStr_imageStr_qqlm5_50622.decodeBase64Image());
  late final ImageProvider _image_hjxz5_50623 = MemoryImage(imageStr_imageStr_gutm5_50623.decodeBase64Image());
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 465.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:50619"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 208.h,
                left: 16.w,
                top: 8.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 208.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:50620"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 358.w,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 196.h),
                              child: Row(
                                key: ValueKey("5:50621"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 12.w,
                                children: [
                                  Container(
                                    width: 118.w,
                                    height: 196.h,
                                    decoration: BoxDecoration(image: DecorationImage(image: _image_gmqj5_50622, fit: BoxFit.fill),borderRadius: BorderRadius.circular(14.h),),
                                    clipBehavior: Clip.hardEdge,
                                    child: Stack(
                                      key: ValueKey("5:50622"),
                                      children: [
                                        Positioned(
                                          width: 118.w,
                                          height: 196.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Container(
                                            key: ValueKey("5:50623"),
                                            decoration: BoxDecoration(image: DecorationImage(image: _image_hjxz5_50623, fit: BoxFit.fill),),),),
                                        Positioned(
                                          width: 38.w,
                                          height: 38.h,
                                          left: 40.w,
                                          top: 79.h,
                                          child: Container(
                                            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,0.92),borderRadius: BorderRadius.circular(19.h),),
                                            child: Stack(
                                              key: ValueKey("5:50624"),
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  width: 18.w,
                                                  height: 18.h,
                                                  left: 7.w,
                                                  top: 4.h,
                                                  child: Container(
                                                    key: ValueKey("5:50625"),
                                                    decoration: BoxDecoration(border: Border(left: BorderSide(width: 11.w,color: Color.fromRGBO(20, 20, 20,1),),bottom: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),top: BorderSide(width: 7.w,color: Color.fromRGBO(20, 20, 20,1),),),),),),
                                              ],),),),
                                        Positioned(
                                          width: 74.38.w,
                                          height: 18.h,
                                          left: 8.w,
                                          top: 170.h,
                                          child: Container(
                                            decoration: BoxDecoration(color: Color.fromRGBO(0, 0, 0,0.45),borderRadius: BorderRadius.circular(8.h),),
                                            child: Stack(
                                              key: ValueKey("5:50626"),
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  width: 60.w,
                                                  height: 14.h,
                                                  left: 8.w,
                                                  top: 2.h,
                                                  child: Text("00:15 / 00:15",
                                                    key: ValueKey("5:50627"),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                              ],),),),
                                      ],),),
                                  Container(
                                    width: 228.w,
                                    height: 114.h,
                                    child: Stack(
                                      key: ValueKey("5:50628"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 228.w,
                                          height: 76.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Container(
                                            decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                                            child: Stack(
                                              key: ValueKey("5:50629"),
                                              clipBehavior: Clip.none,
                                              children: [
                                                Positioned(
                                                  width: 122.02.w,
                                                  height: 21.h,
                                                  left: 16.w,
                                                  top: 14.h,
                                                  child: Text("写一句拍摄心得…",
                                                    key: ValueKey("5:50630"),
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                              ],),),),
                                        Positioned(
                                          width: 228.w,
                                          height: 38.h,
                                          left: 0.w,
                                          top: 76.h,
                                          child: SingleChildScrollView(
                                            clipBehavior: Clip.none,
                                            physics: NeverScrollableScrollPhysics(),
                                            child: Container(
                                              constraints: BoxConstraints(minWidth: 228.w, minHeight: 38.h),
                                              padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 12.h,bottom: 0.h),
                                              child: Column(
                                                key: ValueKey("5:50631"),
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    width: 228.w,
                                                    height: 26.h,
                                                    child: SingleChildScrollView(
                                                      clipBehavior: Clip.none,
                                                      physics: NeverScrollableScrollPhysics(),
                                                      child: Container(
                                                        constraints: BoxConstraints(minWidth: 228.w, minHeight: 26.h),
                                                        child: Wrap(
                                                          key: ValueKey("5:50632"),
                                                          direction: Axis.horizontal,
                                                          alignment: WrapAlignment.start,
                                                          runAlignment: WrapAlignment.center,
                                                          crossAxisAlignment: WrapCrossAlignment.center,
                                                          spacing: 8.w,
                                                          runSpacing: 10.h,
                                                          children: [
                                                            SizedBox(
                                                              width: 48.11.w,
                                                              child: SingleChildScrollView(
                                                                clipBehavior: Clip.none,
                                                                physics: NeverScrollableScrollPhysics(),
                                                                scrollDirection: Axis.horizontal,
                                                                child: Container(
                                                                  constraints: BoxConstraints(minWidth: 48.11.w, minHeight: 26.h),
                                                                  padding: EdgeInsets.only(left: 8.w,right: 8.w, top: 0.h,bottom: 0.h),
                                                                  decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(15.h),),
                                                                  child: Row(
                                                                    key: ValueKey("5:50633"),
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    spacing: 5.w,
                                                                    children: [
                                                                      Container(
                                                                        width: 28.11.w,
                                                                        height: 15.h,
                                                                        child: Text("#拼豆",
                                                                          key: ValueKey("5:50634"),
                                                                          textAlign: TextAlign.left,
                                                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                                                    ],),),),),
                                                            SizedBox(
                                                              width: 70.11.w,
                                                              child: SingleChildScrollView(
                                                                clipBehavior: Clip.none,
                                                                physics: NeverScrollableScrollPhysics(),
                                                                scrollDirection: Axis.horizontal,
                                                                child: Container(
                                                                  constraints: BoxConstraints(minWidth: 70.11.w, minHeight: 26.h),
                                                                  padding: EdgeInsets.only(left: 8.w,right: 8.w, top: 0.h,bottom: 0.h),
                                                                  decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(15.h),),
                                                                  child: Row(
                                                                    key: ValueKey("5:50635"),
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    spacing: 5.w,
                                                                    children: [
                                                                      Container(
                                                                        width: 50.11.w,
                                                                        height: 15.h,
                                                                        child: Text("#手工日常",
                                                                          key: ValueKey("5:50636"),
                                                                          textAlign: TextAlign.left,
                                                                          style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontSize: 10.6.sp, height: 1.3636363636363635, letterSpacing: 0.w),),),
                                                                    ],),),),),
                                                            Container(
                                                              width: 52.58.w,
                                                              height: 26.h,
                                                              child: Image(
                                                                key: ValueKey("5:50637"),
                                                                image: AssetImage("assets/spanchipsm.png"),),),
                                                          ],),),),),
                                                ],),),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 36.h,
                left: 16.w,
                top: 216.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 36.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:50639"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 358.w,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 24.h),
                              child: Row(
                                key: ValueKey("5:50640"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 67.2.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("5:50641"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 69.w,
                                          height: 23.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("视频编辑",
                                            key: ValueKey("5:50642"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 16.6.sp, height: 1.3529411764705883, letterSpacing: -0.2.w),),),
                                      ],),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 165.h,
                left: 16.w,
                top: 300.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 165.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 24.h,bottom: 0.h),
                    child: Column(
                      key: ValueKey("5:50643"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 141.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                          child: Stack(
                            key: ValueKey("5:50644"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 326.w,
                                height: 44.h,
                                left: 16.w,
                                top: 4.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 44.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 12.h,bottom: 12.h),
                                    child: Row(
                                      key: ValueKey("5:50645"),
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 86.w,
                                          child: SingleChildScrollView(
                                            clipBehavior: Clip.none,
                                            physics: NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              constraints: BoxConstraints(minWidth: 86.w, minHeight: 20.h),
                                              child: Row(
                                                key: ValueKey("5:50646"),
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 12.w,
                                                children: [
                                                  Container(
                                                    key: ValueKey("5:50647"),
                                                    width: 18.w,
                                                    height: 18.h,),
                                                  Container(
                                                    width: 56.w,
                                                    height: 20.h,
                                                    child: Stack(
                                                      key: ValueKey("5:50648"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 58.w,
                                                          height: 20.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("添加话题",
                                                            key: ValueKey("5:50649"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                                      ],),),
                                                ],),),),),
                                        Container(
                                          width: 36.14.w,
                                          height: 18.h,
                                          child: Stack(
                                            key: ValueKey("5:50650"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 38.w,
                                                height: 18.h,
                                                left: 0.w,
                                                top: -1.h,
                                                child: Text("+ 添加",
                                                  key: ValueKey("5:50651"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),
                                      ],),),),),
                              Positioned(
                                width: 326.w,
                                height: 1.h,
                                left: 16.w,
                                top: 47.h,
                                child: Container(
                                  key: ValueKey("5:50652"),
                                  decoration: BoxDecoration(color: Color.fromRGBO(239, 239, 239,1),),),),
                              Positioned(
                                width: 326.w,
                                height: 44.h,
                                left: 16.w,
                                top: 48.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 44.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 12.h,bottom: 12.h),
                                    child: Row(
                                      key: ValueKey("5:50653"),
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 56.w,
                                          height: 20.h,
                                          child: Stack(
                                            key: ValueKey("5:50654"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 18.w,
                                                height: 18.h,
                                                left: -35.73.w,
                                                top: -493.73.h,
                                                child: Transform.rotate(
                                                  angle: -0.7853981633974483,
                                                  child: Container(
                                                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.only(topLeft: Radius.circular(50.h), topRight: Radius.circular(50.h),  bottomRight: Radius.circular(50.h),),),
                                                    child: Stack(
                                                      key: ValueKey("5:50655"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 4.w,
                                                          height: 4.h,
                                                          left: 4.w,
                                                          top: 4.h,
                                                          child: Container(
                                                            key: ValueKey("5:50656"),
                                                            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255,1),borderRadius: BorderRadius.circular(2.h),),),),
                                                      ],),),),),
                                              Positioned(
                                                width: 56.w,
                                                height: 20.h,
                                                left: 0.w,
                                                top: 0.h,
                                                child: Stack(
                                                  key: ValueKey("5:50657"),
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      width: 58.w,
                                                      height: 20.h,
                                                      left: 0.w,
                                                      top: 0.h,
                                                      child: Text("所在位置",
                                                        key: ValueKey("5:50658"),
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                                  ],),),
                                            ],),),
                                        Container(
                                          width: 109.83.w,
                                          height: 18.h,
                                          child: Stack(
                                            key: ValueKey("5:50659"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 112.w,
                                                height: 18.h,
                                                left: 0.w,
                                                top: -1.h,
                                                child: Text("上海 · 拾光手作馆",
                                                  key: ValueKey("5:50660"),
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                            ],),),
                                      ],),),),),
                              Positioned(
                                width: 326.w,
                                height: 1.h,
                                left: 16.w,
                                top: 92.h,
                                child: Container(
                                  key: ValueKey("5:50661"),
                                  decoration: BoxDecoration(color: Color.fromRGBO(239, 239, 239,1),),),),
                              Positioned(
                                width: 326.w,
                                height: 44.h,
                                left: 16.w,
                                top: 93.h,
                                child: SingleChildScrollView(
                                  clipBehavior: Clip.none,
                                  physics: NeverScrollableScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    constraints: BoxConstraints(minWidth: 326.w, minHeight: 44.h),
                                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 12.h,bottom: 12.h),
                                    child: Row(
                                      key: ValueKey("5:50662"),
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 56.w,
                                          height: 20.h,
                                          child: Stack(
                                            key: ValueKey("5:50663"),
                                            clipBehavior: Clip.none,
                                            children: [
                                              Positioned(
                                                width: 18.w,
                                                height: 18.h,
                                                left: -30.w,
                                                top: -529.h,
                                                child: Container(
                                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(9.h),border: Border.all(width: 2.w, color: Color.fromRGBO(20, 20, 20,1), ),),
                                                  child: Stack(
                                                    key: ValueKey("5:50664"),
                                                    clipBehavior: Clip.none,
                                                    children: [
                                                      Positioned(
                                                        width: 5.w,
                                                        height: 5.h,
                                                        left: 8.w,
                                                        top: 5.h,
                                                        child: Container(
                                                          key: ValueKey("5:50665"),
                                                          decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(2.5.h),),),),
                                                    ],),),),
                                              Positioned(
                                                width: 56.w,
                                                height: 20.h,
                                                left: 0.w,
                                                top: 0.h,
                                                child: Stack(
                                                  key: ValueKey("5:50666"),
                                                  clipBehavior: Clip.none,
                                                  children: [
                                                    Positioned(
                                                      width: 58.w,
                                                      height: 20.h,
                                                      left: 0.w,
                                                      top: -1.h,
                                                      child: Text("谁可以看",
                                                        key: ValueKey("5:50667"),
                                                        textAlign: TextAlign.left,
                                                        style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 13.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                                  ],),),
                                            ],),),
                                        SizedBox(
                                          width: 52.02.w,
                                          child: SingleChildScrollView(
                                            clipBehavior: Clip.none,
                                            physics: NeverScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            child: Container(
                                              constraints: BoxConstraints(minWidth: 52.02.w, minHeight: 18.h),
                                              child: Row(
                                                key: ValueKey("5:50668"),
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 8.w,
                                                children: [
                                                  Container(
                                                    width: 26.02.w,
                                                    height: 18.h,
                                                    child: Stack(
                                                      key: ValueKey("5:50669"),
                                                      clipBehavior: Clip.none,
                                                      children: [
                                                        Positioned(
                                                          width: 28.w,
                                                          height: 18.h,
                                                          left: 0.w,
                                                          top: -1.h,
                                                          child: Text("公开",
                                                            key: ValueKey("5:50670"),
                                                            textAlign: TextAlign.left,
                                                            style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                      ],),),
                                                  Container(
                                                    key: ValueKey("5:50671"),
                                                    width: 18.w,
                                                    height: 18.h,),
                                                ],),),),),
                                      ],),),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 48.h,
                left: 16.w,
                top: 252.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 48.h),
                    padding: EdgeInsets.only(left: 2.w,right: 2.w, top: 4.h,bottom: 0.h),
                    child: Row(
                      key: ValueKey("5:50672"),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:50673"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 18.w,
                                height: 18.h,
                                left: -3.73.w,
                                top: -5.73.h,
                                child: Transform.rotate(
                                  angle: 0.7853981633974483,
                                  child: Container(
                                    key: ValueKey("5:50674"),
                                    decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(2.h),),),),),
                              Positioned(
                                width: 358.w,
                                height: 14.h,
                                left: -2.w,
                                top: 48.h,
                                child: Stack(
                                  key: ValueKey("5:50675"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 22.w,
                                      height: 14.h,
                                      left: 169.w,
                                      top: -1.h,
                                      child: Text("滤镜",
                                        key: ValueKey("5:50676"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:50677"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 18.w,
                                height: 18.h,
                                left: 13.w,
                                top: 13.h,
                                child: Container(
                                  key: ValueKey("5:50678"),),),
                              Positioned(
                                width: 358.w,
                                height: 14.h,
                                left: -46.w,
                                top: 48.h,
                                child: Stack(
                                  key: ValueKey("5:50679"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 22.w,
                                      height: 14.h,
                                      left: 169.w,
                                      top: -1.h,
                                      child: Text("调节",
                                        key: ValueKey("5:50680"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:50681"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 18.w,
                                height: 18.h,
                                left: 13.w,
                                top: 13.h,
                                child: Container(
                                  key: ValueKey("5:50682"),),),
                              Positioned(
                                width: 358.w,
                                height: 14.h,
                                left: -91.w,
                                top: 48.h,
                                child: Stack(
                                  key: ValueKey("5:50683"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 22.w,
                                      height: 14.h,
                                      left: 169.w,
                                      top: -1.h,
                                      child: Text("速度",
                                        key: ValueKey("5:50684"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:50685"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 18.w,
                                height: 18.h,
                                left: 13.w,
                                top: 13.h,
                                child: Container(
                                  key: ValueKey("5:50686"),),),
                              Positioned(
                                width: 358.w,
                                height: 14.h,
                                left: -135.w,
                                top: 48.h,
                                child: Stack(
                                  key: ValueKey("5:50687"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 22.w,
                                      height: 14.h,
                                      left: 169.w,
                                      top: -1.h,
                                      child: Text("特效",
                                        key: ValueKey("5:50688"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:50689"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 18.w,
                                height: 18.h,
                                left: 13.w,
                                top: 13.h,
                                child: Container(
                                  key: ValueKey("5:50690"),),),
                              Positioned(
                                width: 358.w,
                                height: 14.h,
                                left: -179.w,
                                top: 48.h,
                                child: Stack(
                                  key: ValueKey("5:50691"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 22.w,
                                      height: 14.h,
                                      left: 169.w,
                                      top: -1.h,
                                      child: Text("贴纸",
                                        key: ValueKey("5:50692"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:50693"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 18.w,
                                height: 18.h,
                                left: 13.w,
                                top: 13.h,
                                child: Container(
                                  key: ValueKey("5:50694"),),),
                              Positioned(
                                width: 358.w,
                                height: 14.h,
                                left: -223.w,
                                top: 48.h,
                                child: Stack(
                                  key: ValueKey("5:50695"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 22.w,
                                      height: 14.h,
                                      left: 169.w,
                                      top: -1.h,
                                      child: Text("文字",
                                        key: ValueKey("5:50696"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:50697"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 18.w,
                                height: 18.h,
                                left: 13.w,
                                top: 13.h,
                                child: Container(
                                  key: ValueKey("5:50698"),),),
                              Positioned(
                                width: 358.w,
                                height: 14.h,
                                left: -268.w,
                                top: 48.h,
                                child: Stack(
                                  key: ValueKey("5:50699"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 22.w,
                                      height: 14.h,
                                      left: 169.w,
                                      top: -1.h,
                                      child: Text("音乐",
                                        key: ValueKey("5:50700"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                        Container(
                          width: 44.w,
                          height: 44.h,
                          decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(14.h),),
                          child: Stack(
                            key: ValueKey("5:50701"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 18.w,
                                height: 18.h,
                                left: 13.w,
                                top: 13.h,
                                child: Container(
                                  key: ValueKey("5:50702"),),),
                              Positioned(
                                width: 358.w,
                                height: 14.h,
                                left: -312.w,
                                top: 48.h,
                                child: Stack(
                                  key: ValueKey("5:50703"),
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned(
                                      width: 22.w,
                                      height: 14.h,
                                      left: 169.w,
                                      top: -1.h,
                                      child: Text("裁剪",
                                        key: ValueKey("5:50704"),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                  ],),),
                            ],),),
                      ],),),),),
            ],),);
  }
}

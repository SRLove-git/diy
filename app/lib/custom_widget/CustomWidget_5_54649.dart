import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_5_54635.dart';

class CustomWidget_5_54649 extends StatelessWidget {
 CustomWidget_5_54649({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 390.w,
          height: 509.h,
          left: 0.w,
          top: 106.h,
          child: Stack(
            key: ValueKey("5:54649"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 358.w,
                height: 31.h,
                left: 16.w,
                top: 8.h,
                child: Stack(
                  key: ValueKey("5:54650"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 66.48.w,
                      height: 14.h,
                      left: 147.w,
                      top: 12.h,
                      child: Text("· 接上一页 ·",
                        key: ValueKey("5:54651"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 358.w,
                height: 30.h,
                left: 16.w,
                top: 39.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 30.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:54652"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 358.w,
                          height: 18.h,
                          child: Stack(
                            key: ValueKey("5:54653"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 184.w,
                                height: 18.h,
                                left: 0.w,
                                top: -1.h,
                                child: Text("通知与会话列表无数据时的状态",
                                  key: ValueKey("5:54654"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 226.h,
                left: 16.w,
                top: 69.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 226.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:54655"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 214.h,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            child: Container(
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 214.h),
                              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 28.h,bottom: 28.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                              child: Column(
                                key: ValueKey("5:54656"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8.h,
                                children: [
                                  SizedBox(
                                    width: 56.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 56.w, minHeight: 56.h),
                                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(28.h),),
                                        child: Row(
                                          key: ValueKey("5:54657"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              key: ValueKey("5:54658"),
                                              width: 26.w,
                                              height: 26.h,),
                                          ],),),),),
                                  Container(
                                    width: 75.02.w,
                                    height: 21.h,
                                    child: Stack(
                                      key: ValueKey("5:54659"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 77.w,
                                          height: 21.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("暂无新通知",
                                            key: ValueKey("5:54660"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                      ],),),
                                  Container(
                                    width: 144.02.w,
                                    height: 17.h,
                                    child: Stack(
                                      key: ValueKey("5:54661"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 146.w,
                                          height: 17.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("互动和系统消息都会提醒你",
                                            key: ValueKey("5:54662"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),
                                  SizedBox(
                                    height: 40.h,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 67.02.w, minHeight: 40.h),
                                        padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 6.h,bottom: 0.h),
                                        child: Column(
                                          key: ValueKey("5:54663"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 67.02.w,
                                              child: SingleChildScrollView(
                                                clipBehavior: Clip.none,
                                                physics: NeverScrollableScrollPhysics(),
                                                scrollDirection: Axis.horizontal,
                                                child: Container(
                                                  constraints: BoxConstraints(minWidth: 67.02.w, minHeight: 34.h),
                                                  padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                                  decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                                                  child: Row(
                                                    key: ValueKey("5:54664"),
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 39.02.w,
                                                        height: 18.h,
                                                        child: Text("知道了",
                                                          key: ValueKey("5:54665"),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                    ],),),),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 358.w,
                height: 226.h,
                left: 16.w,
                top: 295.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 358.w, minHeight: 226.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("5:54666"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 214.h,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            child: Container(
                              constraints: BoxConstraints(minWidth: 358.w, minHeight: 214.h),
                              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 28.h,bottom: 28.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                              child: Column(
                                key: ValueKey("5:54667"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8.h,
                                children: [
                                  SizedBox(
                                    width: 56.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 56.w, minHeight: 56.h),
                                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(28.h),),
                                        child: Row(
                                          key: ValueKey("5:54668"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              key: ValueKey("5:54669"),
                                              width: 26.w,
                                              height: 26.h,),
                                          ],),),),),
                                  Container(
                                    width: 75.02.w,
                                    height: 21.h,
                                    child: Stack(
                                      key: ValueKey("5:54670"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 77.w,
                                          height: 21.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("还没有会话",
                                            key: ValueKey("5:54671"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                      ],),),
                                  Container(
                                    width: 108.02.w,
                                    height: 17.h,
                                    child: Stack(
                                      key: ValueKey("5:54672"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 110.w,
                                          height: 17.h,
                                          left: 0.w,
                                          top: -1.h,
                                          child: Text("添加好友开始聊天吧",
                                            key: ValueKey("5:54673"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),
                                  SizedBox(
                                    height: 40.h,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 80.02.w, minHeight: 40.h),
                                        padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 6.h,bottom: 0.h),
                                        child: Column(
                                          key: ValueKey("5:54674"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 80.02.w,
                                              child: SingleChildScrollView(
                                                clipBehavior: Clip.none,
                                                physics: NeverScrollableScrollPhysics(),
                                                scrollDirection: Axis.horizontal,
                                                child: Container(
                                                  constraints: BoxConstraints(minWidth: 80.02.w, minHeight: 34.h),
                                                  padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                                  decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                                                  child: Row(
                                                    key: ValueKey("5:54675"),
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 52.02.w,
                                                        height: 18.h,
                                                        child: Text("添加好友",
                                                          key: ValueKey("5:54676"),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                    ],),),),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
            ],),);
  }
}

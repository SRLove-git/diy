import 'package:flutter/material.dart';
import 'package:diy_ui_app/utils/pix_adapted_screen.dart';
import 'package:diy_ui_app/custom_widget/CustomWidget_6_14261.dart';

class CustomWidget_6_14275 extends StatelessWidget {
 CustomWidget_6_14275({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
          width: 440.w,
          height: 574.h,
          left: 0.w,
          top: 120.h,
          child: Stack(
            key: ValueKey("6:14275"),
            clipBehavior: Clip.none,
            children: [
              Positioned(
                width: 403.9.w,
                height: 35.h,
                left: 18.w,
                top: 9.h,
                child: Stack(
                  key: ValueKey("6:14276"),
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      width: 74.75.w,
                      height: 14.h,
                      left: 166.w,
                      top: 13.h,
                      child: Text("· 接上一页 ·",
                        key: ValueKey("6:14277"),
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 9.6.sp, height: 1.4, letterSpacing: 0.w),),),
                  ],),),
              Positioned(
                width: 403.9.w,
                height: 33.h,
                left: 18.w,
                top: 44.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 33.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("6:14278"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 403.9.w,
                          height: 21.h,
                          child: Stack(
                            key: ValueKey("6:14279"),
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                width: 207.w,
                                height: 18.h,
                                left: 0.w,
                                top: 0.h,
                                child: Text("通知与会话列表无数据时的状态",
                                  key: ValueKey("6:14280"),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Color.fromRGBO(142, 142, 147,1), fontFamily: "Noto Sans SC", fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                            ],),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 253.h,
                left: 18.w,
                top: 78.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 253.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("6:14281"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 241.h,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            child: Container(
                              constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 241.h),
                              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 28.h,bottom: 28.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                              child: Column(
                                key: ValueKey("6:14282"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8.h,
                                children: [
                                  SizedBox(
                                    width: 63.18.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 63.18.w, minHeight: 63.h),
                                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(28.h),),
                                        child: Row(
                                          key: ValueKey("6:14283"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              key: ValueKey("6:14284"),
                                              width: 29.33.w,
                                              height: 29.h,),
                                          ],),),),),
                                  Container(
                                    width: 84.63.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("6:14285"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 87.w,
                                          height: 21.h,
                                          left: 0.w,
                                          top: 2.h,
                                          child: Text("暂无新通知",
                                            key: ValueKey("6:14286"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                      ],),),
                                  Container(
                                    width: 162.48.w,
                                    height: 19.h,
                                    child: Stack(
                                      key: ValueKey("6:14287"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 164.w,
                                          height: 17.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("互动和系统消息都会提醒你",
                                            key: ValueKey("6:14288"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),
                                  SizedBox(
                                    height: 44.h,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 75.61.w, minHeight: 44.h),
                                        padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 6.h,bottom: 0.h),
                                        child: Column(
                                          key: ValueKey("6:14289"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 75.61.w,
                                              child: SingleChildScrollView(
                                                clipBehavior: Clip.none,
                                                physics: NeverScrollableScrollPhysics(),
                                                scrollDirection: Axis.horizontal,
                                                child: Container(
                                                  constraints: BoxConstraints(minWidth: 75.61.w, minHeight: 38.h),
                                                  padding: EdgeInsets.only(left: 12.w,right: 12.w, top: 0.h,bottom: 0.h),
                                                  decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                                                  child: Row(
                                                    key: ValueKey("6:14290"),
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 47.61.w,
                                                        height: 18.h,
                                                        child: Text("知道了",
                                                          key: ValueKey("6:14291"),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                    ],),),),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
              Positioned(
                width: 403.9.w,
                height: 253.h,
                left: 18.w,
                top: 332.h,
                child: SingleChildScrollView(
                  clipBehavior: Clip.none,
                  physics: NeverScrollableScrollPhysics(),
                  child: Container(
                    constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 253.h),
                    padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 0.h,bottom: 12.h),
                    child: Column(
                      key: ValueKey("6:14292"),
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 241.h,
                          child: SingleChildScrollView(
                            clipBehavior: Clip.none,
                            physics: NeverScrollableScrollPhysics(),
                            child: Container(
                              constraints: BoxConstraints(minWidth: 403.9.w, minHeight: 241.h),
                              padding: EdgeInsets.only(left: 16.w,right: 16.w, top: 28.h,bottom: 28.h),
                              decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(16.h),),
                              child: Column(
                                key: ValueKey("6:14293"),
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8.h,
                                children: [
                                  SizedBox(
                                    width: 63.18.w,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.horizontal,
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 63.18.w, minHeight: 63.h),
                                        decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 248,1),borderRadius: BorderRadius.circular(28.h),),
                                        child: Row(
                                          key: ValueKey("6:14294"),
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Container(
                                              key: ValueKey("6:14295"),
                                              width: 29.33.w,
                                              height: 29.h,),
                                          ],),),),),
                                  Container(
                                    width: 84.63.w,
                                    height: 24.h,
                                    child: Stack(
                                      key: ValueKey("6:14296"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 87.w,
                                          height: 21.h,
                                          left: 0.w,
                                          top: 2.h,
                                          child: Text("还没有会话",
                                            key: ValueKey("6:14297"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(20, 20, 20,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 14.6.sp, height: 1.4, letterSpacing: 0.w),),),
                                      ],),),
                                  Container(
                                    width: 121.86.w,
                                    height: 19.h,
                                    child: Stack(
                                      key: ValueKey("6:14298"),
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          width: 124.w,
                                          height: 17.h,
                                          left: 0.w,
                                          top: 0.h,
                                          child: Text("添加好友开始聊天吧",
                                            key: ValueKey("6:14299"),
                                            textAlign: TextAlign.left,
                                            style: TextStyle(color: Color.fromRGBO(199, 199, 204,1), fontFamily: "Noto Sans SC", fontSize: 11.6.sp, height: 1.4000000000000001, letterSpacing: 0.w),),),
                                      ],),),
                                  SizedBox(
                                    height: 44.h,
                                    child: SingleChildScrollView(
                                      clipBehavior: Clip.none,
                                      physics: NeverScrollableScrollPhysics(),
                                      child: Container(
                                        constraints: BoxConstraints(minWidth: 90.27.w, minHeight: 44.h),
                                        padding: EdgeInsets.only(left: 0.w,right: 0.w, top: 6.h,bottom: 0.h),
                                        child: Column(
                                          key: ValueKey("6:14300"),
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 90.27.w,
                                              child: SingleChildScrollView(
                                                clipBehavior: Clip.none,
                                                physics: NeverScrollableScrollPhysics(),
                                                scrollDirection: Axis.horizontal,
                                                child: Container(
                                                  constraints: BoxConstraints(minWidth: 90.27.w, minHeight: 38.h),
                                                  padding: EdgeInsets.only(left: 14.w,right: 14.w, top: 0.h,bottom: 0.h),
                                                  decoration: BoxDecoration(color: Color.fromRGBO(20, 20, 20,1),borderRadius: BorderRadius.circular(18.h),),
                                                  child: Row(
                                                    key: ValueKey("6:14301"),
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Container(
                                                        width: 62.27.w,
                                                        height: 18.h,
                                                        child: Text("添加好友",
                                                          key: ValueKey("6:14302"),
                                                          textAlign: TextAlign.center,
                                                          style: TextStyle(color: Color.fromRGBO(255, 255, 255,1), fontFamily: "Noto Sans SC", fontWeight: FontWeight.bold, fontSize: 12.6.sp, height: 1.3846153846153846, letterSpacing: 0.w),),),
                                                    ],),),),),
                                          ],),),),),
                                ],),),),),
                      ],),),),),
            ],),);
  }
}

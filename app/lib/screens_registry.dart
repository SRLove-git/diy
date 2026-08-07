// GENERATED - 手作星球 82 屏注册表
import 'package:flutter/widgets.dart';
import 'live/screens/activity_screens.dart';
import 'live/screens/appointment_screens.dart';
import 'live/screens/auth_screens.dart';
import 'live/screens/chat_screens.dart';
import 'live/screens/community_screens.dart';
import 'live/screens/home_screen.dart';
import 'live/screens/member_screens.dart';
import 'live/screens/notifications_screen.dart';
import 'live/screens/post_screens.dart';
import 'live/screens/profile_screens.dart';
import 'live/screens/store_screens.dart';
import 'live/screens/video_screens.dart';
import 'pages/Frame_6_7451.dart';
import 'pages/Frame_6_7500.dart';
import 'pages/Frame_6_7553.dart';
import 'pages/Frame_6_7608.dart';
import 'pages/Frame_6_7660.dart';
import 'pages/Frame_6_7777.dart';
import 'pages/Frame_6_7859.dart';
import 'pages/Frame_6_7980.dart';
import 'pages/Frame_6_8109.dart';
import 'pages/Frame_6_8195.dart';
import 'pages/Frame_6_8321.dart';
import 'pages/Frame_6_8425.dart';
import 'pages/Frame_6_8526.dart';
import 'pages/Frame_6_8679.dart';
import 'pages/Frame_6_8767.dart';
import 'pages/Frame_6_8897.dart';
import 'pages/Frame_6_9018.dart';
import 'pages/Frame_6_9102.dart';
import 'pages/Frame_6_9172.dart';
import 'pages/Frame_6_9296.dart';
import 'pages/Frame_6_9391.dart';
import 'pages/Frame_6_9515.dart';
import 'pages/Frame_6_9606.dart';
import 'pages/Frame_6_9710.dart';
import 'pages/Frame_6_9815.dart';
import 'pages/Frame_6_10012.dart';
import 'pages/Frame_6_10113.dart';
import 'pages/Frame_6_10186.dart';
import 'pages/Frame_6_10300.dart';
import 'pages/Frame_6_10443.dart';
import 'pages/Frame_6_10590.dart';
import 'pages/Frame_6_10652.dart';
import 'pages/Frame_6_10717.dart';
import 'pages/Frame_6_10834.dart';
import 'pages/Frame_6_10995.dart';
import 'pages/Frame_6_11104.dart';
import 'pages/Frame_6_11229.dart';
import 'pages/Frame_6_11418.dart';
import 'pages/Frame_6_11494.dart';
import 'pages/Frame_6_11569.dart';
import 'pages/Frame_6_11643.dart';
import 'pages/Frame_6_11749.dart';
import 'pages/Frame_6_11854.dart';
import 'pages/Frame_6_11990.dart';
import 'pages/Frame_6_12089.dart';
import 'pages/Frame_6_12137.dart';
import 'pages/Frame_6_12230.dart';
import 'pages/Frame_6_12296.dart';
import 'pages/Frame_6_12386.dart';
import 'pages/Frame_6_12448.dart';
import 'pages/Frame_6_12584.dart';
import 'pages/Frame_6_12690.dart';
import 'pages/Frame_6_12743.dart';
import 'pages/Frame_6_12805.dart';
import 'pages/Frame_6_12869.dart';
import 'pages/Frame_6_12945.dart';
import 'pages/Frame_6_13072.dart';
import 'pages/Frame_6_13181.dart';
import 'pages/Frame_6_13295.dart';
import 'pages/Frame_6_13351.dart';
import 'pages/Frame_6_13416.dart';
import 'pages/Frame_6_13509.dart';
import 'pages/Frame_6_13624.dart';
import 'pages/Frame_6_13698.dart';
import 'pages/Frame_6_13770.dart';
import 'pages/Frame_6_13872.dart';
import 'pages/Frame_6_13979.dart';
import 'pages/Frame_6_14052.dart';
import 'pages/Frame_6_14145.dart';
import 'pages/Frame_6_14209.dart';
import 'pages/Frame_6_14259.dart';
import 'pages/Frame_6_14308.dart';
import 'pages/Frame_6_14369.dart';
import 'pages/Frame_6_14429.dart';
import 'pages/Frame_6_14465.dart';
import 'pages/Frame_6_14503.dart';
import 'pages/Frame_6_14574.dart';
import 'pages/Frame_6_14611.dart';
import 'pages/Frame_6_14673.dart';
import 'pages/Frame_6_14760.dart';
import 'pages/Frame_6_14850.dart';

final Map<String, Widget Function()> screenRegistry = {
  '01-登录': () => const LoginScreen(),
  '02-设置密码': () => const SetPasswordScreen(),
  '65-密码登录': () => const PasswordLoginScreen(),
  '66-忘记密码': () => const SetPasswordScreen(),
  '03-首页': () => const HomeScreen(),
  '04-附近门店-地图': () => const StoreListScreen(),
  '67-门店搜索': () => const StoreSearchScreen(),
  '05-门店详情-预约': () => Frame_6_7980(),
  '05-门店详情-选择桌位': () => Frame_6_8109(),
  '06-预约确认': () => Frame_6_8195(),
  '07-我的预约': () => const MyAppointmentsScreen(),
  '08-到店核销-体验': () => const CheckinFlowScreen(),
  '71-核销二维码出示': () => Frame_6_8526(),
  '72-体验完成': () => Frame_6_8679(),
  '09-会员中心': () => const MemberCenterScreen(),
  '10-卡包-优惠券': () => const CouponsScreen(),
  '11-活动专区': () => const ActivityListScreen(),
  '11-活动专区-续': () => Frame_6_9102(),
  '11-活动详情-预约': () => Frame_6_9172(),
  '12-社区': () => const CommunityHomeScreen(),
  '12-社区-续': () => Frame_6_9391(),
  '13-作品详情': () => Frame_6_9515(),
  '14-发布作品-微博风': () => const PostPublishScreen(),
  '15-用户主页': () => Frame_6_9710(),
  '68-用户主页-笔记': () => Frame_6_9815(),
  '16-Reels': () => const ReelsScreen(),
  '17-视频详情-评论': () => Frame_6_10012(),
  '18-拍摄页-抖音风': () => const CaptureScreen(),
  '19-发布视频-抖音风': () => const VideoPublishScreen(),
  '20-选择音乐': () => const MusicPickerScreen(),
  '21-会话列表': () => const ConversationListScreen(),
  '22-单聊': () => Frame_6_10590(),
  '23-群聊': () => Frame_6_10652(),
  '24-群设置': () => Frame_6_10717(),
  '64-群成员管理': () => Frame_6_10834(),
  '25-添加好友': () => const AddFriendScreen(),
  '26-我的主页': () => const ProfileScreen(),
  '26-我的主页-菜单': () => Frame_6_11229(),
  '27-点赞与收藏': () => const LikedFavoritesScreen(),
  '28-编辑资料': () => const EditProfileScreen(),
  '29-我的内容': () => const MyContentScreen(),
  '30-我的订单': () => const MyAppointmentsScreen(),
  '30-我的订单-续': () => Frame_6_11749(),
  '31-通知': () => const NotificationsScreen(),
  '32-设置': () => const SettingsScreen(),
  '32-设置-续': () => Frame_6_12089(),
  '33-关注与粉丝': () => Frame_6_12137(),
  '34-弹窗-居中确认': () => Frame_6_12230(),
  '35-弹窗-底部分享': () => Frame_6_12296(),
  '36-聊天-长按气泡菜单': () => Frame_6_12386(),
  '37-动效与交互规范': () => Frame_6_12448(),
  '37-动效与交互规范-续': () => Frame_6_12584(),
  '38-弹窗-删除作品确认': () => Frame_6_12690(),
  '39-弹窗-退出登录确认': () => Frame_6_12743(),
  '40-弹窗-群聊踢人确认': () => Frame_6_12805(),
  '41-弹窗-照片选择': () => Frame_6_12869(),
  '42-会话-长按菜单': () => Frame_6_12945(),
  '43-观看历史': () => const WatchHistoryScreen(),
  '44-预约详情': () => Frame_6_13181(),
  '45-输入核销码': () => const VerifyCodeScreen(),
  '46-预约成功': () => Frame_6_13351(),
  '47-会员开通确认': () => Frame_6_13416(),
  '48-领券中心': () => const CouponCenterScreen(),
  '49-社区搜索': () => const SearchScreen(),
  '49-社区搜索-续': () => Frame_6_13698(),
  '69-搜索首页': () => const SearchScreen(),
  '70-视频搜索': () => const VideoSearchScreen(),
  '50-话题频道页': () => const TopicChannelScreen(),
  '51-单聊设置': () => Frame_6_14052(),
  '52-黑名单管理': () => const BlocksScreen(),
  '53-空状态示例': () => Frame_6_14209(),
  '53-空状态示例-续': () => Frame_6_14259(),
  '54-发布成功-审核中': () => Frame_6_14308(),
  '55-作品全屏查看': () => Frame_6_14369(),
  '56-视频播放页': () => Frame_6_14429(),
  '57-聊天图片查看': () => Frame_6_14465(),
  '58-图片查看-长按操作菜单': () => Frame_6_14503(),
  '59-视频横屏全屏': () => Frame_6_14574(),
  '60-横屏视频-竖屏显示': () => Frame_6_14611(),
  '61-聊天输入-功能面板': () => Frame_6_14673(),
  '62-聊天输入-表情面板': () => Frame_6_14760(),
  '63-聊天输入-语音长按': () => Frame_6_14850(),
};

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In zh, this message translates to:
  /// **'Think Origin'**
  String get appTitle;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get commonConfirm;

  /// No description provided for @commonDone.
  ///
  /// In zh, this message translates to:
  /// **'完成'**
  String get commonDone;

  /// No description provided for @commonBack.
  ///
  /// In zh, this message translates to:
  /// **'返回'**
  String get commonBack;

  /// No description provided for @commonRetry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get commonRetry;

  /// No description provided for @commonLoading.
  ///
  /// In zh, this message translates to:
  /// **'加载中…'**
  String get commonLoading;

  /// No description provided for @commonEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无数据'**
  String get commonEmpty;

  /// No description provided for @commonEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get commonEdit;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonSearch.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get commonSearch;

  /// No description provided for @commonRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get commonRefresh;

  /// No description provided for @commonCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get commonCopy;

  /// No description provided for @commonClose.
  ///
  /// In zh, this message translates to:
  /// **'关闭'**
  String get commonClose;

  /// No description provided for @commonAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get commonAll;

  /// No description provided for @tabHome.
  ///
  /// In zh, this message translates to:
  /// **'首页'**
  String get tabHome;

  /// No description provided for @tabProfile.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get tabProfile;

  /// No description provided for @loginTitle.
  ///
  /// In zh, this message translates to:
  /// **'Think Origin'**
  String get loginTitle;

  /// No description provided for @loginAccountHint.
  ///
  /// In zh, this message translates to:
  /// **'用户名 / 邮箱'**
  String get loginAccountHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'密码（6-32 位）'**
  String get loginPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get loginButton;

  /// No description provided for @loginForgot.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码'**
  String get loginForgot;

  /// No description provided for @loginRegisterLink.
  ///
  /// In zh, this message translates to:
  /// **'注册新账号'**
  String get loginRegisterLink;

  /// No description provided for @loginNeedAccount.
  ///
  /// In zh, this message translates to:
  /// **'请输入用户名或邮箱'**
  String get loginNeedAccount;

  /// No description provided for @loginNeedPassword.
  ///
  /// In zh, this message translates to:
  /// **'请输入密码'**
  String get loginNeedPassword;

  /// No description provided for @registerTitle.
  ///
  /// In zh, this message translates to:
  /// **'注册'**
  String get registerTitle;

  /// No description provided for @registerUsernameHint.
  ///
  /// In zh, this message translates to:
  /// **'用户名（2-30 位，字母/数字/下划线）'**
  String get registerUsernameHint;

  /// No description provided for @registerEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'绑定邮箱'**
  String get registerEmailHint;

  /// No description provided for @registerCodeHint.
  ///
  /// In zh, this message translates to:
  /// **'邮箱验证码'**
  String get registerCodeHint;

  /// No description provided for @registerSendCode.
  ///
  /// In zh, this message translates to:
  /// **'获取验证码'**
  String get registerSendCode;

  /// No description provided for @registerPasswordHint.
  ///
  /// In zh, this message translates to:
  /// **'设置密码（6-32 位）'**
  String get registerPasswordHint;

  /// No description provided for @registerConfirmHint.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get registerConfirmHint;

  /// No description provided for @registerButton.
  ///
  /// In zh, this message translates to:
  /// **'注册并登录'**
  String get registerButton;

  /// No description provided for @registerToLogin.
  ///
  /// In zh, this message translates to:
  /// **'已有账号？去登录'**
  String get registerToLogin;

  /// No description provided for @forgotTitle.
  ///
  /// In zh, this message translates to:
  /// **'忘记密码'**
  String get forgotTitle;

  /// No description provided for @forgotDesc.
  ///
  /// In zh, this message translates to:
  /// **'通过绑定邮箱验证后设置新密码'**
  String get forgotDesc;

  /// No description provided for @forgotResetButton.
  ///
  /// In zh, this message translates to:
  /// **'重置密码'**
  String get forgotResetButton;

  /// No description provided for @forgotBackToLogin.
  ///
  /// In zh, this message translates to:
  /// **'返回登录'**
  String get forgotBackToLogin;

  /// No description provided for @changePasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'修改密码'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordDesc.
  ///
  /// In zh, this message translates to:
  /// **'验证原密码后设置新密码，下次登录请使用新密码'**
  String get changePasswordDesc;

  /// No description provided for @changePasswordOld.
  ///
  /// In zh, this message translates to:
  /// **'原密码'**
  String get changePasswordOld;

  /// No description provided for @changePasswordNew.
  ///
  /// In zh, this message translates to:
  /// **'新密码（6-32 位）'**
  String get changePasswordNew;

  /// No description provided for @changePasswordConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认新密码'**
  String get changePasswordConfirm;

  /// No description provided for @changePasswordButton.
  ///
  /// In zh, this message translates to:
  /// **'确认修改'**
  String get changePasswordButton;

  /// No description provided for @changePasswordNeedOld.
  ///
  /// In zh, this message translates to:
  /// **'请输入原密码'**
  String get changePasswordNeedOld;

  /// No description provided for @changePasswordMin.
  ///
  /// In zh, this message translates to:
  /// **'新密码至少 6 位'**
  String get changePasswordMin;

  /// No description provided for @changePasswordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的新密码不一致'**
  String get changePasswordMismatch;

  /// No description provided for @changePasswordSuccess.
  ///
  /// In zh, this message translates to:
  /// **'密码修改成功'**
  String get changePasswordSuccess;

  /// No description provided for @settingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get settingsTitle;

  /// No description provided for @settingsAccountSecurity.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全'**
  String get settingsAccountSecurity;

  /// No description provided for @settingsGeneral.
  ///
  /// In zh, this message translates to:
  /// **'通用'**
  String get settingsGeneral;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get settingsAbout;

  /// No description provided for @settingsEmail.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get settingsEmail;

  /// No description provided for @settingsNotBound.
  ///
  /// In zh, this message translates to:
  /// **'未绑定'**
  String get settingsNotBound;

  /// No description provided for @settingsUsername.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get settingsUsername;

  /// No description provided for @settingsNotSet.
  ///
  /// In zh, this message translates to:
  /// **'未设置'**
  String get settingsNotSet;

  /// No description provided for @settingsSet.
  ///
  /// In zh, this message translates to:
  /// **'已设置'**
  String get settingsSet;

  /// No description provided for @settingsLoginPassword.
  ///
  /// In zh, this message translates to:
  /// **'登录密码'**
  String get settingsLoginPassword;

  /// No description provided for @settingsLoginPasswordSub.
  ///
  /// In zh, this message translates to:
  /// **'已设置 · 可用密码登录'**
  String get settingsLoginPasswordSub;

  /// No description provided for @settingsSwitchAccount.
  ///
  /// In zh, this message translates to:
  /// **'切换账号'**
  String get settingsSwitchAccount;

  /// No description provided for @settingsSwitchAccountSub.
  ///
  /// In zh, this message translates to:
  /// **'登录其他账号'**
  String get settingsSwitchAccountSub;

  /// No description provided for @settingsSwitchConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'切换账号'**
  String get settingsSwitchConfirmTitle;

  /// No description provided for @settingsSwitchConfirmDesc.
  ///
  /// In zh, this message translates to:
  /// **'切换账号将退出当前账号并返回登录页，需要重新登录后才能继续，确定切换吗？'**
  String get settingsSwitchConfirmDesc;

  /// No description provided for @settingsSwitchAction.
  ///
  /// In zh, this message translates to:
  /// **'切换账号'**
  String get settingsSwitchAction;

  /// No description provided for @settingsNotifications.
  ///
  /// In zh, this message translates to:
  /// **'消息通知'**
  String get settingsNotifications;

  /// No description provided for @settingsNotificationsSub.
  ///
  /// In zh, this message translates to:
  /// **'互动、系统消息提醒'**
  String get settingsNotificationsSub;

  /// No description provided for @settingsVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本'**
  String get settingsVersion;

  /// No description provided for @settingsLogout.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get settingsLogoutConfirmTitle;

  /// No description provided for @settingsLogoutConfirmDesc.
  ///
  /// In zh, this message translates to:
  /// **'退出后需要重新登录，才能查看消息、预约和会员信息，确定退出吗？'**
  String get settingsLogoutConfirmDesc;

  /// No description provided for @settingsLogoutAction.
  ///
  /// In zh, this message translates to:
  /// **'退出登录'**
  String get settingsLogoutAction;

  /// No description provided for @profileTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的'**
  String get profileTitle;

  /// No description provided for @profileEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑资料'**
  String get profileEdit;

  /// No description provided for @profileMyAppointments.
  ///
  /// In zh, this message translates to:
  /// **'我的预约'**
  String get profileMyAppointments;

  /// No description provided for @profileJoined.
  ///
  /// In zh, this message translates to:
  /// **'Think Origin {year} 年 {month} 月入驻'**
  String profileJoined(Object month, Object year);

  /// No description provided for @profileMemberCenter.
  ///
  /// In zh, this message translates to:
  /// **'会员中心'**
  String get profileMemberCenter;

  /// No description provided for @profileEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑资料'**
  String get profileEditTitle;

  /// No description provided for @profileEditNickname.
  ///
  /// In zh, this message translates to:
  /// **'昵称'**
  String get profileEditNickname;

  /// No description provided for @profileEditUsername.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get profileEditUsername;

  /// No description provided for @profileEditUsernameHint.
  ///
  /// In zh, this message translates to:
  /// **'用户名一年内只能修改一次，设置后可用于用户名+密码登录'**
  String get profileEditUsernameHint;

  /// No description provided for @profileEditBio.
  ///
  /// In zh, this message translates to:
  /// **'简介'**
  String get profileEditBio;

  /// No description provided for @profileEditLocation.
  ///
  /// In zh, this message translates to:
  /// **'所在地'**
  String get profileEditLocation;

  /// No description provided for @profileEditBirthday.
  ///
  /// In zh, this message translates to:
  /// **'生日'**
  String get profileEditBirthday;

  /// No description provided for @profileEditGender.
  ///
  /// In zh, this message translates to:
  /// **'性别'**
  String get profileEditGender;

  /// No description provided for @profileEditAvatarUploading.
  ///
  /// In zh, this message translates to:
  /// **'头像上传中，请稍候再保存'**
  String get profileEditAvatarUploading;

  /// No description provided for @profileSaveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get profileSaveSuccess;

  /// No description provided for @profileAvatarPickFailed.
  ///
  /// In zh, this message translates to:
  /// **'选择头像失败'**
  String get profileAvatarPickFailed;

  /// No description provided for @homeOrders.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get homeOrders;

  /// No description provided for @homeStoreSection.
  ///
  /// In zh, this message translates to:
  /// **'拼豆'**
  String get homeStoreSection;

  /// No description provided for @homeStoreSectionBadge.
  ///
  /// In zh, this message translates to:
  /// **'人气手作'**
  String get homeStoreSectionBadge;

  /// No description provided for @homeBookNow.
  ///
  /// In zh, this message translates to:
  /// **'预约'**
  String get homeBookNow;

  /// No description provided for @homeCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'到店'**
  String get homeCheckIn;

  /// No description provided for @homeMember.
  ///
  /// In zh, this message translates to:
  /// **'会员套餐'**
  String get homeMember;

  /// No description provided for @homeWaitingConfirm.
  ///
  /// In zh, this message translates to:
  /// **'待确认'**
  String get homeWaitingConfirm;

  /// No description provided for @homeWaitingStoreConfirm.
  ///
  /// In zh, this message translates to:
  /// **'等待门店确认'**
  String get homeWaitingStoreConfirm;

  /// No description provided for @homeOrderExpired.
  ///
  /// In zh, this message translates to:
  /// **'订单已失效'**
  String get homeOrderExpired;

  /// No description provided for @homeToCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'到店核销'**
  String get homeToCheckIn;

  /// No description provided for @memberCenterTitle.
  ///
  /// In zh, this message translates to:
  /// **'会员中心'**
  String get memberCenterTitle;

  /// No description provided for @memberBenefits.
  ///
  /// In zh, this message translates to:
  /// **'会员权益'**
  String get memberBenefits;

  /// No description provided for @memberOpenRenew.
  ///
  /// In zh, this message translates to:
  /// **'开通 / 续费'**
  String get memberOpenRenew;

  /// No description provided for @memberNotOpened.
  ///
  /// In zh, this message translates to:
  /// **'未开通'**
  String get memberNotOpened;

  /// No description provided for @memberExpired.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get memberExpired;

  /// No description provided for @memberPendingHint.
  ///
  /// In zh, this message translates to:
  /// **'有 {count} 笔会员开通申请待门店确认，到店支付费用后将为你开通'**
  String memberPendingHint(Object count);

  /// No description provided for @memberPurchaseTitle.
  ///
  /// In zh, this message translates to:
  /// **'开通会员'**
  String get memberPurchaseTitle;

  /// No description provided for @memberPurchaseDays.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天有效期'**
  String memberPurchaseDays(Object days);

  /// No description provided for @memberPayDetails.
  ///
  /// In zh, this message translates to:
  /// **'支付明细'**
  String get memberPayDetails;

  /// No description provided for @memberOriginalPrice.
  ///
  /// In zh, this message translates to:
  /// **'套餐原价'**
  String get memberOriginalPrice;

  /// No description provided for @memberDiscount.
  ///
  /// In zh, this message translates to:
  /// **'限时优惠'**
  String get memberDiscount;

  /// No description provided for @memberPayAmount.
  ///
  /// In zh, this message translates to:
  /// **'实付金额'**
  String get memberPayAmount;

  /// No description provided for @memberOfflinePayHint.
  ///
  /// In zh, this message translates to:
  /// **'线上下单，到店支付：提交订单后到店支付会员费用即可开通'**
  String get memberOfflinePayHint;

  /// No description provided for @memberSubmitOrder.
  ///
  /// In zh, this message translates to:
  /// **'提交订单'**
  String get memberSubmitOrder;

  /// No description provided for @memberThinkAgain.
  ///
  /// In zh, this message translates to:
  /// **'再想想'**
  String get memberThinkAgain;

  /// No description provided for @memberAgreeTerms.
  ///
  /// In zh, this message translates to:
  /// **'提交订单即代表同意《会员服务协议》'**
  String get memberAgreeTerms;

  /// No description provided for @memberOrderSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'订单已提交'**
  String get memberOrderSubmitted;

  /// No description provided for @memberWaitingConfirm.
  ///
  /// In zh, this message translates to:
  /// **'等待门店确认'**
  String get memberWaitingConfirm;

  /// No description provided for @memberOrderSubmittedDesc.
  ///
  /// In zh, this message translates to:
  /// **'到店支付会员费用后，由门店确认开通\n开通后即可享受会员权益'**
  String get memberOrderSubmittedDesc;

  /// No description provided for @storeListTitle.
  ///
  /// In zh, this message translates to:
  /// **'门店列表'**
  String get storeListTitle;

  /// No description provided for @storeSearchPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'搜索门店'**
  String get storeSearchPlaceholder;

  /// No description provided for @storeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无门店，请先到管理后台添加'**
  String get storeEmpty;

  /// No description provided for @storeBookingTitle.
  ///
  /// In zh, this message translates to:
  /// **'预约'**
  String get storeBookingTitle;

  /// No description provided for @storePeopleCount.
  ///
  /// In zh, this message translates to:
  /// **'到店人数'**
  String get storePeopleCount;

  /// No description provided for @storeUnitPrice.
  ///
  /// In zh, this message translates to:
  /// **'单价'**
  String get storeUnitPrice;

  /// No description provided for @storeGroupPrice.
  ///
  /// In zh, this message translates to:
  /// **'同行价'**
  String get storeGroupPrice;

  /// No description provided for @storeMemberPrice.
  ///
  /// In zh, this message translates to:
  /// **'会员'**
  String get storeMemberPrice;

  /// No description provided for @storeSelectTable.
  ///
  /// In zh, this message translates to:
  /// **'选择桌位'**
  String get storeSelectTable;

  /// No description provided for @storeConfirmOrder.
  ///
  /// In zh, this message translates to:
  /// **'提交预约'**
  String get storeConfirmOrder;

  /// No description provided for @appointmentMyTitle.
  ///
  /// In zh, this message translates to:
  /// **'我的预约'**
  String get appointmentMyTitle;

  /// No description provided for @appointmentTabAll.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get appointmentTabAll;

  /// No description provided for @appointmentTabBooked.
  ///
  /// In zh, this message translates to:
  /// **'待核销'**
  String get appointmentTabBooked;

  /// No description provided for @appointmentTabInService.
  ///
  /// In zh, this message translates to:
  /// **'服务中'**
  String get appointmentTabInService;

  /// No description provided for @appointmentTabCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get appointmentTabCompleted;

  /// No description provided for @appointmentTabPending.
  ///
  /// In zh, this message translates to:
  /// **'待确认'**
  String get appointmentTabPending;

  /// No description provided for @appointmentStatusBooked.
  ///
  /// In zh, this message translates to:
  /// **'待核销'**
  String get appointmentStatusBooked;

  /// No description provided for @appointmentStatusCheckedIn.
  ///
  /// In zh, this message translates to:
  /// **'已核销'**
  String get appointmentStatusCheckedIn;

  /// No description provided for @appointmentStatusInService.
  ///
  /// In zh, this message translates to:
  /// **'服务中'**
  String get appointmentStatusInService;

  /// No description provided for @appointmentStatusCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get appointmentStatusCompleted;

  /// No description provided for @appointmentStatusCancelled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get appointmentStatusCancelled;

  /// No description provided for @appointmentStatusPending.
  ///
  /// In zh, this message translates to:
  /// **'待确认'**
  String get appointmentStatusPending;

  /// No description provided for @appointmentWaitingConfirm.
  ///
  /// In zh, this message translates to:
  /// **'等待门店确认'**
  String get appointmentWaitingConfirm;

  /// No description provided for @appointmentWaitingDesc.
  ///
  /// In zh, this message translates to:
  /// **'预约已提交，门店确认后即可到店核销'**
  String get appointmentWaitingDesc;

  /// No description provided for @appointmentCheckInCode.
  ///
  /// In zh, this message translates to:
  /// **'核销码'**
  String get appointmentCheckInCode;

  /// No description provided for @appointmentToCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'到店核销'**
  String get appointmentToCheckIn;

  /// No description provided for @appointmentShowCode.
  ///
  /// In zh, this message translates to:
  /// **'出示预约码，店员扫码或输入验证码开始体验'**
  String get appointmentShowCode;

  /// No description provided for @appointmentExpired.
  ///
  /// In zh, this message translates to:
  /// **'订单已失效'**
  String get appointmentExpired;

  /// No description provided for @appointmentExpiredDesc.
  ///
  /// In zh, this message translates to:
  /// **'已超过预约时间，无法再核销'**
  String get appointmentExpiredDesc;

  /// No description provided for @appointmentCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消预约'**
  String get appointmentCancel;

  /// No description provided for @appointmentCancelled.
  ///
  /// In zh, this message translates to:
  /// **'预约已取消'**
  String get appointmentCancelled;

  /// No description provided for @appointmentBookSuccess.
  ///
  /// In zh, this message translates to:
  /// **'预约成功'**
  String get appointmentBookSuccess;

  /// No description provided for @appointmentBookSubmitted.
  ///
  /// In zh, this message translates to:
  /// **'预约已提交'**
  String get appointmentBookSubmitted;

  /// No description provided for @appointmentBookSuccessDesc.
  ///
  /// In zh, this message translates to:
  /// **'到店出示此码即可核销体验，核销后线下付款'**
  String get appointmentBookSuccessDesc;

  /// No description provided for @appointmentBookSubmittedDesc.
  ///
  /// In zh, this message translates to:
  /// **'预约已提交，门店在管理端确认后\n到店出示预约码即可核销体验'**
  String get appointmentBookSubmittedDesc;

  /// No description provided for @appointmentView.
  ///
  /// In zh, this message translates to:
  /// **'查看预约'**
  String get appointmentView;

  /// No description provided for @appointmentBackHome.
  ///
  /// In zh, this message translates to:
  /// **'返回首页'**
  String get appointmentBackHome;

  /// No description provided for @appointmentDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'预约详情'**
  String get appointmentDetailTitle;

  /// No description provided for @appointmentProgress.
  ///
  /// In zh, this message translates to:
  /// **'预约进度'**
  String get appointmentProgress;

  /// No description provided for @appointmentInfo.
  ///
  /// In zh, this message translates to:
  /// **'订单信息'**
  String get appointmentInfo;

  /// No description provided for @appointmentItem.
  ///
  /// In zh, this message translates to:
  /// **'预约项目'**
  String get appointmentItem;

  /// No description provided for @appointmentTime.
  ///
  /// In zh, this message translates to:
  /// **'预约时间'**
  String get appointmentTime;

  /// No description provided for @appointmentPeople.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人'**
  String appointmentPeople(Object count);

  /// No description provided for @appointmentTable.
  ///
  /// In zh, this message translates to:
  /// **'桌位'**
  String get appointmentTable;

  /// No description provided for @appointmentPayMethod.
  ///
  /// In zh, this message translates to:
  /// **'付款方式'**
  String get appointmentPayMethod;

  /// No description provided for @appointmentPayOffline.
  ///
  /// In zh, this message translates to:
  /// **'到店核销后付款'**
  String get appointmentPayOffline;

  /// No description provided for @appointmentAmount.
  ///
  /// In zh, this message translates to:
  /// **'金额'**
  String get appointmentAmount;

  /// No description provided for @appointmentNote.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get appointmentNote;

  /// No description provided for @appointmentCodeCopied.
  ///
  /// In zh, this message translates to:
  /// **'预约码已复制'**
  String get appointmentCodeCopied;

  /// No description provided for @appointmentCheckInScan.
  ///
  /// In zh, this message translates to:
  /// **'扫码核销'**
  String get appointmentCheckInScan;

  /// No description provided for @appointmentDetail.
  ///
  /// In zh, this message translates to:
  /// **'查看详情'**
  String get appointmentDetail;

  /// No description provided for @appointmentBookAgain.
  ///
  /// In zh, this message translates to:
  /// **'再次预约'**
  String get appointmentBookAgain;

  /// No description provided for @appointmentEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无预约，去预约一个体验吧'**
  String get appointmentEmpty;

  /// No description provided for @appointmentPendingOnly.
  ///
  /// In zh, this message translates to:
  /// **'暂无待核销预约'**
  String get appointmentPendingOnly;

  /// No description provided for @appointmentConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认预约'**
  String get appointmentConfirmTitle;

  /// No description provided for @appointmentSubmit.
  ///
  /// In zh, this message translates to:
  /// **'提交预约'**
  String get appointmentSubmit;

  /// No description provided for @appointmentClockOutTitle.
  ///
  /// In zh, this message translates to:
  /// **'结束体验'**
  String get appointmentClockOutTitle;

  /// No description provided for @appointmentClockOutDesc.
  ///
  /// In zh, this message translates to:
  /// **'点击确认下钟后将停止计时'**
  String get appointmentClockOutDesc;

  /// No description provided for @appointmentClockOutConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认下钟'**
  String get appointmentClockOutConfirm;

  /// No description provided for @appointmentClockOutThink.
  ///
  /// In zh, this message translates to:
  /// **'再想想'**
  String get appointmentClockOutThink;

  /// No description provided for @appointmentOrderExpired.
  ///
  /// In zh, this message translates to:
  /// **'订单已失效'**
  String get appointmentOrderExpired;

  /// No description provided for @appointmentShowQr.
  ///
  /// In zh, this message translates to:
  /// **'到店出示二维码核销'**
  String get appointmentShowQr;

  /// No description provided for @appointmentQrCode.
  ///
  /// In zh, this message translates to:
  /// **'核销码 {code}'**
  String appointmentQrCode(Object code);

  /// No description provided for @activityTitle.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get activityTitle;

  /// No description provided for @activityBook.
  ///
  /// In zh, this message translates to:
  /// **'预约活动'**
  String get activityBook;

  /// No description provided for @activityPeople.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人'**
  String activityPeople(Object count);

  /// No description provided for @notificationTitle.
  ///
  /// In zh, this message translates to:
  /// **'通知'**
  String get notificationTitle;

  /// No description provided for @notificationEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无通知'**
  String get notificationEmpty;

  /// No description provided for @notLoggedIn.
  ///
  /// In zh, this message translates to:
  /// **'请先登录'**
  String get notLoggedIn;

  /// No description provided for @noStore.
  ///
  /// In zh, this message translates to:
  /// **'暂无门店'**
  String get noStore;

  /// No description provided for @serverError.
  ///
  /// In zh, this message translates to:
  /// **'网络异常，请稍后重试'**
  String get serverError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

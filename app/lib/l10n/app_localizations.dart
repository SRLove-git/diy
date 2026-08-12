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
  /// **'请输入密码'**
  String get loginPasswordHint;

  /// No description provided for @loginSlogan.
  ///
  /// In zh, this message translates to:
  /// **'发现手作 · 遇见同好'**
  String get loginSlogan;

  /// No description provided for @loginAgreeTerms.
  ///
  /// In zh, this message translates to:
  /// **'注册即代表同意《用户协议》和《隐私政策》'**
  String get loginAgreeTerms;

  /// No description provided for @loginButton.
  ///
  /// In zh, this message translates to:
  /// **'登录'**
  String get loginButton;

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

  /// No description provided for @loginSuccess.
  ///
  /// In zh, this message translates to:
  /// **'登录成功'**
  String get loginSuccess;

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

  /// No description provided for @registerDesc.
  ///
  /// In zh, this message translates to:
  /// **'用用户名和密码注册'**
  String get registerDesc;

  /// No description provided for @registerEmailHint.
  ///
  /// In zh, this message translates to:
  /// **'绑定邮箱'**
  String get registerEmailHint;

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

  /// No description provided for @registerEmailHintFull.
  ///
  /// In zh, this message translates to:
  /// **'邮箱'**
  String get registerEmailHintFull;

  /// No description provided for @registerSuccess.
  ///
  /// In zh, this message translates to:
  /// **'注册成功，欢迎加入 Think Origin'**
  String get registerSuccess;

  /// No description provided for @needValidEmail.
  ///
  /// In zh, this message translates to:
  /// **'请输入正确的邮箱'**
  String get needValidEmail;

  /// No description provided for @usernameInvalid.
  ///
  /// In zh, this message translates to:
  /// **'用户名需为 2-30 位字母、数字或下划线'**
  String get usernameInvalid;

  /// No description provided for @passwordMin6.
  ///
  /// In zh, this message translates to:
  /// **'密码至少 6 位'**
  String get passwordMin6;

  /// No description provided for @passwordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次输入的密码不一致'**
  String get passwordMismatch;

  /// No description provided for @changePasswordTitle.
  ///
  /// In zh, this message translates to:
  /// **'修改登录密码'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordAppBar.
  ///
  /// In zh, this message translates to:
  /// **'修改密码'**
  String get changePasswordAppBar;

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

  /// No description provided for @settingsLanguage.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsLanguageChinese.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get settingsLanguageChinese;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

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

  /// No description provided for @settingsBound.
  ///
  /// In zh, this message translates to:
  /// **'已绑定'**
  String get settingsBound;

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

  /// No description provided for @settingsUserAgreement.
  ///
  /// In zh, this message translates to:
  /// **'用户协议'**
  String get settingsUserAgreement;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsUserAgreementSoon.
  ///
  /// In zh, this message translates to:
  /// **'用户协议敬请期待'**
  String get settingsUserAgreementSoon;

  /// No description provided for @settingsPrivacyPolicySoon.
  ///
  /// In zh, this message translates to:
  /// **'隐私政策敬请期待'**
  String get settingsPrivacyPolicySoon;

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

  /// No description provided for @settingsScrollHint.
  ///
  /// In zh, this message translates to:
  /// **'下拉查看关于与退出登录'**
  String get settingsScrollHint;

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

  /// No description provided for @profileCardWallet.
  ///
  /// In zh, this message translates to:
  /// **'我的卡包'**
  String get profileCardWallet;

  /// No description provided for @profileCardWalletDesc.
  ///
  /// In zh, this message translates to:
  /// **'优惠券 · 会员体验'**
  String get profileCardWalletDesc;

  /// No description provided for @profileCardOrders.
  ///
  /// In zh, this message translates to:
  /// **'我的订单'**
  String get profileCardOrders;

  /// No description provided for @profileCardOrdersDesc.
  ///
  /// In zh, this message translates to:
  /// **'预约 · 体验记录'**
  String get profileCardOrdersDesc;

  /// No description provided for @profileCardSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get profileCardSettings;

  /// No description provided for @profileCardSettingsDesc.
  ///
  /// In zh, this message translates to:
  /// **'账号与安全 · 通用'**
  String get profileCardSettingsDesc;

  /// No description provided for @profileServices.
  ///
  /// In zh, this message translates to:
  /// **'我的服务'**
  String get profileServices;

  /// No description provided for @profileMoreComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'更多服务持续上线'**
  String get profileMoreComingSoon;

  /// No description provided for @profileJoined.
  ///
  /// In zh, this message translates to:
  /// **'Think Origin {year} 年 {month} 月入驻'**
  String profileJoined(String year, String month);

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

  /// No description provided for @profileEditBioHint.
  ///
  /// In zh, this message translates to:
  /// **'简介：拼豆手作爱好者，治愈系手工'**
  String get profileEditBioHint;

  /// No description provided for @profileEditLocationHint.
  ///
  /// In zh, this message translates to:
  /// **'请输入城市 / 地区'**
  String get profileEditLocationHint;

  /// No description provided for @profileEditMe.
  ///
  /// In zh, this message translates to:
  /// **'我'**
  String get profileEditMe;

  /// No description provided for @genderMale.
  ///
  /// In zh, this message translates to:
  /// **'男'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In zh, this message translates to:
  /// **'女'**
  String get genderFemale;

  /// No description provided for @genderSecret.
  ///
  /// In zh, this message translates to:
  /// **'保密'**
  String get genderSecret;

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

  /// No description provided for @commonOk.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonOk;

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

  /// No description provided for @homeBookNowDesc.
  ///
  /// In zh, this message translates to:
  /// **'附近门店 / 活动'**
  String get homeBookNowDesc;

  /// No description provided for @homeCheckIn.
  ///
  /// In zh, this message translates to:
  /// **'到店'**
  String get homeCheckIn;

  /// No description provided for @homeCheckInDesc.
  ///
  /// In zh, this message translates to:
  /// **'核销 · 上钟'**
  String get homeCheckInDesc;

  /// No description provided for @homeMember.
  ///
  /// In zh, this message translates to:
  /// **'会员套餐'**
  String get homeMember;

  /// No description provided for @homeMemberDesc.
  ///
  /// In zh, this message translates to:
  /// **'权益 · 优惠'**
  String get homeMemberDesc;

  /// No description provided for @homeComingSoon.
  ///
  /// In zh, this message translates to:
  /// **'敬请期待'**
  String get homeComingSoon;

  /// No description provided for @homeComingSoonMore.
  ///
  /// In zh, this message translates to:
  /// **'更多活动敬请期待'**
  String get homeComingSoonMore;

  /// No description provided for @homeActivitySection.
  ///
  /// In zh, this message translates to:
  /// **'活动推荐'**
  String get homeActivitySection;

  /// No description provided for @homeViewAll.
  ///
  /// In zh, this message translates to:
  /// **'查看全部 ›'**
  String get homeViewAll;

  /// No description provided for @homeNoActivities.
  ///
  /// In zh, this message translates to:
  /// **'暂无活动，敬请期待'**
  String get homeNoActivities;

  /// No description provided for @homeWaitingConfirm.
  ///
  /// In zh, this message translates to:
  /// **'待确认'**
  String get homeWaitingConfirm;

  /// No description provided for @homeWaitingChip.
  ///
  /// In zh, this message translates to:
  /// **'等待确认'**
  String get homeWaitingChip;

  /// No description provided for @homeWaitingStoreConfirm.
  ///
  /// In zh, this message translates to:
  /// **'等待门店确认'**
  String get homeWaitingStoreConfirm;

  /// No description provided for @homeCode.
  ///
  /// In zh, this message translates to:
  /// **'预约码 {code}'**
  String homeCode(String code);

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

  /// No description provided for @homePriceFrom.
  ///
  /// In zh, this message translates to:
  /// **'{price} 起'**
  String homePriceFrom(String price);

  /// No description provided for @homeStartedAt.
  ///
  /// In zh, this message translates to:
  /// **'{date} {time} 上钟{duration}'**
  String homeStartedAt(String date, String time, String duration);

  /// No description provided for @homeAllDaySuffix.
  ///
  /// In zh, this message translates to:
  /// **' · 全天不限时'**
  String get homeAllDaySuffix;

  /// No description provided for @homeHourSuffix.
  ///
  /// In zh, this message translates to:
  /// **' · {hours} 小时'**
  String homeHourSuffix(int hours);

  /// No description provided for @commonLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败'**
  String get commonLoadFailed;

  /// No description provided for @commonLoadFailedHint.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请确认后端服务已启动'**
  String get commonLoadFailedHint;

  /// No description provided for @commonFree.
  ///
  /// In zh, this message translates to:
  /// **'免费'**
  String get commonFree;

  /// No description provided for @weekdayMon.
  ///
  /// In zh, this message translates to:
  /// **'周一'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In zh, this message translates to:
  /// **'周二'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In zh, this message translates to:
  /// **'周三'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In zh, this message translates to:
  /// **'周四'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In zh, this message translates to:
  /// **'周五'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In zh, this message translates to:
  /// **'周六'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In zh, this message translates to:
  /// **'周日'**
  String get weekdaySun;

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

  /// No description provided for @memberBenefitPrice.
  ///
  /// In zh, this message translates to:
  /// **'会员专属价'**
  String get memberBenefitPrice;

  /// No description provided for @memberBenefitPriceDesc.
  ///
  /// In zh, this message translates to:
  /// **'预约与到店享会员价，最高省 \$20/次'**
  String get memberBenefitPriceDesc;

  /// No description provided for @memberBenefitActivity.
  ///
  /// In zh, this message translates to:
  /// **'专属活动'**
  String get memberBenefitActivity;

  /// No description provided for @memberBenefitActivityDesc.
  ///
  /// In zh, this message translates to:
  /// **'会员限定活动与双倍积分'**
  String get memberBenefitActivityDesc;

  /// No description provided for @memberBenefitCoupon.
  ///
  /// In zh, this message translates to:
  /// **'每月优惠券'**
  String get memberBenefitCoupon;

  /// No description provided for @memberBenefitCouponDesc.
  ///
  /// In zh, this message translates to:
  /// **'每月自动发放专属优惠券'**
  String get memberBenefitCouponDesc;

  /// No description provided for @memberBenefitBirthday.
  ///
  /// In zh, this message translates to:
  /// **'生日礼遇'**
  String get memberBenefitBirthday;

  /// No description provided for @memberBenefitBirthdayDesc.
  ///
  /// In zh, this message translates to:
  /// **'生日当月免费体验一次'**
  String get memberBenefitBirthdayDesc;

  /// No description provided for @memberAgreementHint.
  ///
  /// In zh, this message translates to:
  /// **'会员权益与规则详见《会员服务协议》'**
  String get memberAgreementHint;

  /// No description provided for @memberCurrent.
  ///
  /// In zh, this message translates to:
  /// **'当前：{level}'**
  String memberCurrent(String level);

  /// No description provided for @memberLevel.
  ///
  /// In zh, this message translates to:
  /// **'手作会员 · {level}'**
  String memberLevel(String level);

  /// No description provided for @memberValidUntil.
  ///
  /// In zh, this message translates to:
  /// **'有效期至'**
  String get memberValidUntil;

  /// No description provided for @memberStatusActive.
  ///
  /// In zh, this message translates to:
  /// **'有效'**
  String get memberStatusActive;

  /// No description provided for @memberRemainingDays.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {days} 天'**
  String memberRemainingDays(int days);

  /// No description provided for @memberWalletTitle.
  ///
  /// In zh, this message translates to:
  /// **'卡包 · 优惠券'**
  String get memberWalletTitle;

  /// No description provided for @memberExclusiveExperience.
  ///
  /// In zh, this message translates to:
  /// **'会员专属体验'**
  String get memberExclusiveExperience;

  /// No description provided for @memberMonthlyOnce.
  ///
  /// In zh, this message translates to:
  /// **'每月 1 次 ›'**
  String get memberMonthlyOnce;

  /// No description provided for @memberMoreCoupons.
  ///
  /// In zh, this message translates to:
  /// **'领取更多优惠券'**
  String get memberMoreCoupons;

  /// No description provided for @memberClaimed.
  ///
  /// In zh, this message translates to:
  /// **'领取成功'**
  String get memberClaimed;

  /// No description provided for @memberCouponCenter.
  ///
  /// In zh, this message translates to:
  /// **'领券中心'**
  String get memberCouponCenter;

  /// No description provided for @memberClaimAll.
  ///
  /// In zh, this message translates to:
  /// **'一键领取全部'**
  String get memberClaimAll;

  /// No description provided for @memberRecommended.
  ///
  /// In zh, this message translates to:
  /// **'推荐'**
  String get memberRecommended;

  /// No description provided for @memberRenew.
  ///
  /// In zh, this message translates to:
  /// **'续费'**
  String get memberRenew;

  /// No description provided for @memberOpen.
  ///
  /// In zh, this message translates to:
  /// **'开通'**
  String get memberOpen;

  /// No description provided for @memberUsable.
  ///
  /// In zh, this message translates to:
  /// **'可使用'**
  String get memberUsable;

  /// No description provided for @memberNoCoupons.
  ///
  /// In zh, this message translates to:
  /// **'暂无优惠券，去领券中心看看'**
  String get memberNoCoupons;

  /// No description provided for @memberNoCouponsAvailable.
  ///
  /// In zh, this message translates to:
  /// **'暂无可领取的优惠券'**
  String get memberNoCouponsAvailable;

  /// No description provided for @memberTabUnused.
  ///
  /// In zh, this message translates to:
  /// **'未使用'**
  String get memberTabUnused;

  /// No description provided for @memberTabUsed.
  ///
  /// In zh, this message translates to:
  /// **'已使用'**
  String get memberTabUsed;

  /// No description provided for @memberTabExpired.
  ///
  /// In zh, this message translates to:
  /// **'已过期'**
  String get memberTabExpired;

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
  String memberPendingHint(int count);

  /// No description provided for @memberPurchaseTitle.
  ///
  /// In zh, this message translates to:
  /// **'开通会员'**
  String get memberPurchaseTitle;

  /// No description provided for @memberPurchaseDays.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天有效期'**
  String memberPurchaseDays(int days);

  /// No description provided for @memberPlanDuration.
  ///
  /// In zh, this message translates to:
  /// **'{days} 天'**
  String memberPlanDuration(int days);

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

  /// No description provided for @storeBookNow.
  ///
  /// In zh, this message translates to:
  /// **'立即预约'**
  String get storeBookNow;

  /// No description provided for @storeNoResults.
  ///
  /// In zh, this message translates to:
  /// **'未找到相关门店'**
  String get storeNoResults;

  /// No description provided for @storeHourlyPerPerson.
  ///
  /// In zh, this message translates to:
  /// **'按小时 {price}/人/小时'**
  String storeHourlyPerPerson(String price);

  /// No description provided for @storeStepDate.
  ///
  /// In zh, this message translates to:
  /// **'选择日期'**
  String get storeStepDate;

  /// No description provided for @storeDuration.
  ///
  /// In zh, this message translates to:
  /// **'时长'**
  String get storeDuration;

  /// No description provided for @storeNoStartTimes.
  ///
  /// In zh, this message translates to:
  /// **'该时段已无可约开始时间'**
  String get storeNoStartTimes;

  /// No description provided for @storeStartOnScan.
  ///
  /// In zh, this message translates to:
  /// **'到店扫码即开始计时，结束时间固定不顺延'**
  String get storeStartOnScan;

  /// No description provided for @weekdayToday.
  ///
  /// In zh, this message translates to:
  /// **'今天'**
  String get weekdayToday;

  /// No description provided for @weekdayTomorrow.
  ///
  /// In zh, this message translates to:
  /// **'明天'**
  String get weekdayTomorrow;

  /// No description provided for @storeAutoTables.
  ///
  /// In zh, this message translates to:
  /// **'自动推荐最优组合'**
  String get storeAutoTables;

  /// No description provided for @storeNoTables.
  ///
  /// In zh, this message translates to:
  /// **'该门店暂无可用桌位'**
  String get storeNoTables;

  /// No description provided for @storeMemberPrefix.
  ///
  /// In zh, this message translates to:
  /// **'　会员 {price}'**
  String storeMemberPrefix(String price);

  /// No description provided for @storeMemberFree.
  ///
  /// In zh, this message translates to:
  /// **'　会员免费'**
  String get storeMemberFree;

  /// No description provided for @storeGroupPrefix.
  ///
  /// In zh, this message translates to:
  /// **'　同行 {price}'**
  String storeGroupPrefix(String price);

  /// No description provided for @storeAllDayPrefix.
  ///
  /// In zh, this message translates to:
  /// **'　全天 {price}/人'**
  String storeAllDayPrefix(String price);

  /// No description provided for @storeSearchPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'搜索门店'**
  String get storeSearchPlaceholder;

  /// No description provided for @storeSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索门店名称 / 地址'**
  String get storeSearchHint;

  /// No description provided for @storeEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无门店，请先到管理后台添加'**
  String get storeEmpty;

  /// No description provided for @storeDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'门店详情'**
  String get storeDetailTitle;

  /// No description provided for @storeBookingTitle.
  ///
  /// In zh, this message translates to:
  /// **'预约'**
  String get storeBookingTitle;

  /// No description provided for @storeBookingTypeHourly.
  ///
  /// In zh, this message translates to:
  /// **'按小时'**
  String get storeBookingTypeHourly;

  /// No description provided for @storeBookingTypePackage.
  ///
  /// In zh, this message translates to:
  /// **'时长套餐'**
  String get storeBookingTypePackage;

  /// No description provided for @storeBookingTypeTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择预约方式'**
  String get storeBookingTypeTitle;

  /// No description provided for @storeStartTimeAt.
  ///
  /// In zh, this message translates to:
  /// **'开始时间（营业 {hours}）'**
  String storeStartTimeAt(String hours);

  /// No description provided for @storeNoPackages.
  ///
  /// In zh, this message translates to:
  /// **'门店暂未配置时长套餐'**
  String get storeNoPackages;

  /// No description provided for @storeSelectPackage.
  ///
  /// In zh, this message translates to:
  /// **'选择套餐'**
  String get storeSelectPackage;

  /// No description provided for @storePackagePerPerson.
  ///
  /// In zh, this message translates to:
  /// **'{name} · {price}/人'**
  String storePackagePerPerson(String name, String price);

  /// No description provided for @storePackageMemberPerPerson.
  ///
  /// In zh, this message translates to:
  /// **'{name} · 会员 {price}/人'**
  String storePackageMemberPerPerson(String name, String price);

  /// No description provided for @storePackageMemberFree.
  ///
  /// In zh, this message translates to:
  /// **'{name} · 会员免费'**
  String storePackageMemberFree(String name);

  /// No description provided for @storeAllDay.
  ///
  /// In zh, this message translates to:
  /// **'全天不限时'**
  String get storeAllDay;

  /// No description provided for @storeAllDayDesc.
  ///
  /// In zh, this message translates to:
  /// **'营业时间（{hours}）内不限时长，到店扫码即开始计时'**
  String storeAllDayDesc(String hours);

  /// No description provided for @storeNextSelectTable.
  ///
  /// In zh, this message translates to:
  /// **'下一步 · 选择桌位'**
  String get storeNextSelectTable;

  /// No description provided for @storeMemberGroupLabel.
  ///
  /// In zh, this message translates to:
  /// **'会员+同行 \$'**
  String get storeMemberGroupLabel;

  /// No description provided for @storeGroupLabel.
  ///
  /// In zh, this message translates to:
  /// **'同行价 \$'**
  String get storeGroupLabel;

  /// No description provided for @storeUnitLabel.
  ///
  /// In zh, this message translates to:
  /// **'单价 \$'**
  String get storeUnitLabel;

  /// No description provided for @storePerPerson.
  ///
  /// In zh, this message translates to:
  /// **' / 人 × {count}'**
  String storePerPerson(int count);

  /// No description provided for @storeMemberPlus.
  ///
  /// In zh, this message translates to:
  /// **' + \${price}×{count}'**
  String storeMemberPlus(String price, int count);

  /// No description provided for @storeSurchargeHint.
  ///
  /// In zh, this message translates to:
  /// **'含周末/节假日加价 {pct}%'**
  String storeSurchargeHint(int pct);

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
  /// **'确认预约'**
  String get storeConfirmOrder;

  /// No description provided for @storePricePerHourShort.
  ///
  /// In zh, this message translates to:
  /// **'{price}/时·人'**
  String storePricePerHourShort(String price);

  /// No description provided for @storeMinHours.
  ///
  /// In zh, this message translates to:
  /// **'1 小时起'**
  String get storeMinHours;

  /// No description provided for @storeUnitPerPerson.
  ///
  /// In zh, this message translates to:
  /// **'{price}/人'**
  String storeUnitPerPerson(String price);

  /// No description provided for @storeTableInRecommendation.
  ///
  /// In zh, this message translates to:
  /// **'该桌已在推荐组合中'**
  String get storeTableInRecommendation;

  /// No description provided for @storeKeepRecommendation.
  ///
  /// In zh, this message translates to:
  /// **'请保持推荐规格（可切换同规格桌位编号）'**
  String get storeKeepRecommendation;

  /// No description provided for @storeTableCapacity.
  ///
  /// In zh, this message translates to:
  /// **'{count}人'**
  String storeTableCapacity(int count);

  /// No description provided for @storeTableFull.
  ///
  /// In zh, this message translates to:
  /// **'满'**
  String get storeTableFull;

  /// No description provided for @storeNoTableCombo.
  ///
  /// In zh, this message translates to:
  /// **'当前时段没有合适的桌位组合，请调整时段或联系门店'**
  String get storeNoTableCombo;

  /// No description provided for @storeRecommendedTables.
  ///
  /// In zh, this message translates to:
  /// **'推荐桌位：{names} · 可容纳 {capacity} 人'**
  String storeRecommendedTables(String names, int capacity);

  /// No description provided for @storeCapacityInsufficient.
  ///
  /// In zh, this message translates to:
  /// **'容量不足，请再选桌位'**
  String get storeCapacityInsufficient;

  /// No description provided for @storeLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'加载失败，请确认后端服务已启动'**
  String get storeLoadFailed;

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

  /// No description provided for @appointmentStatusCurrentLabel.
  ///
  /// In zh, this message translates to:
  /// **'当前状态：{status}'**
  String appointmentStatusCurrentLabel(String status);

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

  /// No description provided for @appointmentCancelDesc.
  ///
  /// In zh, this message translates to:
  /// **'取消后该时段名额将释放，确定取消吗？'**
  String get appointmentCancelDesc;

  /// No description provided for @appointmentCancelConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认取消'**
  String get appointmentCancelConfirm;

  /// No description provided for @appointmentCancelled.
  ///
  /// In zh, this message translates to:
  /// **'预约已取消'**
  String get appointmentCancelled;

  /// No description provided for @appointmentBookingType.
  ///
  /// In zh, this message translates to:
  /// **'预约方式'**
  String get appointmentBookingType;

  /// No description provided for @appointmentOriginalPrice.
  ///
  /// In zh, this message translates to:
  /// **'原价'**
  String get appointmentOriginalPrice;

  /// No description provided for @appointmentCoupon.
  ///
  /// In zh, this message translates to:
  /// **'优惠券'**
  String get appointmentCoupon;

  /// No description provided for @appointmentPayable.
  ///
  /// In zh, this message translates to:
  /// **'应付金额'**
  String get appointmentPayable;

  /// No description provided for @appointmentViewQr.
  ///
  /// In zh, this message translates to:
  /// **'查看二维码'**
  String get appointmentViewQr;

  /// No description provided for @appointmentRemainingTime.
  ///
  /// In zh, this message translates to:
  /// **'剩余时间（扫码即开始计时，不顺延）'**
  String get appointmentRemainingTime;

  /// No description provided for @appointmentClockOutEnd.
  ///
  /// In zh, this message translates to:
  /// **'下钟结束'**
  String get appointmentClockOutEnd;

  /// No description provided for @appointmentShowStaff.
  ///
  /// In zh, this message translates to:
  /// **'出示给店员扫码核销'**
  String get appointmentShowStaff;

  /// No description provided for @appointmentCodeLabel.
  ///
  /// In zh, this message translates to:
  /// **'预约码'**
  String get appointmentCodeLabel;

  /// No description provided for @appointmentQrRefresh.
  ///
  /// In zh, this message translates to:
  /// **'二维码每 30 秒自动刷新'**
  String get appointmentQrRefresh;

  /// No description provided for @appointmentValidUntilAt.
  ///
  /// In zh, this message translates to:
  /// **'有效期至 {time}'**
  String appointmentValidUntilAt(String time);

  /// No description provided for @appointmentQrDestroyed.
  ///
  /// In zh, this message translates to:
  /// **'二维码已销毁'**
  String get appointmentQrDestroyed;

  /// No description provided for @appointmentQrDestroyedHint.
  ///
  /// In zh, this message translates to:
  /// **'该核销码已使用，无法再次核销'**
  String get appointmentQrDestroyedHint;

  /// No description provided for @appointmentServiceEnd.
  ///
  /// In zh, this message translates to:
  /// **'体验结束'**
  String get appointmentServiceEnd;

  /// No description provided for @appointmentServiceEndDesc.
  ///
  /// In zh, this message translates to:
  /// **'已为您记录本次体验时长，欢迎再次光临'**
  String get appointmentServiceEndDesc;

  /// No description provided for @appointmentStore.
  ///
  /// In zh, this message translates to:
  /// **'门店'**
  String get appointmentStore;

  /// No description provided for @appointmentTablePeople.
  ///
  /// In zh, this message translates to:
  /// **'桌位 / 人数'**
  String get appointmentTablePeople;

  /// No description provided for @appointmentStartTime.
  ///
  /// In zh, this message translates to:
  /// **'上钟时间'**
  String get appointmentStartTime;

  /// No description provided for @appointmentEndTime.
  ///
  /// In zh, this message translates to:
  /// **'下钟时间'**
  String get appointmentEndTime;

  /// No description provided for @appointmentPayAtStore.
  ///
  /// In zh, this message translates to:
  /// **'到店支付 {amount}'**
  String appointmentPayAtStore(String amount);

  /// No description provided for @appointmentPayMemberFree.
  ///
  /// In zh, this message translates to:
  /// **'到店支付 \$0（会员免费）'**
  String get appointmentPayMemberFree;

  /// No description provided for @bookingTypeHours.
  ///
  /// In zh, this message translates to:
  /// **'{hours} 小时'**
  String bookingTypeHours(int hours);

  /// No description provided for @bookingTypePackage.
  ///
  /// In zh, this message translates to:
  /// **'{name} · {hours} 小时'**
  String bookingTypePackage(String name, int hours);

  /// No description provided for @bookingTypeAllDay.
  ///
  /// In zh, this message translates to:
  /// **'全天不限时'**
  String get bookingTypeAllDay;

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

  /// No description provided for @appointmentPeopleCountLabel.
  ///
  /// In zh, this message translates to:
  /// **'人数'**
  String get appointmentPeopleCountLabel;

  /// No description provided for @appointmentNoOnlinePay.
  ///
  /// In zh, this message translates to:
  /// **'无需线上支付，预约成功后到店出示核销码，核销后线下付款'**
  String get appointmentNoOnlinePay;

  /// No description provided for @appointmentSurchargeLabel.
  ///
  /// In zh, this message translates to:
  /// **'周末/节假日加价 {pct}%'**
  String appointmentSurchargeLabel(int pct);

  /// No description provided for @discountMember.
  ///
  /// In zh, this message translates to:
  /// **'会员优惠'**
  String get discountMember;

  /// No description provided for @discountGroup.
  ///
  /// In zh, this message translates to:
  /// **'同行优惠'**
  String get discountGroup;

  /// No description provided for @discountMemberGroup.
  ///
  /// In zh, this message translates to:
  /// **'会员/同行优惠'**
  String get discountMemberGroup;

  /// No description provided for @commonPackage.
  ///
  /// In zh, this message translates to:
  /// **'套餐'**
  String get commonPackage;

  /// No description provided for @activitySession.
  ///
  /// In zh, this message translates to:
  /// **'活动场次'**
  String get activitySession;

  /// No description provided for @activityBooking.
  ///
  /// In zh, this message translates to:
  /// **'活动预约'**
  String get activityBooking;

  /// No description provided for @storeBooking.
  ///
  /// In zh, this message translates to:
  /// **'门店预约'**
  String get storeBooking;

  /// No description provided for @appointmentPeople.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人'**
  String appointmentPeople(int count);

  /// No description provided for @appointmentTable.
  ///
  /// In zh, this message translates to:
  /// **'桌位'**
  String get appointmentTable;

  /// No description provided for @appointmentSeat.
  ///
  /// In zh, this message translates to:
  /// **'座位'**
  String get appointmentSeat;

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
  /// **'下钟后将停止计时并生成完成记录，确认结束本次体验吗？'**
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
  String appointmentQrCode(String code);

  /// No description provided for @activityTitle.
  ///
  /// In zh, this message translates to:
  /// **'活动'**
  String get activityTitle;

  /// No description provided for @activityListTitle.
  ///
  /// In zh, this message translates to:
  /// **'活动专区'**
  String get activityListTitle;

  /// No description provided for @activityDetailTitle.
  ///
  /// In zh, this message translates to:
  /// **'活动详情'**
  String get activityDetailTitle;

  /// No description provided for @activityBook.
  ///
  /// In zh, this message translates to:
  /// **'预约活动'**
  String get activityBook;

  /// No description provided for @activityPeople.
  ///
  /// In zh, this message translates to:
  /// **'{count} 人'**
  String activityPeople(int count);

  /// No description provided for @activityMemberOnly.
  ///
  /// In zh, this message translates to:
  /// **'限会员'**
  String get activityMemberOnly;

  /// No description provided for @activityBookable.
  ///
  /// In zh, this message translates to:
  /// **'可预约'**
  String get activityBookable;

  /// No description provided for @activityDescPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'活动详情敬请期待'**
  String get activityDescPlaceholder;

  /// No description provided for @activityPrice.
  ///
  /// In zh, this message translates to:
  /// **'价格'**
  String get activityPrice;

  /// No description provided for @activitySelectSession.
  ///
  /// In zh, this message translates to:
  /// **'选择场次'**
  String get activitySelectSession;

  /// No description provided for @activityRemaining.
  ///
  /// In zh, this message translates to:
  /// **'剩余 {remain}/{capacity}'**
  String activityRemaining(int remain, int capacity);

  /// No description provided for @activityNoteHint.
  ///
  /// In zh, this message translates to:
  /// **'备注（选填），如：两人同行'**
  String get activityNoteHint;

  /// No description provided for @activityNotBookable.
  ///
  /// In zh, this message translates to:
  /// **'该活动暂不支持线上预约，敬请期待'**
  String get activityNotBookable;

  /// No description provided for @activityEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无活动'**
  String get activityEmpty;

  /// No description provided for @activityCardDescPlaceholder.
  ///
  /// In zh, this message translates to:
  /// **'详情敬请期待'**
  String get activityCardDescPlaceholder;

  /// No description provided for @activityPricePerPerson.
  ///
  /// In zh, this message translates to:
  /// **'{price}/人'**
  String activityPricePerPerson(String price);

  /// No description provided for @activityNoSessions.
  ///
  /// In zh, this message translates to:
  /// **'暂无可约场次'**
  String get activityNoSessions;

  /// No description provided for @activityFull.
  ///
  /// In zh, this message translates to:
  /// **'已满员'**
  String get activityFull;

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

  /// No description provided for @notificationInteract.
  ///
  /// In zh, this message translates to:
  /// **'互动'**
  String get notificationInteract;

  /// No description provided for @notificationSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统消息'**
  String get notificationSystem;

  /// No description provided for @notificationMarkAllRead.
  ///
  /// In zh, this message translates to:
  /// **'已全部标记为已读'**
  String get notificationMarkAllRead;

  /// No description provided for @notificationCommunitySoon.
  ///
  /// In zh, this message translates to:
  /// **'社区功能暂未开放'**
  String get notificationCommunitySoon;

  /// No description provided for @notificationReelsSoon.
  ///
  /// In zh, this message translates to:
  /// **'Reels 功能暂未开放'**
  String get notificationReelsSoon;

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

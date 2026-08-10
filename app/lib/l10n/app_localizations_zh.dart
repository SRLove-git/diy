// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Think Origin';

  @override
  String get commonSave => '保存';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonDone => '完成';

  @override
  String get commonBack => '返回';

  @override
  String get commonRetry => '重试';

  @override
  String get commonLoading => '加载中…';

  @override
  String get commonEmpty => '暂无数据';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonDelete => '删除';

  @override
  String get commonSearch => '搜索';

  @override
  String get commonRefresh => '刷新';

  @override
  String get commonCopy => '复制';

  @override
  String get commonClose => '关闭';

  @override
  String get commonAll => '全部';

  @override
  String get tabHome => '首页';

  @override
  String get tabProfile => '我的';

  @override
  String get loginTitle => 'Think Origin';

  @override
  String get loginAccountHint => '用户名 / 邮箱';

  @override
  String get loginPasswordHint => '请输入密码';

  @override
  String get loginSlogan => '发现手作 · 遇见同好';

  @override
  String get loginForgotQuestion => '忘记密码？';

  @override
  String get loginAgreeTerms => '注册即代表同意《用户协议》和《隐私政策》';

  @override
  String get loginButton => '登录';

  @override
  String get loginForgot => '忘记密码';

  @override
  String get loginRegisterLink => '注册新账号';

  @override
  String get loginNeedAccount => '请输入用户名或邮箱';

  @override
  String get loginNeedPassword => '请输入密码';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get registerTitle => '注册';

  @override
  String get registerUsernameHint => '用户名（2-30 位，字母/数字/下划线）';

  @override
  String get registerDesc => '用用户名和密码注册，绑定邮箱用于找回密码';

  @override
  String get registerEmailHint => '绑定邮箱';

  @override
  String get registerCodeHint => '邮箱验证码';

  @override
  String get registerSendCode => '获取验证码';

  @override
  String registerResendIn(int count) {
    return '${count}s 后重发';
  }

  @override
  String get registerPasswordHint => '设置密码（6-32 位）';

  @override
  String get registerConfirmHint => '确认密码';

  @override
  String get registerButton => '注册并登录';

  @override
  String get registerToLogin => '已有账号？去登录';

  @override
  String get registerEmailHintFull => '邮箱（用于绑定和找回密码）';

  @override
  String get registerSuccess => '注册成功，欢迎加入 Think Origin';

  @override
  String get needValidEmail => '请输入正确的邮箱';

  @override
  String get needCode6 => '请输入 6 位验证码';

  @override
  String get usernameInvalid => '用户名需为 2-30 位字母、数字或下划线';

  @override
  String get passwordMin6 => '密码至少 6 位';

  @override
  String get passwordMismatch => '两次输入的密码不一致';

  @override
  String get sendCodeSent => '验证码已发送';

  @override
  String sendCodeSentDev(String code) {
    return '验证码已发送（开发环境：$code）';
  }

  @override
  String get resetPasswordSuccess => '密码重置成功，请重新登录';

  @override
  String get forgotTitle => '忘记密码';

  @override
  String get forgotDesc => '通过绑定邮箱验证后设置新密码';

  @override
  String get forgotResetButton => '重置密码';

  @override
  String get forgotBackToLogin => '返回登录';

  @override
  String get forgotNewPassword => '设置新密码（6-32 位）';

  @override
  String get changePasswordTitle => '修改登录密码';

  @override
  String get changePasswordDesc => '验证原密码后设置新密码，下次登录请使用新密码';

  @override
  String get changePasswordOld => '原密码';

  @override
  String get changePasswordNew => '新密码（6-32 位）';

  @override
  String get changePasswordConfirm => '确认新密码';

  @override
  String get changePasswordButton => '确认修改';

  @override
  String get changePasswordNeedOld => '请输入原密码';

  @override
  String get changePasswordMin => '新密码至少 6 位';

  @override
  String get changePasswordMismatch => '两次输入的新密码不一致';

  @override
  String get changePasswordSuccess => '密码修改成功';

  @override
  String get settingsTitle => '设置';

  @override
  String get settingsAccountSecurity => '账号与安全';

  @override
  String get settingsGeneral => '通用';

  @override
  String get settingsAbout => '关于';

  @override
  String get settingsEmail => '邮箱';

  @override
  String get settingsNotBound => '未绑定';

  @override
  String get settingsBound => '已绑定';

  @override
  String get settingsUsername => '用户名';

  @override
  String get settingsNotSet => '未设置';

  @override
  String get settingsSet => '已设置';

  @override
  String get settingsLoginPassword => '登录密码';

  @override
  String get settingsLoginPasswordSub => '已设置 · 可用密码登录';

  @override
  String get settingsSwitchAccount => '切换账号';

  @override
  String get settingsSwitchAccountSub => '登录其他账号';

  @override
  String get settingsSwitchConfirmTitle => '切换账号';

  @override
  String get settingsSwitchConfirmDesc =>
      '切换账号将退出当前账号并返回登录页，需要重新登录后才能继续，确定切换吗？';

  @override
  String get settingsSwitchAction => '切换账号';

  @override
  String get settingsNotifications => '消息通知';

  @override
  String get settingsNotificationsSub => '互动、系统消息提醒';

  @override
  String get settingsVersion => '版本';

  @override
  String get settingsLogout => '退出登录';

  @override
  String get settingsUserAgreement => '用户协议';

  @override
  String get settingsPrivacyPolicy => '隐私政策';

  @override
  String get settingsUserAgreementSoon => '用户协议敬请期待';

  @override
  String get settingsPrivacyPolicySoon => '隐私政策敬请期待';

  @override
  String get settingsLogoutConfirmTitle => '退出登录';

  @override
  String get settingsLogoutConfirmDesc => '退出后需要重新登录，才能查看消息、预约和会员信息，确定退出吗？';

  @override
  String get settingsLogoutAction => '退出登录';

  @override
  String get settingsScrollHint => '下拉查看关于与退出登录';

  @override
  String get profileTitle => '我的';

  @override
  String get profileEdit => '编辑资料';

  @override
  String get profileMyAppointments => '我的预约';

  @override
  String get profileCardWallet => '我的卡包';

  @override
  String get profileCardWalletDesc => '优惠券 · 会员体验';

  @override
  String get profileCardOrders => '我的订单';

  @override
  String get profileCardOrdersDesc => '预约 · 体验记录';

  @override
  String get profileCardSettings => '设置';

  @override
  String get profileCardSettingsDesc => '账号与安全 · 通用';

  @override
  String get profileServices => '我的服务';

  @override
  String get profileMoreComingSoon => '更多服务持续上线';

  @override
  String profileJoined(String year, String month) {
    return 'Think Origin $year 年 $month 月入驻';
  }

  @override
  String get profileMemberCenter => '会员中心';

  @override
  String get profileEditTitle => '编辑资料';

  @override
  String get profileEditNickname => '昵称';

  @override
  String get profileEditUsername => '用户名';

  @override
  String get profileEditUsernameHint => '用户名一年内只能修改一次，设置后可用于用户名+密码登录';

  @override
  String get profileEditBio => '简介';

  @override
  String get profileEditLocation => '所在地';

  @override
  String get profileEditBirthday => '生日';

  @override
  String get profileEditGender => '性别';

  @override
  String get profileEditBioHint => '简介：拼豆手作爱好者，治愈系手工';

  @override
  String get profileEditLocationHint => '请输入城市 / 地区';

  @override
  String get profileEditMe => '我';

  @override
  String get genderMale => '男';

  @override
  String get genderFemale => '女';

  @override
  String get genderSecret => '保密';

  @override
  String get profileEditAvatarUploading => '头像上传中，请稍候再保存';

  @override
  String get profileSaveSuccess => '保存成功';

  @override
  String get profileAvatarPickFailed => '选择头像失败';

  @override
  String get commonOk => '确定';

  @override
  String get homeOrders => '我的订单';

  @override
  String get homeStoreSection => '拼豆';

  @override
  String get homeStoreSectionBadge => '人气手作';

  @override
  String get homeBookNow => '预约';

  @override
  String get homeBookNowDesc => '附近门店 / 活动';

  @override
  String get homeCheckIn => '到店';

  @override
  String get homeCheckInDesc => '核销 · 上钟';

  @override
  String get homeMember => '会员套餐';

  @override
  String get homeMemberDesc => '权益 · 优惠';

  @override
  String get homeComingSoon => '敬请期待';

  @override
  String get homeComingSoonMore => '更多活动敬请期待';

  @override
  String get homeActivitySection => '活动推荐';

  @override
  String get homeViewAll => '查看全部 ›';

  @override
  String get homeNoActivities => '暂无活动，敬请期待';

  @override
  String get homeWaitingConfirm => '待确认';

  @override
  String get homeWaitingChip => '等待确认';

  @override
  String get homeWaitingStoreConfirm => '等待门店确认';

  @override
  String homeCode(String code) {
    return '预约码 $code';
  }

  @override
  String get homeOrderExpired => '订单已失效';

  @override
  String get homeToCheckIn => '到店核销';

  @override
  String homeStartedAt(String date, String time, String duration) {
    return '$date $time 上钟$duration';
  }

  @override
  String get homeAllDaySuffix => ' · 全天不限时';

  @override
  String homeHourSuffix(int hours) {
    return ' · $hours 小时';
  }

  @override
  String get commonLoadFailed => '加载失败';

  @override
  String get weekdayMon => '周一';

  @override
  String get weekdayTue => '周二';

  @override
  String get weekdayWed => '周三';

  @override
  String get weekdayThu => '周四';

  @override
  String get weekdayFri => '周五';

  @override
  String get weekdaySat => '周六';

  @override
  String get weekdaySun => '周日';

  @override
  String get memberCenterTitle => '会员中心';

  @override
  String get memberBenefits => '会员权益';

  @override
  String get memberOpenRenew => '开通 / 续费';

  @override
  String get memberNotOpened => '未开通';

  @override
  String get memberExpired => '已过期';

  @override
  String memberPendingHint(int count) {
    return '有 $count 笔会员开通申请待门店确认，到店支付费用后将为你开通';
  }

  @override
  String get memberPurchaseTitle => '开通会员';

  @override
  String memberPurchaseDays(int days) {
    return '$days 天有效期';
  }

  @override
  String get memberPayDetails => '支付明细';

  @override
  String get memberOriginalPrice => '套餐原价';

  @override
  String get memberDiscount => '限时优惠';

  @override
  String get memberPayAmount => '实付金额';

  @override
  String get memberOfflinePayHint => '线上下单，到店支付：提交订单后到店支付会员费用即可开通';

  @override
  String get memberSubmitOrder => '提交订单';

  @override
  String get memberThinkAgain => '再想想';

  @override
  String get memberAgreeTerms => '提交订单即代表同意《会员服务协议》';

  @override
  String get memberOrderSubmitted => '订单已提交';

  @override
  String get memberWaitingConfirm => '等待门店确认';

  @override
  String get memberOrderSubmittedDesc => '到店支付会员费用后，由门店确认开通\n开通后即可享受会员权益';

  @override
  String get storeListTitle => '门店列表';

  @override
  String get storeSearchPlaceholder => '搜索门店';

  @override
  String get storeEmpty => '暂无门店，请先到管理后台添加';

  @override
  String get storeBookingTitle => '预约';

  @override
  String get storePeopleCount => '到店人数';

  @override
  String get storeUnitPrice => '单价';

  @override
  String get storeGroupPrice => '同行价';

  @override
  String get storeMemberPrice => '会员';

  @override
  String get storeSelectTable => '选择桌位';

  @override
  String get storeConfirmOrder => '提交预约';

  @override
  String get appointmentMyTitle => '我的预约';

  @override
  String get appointmentTabAll => '全部';

  @override
  String get appointmentTabBooked => '待核销';

  @override
  String get appointmentTabInService => '服务中';

  @override
  String get appointmentTabCompleted => '已完成';

  @override
  String get appointmentTabPending => '待确认';

  @override
  String get appointmentStatusBooked => '待核销';

  @override
  String get appointmentStatusCheckedIn => '已核销';

  @override
  String get appointmentStatusInService => '服务中';

  @override
  String get appointmentStatusCompleted => '已完成';

  @override
  String get appointmentStatusCancelled => '已取消';

  @override
  String get appointmentStatusPending => '待确认';

  @override
  String get appointmentWaitingConfirm => '等待门店确认';

  @override
  String get appointmentWaitingDesc => '预约已提交，门店确认后即可到店核销';

  @override
  String get appointmentCheckInCode => '核销码';

  @override
  String get appointmentToCheckIn => '到店核销';

  @override
  String get appointmentShowCode => '出示预约码，店员扫码或输入验证码开始体验';

  @override
  String get appointmentExpired => '订单已失效';

  @override
  String get appointmentExpiredDesc => '已超过预约时间，无法再核销';

  @override
  String get appointmentCancel => '取消预约';

  @override
  String get appointmentCancelled => '预约已取消';

  @override
  String get appointmentBookSuccess => '预约成功';

  @override
  String get appointmentBookSubmitted => '预约已提交';

  @override
  String get appointmentBookSuccessDesc => '到店出示此码即可核销体验，核销后线下付款';

  @override
  String get appointmentBookSubmittedDesc => '预约已提交，门店在管理端确认后\n到店出示预约码即可核销体验';

  @override
  String get appointmentView => '查看预约';

  @override
  String get appointmentBackHome => '返回首页';

  @override
  String get appointmentDetailTitle => '预约详情';

  @override
  String get appointmentProgress => '预约进度';

  @override
  String get appointmentInfo => '订单信息';

  @override
  String get appointmentItem => '预约项目';

  @override
  String get appointmentTime => '预约时间';

  @override
  String appointmentPeople(int count) {
    return '$count 人';
  }

  @override
  String get appointmentTable => '桌位';

  @override
  String get appointmentPayMethod => '付款方式';

  @override
  String get appointmentPayOffline => '到店核销后付款';

  @override
  String get appointmentAmount => '金额';

  @override
  String get appointmentNote => '备注';

  @override
  String get appointmentCodeCopied => '预约码已复制';

  @override
  String get appointmentCheckInScan => '扫码核销';

  @override
  String get appointmentDetail => '查看详情';

  @override
  String get appointmentBookAgain => '再次预约';

  @override
  String get appointmentEmpty => '暂无预约，去预约一个体验吧';

  @override
  String get appointmentPendingOnly => '暂无待核销预约';

  @override
  String get appointmentConfirmTitle => '确认预约';

  @override
  String get appointmentSubmit => '提交预约';

  @override
  String get appointmentClockOutTitle => '结束体验';

  @override
  String get appointmentClockOutDesc => '点击确认下钟后将停止计时';

  @override
  String get appointmentClockOutConfirm => '确认下钟';

  @override
  String get appointmentClockOutThink => '再想想';

  @override
  String get appointmentOrderExpired => '订单已失效';

  @override
  String get appointmentShowQr => '到店出示二维码核销';

  @override
  String appointmentQrCode(String code) {
    return '核销码 $code';
  }

  @override
  String get activityTitle => '活动';

  @override
  String get activityBook => '预约活动';

  @override
  String activityPeople(int count) {
    return '$count 人';
  }

  @override
  String get notificationTitle => '通知';

  @override
  String get notificationEmpty => '暂无通知';

  @override
  String get notLoggedIn => '请先登录';

  @override
  String get noStore => '暂无门店';

  @override
  String get serverError => '网络异常，请稍后重试';
}

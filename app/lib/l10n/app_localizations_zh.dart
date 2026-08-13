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
  String commonUserId(int id) {
    return '用户 #$id';
  }

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
  String get loginAgreeTerms => '注册即代表同意《用户协议》和《隐私政策》';

  @override
  String get loginButton => '登录';

  @override
  String get loginRegisterLink => '注册新账号';

  @override
  String get loginNeedAccount => '请输入用户名或邮箱';

  @override
  String get loginNeedPassword => '请输入密码';

  @override
  String get loginSuccess => '登录成功';

  @override
  String get loginRecentAccounts => '最近登录账号';

  @override
  String get loginCaptchaHint => '图形验证码';

  @override
  String get loginCaptchaRefresh => '点击刷新验证码';

  @override
  String get loginCaptchaError => '请输入图形验证码';

  @override
  String get loginCaptchaExpired => '验证码已失效，请刷新后重试';

  @override
  String get registerTitle => '注册';

  @override
  String get registerUsernameHint => '用户名（2-30 位，字母/数字/下划线）';

  @override
  String get registerDesc => '用用户名和密码注册';

  @override
  String get registerEmailHint => '绑定邮箱';

  @override
  String get registerPasswordHint => '设置密码（6-32 位）';

  @override
  String get registerConfirmHint => '确认密码';

  @override
  String get registerButton => '注册并登录';

  @override
  String get registerToLogin => '已有账号？去登录';

  @override
  String get registerEmailHintFull => '邮箱';

  @override
  String get registerSuccess => '注册成功，欢迎加入 Think Origin';

  @override
  String get needValidEmail => '请输入正确的邮箱';

  @override
  String get usernameInvalid => '用户名需为 2-30 位字母、数字或下划线';

  @override
  String get passwordMin6 => '密码至少 6 位';

  @override
  String get passwordMismatch => '两次输入的密码不一致';

  @override
  String get changePasswordTitle => '修改登录密码';

  @override
  String get changePasswordAppBar => '修改密码';

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
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '跟随系统';

  @override
  String get settingsLanguageChinese => '中文';

  @override
  String get settingsLanguageEnglish => 'English';

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
  String get settingsSwitchCurrent => '当前账号';

  @override
  String get settingsSwitchOther => '其他账号';

  @override
  String get settingsSwitchCurrentTag => '当前';

  @override
  String get settingsSwitchSuccess => '已切换账号';

  @override
  String get switchSessionExpired => '该账号登录已过期，请重新登录';

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
  String get adminStoreSection => '门店管理';

  @override
  String get adminStoreBadge => '管理员';

  @override
  String get adminRedeem => '扫码核销';

  @override
  String get adminRedeemDesc => '预约 · 券码';

  @override
  String get adminOrders => '订单管理';

  @override
  String get adminOrdersDesc => '预约 · 会员订单';

  @override
  String get adminMembers => '会员运营';

  @override
  String get adminMembersDesc => '会员 · 套餐 · 优惠券';

  @override
  String get adminOrdersTab => '预约订单';

  @override
  String get adminMemberOrdersTab => '会员订单';

  @override
  String get adminMembersTab => '会员列表';

  @override
  String get adminPlansTab => '套餐';

  @override
  String get adminCouponsTab => '优惠券';

  @override
  String get adminAddCoupon => '新增优惠券';

  @override
  String get adminAddPlan => '新增套餐';

  @override
  String get adminAllCanClaim => '全员可领';

  @override
  String get adminAllStores => '全部门店';

  @override
  String get adminAmountHint => '20 / 8.8 折';

  @override
  String get adminAmountText => '面额文案';

  @override
  String get adminAppointmentCheckedIn => '核销成功，已开始服务';

  @override
  String get adminAppointmentConfirmed => '已确认预约';

  @override
  String get adminApptHintCancelled => '该预约已取消';

  @override
  String get adminApptHintCheckedIn => '该预约已核销 / 服务中，无需重复核销';

  @override
  String get adminApptHintCompleted => '该预约已完成';

  @override
  String get adminApptHintPending => '该预约待门店确认，确认后方可核销';

  @override
  String get adminBadge => '角标';

  @override
  String get adminBadgeHint => '推荐 / 最划算';

  @override
  String get adminBenefitsHint => '全场消费8折专属优惠';

  @override
  String get adminBenefitsLabel => '权益列表（一行一条）';

  @override
  String adminCancelMemberOrderDesc(String plan) {
    return '确定取消「$plan」的开通申请吗？';
  }

  @override
  String get adminCancelMemberOrderTitle => '取消开通申请';

  @override
  String adminCancelAppointmentDesc(String title) {
    return '确定取消「$title」的预约吗？';
  }

  @override
  String get adminCheckInTime => '核销时间';

  @override
  String get adminClockIn => '上钟';

  @override
  String get adminClockInSuccess => '已上钟，开始服务';

  @override
  String get adminClockOut => '下钟';

  @override
  String get adminClockOutSuccess => '已下钟，服务完成';

  @override
  String adminCodeShort(String code) {
    return '码 $code';
  }

  @override
  String get adminConfirmMemberAction => '确认开通';

  @override
  String adminConfirmMemberDesc(
    String user,
    String plan,
    int days,
    String amount,
  ) {
    return '确认开通 $user 的会员（$plan，$days 天，$amount）？请先确认已收取到店支付费用。';
  }

  @override
  String get adminConfirmMemberTitle => '确认开通会员';

  @override
  String get adminConfirmRedeem => '确认核销';

  @override
  String adminCouponAmountLine(String amount, String threshold) {
    return '优惠券 $amount · $threshold';
  }

  @override
  String adminCouponCodeStatus(String code, String status) {
    return '核销码 $code · $status';
  }

  @override
  String get adminCouponDisabled => '已停用优惠券';

  @override
  String adminCouponDiscount(String title, String amount) {
    return '优惠券 $title（-$amount）';
  }

  @override
  String adminCouponEmail(String email) {
    return '邮箱 $email';
  }

  @override
  String get adminCouponEnabled => '已启用优惠券';

  @override
  String get adminCouponHintExpired => '该优惠券已过期';

  @override
  String get adminCouponHintUsed => '该优惠券已核销，不可重复使用';

  @override
  String get adminCouponName => '优惠券名称';

  @override
  String get adminCouponNameHint => '全场 8 折券';

  @override
  String get adminCouponRedeemed => '优惠券核销成功';

  @override
  String get adminCouponSaved => '已保存优惠券';

  @override
  String get adminCouponStatusUnused => '未核销';

  @override
  String get adminCouponStatusUsed => '已核销';

  @override
  String adminCouponStockLine(String amount, String threshold, int stock) {
    return '$amount · $threshold · 剩余 $stock';
  }

  @override
  String adminCouponUser(String name) {
    return '用户 $name';
  }

  @override
  String get adminCouponsManage => '优惠券管理';

  @override
  String get adminDate => '日期';

  @override
  String adminDeleteMemberDesc(String no, String name) {
    return '确认删除会员编号 $no（$name）？删除后该用户会员资格立即失效，操作不可恢复。';
  }

  @override
  String get adminDeleteMemberTitle => '删除会员记录';

  @override
  String get adminDurationDays => '时长（天）';

  @override
  String adminDurationHours(int hours) {
    return '$hours 小时';
  }

  @override
  String get adminEditCoupon => '编辑优惠券';

  @override
  String get adminEditMember => '编辑会员';

  @override
  String get adminEditPlan => '编辑套餐';

  @override
  String get adminEmail => '邮箱';

  @override
  String get adminExpireTime => '到期时间';

  @override
  String get adminFillByPlan => '按套餐快捷填充';

  @override
  String adminLastUpdated(String time) {
    return '最近更新 $time';
  }

  @override
  String get adminLevelDefault => '手作会员';

  @override
  String get adminMemberConfirmed => '已确认开通';

  @override
  String get adminMemberCreated => '已开通会员';

  @override
  String get adminMemberDeleted => '已删除会员记录';

  @override
  String get adminMemberLevel => '会员等级';

  @override
  String get adminMemberOrderCancelled => '已取消开通申请';

  @override
  String adminMemberOrderId(int id) {
    return '会员订单 #$id';
  }

  @override
  String get adminMemberOrdersNo => '暂无会员订单';

  @override
  String get adminMemberSaved => '已保存会员信息';

  @override
  String get adminMemberStatusConfirmed => '已开通';

  @override
  String get adminMembersOnly => '仅会员';

  @override
  String get adminMembersOnlyClaim => '仅会员可领';

  @override
  String get adminNeedCouponFields => '请填写名称、面额和门槛';

  @override
  String get adminNeedExpire => '请选择有效期';

  @override
  String get adminNeedExpireTime => '请选择到期时间';

  @override
  String get adminNeedPlanDays => '请输入正确的时长（天）';

  @override
  String get adminNeedPlanName => '请输入套餐名称';

  @override
  String get adminNeedPlanPrice => '请输入正确的价格';

  @override
  String get adminNeedStock => '请输入正确的库存';

  @override
  String get adminNeedThresholdNumber => '门槛请填写数字（0 表示无门槛）';

  @override
  String get adminNeedUserId => '请输入用户 ID';

  @override
  String get adminNoCoupons => '暂无优惠券';

  @override
  String get adminNoMembers => '暂无会员';

  @override
  String get adminNoMore => '没有更多了';

  @override
  String get adminNoOrders => '暂无订单';

  @override
  String get adminNoPlanHint => '不按套餐，手动选择有效期';

  @override
  String get adminNoPlanShort => '不按套餐';

  @override
  String get adminNoPlans => '暂无套餐';

  @override
  String get adminOpenMember => '开通会员';

  @override
  String adminPlanDays(String plan, int days) {
    return '$plan · $days 天';
  }

  @override
  String get adminPlanDisabled => '已下架套餐';

  @override
  String adminPlanDurationPrice(int days, String price) {
    return '$days 天 · $price';
  }

  @override
  String get adminPlanEnabled => '已上架套餐';

  @override
  String get adminPlanName => '套餐名称';

  @override
  String get adminPlanNameHint => '月卡 / 季卡 / 年卡';

  @override
  String adminPlanOption(String name, int days) {
    return '$name（$days 天）';
  }

  @override
  String adminPlanOriginalPrice(String price) {
    return '（原价 $price）';
  }

  @override
  String get adminPlanSaved => '已保存套餐';

  @override
  String get adminPlansManage => '套餐管理';

  @override
  String get adminPrice => '售价';

  @override
  String get adminPublishNow => '立即上架';

  @override
  String get adminQuery => '查询';

  @override
  String get adminQuerying => '查询中…';

  @override
  String get adminRedeemAction => '核销';

  @override
  String get adminRedeemCodeHint => '6 位预约码 / 券码';

  @override
  String get adminRedeemCodeInvalid => '请输入 6 位核销码';

  @override
  String get adminRedeemOrEnter => '或输入核销码';

  @override
  String get adminRecommendedPlan => '推荐套餐';

  @override
  String get adminReset => '重置';

  @override
  String get adminScanAutoHint => '对准二维码，自动识别核销码';

  @override
  String get adminScanHint => '对准预约码 / 券码二维码，自动识别';

  @override
  String get adminScanPrompt => '扫描用户出示的二维码';

  @override
  String get adminSearchMemberHint => '搜索用户 / 会员编号';

  @override
  String get adminSearchUserHint => '搜索用户昵称 / 用户名 / 邮箱';

  @override
  String get adminSelectTime => '选择时间';

  @override
  String adminServiceDuration(String duration) {
    return '服务时长 $duration';
  }

  @override
  String get adminServiceDurationLabel => '服务时长';

  @override
  String get adminStatus => '状态';

  @override
  String get adminStock => '库存';

  @override
  String get adminThreshold => '使用门槛';

  @override
  String get adminThresholdHint => '0 表示无门槛';

  @override
  String adminThresholdMin(String amount) {
    return '满 $amount 可用';
  }

  @override
  String get adminThresholdNone => '无门槛';

  @override
  String get adminTimeSlot => '预约时段';

  @override
  String get adminTypeTable => '类型 / 桌位';

  @override
  String get adminUser => '用户';

  @override
  String get adminUserIdHint => '输入用户 ID 直接开通';

  @override
  String get adminUserIdLabel => '用户 ID';

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
  String homePriceFrom(String price) {
    return '$price 起';
  }

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
  String get commonLoadFailedHint => '加载失败，请确认后端服务已启动';

  @override
  String get commonFree => '免费';

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
  String get memberBenefitPrice => '会员专属价';

  @override
  String get memberBenefitPriceDesc => '预约与到店享会员价，最高省 \$20/次';

  @override
  String get memberBenefitActivity => '专属活动';

  @override
  String get memberBenefitActivityDesc => '会员限定活动与双倍积分';

  @override
  String get memberBenefitCoupon => '每月优惠券';

  @override
  String get memberBenefitCouponDesc => '每月自动发放专属优惠券';

  @override
  String get memberBenefitBirthday => '生日礼遇';

  @override
  String get memberBenefitBirthdayDesc => '生日当月免费体验一次';

  @override
  String get memberAgreementHint => '会员权益与规则详见《会员服务协议》';

  @override
  String memberCurrent(String level) {
    return '当前：$level';
  }

  @override
  String memberLevel(String level) {
    return '手作会员 · $level';
  }

  @override
  String get memberValidUntil => '有效期至';

  @override
  String get memberStatusActive => '有效';

  @override
  String memberRemainingDays(int days) {
    return '剩余 $days 天';
  }

  @override
  String get memberWalletTitle => '卡包 · 优惠券';

  @override
  String get memberExclusiveExperience => '会员专属体验';

  @override
  String get memberMonthlyOnce => '每月 1 次 ›';

  @override
  String get memberMoreCoupons => '领取更多优惠券';

  @override
  String get memberClaim => '领取';

  @override
  String get memberAlreadyClaimed => '已领取';

  @override
  String get memberClaimed => '领取成功';

  @override
  String get memberCouponCenter => '领券中心';

  @override
  String get memberClaimAll => '一键领取全部';

  @override
  String get memberRecommended => '推荐';

  @override
  String get memberRenew => '续费';

  @override
  String get memberOpen => '开通';

  @override
  String get memberUsable => '可使用';

  @override
  String get memberNoCoupons => '暂无优惠券，去领券中心看看';

  @override
  String get memberNoCouponsAvailable => '暂无可领取的优惠券';

  @override
  String get memberTabUnused => '未使用';

  @override
  String get memberTabUsed => '已使用';

  @override
  String get memberTabExpired => '已过期';

  @override
  String memberShowRedeemCode(String code) {
    return '出示核销码 $code';
  }

  @override
  String get memberRedeemQrHint => '到店出示二维码，店员扫码或输码核销后即视为已使用';

  @override
  String get memberNotOpened => '未开通';

  @override
  String get memberExpired => '已过期';

  @override
  String memberPendingHint(int count) {
    return '有 $count 笔会员开通申请待门店确认，到店支付费用后将为你开通';
  }

  @override
  String get memberPendingOnce => '您已提交会员开通申请，待门店确认后可再次申请';

  @override
  String get memberPurchaseTitle => '开通会员';

  @override
  String memberPurchaseDays(int days) {
    return '$days 天有效期';
  }

  @override
  String memberPlanDuration(int days) {
    return '$days 天';
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
  String get storeBookNow => '立即预约';

  @override
  String get storeNoResults => '未找到相关门店';

  @override
  String storeHourlyPerPerson(String price) {
    return '按小时 $price/人/小时';
  }

  @override
  String get storeStepDate => '选择日期';

  @override
  String get storeDuration => '时长';

  @override
  String get storeNoStartTimes => '该时段已无可约开始时间';

  @override
  String get storeStartOnScan => '到店扫码即开始计时，结束时间固定不顺延';

  @override
  String get weekdayToday => '今天';

  @override
  String get weekdayTomorrow => '明天';

  @override
  String get storeAutoTables => '自动推荐最优组合';

  @override
  String get storeNoTables => '该门店暂无可用桌位';

  @override
  String storeMemberPrefix(String price) {
    return '　会员 $price';
  }

  @override
  String get storeMemberFree => '　会员免费';

  @override
  String storeGroupPrefix(String price) {
    return '　同行 $price';
  }

  @override
  String storeAllDayPrefix(String price) {
    return '　全天 $price/人';
  }

  @override
  String get storeSearchPlaceholder => '搜索门店';

  @override
  String get storeSearchHint => '搜索门店名称 / 地址';

  @override
  String get storeEmpty => '暂无门店，请先到管理后台添加';

  @override
  String get storeDetailTitle => '门店详情';

  @override
  String get storeBookingTitle => '预约';

  @override
  String get storeBookingTypeHourly => '按小时';

  @override
  String get storeBookingTypePackage => '时长套餐';

  @override
  String get storeBookingTypeTitle => '选择预约方式';

  @override
  String storeStartTimeAt(String hours) {
    return '开始时间（营业 $hours）';
  }

  @override
  String get storeNoPackages => '门店暂未配置时长套餐';

  @override
  String get storeSelectPackage => '选择套餐';

  @override
  String storePackagePerPerson(String name, String price) {
    return '$name · $price/人';
  }

  @override
  String storePackageMemberPerPerson(String name, String price) {
    return '$name · 会员 $price/人';
  }

  @override
  String storePackageMemberFree(String name) {
    return '$name · 会员免费';
  }

  @override
  String get storeAllDay => '全天不限时';

  @override
  String storeAllDayDesc(String hours) {
    return '营业时间（$hours）内不限时长，到店扫码即开始计时';
  }

  @override
  String get storeNextSelectTable => '下一步 · 选择桌位';

  @override
  String get storeMemberGroupLabel => '会员+同行 \$';

  @override
  String get storeGroupLabel => '同行价 \$';

  @override
  String get storeUnitLabel => '单价 \$';

  @override
  String storePerPerson(int count) {
    return ' / 人 × $count';
  }

  @override
  String storeMemberPlus(String price, int count) {
    return ' + \$$price×$count';
  }

  @override
  String storeSurchargeHint(int pct) {
    return '含周末/节假日加价 $pct%';
  }

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
  String get storeConfirmOrder => '确认预约';

  @override
  String storePricePerHourShort(String price) {
    return '$price/时·人';
  }

  @override
  String get storeMinHours => '1 小时起';

  @override
  String storeUnitPerPerson(String price) {
    return '$price/人';
  }

  @override
  String get storeTableInRecommendation => '该桌已在推荐组合中';

  @override
  String get storeKeepRecommendation => '请保持推荐规格（可切换同规格桌位编号）';

  @override
  String storeTableCapacity(int count) {
    return '$count人';
  }

  @override
  String get storeTableFull => '满';

  @override
  String get storeNoTableCombo => '当前时段没有合适的桌位组合，请调整时段或联系门店';

  @override
  String storeRecommendedTables(String names, int capacity) {
    return '推荐桌位：$names · 可容纳 $capacity 人';
  }

  @override
  String get storeCapacityInsufficient => '容量不足，请再选桌位';

  @override
  String get storeLoadFailed => '加载失败，请确认后端服务已启动';

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
  String appointmentStatusCurrentLabel(String status) {
    return '当前状态：$status';
  }

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
  String get appointmentCancelDesc => '取消后该时段名额将释放，确定取消吗？';

  @override
  String get appointmentCancelConfirm => '确认取消';

  @override
  String get appointmentCancelled => '预约已取消';

  @override
  String get appointmentBookingType => '预约方式';

  @override
  String get appointmentOriginalPrice => '原价';

  @override
  String get appointmentCoupon => '优惠券';

  @override
  String get appointmentNoCoupons => '暂无可用优惠券';

  @override
  String get appointmentCouponRedeemLabel => '优惠券核销码';

  @override
  String appointmentCouponCode(String code) {
    return '优惠券码 $code';
  }

  @override
  String get appointmentCouponRedeemHint => '到店出示预约码与优惠券核销码，核销预约时一并核销优惠券';

  @override
  String get appointmentPayable => '应付金额';

  @override
  String get appointmentViewQr => '查看二维码';

  @override
  String get appointmentRemainingTime => '剩余时间（扫码即开始计时，不顺延）';

  @override
  String get appointmentClockOutEnd => '下钟结束';

  @override
  String get appointmentShowStaff => '出示给店员扫码核销';

  @override
  String get appointmentCodeLabel => '预约码';

  @override
  String get appointmentQrRefresh => '二维码每 30 秒自动刷新';

  @override
  String appointmentValidUntilAt(String time) {
    return '有效期至 $time';
  }

  @override
  String get appointmentQrDestroyed => '二维码已销毁';

  @override
  String get appointmentQrDestroyedHint => '该核销码已使用，无法再次核销';

  @override
  String get appointmentServiceEnd => '体验结束';

  @override
  String get appointmentServiceEndDesc => '已为您记录本次体验时长，欢迎再次光临';

  @override
  String get appointmentStore => '门店';

  @override
  String get appointmentTablePeople => '桌位 / 人数';

  @override
  String get appointmentStartTime => '上钟时间';

  @override
  String get appointmentEndTime => '下钟时间';

  @override
  String appointmentPayAtStore(String amount) {
    return '到店支付 $amount';
  }

  @override
  String get appointmentPayMemberFree => '到店支付 \$0（会员免费）';

  @override
  String bookingTypeHours(int hours) {
    return '$hours 小时';
  }

  @override
  String bookingTypePackage(String name, int hours) {
    return '$name · $hours 小时';
  }

  @override
  String get bookingTypeAllDay => '全天不限时';

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
  String get appointmentPeopleCountLabel => '人数';

  @override
  String get appointmentNoOnlinePay => '无需线上支付，预约成功后到店出示核销码，核销后线下付款';

  @override
  String appointmentSurchargeLabel(int pct) {
    return '周末/节假日加价 $pct%';
  }

  @override
  String get discountMember => '会员优惠';

  @override
  String get discountGroup => '同行优惠';

  @override
  String get discountMemberGroup => '会员/同行优惠';

  @override
  String get commonPackage => '套餐';

  @override
  String get activitySession => '活动场次';

  @override
  String get activityBooking => '活动预约';

  @override
  String get storeBooking => '门店预约';

  @override
  String appointmentPeople(int count) {
    return '$count 人';
  }

  @override
  String get appointmentTable => '桌位';

  @override
  String get appointmentSeat => '座位';

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
  String get appointmentClockOutDesc => '下钟后将停止计时并生成完成记录，确认结束本次体验吗？';

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
  String get activityListTitle => '活动专区';

  @override
  String get activityDetailTitle => '活动详情';

  @override
  String get activityBook => '预约活动';

  @override
  String activityPeople(int count) {
    return '$count 人';
  }

  @override
  String get activityMemberOnly => '限会员';

  @override
  String get activityBookable => '可预约';

  @override
  String get activityDescPlaceholder => '活动详情敬请期待';

  @override
  String get activityPrice => '价格';

  @override
  String get activitySelectSession => '选择场次';

  @override
  String activityRemaining(int remain, int capacity) {
    return '剩余 $remain/$capacity';
  }

  @override
  String get activityNoteHint => '备注（选填），如：两人同行';

  @override
  String get activityNotBookable => '该活动暂不支持线上预约，敬请期待';

  @override
  String get activityEmpty => '暂无活动';

  @override
  String get activityCardDescPlaceholder => '详情敬请期待';

  @override
  String activityPricePerPerson(String price) {
    return '$price/人';
  }

  @override
  String get activityNoSessions => '暂无可约场次';

  @override
  String get activityFull => '已满员';

  @override
  String get notificationTitle => '通知';

  @override
  String get notificationEmpty => '暂无通知';

  @override
  String get notificationInteract => '互动';

  @override
  String get notificationSystem => '系统消息';

  @override
  String get notificationMarkAllRead => '已全部标记为已读';

  @override
  String get notificationCommunitySoon => '社区功能暂未开放';

  @override
  String get notificationReelsSoon => 'Reels 功能暂未开放';

  @override
  String get notLoggedIn => '请先登录';

  @override
  String get noStore => '暂无门店';

  @override
  String get serverError => '网络异常，请稍后重试';
}

/// 内置法律文档全文（用户协议 / 隐私政策）。
///
/// 与仓库根目录 USER_AGREEMENT.md / USER_AGREEMENT.en.md / PRIVACY_POLICY.md 保持一致；
/// 占位内容（【】）发布前需由运营方填写。
///
/// 支持轻量标记（见 LegalDocScreen）：
/// - `# ` / `## ` / `### ` 各级标题
/// - `- ` 无序列表、`1. ` 有序列表
/// - `> ` 版本说明等弱化行
/// - `---` 分隔线（忽略）
/// - 其余为普通段落
library;

/// 用户协议全文。
const String legalUserAgreementText = r'''
# 用户协议

1. 客服邮箱 eledzhang@gmail.com
2. 客服电话 83811666
3. 注册地址 18A, Sago Street，Singapore 059017
4. 合约生效日期：2026年8月23日

如您有关于预约、取消、修改、付款或其他预约相关事宜的咨询，请通过上述联系方式联系我们的客服团队。

本合约自 2026年8月23日 起生效。用户提交预约即视为已阅读、理解并同意本预约规则的全部内容。

## 5. 退款规则

本平台采用到店核销后付款的方式。用户在线提交预约时无需支付预约费用，预约成功仅代表预约时段及相关服务已被预留，并不代表用户已经完成付款。

如用户因个人原因无法到店，请提前取消预约。由于预约时未预先收取费用，因此正常取消预约时不涉及线上退款。

如用户已经在门店完成付款，后续发生退款、价格调整或消费争议等情况，应按照门店实际退款政策处理；如需平台协助，可联系客服进行咨询。

## 6. 预约取消规则

用户可在预约开始时间前免费取消预约。如因个人原因无法按照预约时间到店，请尽早取消，以便将预约时段释放给其他用户。

如预约开始时间后，用户未到店且未提前取消预约，则视为无故缺席（No-show）。对于多次无故缺席的用户，平台或门店有权根据实际情况对其后续预约进行限制，包括但不限于限制预约、要求提前支付预约费用或采取其他合理措施。

## 7. 预约时间及迟到规则

预约开始时间及结束时间以用户预约订单中显示的时间为准。

如用户迟到，预约结束时间不会因迟到而自动顺延。例如，用户预约时间为19:00至21:00，即使用户19:30才到店，原则上预约仍于21:00结束。因用户个人原因迟到而导致实际使用时间减少的，原则上不提供额外延时或退款。

## 8. 超时使用规则

如用户在预约结束后希望继续使用场地或座位，应提前向门店工作人员提出申请。

是否可以延长使用时间，以门店当时的座位及场地情况为准。如现场仍有可用座位，用户可根据门店安排继续使用，并按照实际超出时间及门店当日适用价格支付相应费用。

如该座位在预约结束后已有其他用户预约，原用户应在预约结束时间前完成使用并离店。

## 9. 修改预约规则

如用户需要更改预约的日期、时间、人数或预约项目，应在预约开始时间前，通过平台提供的功能或联系门店提出修改申请。

预约修改是否成功，以平台系统最终显示或门店最终确认为准。如新的预约日期、时间、人数或项目对应的价格发生变化，用户应按照修改后的实际价格进行结算。

## 10. 到店核销规则

用户到店后，应向门店工作人员出示预约订单、预约码或其他有效预约信息进行核销。完成核销后，用户按照门店实际消费情况进行付款。

实际应付金额以实际到店人数、实际使用时间、所选择的预约项目或套餐，以及当日适用价格为准。

## 11. 门店取消预约规则

如因门店临时闭店、场地安排、设备故障或其他门店原因导致原预约无法正常进行，门店将尽可能提前通知用户。

对于受影响的预约，用户可根据实际情况选择更换其他可用时间或取消本次预约。

由于此类情况下用户尚未完成付款，因此取消预约通常不涉及退款。

## 12. 预约成功说明

用户收到预约成功通知后，即代表系统已经成功记录并预留相应的预约时段。

预约成功不代表已付款。

用户应按照预约订单显示的日期及时间到店，并在完成核销后按照实际消费金额进行付款。

## 13. 价格及优惠规则

不同日期、时间段、人数、预约方式、套餐、会员身份及优惠活动可能对应不同价格。

如涉及会员优惠、同行优惠、周末或节假日加价等情况，最终价格以用户提交预约时页面显示的适用价格以及到店核销后的实际结算金额为准。如优惠活动存在特定使用条件，应以对应活动页面公布的规则为准。

## 14. 用户确认

用户提交预约前，应确认已阅读并理解本预约规则。提交预约后，即视为用户同意遵守上述预约、取消、迟到、超时、修改及付款相关规定。
''';

/// 用户协议全文（英文版）。
const String legalUserAgreementTextEn = r'''
# Booking Terms and User Agreement

1. Customer Service Email: eledzhang@gmail.com
2. Customer Service Hotline: 83811666

For enquiries regarding reservations, cancellations, modifications, payments, or other booking-related matters, please contact our customer service team using the contact details above.

3. Registered Address: 18A, Sago Street, Singapore 059017
4. Agreement Effective Date: 23 August 2026

This Agreement shall take effect from 23 August 2026. By submitting a reservation through the Platform, the User acknowledges that they have read, understood, and agreed to all applicable reservation terms and conditions set out in this Agreement.

## 5. Payment and Refund Policy

The Platform operates on a pay-at-store basis. No reservation fee or advance payment is required when the User submits an online reservation.

A successful reservation only means that the selected time slot and relevant services have been reserved for the User. It does not constitute payment or completion of the transaction.

If the User is unable to attend due to personal reasons, the User should cancel the reservation in advance. As no payment is collected online at the time of reservation, a normal cancellation does not involve an online refund.

If the User has already completed payment at the store, any subsequent request for a refund, price adjustment, or dispute regarding payment or consumption shall be handled in accordance with the store's applicable refund and payment policies. The User may contact customer service if Platform assistance is required.

## 6. Reservation Cancellation Policy

Users can cancel their reservation free of charge before the scheduled reservation start time.

If the User is unable to attend as scheduled, they are encouraged to cancel the reservation as early as possible so that the reserved time slot can be made available to other customers.

If the User fails to arrive after the scheduled start time without cancelling the reservation in advance, the reservation will be considered a No-Show.

For Users who repeatedly fail to attend without prior cancellation, the Platform or store may, at its reasonable discretion, restrict future reservation privileges, including but not limited to limiting future bookings, requiring advance payment, or implementing other reasonable measures.

## 7. Reservation Time and Late Arrival Policy

The reservation start and end times shall be based on the date and time stated in the User's reservation order.

For example, if a User books a reservation from 7:00 PM to 9:00 PM but arrives at 7:30 PM, the reservation will generally still end at 9:00 PM.

Any reduction in actual usage time resulting from the User's late arrival will generally not entitle the User to an extension, refund, or price adjustment.

## 8. Extended Use After Reservation

If the User wishes to continue using the venue or seats after the scheduled reservation end time, the User should request an extension from the store staff before the reservation period ends.

Any extension is subject to the availability of seats and venue capacity at that time.

If seats are available, the User may continue using the venue subject to the store's arrangement and shall pay the applicable charges based on the actual additional usage time and the store's prevailing rates.

If the reserved seat or space has been allocated to another customer after the reservation period, the User must complete their use and vacate the seat or venue by the scheduled end time.

## 9. Reservation Modification Policy

If the User wishes to change the reservation date, time, number of persons, or reservation item/service, the User should submit a modification request through the available Platform functions or contact the store before the scheduled reservation start time.

A modification shall only be considered successful once it is confirmed by the Platform system or the store.

If the price changes due to the modified date, time, number of persons, service, or package, the User shall be charged according to the applicable price following the modification.

## 10. Check-In and Payment at Store

Upon arrival, the User shall present their reservation order, reservation code, or other valid reservation information to the store staff for verification and check-in.

After successful check-in, the User shall make payment according to their actual consumption at the store.

The final amount payable shall be determined based on applicable factors including, but not limited to: actual number of persons; actual usage time; selected reservation item, service, or package; applicable prices on the date of use; and any applicable discounts, surcharges, or promotions.

## 11. Store-Initiated Cancellation

If the store is temporarily closed or the reservation cannot be fulfilled due to venue arrangements, equipment failure, operational issues, or other circumstances attributable to the store, the store will make reasonable efforts to notify the User as soon as practicable.

For affected reservations, the User may, subject to availability, choose to reschedule the reservation to another available date or time; or cancel the affected reservation.

As no advance payment is normally collected for reservations, cancellation in such circumstances generally does not involve an online refund.

## 12. Successful Reservation

Once the User receives a reservation confirmation, the Platform has successfully recorded the reservation and reserved the corresponding time slot, subject to the applicable terms of this Agreement.

A successful reservation does not mean that payment has been made.

The User should arrive at the store according to the date and time stated in the reservation order and complete payment after check-in based on the actual amount payable.

## 13. Pricing and Promotional Policy

Different prices may apply depending on factors including, but not limited to: date; time period; number of persons; reservation method; package or service selected; membership status; promotional campaigns; member discounts; companion discounts; and weekend or public holiday surcharges.

Where applicable, the price displayed on the Platform at the time the User submits the reservation, together with the final amount determined after check-in and based on actual consumption, shall be used as the basis for settlement.

Where a promotion or discount is subject to specific eligibility or usage conditions, the relevant promotional terms displayed on the applicable promotion page shall apply.

## 14. User Acknowledgement and Acceptance

Before submitting a reservation, the User should carefully read and ensure that they understand all applicable reservation terms.

By submitting a reservation, the User acknowledges and agrees to comply with the provisions relating to reservation, cancellation, late arrival, extended use, modification, check-in, payment, pricing, and other applicable rules set out in this Agreement.

If the User does not agree with any part of these terms, the User should not submit the reservation.
''';

/// 隐私政策全文。
const String legalPrivacyPolicyText = r'''
# Think Origin 手作工坊隐私政策

> 版本：V1.0 ｜ 生效日期：2026-08-23

## 一、引言与适用范围

欢迎使用 Think Origin 手作工坊平台（以下简称"本平台"或"我们"）。我们深知个人信息对您的重要性，并承诺按照相关法律法规的要求，采取合理措施保护您的个人信息。

本隐私政策适用于您通过以下渠道使用本平台服务的情形：

- 移动端应用（iOS / Android，应用名：Think Origin）；
- Web 端（如适用）；
- 本平台提供的其他相关服务。

请您在使用本平台服务前，仔细阅读并理解本政策。您注册、登录或继续使用本平台服务，即表示您已充分理解并同意本政策。

## 二、我们收集的信息

我们仅收集为您提供相应功能所必需的信息。本平台当前未接入第三方广告、统计分析类 SDK，不会向您推送个性化商业广告。

### （一）您主动提供的信息

- 注册账号信息：用户名、邮箱、密码 — 用途：创建账号、身份验证、账号登录；
- 个人资料：昵称、头像、性别、生日、所在地、个人简介 — 用途：展示您的个人主页，完善社区互动体验；
- 预约信息：预约门店、桌位、日期与时段、人数、预约码、备注 — 用途：生成预约单、到店核销、订单管理；
- 消费信息：预约金额、优惠券使用情况、会员开通申请 — 用途：费用核算、会员权益管理；
- 内容信息：您发布的社区作品（图文/视频、标签、地点）、短视频（含拍摄剪辑信息）、评论 — 用途：提供内容发布、展示与互动功能；
- 聊天信息：私聊/群聊中的文本、图片、语音、视频消息 — 用途：提供即时通讯功能。

### （二）我们在您使用服务过程中自动收集的信息

- 设备标识：安装时生成的随机设备标识（安装 ID，非真实 MAC 地址）— 用途：账号安全风控、防止同一设备恶意批量注册（同一设备最多注册 3 个账号）；
- 登录与安全日志：IP 地址、请求时间、登录与操作记录 — 用途：安全防护、账号保护、反滥用限流（如登录失败锁定）；
- 互动数据：点赞、收藏、评论、关注、浏览历史、分享、通知已读状态 — 用途：提供社交互动与个性化记录功能；
- 会员与积分数据：会员编号、会员等级、有效期、积分/成长值 — 用途：提供会员权益服务；
- 服务状态数据：预约单状态（待确认/已预约/服务中/已完成/已取消）、上下钟时间、核销记录 — 用途：预约履约与门店服务管理。

### （三）设备权限信息

为实现特定功能，我们可能会在您主动使用相应功能时申请以下设备权限：

- 相机：拍摄作品照片/视频、拍摄头像 — 仅在您主动拍摄时使用；
- 相册（照片库）：发布作品、设置头像、聊天选择图片 — 仅在您主动选择图片时使用；
- 麦克风：拍摄带声音的视频、发送聊天语音消息 — 仅在您主动录音时使用。

您可以在设备系统设置中随时关闭上述权限。关闭后，对应功能可能无法正常使用，但不会影响其他不依赖该权限的功能。

本平台当前不采集您的精确地理位置。作品发布地点、门店/活动地址等信息由您或门店运营人员自行填写。

### （四）本地存储信息

为改善使用体验，我们会在您的设备本地存储以下信息：

- 登录凭证（访问令牌与刷新令牌）及当前登录用户 ID；
- 设备标识（安装 ID）；
- 语言偏好设置。

上述信息仅保存在您的设备本地，用于恢复登录态和记录偏好。您卸载应用或清除应用数据后，本地存储的信息将被清除。

## 三、我们如何使用信息

我们仅在以下目的范围内使用您的个人信息：

1. 提供核心服务：账号注册与登录、门店/活动预约、预约核销与计时、会员开通与权益、优惠券发放与使用；
2. 内容功能：社区作品与短视频的发布、展示、点赞、评论、收藏、关注、分享、浏览历史记录；
3. 即时通讯：私聊、群聊、消息收发（文本/图片/语音/视频）、已读状态、撤回、置顶、拉黑；
4. 通知服务：向您发送预约、活动、会员、互动（点赞/评论/关注等）及系统通知；
5. 安全与风控：登录失败锁定、同一设备注册数量限制、异常行为识别、账号封禁等安全防护措施；
6. 内容治理：依据法律法规对您发布的内容进行关键词机审及人工复核；
7. 服务改进：分析服务运行情况、优化产品功能（在不涉及个人身份识别的前提下）；
8. 法律合规：履行法律法规规定的义务，处理争议纠纷，配合有权机关调查。

## 四、我们如何存储与保护信息

### （一）存储方式与地点

- 您的个人信息存储于我们部署的服务器及数据库（MySQL）中；会话与临时数据使用 Redis 缓存；
- 您上传的图片、音频、视频等媒体文件存储于我们配置的存储服务中，可能为本地服务器或对象存储（如阿里云 OSS 等 S3 兼容服务），并可能通过 CDN 加速分发；
- 数据存储地点：新加坡。

### （二）安全保护措施

- 加密传输：我们通过传输加密协议（HTTPS/TLS）保护数据在传输过程中的安全；
- 密码保护：您的密码经 scrypt 算法加盐哈希后存储，我们不会以明文形式保存或展示您的密码；
- 访问控制：仅授权人员可访问相关数据，管理端操作受账号权限与登录校验保护；
- 备份与恢复：我们定期对数据库和缓存执行备份（默认每日备份、保留若干天），以防止数据丢失；
- 安全风控：对登录失败、注册频率等异常行为实施限流与锁定机制，降低账号被盗与恶意刷号风险；
- 内容安全：对发布内容进行关键词机审和管理端人工审核，发现违法违规内容将依法处理。

尽管我们采取上述措施，任何互联网传输与存储方式均无法保证绝对安全，请您妥善保管账号密码。

### （三）信息保留期限

我们仅在实现本政策所述目的所必需的期限内保留您的个人信息，具体包括：

- 账号存续期内保留您的账号与使用记录；您注销账号后，我们将按照您的要求或法律法规规定的期限删除或匿名化处理相关个人信息；
- 备份数据按备份策略保留（默认保留 7 天，可配置），到期自动清除；
- 法律法规另有规定的，从其规定。

## 五、信息的共享、委托处理与公开披露

### （一）共享与委托处理

我们不会向任何无关第三方出售您的个人信息。为实现服务目的，我们可能在以下情形中与第三方共享或委托其处理您的信息：

1. 云服务提供商：对象存储/CDN 服务商（如阿里云 OSS、CDN），用于存储和分发您上传的媒体文件；
2. 邮件服务商：在启用邮件通知/验证码服务时，通过 SMTP 邮件服务向您发送服务邮件；
3. 门店运营人员：为完成预约、核销、上钟/下钟等线下履约服务，您的预约信息（含预约码）会提供给对应门店的工作人员核验；
4. 法律要求的披露：根据法律法规、司法或行政主管机关的要求，我们可能会披露相关信息。

上述第三方仅能在必要范围内接触您的信息，我们要求其采取相应的保密与安全措施。

### （二）公开信息

您在社区、短视频等公开场景发布的内容（含头像、昵称、作品、评论等）将对其他用户可见。请勿在公开内容中透露您不愿公开的个人信息。

## 六、Cookie 与本地存储技术

Web 端（如适用）可能使用 Cookie 或同类技术以维持登录状态和基础功能；移动端通过系统本地存储保存登录凭证与偏好设置。您可通过清除浏览器缓存或应用数据的方式删除上述信息，但可能导致需要重新登录。

## 七、您的权利

依据相关法律法规，您对您的个人信息享有以下权利：

1. 访问与更正：您可以在"我的"页面查看并修改昵称、头像、性别、生日、所在地、个人简介等资料；用户名在一年内仅可修改一次；
2. 查看服务记录：您可以在应用内查看预约记录、会员信息、优惠券、通知等；
3. 删除内容：您可以删除自己发布的聊天消息（或撤回）、作品等；撤回时限以功能规则为准；
4. 撤回授权：您可以在系统设置中关闭相机、相册、麦克风等权限；
5. 注销账号：您可以在应用内「我的 → 设置 → 注销账号」提交注销申请（需输入登录密码确认），也可联系客服协助办理。注销后，我们将删除或匿名化处理您的账号信息及相关数据（包括作品、互动、预约、会员、聊天等关联数据），法律法规要求保留的除外；
6. 投诉举报：如您发现平台内存在违法违规或侵权内容，可通过应用内"我的 → 设置 → 意见反馈"（当前为规划中）或本政策文末的联系方式向我们反馈。

## 八、未成年人保护

我们非常重视未成年人个人信息保护。未满 12 周岁的未成年人不得注册使用本平台；已满 12 周岁未满 18 周岁的未成年人使用本平台须征得其监护人同意，并由监护人阅读本政策及用户协议。

如果我们发现在未获得监护人同意的情况下收集了未成年人的个人信息，我们将设法尽快删除相关数据。如您是监护人并发现被监护人向我们提供了个人信息，请及时联系我们。

## 九、内容审核

为维护平台秩序和内容安全，我们会对您发布的内容进行机器关键词审核和管理端人工审核。内容命中违规关键词或经人工审核认定为违规的，可能被限制展示、删除，情节严重的账号可能被限制使用或封禁。

## 十、本政策的更新

我们可能适时修订本政策。政策更新后，我们将在应用内或通过其他适当方式通知您。若修订涉及对您权利义务的重大变更，我们将在生效前以显著方式提示您。您在政策更新后继续使用本平台服务，即视为接受更新后的政策。

## 十一、联系我们

如您对本政策或个人信息保护有任何疑问、意见或建议，请通过以下方式联系我们：

- 客服邮箱：eledzhang@gmail.com
- 客服电话：83811666
- 运营主体名称：Think Origin PTE. LTD.　
- 注册地址：18A, Sago Street Singapore 059017

我们将在收到您的反馈后【15】个工作日内予以答复。''';

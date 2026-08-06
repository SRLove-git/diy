import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// 协议类型：用户协议 / 隐私政策
enum AgreementType { user, privacy }

/// 静态协议展示页：登录/注册前需勾选同意，链接跳转到这里。
/// 内容为草稿模板，正式上线前请替换为法务审核后的正式文本。
class AgreementPage extends StatelessWidget {
  const AgreementPage({super.key, required this.type});

  final AgreementType type;

  @override
  Widget build(BuildContext context) {
    final isUser = type == AgreementType.user;
    final colors = AppColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(isUser ? '用户协议' : '隐私政策')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? 'IDOL BEADS 用户协议' : 'IDOL BEADS 隐私政策',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '更新日期：2026 年 8 月 6 日',
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
              const SizedBox(height: 18),
              ...(isUser ? _userSections() : _privacySections()),
              const SizedBox(height: 16),
              Divider(color: colors.divider),
              const SizedBox(height: 10),
              Text(
                '本页面为草稿模板，正式上线前请由法务审核后替换。',
                style: TextStyle(fontSize: 12, color: colors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _userSections() => const [
    _Section(
      title: '一、引言',
      body:
          '欢迎使用 IDOL BEADS（以下简称"本平台"）。本协议是您与本平台之间'
          '就注册、登录及使用本平台服务所订立的协议。您注册、登录或使用本平台'
          '服务，即视为已阅读并同意本协议全部条款。',
    ),
    _Section(
      title: '二、账号注册与登录',
      body:
          '1. 您可以通过手机号与短信验证码注册或登录账号，未注册手机号在'
          '验证通过后将自动注册。\n2. 您应确保提供的手机号真实有效，并对账号下'
          '的所有操作承担相应责任。\n3. 请妥善保管账号信息，发现账号异常时应及时'
          '通过本平台提供的途径联系客服处理。',
    ),
    _Section(
      title: '三、用户行为规范',
      body:
          '1. 您承诺遵守法律法规及公序良俗，不得利用本平台从事任何违法、'
          '违规或侵犯他人合法权益的行为。\n2. 您不得发布、传播违法违规、虚假'
          '误导或侵犯第三方知识产权的内容。\n3. 违反本协议导致他人或平台受损的，'
          '由您自行承担相应责任。',
    ),
    _Section(
      title: '四、内容与知识产权',
      body:
          '您在本平台发布的作品、评论等内容的知识产权归您所有或您有权合法'
          '使用；您授权本平台在平台范围内展示、存储及按规则传播上述内容。'
          '平台自身的界面、标识及技术均受相关法律保护。',
    ),
    _Section(
      title: '五、服务变更与终止',
      body:
          '本平台有权根据业务发展调整或停止部分服务，并尽合理努力提前通知。'
          '若您违反本协议，本平台有权视情节采取警示、限制功能直至封禁账号等'
          '处理措施。',
    ),
    _Section(
      title: '六、免责声明',
      body:
          '您应自行评估平台内第三方内容与线下服务（包括但不限于门店预约、'
          '到店消费）的风险并独立承担相应后果，平台在法律允许范围内免除相应'
          '责任。',
    ),
    _Section(title: '七、联系我们', body: '如对本协议有任何疑问或建议，可通过平台内客服渠道与我们联系。'),
  ];

  List<Widget> _privacySections() => const [
    _Section(
      title: '一、我们收集的信息',
      body:
          '1. 账号信息：手机号（用于注册、登录、身份验证与安全保护）、'
          '昵称与头像（用于平台内展示）。\n2. 使用信息：浏览、发布、预约、'
          '收藏、评论等操作记录，用于提供与优化服务。\n3. 设备与日志信息：'
          '设备型号、系统版本、网络状态等，用于保障服务安全与稳定性。',
    ),
    _Section(
      title: '二、信息的使用',
      body:
          '我们仅在提供服务所必需的范围内使用您的信息，包括：验证身份、'
          '发送短信验证码与服务通知、推荐与运营活动、安全风控与纠纷处理。',
    ),
    _Section(
      title: '三、信息的共享',
      body:
          '未经您同意，我们不会向第三方出售或提供您的个人信息，但以下情形'
          '除外：依法需要向监管机关披露；为完成订单与第三方服务商（如短信'
          '服务商）合作的必要场景；您主动公开的信息。',
    ),
    _Section(
      title: '四、信息的存储与保护',
      body:
          '您的个人信息将存储于中华人民共和国境内，并通过加密、访问控制等'
          '技术手段加以保护。如发生安全事件，我们将依法及时告知并采取补救措施。',
    ),
    _Section(
      title: '五、您的权利',
      body:
          '您有权查询、更正、删除您的个人信息，注销账号，或撤回相关授权。'
          '您可通过平台内客服渠道行使上述权利，我们将在法定期限内处理。',
    ),
    _Section(
      title: '六、未成年人保护',
      body:
          '未满 14 周岁的未成年人应在监护人陪同下使用本平台；我们不会在'
          '监护人未同意的情况下处理未成年人个人信息。',
    ),
    _Section(
      title: '七、政策更新与联系我们',
      body:
          '本政策更新时将在平台内公告。如对本政策有疑问，请通过平台内客服'
          '渠道与我们联系。',
    ),
  ];
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.7,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

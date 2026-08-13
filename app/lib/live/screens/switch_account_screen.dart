import 'package:flutter/material.dart';

import '../../api/auth_store.dart';
import '../../api/services.dart';
import '../../l10n/l10n_ext.dart';
import '../live_routes.dart';
import '../live_theme.dart';
import '../live_widgets.dart';

/// 切换账号：保留所有记住账号的登录态，可免密快速切回；
/// 「登录其他账号」只清空当前登录态、不销毁记住列表。
class SwitchAccountScreen extends StatefulWidget {
  const SwitchAccountScreen({super.key});

  @override
  State<SwitchAccountScreen> createState() => _SwitchAccountScreenState();
}

class _SwitchAccountScreenState extends State<SwitchAccountScreen> {
  @override
  void initState() {
    super.initState();
    AuthStore.instance.addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    AuthStore.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _switchTo(SavedAccount account) async {
    if (account.userId == AuthStore.instance.userId) return;
    // 切换前先校验该账号的登录态：失效的会话不再进入首页
    // （避免闪进闪退），有效会话直接用最新 token 切换。
    final check = await AuthService.instance.checkSavedAccount(account);
    if (!mounted) return;
    if (check == SavedAccountCheck.expired) {
      await AuthStore.instance.removeAccount(account.userId);
      if (!mounted) return;
      showLiveSnack(context, context.l10n.switchSessionExpired);
      return;
    }
    if (check == SavedAccountCheck.networkError) {
      showLiveSnack(context, context.l10n.serverError);
      return;
    }
    await AuthStore.instance.switchTo(account.userId);
    if (!mounted) return;
    showLiveSnack(context, context.l10n.settingsSwitchSuccess);
    await LiveRoutes.goHome(context);
  }

  Future<void> _loginOther() async {
    // 保留记住账号列表，仅清空当前登录态；
    // redirect（AuthStore 置为未登录）会自动跳转登录页。
    await AuthStore.instance.clear();
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: LiveColors.textSecondary,
      ),
    ),
  );

  Widget _accountCard({
    required SavedAccount account,
    required bool current,
    VoidCallback? onTap,
  }) {
    final l10n = context.l10n;
    final name = account.displayName?.isNotEmpty == true
        ? account.displayName!
        : l10n.commonUserId(account.userId);
    return Material(
      color: LiveColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Avatar(url: account.avatar ?? '', name: name, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: LiveColors.textPrimary,
                      ),
                    ),
                    if (account.displayName != null &&
                        account.displayName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.commonUserId(account.userId),
                        style: const TextStyle(
                          fontSize: 12,
                          color: LiveColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (current)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: LiveColors.brandLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    context.l10n.settingsSwitchCurrentTag,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: LiveColors.brand,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: LiveColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final store = AuthStore.instance;
    final currentId = store.userId;
    final current =
        store.currentAccount ??
        (store.userId == null
            ? null
            : SavedAccount(
                userId: store.userId!,
                accessToken: store.accessToken ?? '',
                refreshToken: store.refreshToken ?? '',
              ));
    final others = store.accounts
        .where((a) => a.userId != currentId)
        .toList(growable: false);

    return LivePage(
      child: Column(
        children: [
          LiveAppBar(title: l10n.settingsSwitchAccount),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                if (current != null) ...[
                  _sectionTitle(l10n.settingsSwitchCurrent),
                  _accountCard(account: current, current: true),
                  const SizedBox(height: 20),
                ],
                if (others.isNotEmpty) ...[
                  _sectionTitle(l10n.settingsSwitchOther),
                  for (var i = 0; i < others.length; i++) ...[
                    _accountCard(
                      account: others[i],
                      current: false,
                      onTap: () => _switchTo(others[i]),
                    ),
                    if (i != others.length - 1) const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 20),
                ],
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: PrimaryButton(
                    label: l10n.settingsSwitchAccountSub,
                    color: LiveColors.black,
                    textColor: Colors.white,
                    borderRadius: 16,
                    onTap: _loginOther,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

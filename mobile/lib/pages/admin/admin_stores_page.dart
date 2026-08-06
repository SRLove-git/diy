import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/admin_api.dart';
import '../../core/app_colors.dart';
import '../../widgets/state_widgets.dart';

/// 门店管理：门店列表 + 新增/编辑 + 桌位/时段配置（对齐网页管理端）
class AdminStoresPage extends StatefulWidget {
  const AdminStoresPage({super.key});

  @override
  State<AdminStoresPage> createState() => _AdminStoresPageState();
}

class _AdminStoresPageState extends State<AdminStoresPage> {
  List<AdminStore> _stores = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await AdminApi.fetchStores();
      if (mounted) setState(() => _stores = list);
    } on DioException catch (e) {
      if (mounted) setState(() => _error = AdminApi.messageOf(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ─── 门店新增 / 编辑 ───
  Future<void> _openStoreForm([AdminStore? store]) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _StoreFormDialog(store: store),
    );
    if (result == null) return;
    try {
      if (store == null) {
        await AdminApi.createStore(result);
      } else {
        await AdminApi.updateStore(store.id, result);
      }
      if (mounted) {
        _toast(store == null ? '新增门店成功' : '保存成功');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  Future<void> _removeStore(AdminStore store) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除门店'),
        content: Text('确认删除门店「${store.name}」？其桌位和时段将一并删除。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.of(ctx).danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await AdminApi.removeStore(store.id);
      if (mounted) {
        _toast('已删除');
        _load();
      }
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  // ─── 桌位管理 ───
  Future<void> _openTables(AdminStore store) async {
    // 每次进入从接口重新拉取，保证是最新数据
    try {
      final list = await AdminApi.fetchStores();
      if (!mounted) return;
      final fresh = list.firstWhere((s) => s.id == store.id, orElse: () => store);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _TablesSheet(store: fresh),
      );
      _load();
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  // ─── 时段管理 ───
  Future<void> _openSlots(AdminStore store) async {
    try {
      final list = await AdminApi.fetchStores();
      if (!mounted) return;
      final fresh = list.firstWhere((s) => s.id == store.id, orElse: () => store);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => _SlotsSheet(store: fresh),
      );
      _load();
    } on DioException catch (e) {
      if (mounted) _toast(AdminApi.messageOf(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('门店管理'),
        actions: [
          IconButton(icon: const Icon(Icons.add), tooltip: '新增门店', onPressed: () => _openStoreForm()),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingWidget();
    if (_error != null) return AppErrorWidget(message: _error!, onRetry: _load);
    if (_stores.isEmpty) {
      return const EmptyWidget(
        icon: Icons.store_outlined,
        message: '暂无门店，点击右上角 + 新增',
      );
    }
    final colors = AppColors.of(context);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _stores.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _buildStoreCard(_stores[i], colors),
      ),
    );
  }

  Widget _buildStoreCard(AdminStore s, AppColors colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '★ ${s.rating.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 13, color: Palette.warning),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoLine(Icons.place_outlined, s.address.isEmpty ? '-' : s.address),
          _infoLine(Icons.schedule, s.businessHours.isEmpty ? '-' : s.businessHours),
          _infoLine(Icons.phone_outlined, s.phone.isEmpty ? '-' : s.phone),
          const SizedBox(height: 6),
          Text(
            '桌位 ${s.tables.length} 个 · 时段 ${s.slots.length} 个',
            style: TextStyle(fontSize: 12, color: colors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _actionBtn('编辑', () => _openStoreForm(s)),
              _actionBtn('桌位', () => _openTables(s)),
              _actionBtn('时段', () => _openSlots(s)),
              _actionBtn('删除', () => _removeStore(s), danger: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoLine(IconData icon, String text) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: colors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, VoidCallback onTap, {bool danger = false}) {
    final colors = AppColors.of(context);
    final color = danger ? colors.danger : colors.textPrimary;
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: colors.divider),
          padding: const EdgeInsets.symmetric(vertical: 8),
          minimumSize: const Size(0, 36),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}

/// 门店新增/编辑表单对话框
class _StoreFormDialog extends StatefulWidget {
  const _StoreFormDialog({this.store});

  final AdminStore? store;

  @override
  State<_StoreFormDialog> createState() => _StoreFormDialogState();
}

class _StoreFormDialogState extends State<_StoreFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _hours;
  late final TextEditingController _phone;
  late final TextEditingController _price;
  late final TextEditingController _memberPrice;

  bool get _isEdit => widget.store != null;

  @override
  void initState() {
    super.initState();
    final s = widget.store;
    _name = TextEditingController(text: s?.name ?? '');
    _address = TextEditingController(text: s?.address ?? '');
    _lat = TextEditingController(text: (s?.lat ?? 30.3).toString());
    _lng = TextEditingController(text: (s?.lng ?? 120.1).toString());
    _hours = TextEditingController(text: s?.businessHours ?? '10:00-22:00');
    _phone = TextEditingController(text: s?.phone ?? '');
    _price = TextEditingController(text: (s?.price ?? 39.9).toString());
    _memberPrice = TextEditingController(
      text: s?.memberPrice == null ? '' : s!.memberPrice.toString(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _lat.dispose();
    _lng.dispose();
    _hours.dispose();
    _phone.dispose();
    _price.dispose();
    _memberPrice.dispose();
    super.dispose();
  }

  void _submit() {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入门店名称')));
      return;
    }
    Navigator.of(context).pop({
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'lat': double.tryParse(_lat.text.trim()) ?? 0,
      'lng': double.tryParse(_lng.text.trim()) ?? 0,
      'businessHours': _hours.text.trim(),
      'phone': _phone.text.trim(),
      'price': double.tryParse(_price.text.trim()) ?? 0,
      if (_memberPrice.text.trim().isNotEmpty)
        'memberPrice': double.tryParse(_memberPrice.text.trim()) ?? 0,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEdit ? '编辑门店' : '新增门店'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_name, '门店名称', hint: '如 手作工坊·滨江店'),
            _field(_address, '地址'),
            Row(
              children: [
                Expanded(child: _field(_lat, '纬度', number: true)),
                const SizedBox(width: 8),
                Expanded(child: _field(_lng, '经度', number: true)),
              ],
            ),
            _field(_hours, '营业时间', hint: '如 10:00-22:00'),
            _field(_phone, '联系电话'),
            Row(
              children: [
                Expanded(child: _field(_price, '门市价（元/人）', hint: '如 39.9', number: true)),
                const SizedBox(width: 8),
                Expanded(child: _field(_memberPrice, '会员价（元/人）', hint: '0 = 会员免费', number: true)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
        FilledButton(onPressed: _submit, child: Text(_isEdit ? '保存' : '创建')),
      ],
    );
  }

  Widget _field(TextEditingController c, String label, {String? hint, bool number = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        keyboardType: number ? const TextInputType.numberWithOptions(decimal: true) : null,
        inputFormatters: number ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]'))] : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}

/// 桌位配置底部弹层
class _TablesSheet extends StatefulWidget {
  const _TablesSheet({required this.store});

  final AdminStore store;

  @override
  State<_TablesSheet> createState() => _TablesSheetState();
}

class _TablesSheetState extends State<_TablesSheet> {
  late List<AdminStoreTable> _tables = widget.store.tables;
  final _name = TextEditingController();
  final _capacity = TextEditingController(text: '2');
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _capacity.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _name.text.trim();
    final cap = int.tryParse(_capacity.text.trim()) ?? 2;
    if (name.isEmpty) return;
    setState(() => _busy = true);
    try {
      final t = await AdminApi.addTable(widget.store.id, {'name': name, 'capacity': cap});
      if (mounted) {
        setState(() {
          _tables = [..._tables, t];
          _name.clear();
          _capacity.text = '2';
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AdminApi.messageOf(e))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(AdminStoreTable t) async {
    try {
      await AdminApi.removeTable(t.id);
      if (mounted) setState(() => _tables = _tables.where((x) => x.id != t.id).toList());
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AdminApi.messageOf(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '桌位配置 · ${widget.store.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _tables.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = _tables[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.placeholder,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('${t.name} · 容纳 ${t.capacity} 人'),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: colors.danger),
                            onPressed: () => _remove(t),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        hintText: '桌位名，如 B1',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _capacity,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        hintText: '人数',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _busy ? null : _add,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text('添加'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 时段配置底部弹层
class _SlotsSheet extends StatefulWidget {
  const _SlotsSheet({required this.store});

  final AdminStore store;

  @override
  State<_SlotsSheet> createState() => _SlotsSheetState();
}

class _SlotsSheetState extends State<_SlotsSheet> {
  late List<AdminTimeSlot> _slots = widget.store.slots;
  TimeOfDay? _start;
  TimeOfDay? _end;
  bool _busy = false;

  Future<void> _pickStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _start ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null) setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _end ?? const TimeOfDay(hour: 11, minute: 30),
    );
    if (picked != null) setState(() => _end = picked);
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _add() async {
    final s = _start;
    final e = _end;
    if (s == null || e == null) return;
    setState(() => _busy = true);
    try {
      final slot = await AdminApi.addSlot(widget.store.id, {
        'startTime': _fmt(s),
        'endTime': _fmt(e),
      });
      if (mounted) {
        setState(() {
          _slots = [..._slots, slot];
          _start = null;
          _end = null;
        });
      }
    } on DioException catch (ex) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AdminApi.messageOf(ex))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(AdminTimeSlot slot) async {
    try {
      await AdminApi.removeSlot(slot.id);
      if (mounted) {
        setState(() => _slots = _slots.where((x) => x.id != slot.id).toList());
      }
    } on DioException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(AdminApi.messageOf(e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '时段配置 · ${widget.store.name}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _slots.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final slot = _slots[i];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.placeholder,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text('${slot.startTime} - ${slot.endTime}')),
                          IconButton(
                            icon: Icon(Icons.delete_outline, color: colors.danger),
                            onPressed: () => _remove(slot),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _TimeField(
                      selected: _start,
                      hint: '开始 10:00',
                      onTap: _pickStart,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _TimeField(
                      selected: _end,
                      hint: '结束 11:30',
                      onTap: _pickEnd,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _busy ? null : _add,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text('添加'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('完成'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 时间选择输入框：点击弹出系统时间选择器
class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.selected,
    required this.hint,
    required this.onTap,
  });

  final TimeOfDay? selected;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasValue = selected != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: colors.divider),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, size: 16, color: colors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                hasValue
                    ? '${selected!.hour.toString().padLeft(2, '0')}:${selected!.minute.toString().padLeft(2, '0')}'
                    : hint,
                style: TextStyle(
                  color: hasValue ? colors.textPrimary : colors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

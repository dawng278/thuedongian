import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/invoices_provider.dart';
import '../../services/local_db.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');
final _dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');

/// Trang xem danh sách hóa đơn chưa đồng bộ + xác nhận đẩy lên server.
/// Hiện khi người quản lý bấm nút đồng bộ — để xem qua trước khi đồng bộ.
class PendingSyncScreen extends StatefulWidget {
  const PendingSyncScreen({super.key});

  @override
  State<PendingSyncScreen> createState() => _PendingSyncScreenState();
}

class _PendingSyncScreenState extends State<PendingSyncScreen> {
  List<LocalInvoice> _pending = [];
  bool _loading = true;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final pending = await context.read<InvoicesProvider>().pendingInvoices();
    if (mounted) {
      setState(() {
        _pending = pending;
        _loading = false;
      });
    }
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    try {
      final result = await context.read<InvoicesProvider>().syncPending();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Đồng bộ: ${result.synced} thành công, ${result.errors} lỗi'),
          backgroundColor: result.errors > 0
              ? const Color(0xFFD97706)
              : const Color(0xFF059669),
        ),
      );
      await _load();
      // Nếu đã đồng bộ hết thì đóng trang.
      if (mounted && _pending.isEmpty) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total =
        _pending.fold<int>(0, (s, inv) => s + inv.totalAmount);

    return Scaffold(
      appBar: AppBar(title: const Text('Hóa đơn chờ đồng bộ')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pending.isEmpty
              ? _emptyState(cs)
              : Column(
                  children: [
                    // Tóm tắt
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: const Color(0xFFFFF4E5),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off_outlined,
                              color: Color(0xFFD97706)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_pending.length} hóa đơn chưa lên server',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF7A4100)),
                                ),
                                Text(
                                  'Tổng ${_currencyFmt.format(total)}đ',
                                  style: const TextStyle(
                                      fontSize: 13, color: Color(0xFF7A4100)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _pending.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final inv = _pending[i];
                          final itemCount =
                              inv.items.fold<int>(0, (s, it) => s + it.quantity);
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.primaryContainer,
                              child: Text('#${inv.localNumber}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onPrimaryContainer)),
                            ),
                            title: Text('${_currencyFmt.format(inv.totalAmount)}đ',
                                style:
                                    const TextStyle(fontWeight: FontWeight.w700)),
                            subtitle: Text(
                                '$itemCount món · ${_dateFmt.format(inv.createdAt)} · '
                                '${inv.paymentMethod == 'transfer' ? 'Chuyển khoản' : 'Tiền mặt'}'),
                            trailing: const Icon(Icons.schedule,
                                size: 18, color: Color(0xFFD97706)),
                          );
                        },
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: _pending.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.icon(
                  onPressed: _syncing ? null : _sync,
                  icon: _syncing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.cloud_upload_outlined),
                  label: Text(_syncing
                      ? 'Đang đồng bộ...'
                      : 'Đồng bộ ${_pending.length} hóa đơn lên server'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _emptyState(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_done_outlined, size: 64, color: cs.primary),
          const SizedBox(height: 16),
          const Text('Tất cả hóa đơn đã được đồng bộ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Không có hóa đơn nào đang chờ',
              style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}

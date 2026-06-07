import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/invoice.dart';

final _currencyFmt = NumberFormat('#,###', 'vi_VN');
final _dateFmt = DateFormat('dd/MM/yyyy HH:mm', 'vi_VN');

class InvoiceQrScreen extends StatelessWidget {
  final InvoiceDto invoice;

  const InvoiceQrScreen({super.key, required this.invoice});

  String _buildQrPayload() {
    final payload = {
      'id': invoice.id,
      'so': invoice.invoiceNumber,
      'ngay': invoice.createdAt.toIso8601String(),
      'tong': invoice.totalAmount,
      'so_mon': invoice.items?.length ?? 0,
    };
    return jsonEncode(payload);
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;
    final qrData = _buildQrPayload();
    final num = invoice.invoiceNumber;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hóa đơn #$num'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // QR code
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.shadow.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 240,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: color.primary,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: color.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Khách quét mã để xem thông tin hóa đơn',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: color.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Invoice summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                      label: 'Số hóa đơn',
                      value: '#$num',
                      bold: true,
                    ),
                    _SummaryRow(
                      label: 'Ngày tạo',
                      value: _dateFmt.format(invoice.createdAt),
                    ),
                    const Divider(height: 24),
                    Text(
                      'Chi tiết',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    ...(invoice.items ?? []).map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName} x${item.quantity}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            Text(
                              '${_currencyFmt.format(item.subtotal)}đ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Tổng cộng',
                      value: '${_currencyFmt.format(invoice.totalAmount)}đ',
                      bold: true,
                      color: color.primary,
                    ),
                    if (invoice.note != null && invoice.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _SummaryRow(label: 'Ghi chú', value: invoice.note!),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Xong'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        );
    return Row(
      children: [
        Text('$label: ', style: Theme.of(context).textTheme.bodySmall),
        Expanded(child: Text(value, style: style, textAlign: TextAlign.end)),
      ],
    );
  }
}

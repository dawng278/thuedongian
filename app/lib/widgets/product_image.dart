import 'dart:io';
import 'package:flutter/material.dart';

/// Dựng widget ảnh sản phẩm từ một `image_url`, tự nhận diện nguồn:
/// - `assets/...`  → ảnh đóng gói trong app (chạy offline, không bao giờ vỡ).
/// - `http...`     → ảnh mạng (có loading + fallback khi lỗi/mất mạng).
/// - còn lại       → đường dẫn file local (ảnh người dùng tự chọn).
///
/// Mọi nhánh đều có [errorWidget] phòng ảnh hỏng — UI không bao giờ để lộ
/// icon "ảnh lỗi" mặc định của Flutter.
Widget buildProductImage(
  String url, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  required Widget errorWidget,
  Widget? loadingWidget,
}) {
  final src = url.trim();

  if (src.startsWith('assets/')) {
    return Image.asset(
      src,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => errorWidget,
    );
  }

  if (src.startsWith('http')) {
    return Image.network(
      src,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => errorWidget,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return loadingWidget ?? errorWidget;
      },
    );
  }

  // Đường dẫn file local (ảnh từ image_picker chưa upload).
  final file = File(src);
  if (file.existsSync()) {
    return Image.file(
      file,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => errorWidget,
    );
  }
  return errorWidget;
}

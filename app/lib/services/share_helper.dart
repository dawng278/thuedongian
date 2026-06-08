import 'dart:io';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Cross-platform share/open file.
/// - Android/iOS: dùng share_plus để hiển thị share sheet.
/// - Linux/Windows/macOS desktop: share_plus không hỗ trợ, dùng open_file
///   để mở file bằng ứng dụng mặc định (trình duyệt PDF, text editor...).
Future<void> shareOrOpenFile(
  String filePath, {
  String? mimeType,
  String? subject,
}) async {
  if (Platform.isAndroid || Platform.isIOS) {
    await Share.shareXFiles(
      [XFile(filePath, mimeType: mimeType)],
      subject: subject,
    );
  } else {
    await OpenFile.open(filePath);
  }
}

/// Thư mục để LƯU file xuất ra (báo cáo, hóa đơn) cho người dùng truy cập lại.
///
/// - Android: thư mục Download công khai (`/storage/emulated/0/Download`) nếu
///   tồn tại, nếu không thì external storage riêng của app. Không cần quyền
///   runtime cho thư mục Download trên hầu hết máy vì ta chỉ ghi file của app.
/// - iOS/desktop: thư mục Documents của app.
///
/// Trả về thư mục đã chọn để caller ghi file vào đó.
Future<Directory> resolveSaveDirectory() async {
  if (Platform.isAndroid) {
    // Thử thư mục Download công khai trước — kiểm tra ghi được thật sự.
    const publicDownload = '/storage/emulated/0/Download';
    final pub = Directory(publicDownload);
    try {
      if (await pub.exists()) {
        // Thử ghi 1 file tạm để chắc chắn có quyền (máy cũ có thể bị chặn).
        final probe = File('${pub.path}/.taxeasy_probe');
        await probe.writeAsString('ok', flush: true);
        await probe.delete();
        return pub;
      }
    } catch (_) {
      // Không ghi được Download → rơi xuống external riêng của app.
    }
    // Fallback: external storage riêng của app (Android/data/<pkg>/files).
    final ext = await getExternalStorageDirectory();
    if (ext != null) return ext;
  }
  // iOS / desktop / fallback cuối.
  return getApplicationDocumentsDirectory();
}

/// Lưu file vào thư mục người dùng truy cập được, rồi mở share sheet (mobile)
/// hoặc mở file (desktop). Trả về đường dẫn cuối cùng đã lưu để hiển thị cho
/// người dùng biết file nằm ở đâu.
Future<String> saveAndShareBytes(
  List<int> bytes,
  String fileName, {
  String? mimeType,
  String? subject,
}) async {
  final dir = await resolveSaveDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes, flush: true);
  await shareOrOpenFile(file.path, mimeType: mimeType, subject: subject);
  return file.path;
}

/// Như [saveAndShareBytes] nhưng cho nội dung text (CSV/XML).
Future<String> saveAndShareString(
  String content,
  String fileName, {
  String? mimeType,
  String? subject,
}) async {
  final dir = await resolveSaveDirectory();
  final file = File('${dir.path}/$fileName');
  await file.writeAsString(content, flush: true);
  await shareOrOpenFile(file.path, mimeType: mimeType, subject: subject);
  return file.path;
}

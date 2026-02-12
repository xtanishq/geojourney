import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class StorageService {
  static String? _momentsDir;

  /// Get persistent moments directory (same across app restarts)
  static Future<String> getMomentsDirectory() async {
    if (_momentsDir != null) return _momentsDir!;

    final dir = await getApplicationDocumentsDirectory();
    final momentsDir = Directory(path.join(dir.path, 'moments'));
    if (!await momentsDir.exists()) {
      await momentsDir.create(recursive: true);
    }
    _momentsDir = momentsDir.path;
    return _momentsDir!;
  }

  /// Copy file to moments dir and return **relative path** (filename only)
  static Future<String?> copyToPersistentDir(String tempPath, String prefix) async {
    try {
      final file = File(tempPath);
      if (!await file.exists()) return null;

      final dir = await getMomentsDirectory();
      final ext = path.extension(tempPath);
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final fileName = '${prefix}_$timestamp$ext';
      final newPath = path.join(dir, fileName);

      await file.copy(newPath);
      print('Copied to persistent: $newPath');
      return fileName; // Return filename only
    } catch (e) {
      print('Copy error: $e');
      return null;
    }
  }

  /// Build full path from relative filename
  static Future<String> getFullPath(String relativePath) async {
    final dir = await getMomentsDirectory();
    return path.join(dir, relativePath);
  }

  /// Delete file by relative path
  static Future<void> deleteFile(String relativePath) async {
    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
        print('Deleted: $fullPath');
      }
    } catch (e) {
      print('Delete error: $e');
    }
  }

  /// Validate file exists
  static Future<bool> fileExists(String relativePath) async {
    try {
      final fullPath = await getFullPath(relativePath);
      return await File(fullPath).exists();
    } catch (e) {
      return false;
    }
  }
}
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'log.dart';

class CacheUtils {
  CacheUtils._internal() : super();
  static final CacheUtils _instance = CacheUtils._internal();
  static CacheUtils get instance {
    return _instance;
  }

  Future<String> loadCacheSize() async {
    Directory tempDir = await getTemporaryDirectory();
    double value = await _getTotalSizeOfFilesInDir(tempDir);
    return _renderSize(value);
  }

  Future<double> _getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    try {
      if (file is File) {
        int length = await file.length();
        return double.parse(length.toString());
      }
      if (file is Directory) {
        final List<FileSystemEntity> children = await file.list().toList();
        double total = 0;
        for (final child in children) {
          total += await _getTotalSizeOfFilesInDir(child);
        }
        return total;
      }
    } catch (e) {
      AppLog.e(e);
    }
    return 0;
  }

  String _renderSize(double value) {
    List<String> unitArr = ['B', 'K', 'M', 'G'];
    int index = 0;
    while (value > 1024) {
      index++;
      value = value / 1024;
    }
    String size = value.toStringAsFixed(2);
    return size + unitArr[index];
  }

  Future<void> clearCache() async {
    Directory tempDir = await getTemporaryDirectory();
    //删除缓存目录
    await _delDir(tempDir);
  }

  ///递归方式删除目录
  Future<void> _delDir(FileSystemEntity file) async {
    try {
      await file.delete(recursive: true);
    } catch (e) {
      AppLog.e(e);
    }

    // if (file is Directory) {
    //   final List<FileSystemEntity> children = file.listSync();
    //   for (final FileSystemEntity child in children) {
    //     await _delDir(child);
    //   }
    // }
    // await file.delete();
  }
}

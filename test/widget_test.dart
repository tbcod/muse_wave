// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';
import 'package:image/image.dart';

import 'package:muse_wave/main.dart';

void main() {
  changeImgMd5();
}

void changeImgMd5() async {
  final directory = Directory("./assets/img/");

  if (!directory.existsSync()) {
    print('文件夹不存在: $directory');
    return;
  }

  // 遍历文件夹中的所有文件
  directory.listSync().forEach((file) {
    if (file is File && _isImageFile(file.path)) {
      _modifyImageMd5(file);
    }
  });

  print('所有图片的MD5值已修改完成');
}

// 检查文件是否是图片
bool _isImageFile(String path) {
  final ext = path.split('.').last.toLowerCase();
  return ['jpg', 'jpeg', 'png', 'bmp', 'gif'].contains(ext);
}

// 修改图片的MD5值
void _modifyImageMd5(File file) {
  try {
    // 读取图片
    final image = decodeImage(file.readAsBytesSync())!;

    // 修改图片内容（例如：修改第一个像素的颜色）
    image.setPixel(0, 0, ColorFloat32.rgb(0, 0, 0));

    // 保存修改后的图片
    file.writeAsBytesSync(encodePng(image)); // 保存为PNG格式
    print('已修改: ${file.path}');
  } catch (e) {
    print('修改失败: ${file.path}, 错误: $e');
  }
}

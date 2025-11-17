import 'package:logger/logger.dart';

import '../static/env.dart';

class AppLog {
  static var logger = Logger(filter: LoggerFilter());

  static bool get isLog {
    return !Env.isUser;
  }

  static set level(Level value) {
    Logger.level = value;
  }

  static void v(dynamic message) {
    if (!isLog) return;
    logger.t(message);
  }

  static void i(dynamic message) {
    if (!isLog) return;
    logger.i(message);
  }

  static void d(dynamic message) {
    if (!isLog) return;
    logger.d(message);
  }

  static void w(dynamic message) {
    if (!isLog) return;
    logger.w(message);
  }

  static void e(dynamic message) {
    if (!isLog) return;
    logger.e(message);
  }

  static void wtf(dynamic message) {
    if (!isLog) return;
    logger.f(message);
  }
}

class LoggerFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

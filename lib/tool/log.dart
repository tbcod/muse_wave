import 'package:logger/logger.dart';
import 'package:muse_wave/muse_config.dart';

class AppLog {
  static var logger = Logger(filter: LoggerFilter(), printer: PrettyPrinter(stackTraceBeginIndex: 1));

  static const int _maxLogCount = 400;
  static final List<String> _logs = [];

  static List<String> get logs => List.unmodifiable(_logs);

  static void _addLog(String level, dynamic message) {
    final now = DateTime.now();
    final time = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    _logs.add('[$time] [$level] $message');
    if (_logs.length > _maxLogCount) {
      _logs.removeRange(0, _logs.length - _maxLogCount);
    }
  }


  static void clearLogs() {
    _logs.clear();
  }

  static bool get isLog {
    return !MuseConfig.isUser;
  }

  static set level(Level value) {
    Logger.level = value;
  }

  static void v(dynamic message) {
    _addLog('VERBOSE', message);
    if (!isLog) return;
    logger.t(message);
  }

  static void i(dynamic message) {
    _addLog('INFO', message);
    if (!isLog) return;
    logger.i(message);
  }

  static void d(dynamic message) {
    _addLog('DEBUG', message);
    if (!isLog) return;
    logger.d(message);
  }

  static void w(dynamic message) {
    _addLog('WARN', message);
    if (!isLog) return;
    logger.w(message);
  }

  static void e(dynamic message) {
    _addLog('ERROR', message);
    if (!isLog) return;
    logger.e(message);
  }

  static void wtf(dynamic message) {
    _addLog('WTF', message);
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

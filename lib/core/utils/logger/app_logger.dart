// ignore_for_file: non_constant_identifier_names

import 'package:logger/logger.dart';

const String _tag = 'mlay';

final Logger _logger = Logger(printer: PrettyPrinter(methodCount: 0));

void LogV(String msg) {
  _logger.t('$_tag :: $msg');
}

void LogD(String msg) {
  final StackTrace trace = StackTrace.current;
  final List<String> frames = trace.toString().split('\n');
  final String frame = frames.length > 1 ? frames[1] : frames[0];
  final String location = _extractLocation(frame);
  _logger.d('$_tag :: $location :: $msg');
}

void LogI(String msg) {
  _logger.i('$_tag :: $msg');
}

void LogW(String msg) {
  _logger.w('$_tag :: $msg');
}

void LogE(String msg) {
  _logger.e('$_tag :: $msg');
}

void LogWTF(String msg) {
  _logger.f('$_tag :: $msg');
}

String _extractLocation(String frame) {
  final RegExp regex = RegExp(r'(\w+\.dart):(\d+):(\d+)');
  final RegExpMatch? match = regex.firstMatch(frame);
  if (match != null) {
    final String? file = match.group(1);
    final String? line = match.group(2);
    return '$file:$line';
  }
  return 'unknown location';
}

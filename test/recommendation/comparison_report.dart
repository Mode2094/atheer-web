import 'dart:io';

Future<void> main() async {
  stdout.writeln('=== بدء اختبارات مقارنة Cloud vs Local ===');
  stdout.writeln('تاريخ: ${DateTime.now()}');
  stdout.writeln('==========================================');

  final result = await Process.run(
    'flutter',
    ['test', 'test/recommendation/comparison_test.dart'],
  );

  stdout.write(result.stdout);
  stderr.write(result.stderr);

  stdout.writeln('==========================================');
  if (result.exitCode == 0) {
    stdout.writeln('✅ اكتملت الاختبارات بنجاح');
  } else {
    stdout.writeln('❌ فشلت الاختبارات (exit code: ${result.exitCode})');
  }
}

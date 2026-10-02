/// واجهة عامة لمزوّد جهاز EEG.
///
/// الهدف منها توحيد طريقة الاتصال وتشغيل جلسة القياس وإرجاع مؤشرات بسيطة
/// يمكن للتطبيق استخدامها دون الاعتماد على مكتبة/جهاز بعينه.
abstract class EEGDeviceProvider {
  /// يحاول الاتصال بالجهاز وإرجاع `true` عند نجاح الاتصال.
  Future<bool> connect();

  /// يقطع الاتصال بالجهاز ويوقف أي جلسة فعّالة إن وُجدت.
  Future<void> disconnect();

  /// يبدأ جلسة قراءة/قياس.
  ///
  /// يجب أن يعيد `true` عند بدء الجلسة بنجاح.
  Future<bool> startSession();

  /// يوقف الجلسة الحالية ويعيد آخر قياسات معروفة.
  ///
  /// قد يعيد `null` إذا لم تتوفر أي قياسات أثناء الجلسة.
  Future<Map<String, double>?> stopSession();

  /// تيار القياسات المبسطة.
  ///
  /// المفاتيح المتوقعة: `interest`, `excitement`, `stress`, `relaxation`,
  /// `engagement`, `attention` وقيمها من 0.0 إلى 1.0.
  Stream<Map<String, double>> get metricsStream;

  /// هل الجهاز متصل حالياً؟
  bool get isConnected;

  /// هل هناك جلسة قراءة فعّالة حالياً؟
  bool get isSessionActive;
}


import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework/clean_framework_defaults.dart';

void testConfig() {
  TestLocator();
}

final defaultLogLevel = LogLevel.error;

class TestLocator implements Locator {
  TestLocator._();

  factory TestLocator() =>
      (Locator.instance ??= TestLocator._()) as TestLocator;

  @override
  Connectivity connectivity = AlwaysOnlineConnectivity();

  @override
  Logger logger = () {
    final logger = ConsoleLogger();

    logger.setLogLevel(defaultLogLevel);
    return logger;
  }();

  void dispose() {
    Locator.instance = null;
  }
}

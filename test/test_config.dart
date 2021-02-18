import 'package:clean_framework/clean_framework.dart';
import 'package:clean_framework/clean_framework_defaults.dart';

void testConfig() {
  TestLocator();
}

final defaultLogLevel = LogLevel.error;

class TestLocator implements Locator {
  TestLocator._();

  factory TestLocator() {
    Locator.init(TestLocator._());
    return Locator.getInstance();
  }

  @override
  Connectivity connectivity = AlwaysOnlineConnectivity();

  @override
  Logger logger = ConsoleLogger(defaultLogLevel);

  void dispose() => Locator.dispose();
}

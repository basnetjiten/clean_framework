import 'package:clean_framework/clean_framework.dart';
import 'package:test/test.dart';

void main() {
  test('Pipe sends data', () async {
    Pipe<String> testPipe = Pipe<String>(initialData: 'initial');
    expect(testPipe.hasListeners, isFalse);
    expect(testPipe.initialData, 'initial');
    testPipe.receive.listen(expectAsync1((value) {
      expect(value.startsWith('test'), isTrue);
      testPipe.dispose();
    }, count: 2));
    expect(testPipe.hasListeners, isTrue);

    testPipe.send('test');

    //confirms that the pipe can only send the same data once
    testPipe.send('test');

    //this one is sent because the data is different
    testPipe.send('test2');
  }, timeout: Timeout(Duration(seconds: 3)));

  test('Pipe that allows duplication sends duplicated data', () async {
    Pipe<String> testPipe =
        Pipe<String>(initialData: 'initial', canSendDuplicateData: true);
    expect(testPipe.hasListeners, isFalse);
    expect(testPipe.initialData, 'initial');
    testPipe.receive.listen(expectAsync1((value) {
      expect(value, 'test');
      testPipe.dispose();
    }, count: 2));
    expect(testPipe.hasListeners, isTrue);

    testPipe.send('test');

    //Duplicated data is sent successfully
    testPipe.send('test');
  }, timeout: Timeout(Duration(seconds: 3)));

  test('Pipe emits data in order', () async {
    Pipe<int> testPipe = Pipe(initialData: 0);
    expect(testPipe.hasListeners, isFalse);
    expect(testPipe.initialData, 0);
    expectLater(
      testPipe.receive,
      emitsInOrder([
        1,
        2,
        3,
      ]),
    );

    testPipe..send(1)..send(2)..send(3);
  }, timeout: Timeout(Duration(seconds: 3)));

  test('Pipe throws an error', () async {
    Pipe<bool> testPipe = Pipe<bool>();
    expect(testPipe.hasListeners, isFalse);
    testPipe.receive.listen(expectAsync1((_) {}, max: 0, count: 0),
        onError: expectAsync1((error) {
      expect(error, isNotNull);
      testPipe.dispose();
    }));
    expect(testPipe.hasListeners, isTrue);
    testPipe.throwError(Error());
  }, timeout: Timeout(Duration(seconds: 3)));

  test('EventPipe launches successfully', () async {
    EventPipe testPipe = EventPipe();
    expect(testPipe.hasListeners, isFalse);

    testPipe.listen(expectAsync0(() {
      testPipe.dispose();
    }));

    expect(testPipe.hasListeners, isTrue);
    testPipe.launch();
  }, timeout: Timeout(Duration(seconds: 3)));

  test('EventPipe throws error on trying to receive data on it', () async {
    EventPipe testPipe = EventPipe();
    expect(() => testPipe.receive, throwsStateError);
  }, timeout: Timeout(Duration(seconds: 3)));
}

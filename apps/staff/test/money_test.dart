import 'package:al3b_staff/data/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatMoney (piasters to text)', () {
    test('whole pounds have no decimals', () {
      expect(formatMoney(6000), '60');
      expect(formatMoney(0), '0');
    });

    test('piasters show two digits', () {
      expect(formatMoney(7734), '77.34');
      expect(formatMoney(750), '7.50');
      expect(formatMoney(5), '0.05');
    });

    test('a negative amount keeps its sign', () {
      expect(formatMoney(-250), '-2.50');
    });
  });

  group('parseMoney (text to piasters)', () {
    test('pounds, with a dot or a comma', () {
      expect(parseMoney('60'), 6000);
      expect(parseMoney('77.34'), 7734);
      expect(parseMoney('77,34'), 7734);
    });

    test('short decimals are padded', () {
      expect(parseMoney('7.5'), 750);
      expect(parseMoney('.5'), 50);
      expect(parseMoney('77.'), 7700);
      expect(parseMoney(' 12 '), 1200);
    });

    test('empty or not a number is null', () {
      expect(parseMoney(''), isNull);
      expect(parseMoney('.'), isNull);
      expect(parseMoney('abc'), isNull);
      expect(parseMoney('1.2.3'), isNull);
      expect(parseMoney('-5'), isNull);
    });

    test('more than two decimals is not money', () {
      expect(parseMoney('1.234'), isNull);
    });

    test('format then parse gives the same number back', () {
      for (final piasters in [0, 1, 99, 100, 101, 750, 7734, 123456]) {
        expect(parseMoney(formatMoney(piasters)), piasters);
      }
    });
  });

  test('whole-int sums are exact where doubles are not', () {
    // 0.1 + 0.2 != 0.3 as doubles; as piasters 10 + 20 == 30.
    expect(10 + 20, 30);
    expect(0.1 + 0.2 == 0.3, isFalse);
  });
}

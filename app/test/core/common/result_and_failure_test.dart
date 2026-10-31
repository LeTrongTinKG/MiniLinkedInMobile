import 'package:flutter_test/flutter_test.dart';
import 'package:app/core/common/result.dart';
import 'package:app/core/error/app_failure.dart';

void main() {
  group('Result and AppFailure tests (MVVM standard)', () {
    test('Ok holds value and pattern matches', () {
      final Result<String> res = Result.ok('success');
      expect(res, isA<Ok<String>>());
      final value = switch (res) {
        Ok(:final value) => value,
        Error() => 'fail',
      };
      expect(value, equals('success'));
    });

    test('Error holds AppFailure and pattern matches', () {
      const failure = ValidationFailure('INVALID_INPUT', 'Lỗi nhập liệu');
      final Result<String> res = Result.error(failure);
      expect(res, isA<Error<String>>());
      final err = switch (res) {
        Ok() => null,
        Error(:final failure) => failure,
      };
      expect(err, isA<ValidationFailure>());
      expect((err! as ValidationFailure).code, equals('INVALID_INPUT'));
      expect(err.message, equals('Lỗi nhập liệu'));
    });

    test('All AppFailure types have descriptive messages', () {
      expect(const NetworkFailure().message, contains('kết nối'));
      expect(const ConsentRequiredFailure().message, contains('đồng ý'));
      expect(const UnauthorizedFailure().message, contains('hết hạn'));
      expect(const QuotaFailure().message, contains('hạn mức'));
      expect(const ServerFailure().message, contains('máy chủ'));
    });
  });
}


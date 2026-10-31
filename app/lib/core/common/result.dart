import '../error/app_failure.dart';

/// Đại diện cho kết quả của một tác vụ: thành công (Ok) hoặc thất bại (Error).
/// Kế thừa mẫu hình kiến trúc từ dự án Atom.
sealed class Result<T> {
  const Result();

  static Result<T> ok<T>(T value) => Ok(value);
  static Result<T> error<T>(AppFailure failure) => Error(failure);
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);

  @override
  String toString() => 'Ok($value)';
}

final class Error<T> extends Result<T> {
  final AppFailure failure;
  const Error(this.failure);

  @override
  String toString() => 'Error($failure)';
}


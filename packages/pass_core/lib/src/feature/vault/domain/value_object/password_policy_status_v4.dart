import 'package:equatable/equatable.dart';

final class PasswordPolicyStatusV4 extends Equatable {
  final bool minimumLength,
      maximumBytes,
      uppercase,
      lowercase,
      digit,
      special,
      singleLine;

  const PasswordPolicyStatusV4({
    required this.minimumLength,
    required this.maximumBytes,
    required this.uppercase,
    required this.lowercase,
    required this.digit,
    required this.special,
    required this.singleLine,
  });

  bool get valid =>
      minimumLength &&
      maximumBytes &&
      uppercase &&
      lowercase &&
      digit &&
      special &&
      singleLine;

  @override
  List<Object?> get props => [
    minimumLength,
    maximumBytes,
    uppercase,
    lowercase,
    digit,
    special,
    singleLine,
  ];
}

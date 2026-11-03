import 'package:equatable/equatable.dart';
import 'package:want_pass_core/want_pass_core.dart';

final class LoadContentParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  const LoadContentParamsV1({required this.handle});
  @override
  List<Object?> get props => [handle];
  @override
  String toString() => 'LoadContentParamsV1(<redacted>)';
}

final class LoadContentResultV1 extends Equatable {
  final ContentSnapshotV1 snapshot;
  const LoadContentResultV1({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'LoadContentResultV1(<redacted>)';
}

final class SaveGroupParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final GroupDraftV1 input;
  final BigInt revision;
  const SaveGroupParamsV1({
    required this.handle,
    required this.input,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, input, revision];
  @override
  String toString() => 'SaveGroupParamsV1(<redacted>)';
}

final class SaveGroupResultV1 extends Equatable {
  final ContentSnapshotV1 snapshot;
  const SaveGroupResultV1({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'SaveGroupResultV1(<redacted>)';
}

final class DeleteGroupParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  final BigInt revision;
  const DeleteGroupParamsV1({
    required this.handle,
    required this.id,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, id, revision];
  @override
  String toString() => 'DeleteGroupParamsV1(<redacted>)';
}

final class DeleteGroupResultV1 extends Equatable {
  final ContentSnapshotV1 snapshot;
  const DeleteGroupResultV1({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'DeleteGroupResultV1(<redacted>)';
}

final class ReadAccountParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  const ReadAccountParamsV1({required this.handle, required this.id});
  @override
  List<Object?> get props => [handle, id];
  @override
  String toString() => 'ReadAccountParamsV1(<redacted>)';
}

final class ReadAccountResultV1 extends Equatable {
  final AccountV1 account;
  const ReadAccountResultV1({required this.account});
  @override
  List<Object?> get props => [account];
  @override
  String toString() => 'ReadAccountResultV1(<redacted>)';
}

final class SaveAccountParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final AccountDraftV1 input;
  final BigInt revision;
  const SaveAccountParamsV1({
    required this.handle,
    required this.input,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, input, revision];
  @override
  String toString() => 'SaveAccountParamsV1(<redacted>)';
}

final class SaveAccountResultV1 extends Equatable {
  final ContentSnapshotV1 snapshot;
  const SaveAccountResultV1({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'SaveAccountResultV1(<redacted>)';
}

final class DeleteAccountParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  final BigInt revision;
  const DeleteAccountParamsV1({
    required this.handle,
    required this.id,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, id, revision];
  @override
  String toString() => 'DeleteAccountParamsV1(<redacted>)';
}

final class DeleteAccountResultV1 extends Equatable {
  final ContentSnapshotV1 snapshot;
  const DeleteAccountResultV1({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'DeleteAccountResultV1(<redacted>)';
}

final class SelectGroupLogoParamsV1 extends Equatable {
  const SelectGroupLogoParamsV1();
  @override
  List<Object?> get props => const [];
}

final class SelectGroupLogoResultV1 extends Equatable {
  final List<int>? bytes;
  const SelectGroupLogoResultV1({required this.bytes});
  @override
  List<Object?> get props => [bytes];
  @override
  String toString() => 'SelectGroupLogoResultV1(<redacted>)';
}

import 'package:equatable/equatable.dart';
import 'package:want_pass_core/want_pass_core.dart';

final class LoadContentParamsV2 extends Equatable {
  final VaultHandleV1 handle;
  const LoadContentParamsV2({required this.handle});
  @override
  List<Object?> get props => [handle];
  @override
  String toString() => 'LoadContentParamsV2(<redacted>)';
}

final class LoadContentResultV2 extends Equatable {
  final ContentSnapshotV2 snapshot;
  final CardCatalogV1 catalog;
  const LoadContentResultV2({required this.snapshot, required this.catalog});
  @override
  List<Object?> get props => [snapshot, catalog];
  @override
  String toString() => 'LoadContentResultV2(<redacted>)';
}

final class SaveGroupParamsV2 extends Equatable {
  final VaultHandleV1 handle;
  final GroupDraftV1 input;
  final BigInt revision;
  const SaveGroupParamsV2({
    required this.handle,
    required this.input,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, input, revision];
  @override
  String toString() => 'SaveGroupParamsV2(<redacted>)';
}

final class SaveGroupResultV2 extends Equatable {
  final ContentSnapshotV2 snapshot;
  const SaveGroupResultV2({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'SaveGroupResultV2(<redacted>)';
}

final class DeleteGroupParamsV2 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  final BigInt revision;
  const DeleteGroupParamsV2({
    required this.handle,
    required this.id,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, id, revision];
  @override
  String toString() => 'DeleteGroupParamsV2(<redacted>)';
}

final class DeleteGroupResultV2 extends Equatable {
  final ContentSnapshotV2 snapshot;
  const DeleteGroupResultV2({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'DeleteGroupResultV2(<redacted>)';
}

final class ReadCardParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  const ReadCardParamsV1({required this.handle, required this.id});
  @override
  List<Object?> get props => [handle, id];
  @override
  String toString() => 'ReadCardParamsV1(<redacted>)';
}

final class ReadCardResultV1 extends Equatable {
  final CardV1 card;
  const ReadCardResultV1({required this.card});
  @override
  List<Object?> get props => [card];
  @override
  String toString() => 'ReadCardResultV1(<redacted>)';
}

final class SaveCardParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final CardDraftV1 input;
  final BigInt revision;
  const SaveCardParamsV1({
    required this.handle,
    required this.input,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, input, revision];
  @override
  String toString() => 'SaveCardParamsV1(<redacted>)';
}

final class SaveCardResultV1 extends Equatable {
  final ContentSnapshotV2 snapshot;
  const SaveCardResultV1({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'SaveCardResultV1(<redacted>)';
}

final class DeleteCardParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  final BigInt revision;
  const DeleteCardParamsV1({
    required this.handle,
    required this.id,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, id, revision];
  @override
  String toString() => 'DeleteCardParamsV1(<redacted>)';
}

final class DeleteCardResultV1 extends Equatable {
  final ContentSnapshotV2 snapshot;
  const DeleteCardResultV1({required this.snapshot});
  @override
  List<Object?> get props => [snapshot];
  @override
  String toString() => 'DeleteCardResultV1(<redacted>)';
}

final class ReadTotpParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  const ReadTotpParamsV1({required this.handle, required this.id});
  @override
  List<Object?> get props => [handle, id];
  @override
  String toString() => 'ReadTotpParamsV1(<redacted>)';
}

final class ReadTotpResultV1 extends Equatable {
  final TotpCodeV1 code;
  const ReadTotpResultV1({required this.code});
  @override
  List<Object?> get props => [code];
  @override
  String toString() => 'ReadTotpResultV1(<redacted>)';
}

final class CopyCardResultV1 extends Equatable {
  final String text;
  const CopyCardResultV1({required this.text});
  @override
  List<Object?> get props => [text];
  @override
  String toString() => 'CopyCardResultV1(<redacted>)';
}

final class SelectAttachmentParamsV1 extends Equatable {
  const SelectAttachmentParamsV1();
  @override
  List<Object?> get props => [];
  @override
  String toString() => 'SelectAttachmentParamsV1(<redacted>)';
}

final class SelectAttachmentResultV1 extends Equatable {
  final AttachmentDraftV1? attachment;
  const SelectAttachmentResultV1({required this.attachment});
  @override
  List<Object?> get props => [attachment];
  @override
  String toString() => 'SelectAttachmentResultV1(<redacted>)';
}

final class SelectCardDestinationParamsV1 extends Equatable {
  final String name;
  const SelectCardDestinationParamsV1({required this.name});
  @override
  List<Object?> get props => [name];
  @override
  String toString() => 'SelectCardDestinationParamsV1(<redacted>)';
}

final class SelectCardDestinationResultV1 extends Equatable {
  final String? destination;
  const SelectCardDestinationResultV1({required this.destination});
  @override
  List<Object?> get props => [destination];
  @override
  String toString() => 'SelectCardDestinationResultV1(<redacted>)';
}

final class ExportCardAttachmentParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  final String destination;
  final BigInt revision;
  const ExportCardAttachmentParamsV1({
    required this.handle,
    required this.id,
    required this.destination,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, id, destination, revision];
  @override
  String toString() => 'ExportCardAttachmentParamsV1(<redacted>)';
}

final class ExportCardAttachmentResultV1 extends Equatable {
  const ExportCardAttachmentResultV1();
  @override
  List<Object?> get props => [];
  @override
  String toString() => 'ExportCardAttachmentResultV1(<redacted>)';
}

enum CardCopyKindV1 { account, otp, field }

final class CopyCardParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  final CardCopyKindV1 kind;
  final FieldIdV1? field;
  const CopyCardParamsV1.account({required this.handle, required this.id})
    : kind = CardCopyKindV1.account,
      field = null;
  const CopyCardParamsV1.otp({required this.handle, required this.id})
    : kind = CardCopyKindV1.otp,
      field = null;
  const CopyCardParamsV1.field({
    required this.handle,
    required this.id,
    required FieldIdV1 this.field,
  }) : kind = CardCopyKindV1.field;
  @override
  List<Object?> get props => [handle, id, kind, field];
  @override
  String toString() => 'CopyCardParamsV1(<redacted>)';
}

final class ReadCardPreviewParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  final BigInt revision;
  const ReadCardPreviewParamsV1({
    required this.handle,
    required this.id,
    required this.revision,
  });
  @override
  List<Object?> get props => [handle, id, revision];
  @override
  String toString() => 'ReadCardPreviewParamsV1(<redacted>)';
}

final class ReadCardPreviewResultV1 extends Equatable {
  final CardPreviewV1 preview;
  const ReadCardPreviewResultV1({required this.preview});
  @override
  List<Object?> get props => [preview];
  @override
  String toString() => 'ReadCardPreviewResultV1(<redacted>)';
}

final class ReadCardFieldParamsV1 extends Equatable {
  final VaultHandleV1 handle;
  final String id;
  final FieldIdV1 field;
  const ReadCardFieldParamsV1({
    required this.handle,
    required this.id,
    required this.field,
  });
  @override
  List<Object?> get props => [handle, id, field];
  @override
  String toString() => 'ReadCardFieldParamsV1(<redacted>)';
}

final class ReadCardFieldResultV1 extends Equatable {
  final String value;
  const ReadCardFieldResultV1({required this.value});
  @override
  List<Object?> get props => [value];
  @override
  String toString() => 'ReadCardFieldResultV1(<redacted>)';
}

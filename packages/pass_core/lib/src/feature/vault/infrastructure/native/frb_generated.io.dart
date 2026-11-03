// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated_io.dart';

abstract class VaultRustLibApiImplPlatform
    extends BaseApiImpl<VaultRustLibWire> {
  VaultRustLibApiImplPlatform({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  CrossPlatformFinalizerArg get rust_arc_decrement_strong_count_VaultPtr => wire
      ._rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVaultPtr;

  @protected
  Vault
  dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    dynamic raw,
  );

  @protected
  Vault
  dco_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    dynamic raw,
  );

  @protected
  Vault
  dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    dynamic raw,
  );

  @protected
  String dco_decode_String(dynamic raw);

  @protected
  AccountInputV1 dco_decode_account_input_v_1(dynamic raw);

  @protected
  AccountRecordV1 dco_decode_account_record_v_1(dynamic raw);

  @protected
  AccountSummaryV1 dco_decode_account_summary_v_1(dynamic raw);

  @protected
  AttachmentInputV1 dco_decode_attachment_input_v_1(dynamic raw);

  @protected
  AttachmentSummaryV1 dco_decode_attachment_summary_v_1(dynamic raw);

  @protected
  bool dco_decode_bool(dynamic raw);

  @protected
  AccountInputV1 dco_decode_box_autoadd_account_input_v_1(dynamic raw);

  @protected
  AttachmentInputV1 dco_decode_box_autoadd_attachment_input_v_1(dynamic raw);

  @protected
  AttachmentSummaryV1 dco_decode_box_autoadd_attachment_summary_v_1(
    dynamic raw,
  );

  @protected
  CardInputV1 dco_decode_box_autoadd_card_input_v_1(dynamic raw);

  @protected
  EnvironmentV1 dco_decode_box_autoadd_environment_v_1(dynamic raw);

  @protected
  GroupInputV1 dco_decode_box_autoadd_group_input_v_1(dynamic raw);

  @protected
  CardInputV1 dco_decode_card_input_v_1(dynamic raw);

  @protected
  CardPresetV1 dco_decode_card_preset_v_1(dynamic raw);

  @protected
  CardRecordV1 dco_decode_card_record_v_1(dynamic raw);

  @protected
  CardSummaryV1 dco_decode_card_summary_v_1(dynamic raw);

  @protected
  CardTypeV1 dco_decode_card_type_v_1(dynamic raw);

  @protected
  CardValueV1 dco_decode_card_value_v_1(dynamic raw);

  @protected
  ContentSnapshotV1 dco_decode_content_snapshot_v_1(dynamic raw);

  @protected
  ContentSnapshotV2 dco_decode_content_snapshot_v_2(dynamic raw);

  @protected
  EnvironmentV1 dco_decode_environment_v_1(dynamic raw);

  @protected
  FieldIdV1 dco_decode_field_id_v_1(dynamic raw);

  @protected
  FieldSpecV1 dco_decode_field_spec_v_1(dynamic raw);

  @protected
  GroupInputV1 dco_decode_group_input_v_1(dynamic raw);

  @protected
  GroupRecordV1 dco_decode_group_record_v_1(dynamic raw);

  @protected
  int dco_decode_i_32(dynamic raw);

  @protected
  List<String> dco_decode_list_String(dynamic raw);

  @protected
  List<AccountSummaryV1> dco_decode_list_account_summary_v_1(dynamic raw);

  @protected
  List<CardPresetV1> dco_decode_list_card_preset_v_1(dynamic raw);

  @protected
  List<CardSummaryV1> dco_decode_list_card_summary_v_1(dynamic raw);

  @protected
  List<CardValueV1> dco_decode_list_card_value_v_1(dynamic raw);

  @protected
  List<FieldSpecV1> dco_decode_list_field_spec_v_1(dynamic raw);

  @protected
  List<GroupRecordV1> dco_decode_list_group_record_v_1(dynamic raw);

  @protected
  List<List<String>> dco_decode_list_list_String(dynamic raw);

  @protected
  Uint32List dco_decode_list_prim_u_32_strict(dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  String? dco_decode_opt_String(dynamic raw);

  @protected
  AttachmentInputV1? dco_decode_opt_box_autoadd_attachment_input_v_1(
    dynamic raw,
  );

  @protected
  AttachmentSummaryV1? dco_decode_opt_box_autoadd_attachment_summary_v_1(
    dynamic raw,
  );

  @protected
  EnvironmentV1? dco_decode_opt_box_autoadd_environment_v_1(dynamic raw);

  @protected
  RecoveryChallenge dco_decode_recovery_challenge(dynamic raw);

  @protected
  RecoveryChallengeV2 dco_decode_recovery_challenge_v_2(dynamic raw);

  @protected
  RecoveryChallengeV3 dco_decode_recovery_challenge_v_3(dynamic raw);

  @protected
  TotpCodeV1 dco_decode_totp_code_v_1(dynamic raw);

  @protected
  int dco_decode_u_32(dynamic raw);

  @protected
  BigInt dco_decode_u_64(dynamic raw);

  @protected
  int dco_decode_u_8(dynamic raw);

  @protected
  void dco_decode_unit(dynamic raw);

  @protected
  BigInt dco_decode_usize(dynamic raw);

  @protected
  VaultFailure dco_decode_vault_failure(dynamic raw);

  @protected
  VaultHintsV2 dco_decode_vault_hints_v_2(dynamic raw);

  @protected
  VaultStatus dco_decode_vault_status(dynamic raw);

  @protected
  Vault
  sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    SseDeserializer deserializer,
  );

  @protected
  Vault
  sse_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    SseDeserializer deserializer,
  );

  @protected
  Vault
  sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    SseDeserializer deserializer,
  );

  @protected
  String sse_decode_String(SseDeserializer deserializer);

  @protected
  AccountInputV1 sse_decode_account_input_v_1(SseDeserializer deserializer);

  @protected
  AccountRecordV1 sse_decode_account_record_v_1(SseDeserializer deserializer);

  @protected
  AccountSummaryV1 sse_decode_account_summary_v_1(SseDeserializer deserializer);

  @protected
  AttachmentInputV1 sse_decode_attachment_input_v_1(
    SseDeserializer deserializer,
  );

  @protected
  AttachmentSummaryV1 sse_decode_attachment_summary_v_1(
    SseDeserializer deserializer,
  );

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

  @protected
  AccountInputV1 sse_decode_box_autoadd_account_input_v_1(
    SseDeserializer deserializer,
  );

  @protected
  AttachmentInputV1 sse_decode_box_autoadd_attachment_input_v_1(
    SseDeserializer deserializer,
  );

  @protected
  AttachmentSummaryV1 sse_decode_box_autoadd_attachment_summary_v_1(
    SseDeserializer deserializer,
  );

  @protected
  CardInputV1 sse_decode_box_autoadd_card_input_v_1(
    SseDeserializer deserializer,
  );

  @protected
  EnvironmentV1 sse_decode_box_autoadd_environment_v_1(
    SseDeserializer deserializer,
  );

  @protected
  GroupInputV1 sse_decode_box_autoadd_group_input_v_1(
    SseDeserializer deserializer,
  );

  @protected
  CardInputV1 sse_decode_card_input_v_1(SseDeserializer deserializer);

  @protected
  CardPresetV1 sse_decode_card_preset_v_1(SseDeserializer deserializer);

  @protected
  CardRecordV1 sse_decode_card_record_v_1(SseDeserializer deserializer);

  @protected
  CardSummaryV1 sse_decode_card_summary_v_1(SseDeserializer deserializer);

  @protected
  CardTypeV1 sse_decode_card_type_v_1(SseDeserializer deserializer);

  @protected
  CardValueV1 sse_decode_card_value_v_1(SseDeserializer deserializer);

  @protected
  ContentSnapshotV1 sse_decode_content_snapshot_v_1(
    SseDeserializer deserializer,
  );

  @protected
  ContentSnapshotV2 sse_decode_content_snapshot_v_2(
    SseDeserializer deserializer,
  );

  @protected
  EnvironmentV1 sse_decode_environment_v_1(SseDeserializer deserializer);

  @protected
  FieldIdV1 sse_decode_field_id_v_1(SseDeserializer deserializer);

  @protected
  FieldSpecV1 sse_decode_field_spec_v_1(SseDeserializer deserializer);

  @protected
  GroupInputV1 sse_decode_group_input_v_1(SseDeserializer deserializer);

  @protected
  GroupRecordV1 sse_decode_group_record_v_1(SseDeserializer deserializer);

  @protected
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer);

  @protected
  List<AccountSummaryV1> sse_decode_list_account_summary_v_1(
    SseDeserializer deserializer,
  );

  @protected
  List<CardPresetV1> sse_decode_list_card_preset_v_1(
    SseDeserializer deserializer,
  );

  @protected
  List<CardSummaryV1> sse_decode_list_card_summary_v_1(
    SseDeserializer deserializer,
  );

  @protected
  List<CardValueV1> sse_decode_list_card_value_v_1(
    SseDeserializer deserializer,
  );

  @protected
  List<FieldSpecV1> sse_decode_list_field_spec_v_1(
    SseDeserializer deserializer,
  );

  @protected
  List<GroupRecordV1> sse_decode_list_group_record_v_1(
    SseDeserializer deserializer,
  );

  @protected
  List<List<String>> sse_decode_list_list_String(SseDeserializer deserializer);

  @protected
  Uint32List sse_decode_list_prim_u_32_strict(SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  String? sse_decode_opt_String(SseDeserializer deserializer);

  @protected
  AttachmentInputV1? sse_decode_opt_box_autoadd_attachment_input_v_1(
    SseDeserializer deserializer,
  );

  @protected
  AttachmentSummaryV1? sse_decode_opt_box_autoadd_attachment_summary_v_1(
    SseDeserializer deserializer,
  );

  @protected
  EnvironmentV1? sse_decode_opt_box_autoadd_environment_v_1(
    SseDeserializer deserializer,
  );

  @protected
  RecoveryChallenge sse_decode_recovery_challenge(SseDeserializer deserializer);

  @protected
  RecoveryChallengeV2 sse_decode_recovery_challenge_v_2(
    SseDeserializer deserializer,
  );

  @protected
  RecoveryChallengeV3 sse_decode_recovery_challenge_v_3(
    SseDeserializer deserializer,
  );

  @protected
  TotpCodeV1 sse_decode_totp_code_v_1(SseDeserializer deserializer);

  @protected
  int sse_decode_u_32(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_u_64(SseDeserializer deserializer);

  @protected
  int sse_decode_u_8(SseDeserializer deserializer);

  @protected
  void sse_decode_unit(SseDeserializer deserializer);

  @protected
  BigInt sse_decode_usize(SseDeserializer deserializer);

  @protected
  VaultFailure sse_decode_vault_failure(SseDeserializer deserializer);

  @protected
  VaultHintsV2 sse_decode_vault_hints_v_2(SseDeserializer deserializer);

  @protected
  VaultStatus sse_decode_vault_status(SseDeserializer deserializer);

  @protected
  void
  sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    Vault self,
    SseSerializer serializer,
  );

  @protected
  void
  sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    Vault self,
    SseSerializer serializer,
  );

  @protected
  void
  sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    Vault self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_String(String self, SseSerializer serializer);

  @protected
  void sse_encode_account_input_v_1(
    AccountInputV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_account_record_v_1(
    AccountRecordV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_account_summary_v_1(
    AccountSummaryV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_attachment_input_v_1(
    AttachmentInputV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_attachment_summary_v_1(
    AttachmentSummaryV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);

  @protected
  void sse_encode_box_autoadd_account_input_v_1(
    AccountInputV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_box_autoadd_attachment_input_v_1(
    AttachmentInputV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_box_autoadd_attachment_summary_v_1(
    AttachmentSummaryV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_box_autoadd_card_input_v_1(
    CardInputV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_box_autoadd_environment_v_1(
    EnvironmentV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_box_autoadd_group_input_v_1(
    GroupInputV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_card_input_v_1(CardInputV1 self, SseSerializer serializer);

  @protected
  void sse_encode_card_preset_v_1(CardPresetV1 self, SseSerializer serializer);

  @protected
  void sse_encode_card_record_v_1(CardRecordV1 self, SseSerializer serializer);

  @protected
  void sse_encode_card_summary_v_1(
    CardSummaryV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_card_type_v_1(CardTypeV1 self, SseSerializer serializer);

  @protected
  void sse_encode_card_value_v_1(CardValueV1 self, SseSerializer serializer);

  @protected
  void sse_encode_content_snapshot_v_1(
    ContentSnapshotV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_content_snapshot_v_2(
    ContentSnapshotV2 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_environment_v_1(EnvironmentV1 self, SseSerializer serializer);

  @protected
  void sse_encode_field_id_v_1(FieldIdV1 self, SseSerializer serializer);

  @protected
  void sse_encode_field_spec_v_1(FieldSpecV1 self, SseSerializer serializer);

  @protected
  void sse_encode_group_input_v_1(GroupInputV1 self, SseSerializer serializer);

  @protected
  void sse_encode_group_record_v_1(
    GroupRecordV1 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer);

  @protected
  void sse_encode_list_account_summary_v_1(
    List<AccountSummaryV1> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_list_card_preset_v_1(
    List<CardPresetV1> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_list_card_summary_v_1(
    List<CardSummaryV1> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_list_card_value_v_1(
    List<CardValueV1> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_list_field_spec_v_1(
    List<FieldSpecV1> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_list_group_record_v_1(
    List<GroupRecordV1> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_list_list_String(
    List<List<String>> self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_list_prim_u_32_strict(
    Uint32List self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_list_prim_u_8_strict(
    Uint8List self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_opt_String(String? self, SseSerializer serializer);

  @protected
  void sse_encode_opt_box_autoadd_attachment_input_v_1(
    AttachmentInputV1? self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_opt_box_autoadd_attachment_summary_v_1(
    AttachmentSummaryV1? self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_opt_box_autoadd_environment_v_1(
    EnvironmentV1? self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_recovery_challenge(
    RecoveryChallenge self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_recovery_challenge_v_2(
    RecoveryChallengeV2 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_recovery_challenge_v_3(
    RecoveryChallengeV3 self,
    SseSerializer serializer,
  );

  @protected
  void sse_encode_totp_code_v_1(TotpCodeV1 self, SseSerializer serializer);

  @protected
  void sse_encode_u_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_u_64(BigInt self, SseSerializer serializer);

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer);

  @protected
  void sse_encode_unit(void self, SseSerializer serializer);

  @protected
  void sse_encode_usize(BigInt self, SseSerializer serializer);

  @protected
  void sse_encode_vault_failure(VaultFailure self, SseSerializer serializer);

  @protected
  void sse_encode_vault_hints_v_2(VaultHintsV2 self, SseSerializer serializer);

  @protected
  void sse_encode_vault_status(VaultStatus self, SseSerializer serializer);
}

// Section: wire_class

class VaultRustLibWire implements BaseWire {
  factory VaultRustLibWire.fromExternalLibrary(ExternalLibrary lib) =>
      VaultRustLibWire(lib.ffiDynamicLibrary);

  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
  _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  VaultRustLibWire(ffi.DynamicLibrary dynamicLibrary)
    : _lookup = dynamicLibrary.lookup;

  void
  rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    ffi.Pointer<ffi.Void> ptr,
  ) {
    return _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
      ptr,
    );
  }

  late final _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVaultPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
        'frbgen_want_pass_core_rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault',
      );
  late final _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault =
      _rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVaultPtr
          .asFunction<void Function(ffi.Pointer<ffi.Void>)>();

  void
  rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    ffi.Pointer<ffi.Void> ptr,
  ) {
    return _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
      ptr,
    );
  }

  late final _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVaultPtr =
      _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(
        'frbgen_want_pass_core_rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault',
      );
  late final _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault =
      _rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVaultPtr
          .asFunction<void Function(ffi.Pointer<ffi.Void>)>();
}

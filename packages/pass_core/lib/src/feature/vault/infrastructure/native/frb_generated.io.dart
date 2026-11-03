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
  int dco_decode_i_32(dynamic raw);

  @protected
  List<String> dco_decode_list_String(dynamic raw);

  @protected
  Uint32List dco_decode_list_prim_u_32_strict(dynamic raw);

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw);

  @protected
  RecoveryChallenge dco_decode_recovery_challenge(dynamic raw);

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
  int sse_decode_i_32(SseDeserializer deserializer);

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer);

  @protected
  Uint32List sse_decode_list_prim_u_32_strict(SseDeserializer deserializer);

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer);

  @protected
  RecoveryChallenge sse_decode_recovery_challenge(SseDeserializer deserializer);

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
  VaultStatus sse_decode_vault_status(SseDeserializer deserializer);

  @protected
  bool sse_decode_bool(SseDeserializer deserializer);

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
  void sse_encode_i_32(int self, SseSerializer serializer);

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer);

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
  void sse_encode_recovery_challenge(
    RecoveryChallenge self,
    SseSerializer serializer,
  );

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
  void sse_encode_vault_status(VaultStatus self, SseSerializer serializer);

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer);
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

// ignore_for_file: unused_import, unused_element, unnecessary_import, duplicate_ignore, invalid_use_of_internal_member, annotate_overrides, non_constant_identifier_names, curly_braces_in_flow_control_structures, prefer_const_literals_to_create_immutables, unused_field

import 'package:want_pass_core/src/feature/vault/infrastructure/_barrel.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

/// Main entrypoint of the Rust API
class VaultRustLib
    extends
        BaseEntrypoint<VaultRustLibApi, VaultRustLibApiImpl, VaultRustLibWire> {
  @internal
  static final instance = VaultRustLib._();

  VaultRustLib._();

  /// Initialize flutter_rust_bridge
  static Future<void> init({
    VaultRustLibApi? api,
    BaseHandler? handler,
    ExternalLibrary? externalLibrary,
    bool forceSameCodegenVersion = true,
  }) async {
    await instance.initImpl(
      api: api,
      handler: handler,
      externalLibrary: externalLibrary,
      forceSameCodegenVersion: forceSameCodegenVersion,
    );
  }

  /// Initialize flutter_rust_bridge in mock mode.
  /// No libraries for FFI are loaded.
  static void initMock({required VaultRustLibApi api}) {
    instance.initMockImpl(api: api);
  }

  /// Dispose flutter_rust_bridge
  ///
  /// The call to this function is optional, since flutter_rust_bridge (and everything else)
  /// is automatically disposed when the app stops.
  static void dispose() => instance.disposeImpl();

  @override
  ApiImplConstructor<VaultRustLibApiImpl, VaultRustLibWire>
  get apiImplConstructor => VaultRustLibApiImpl.new;

  @override
  WireConstructor<VaultRustLibWire> get wireConstructor =>
      VaultRustLibWire.fromExternalLibrary;

  @override
  Future<void> executeRustInitializers() async {}

  @override
  ExternalLibraryLoaderConfig get defaultExternalLibraryLoaderConfig =>
      kDefaultExternalLibraryLoaderConfig;

  @override
  String get codegenVersion => '2.13.0';

  @override
  int get rustContentHash => -469700598;

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
        stem: 'want_pass_vault',
        ioDirectory: 'rust/target/release/',
        webPrefix: 'pkg/',
        wasmBindgenName: 'wasm_bindgen',
      );
}

abstract class VaultRustLibApi extends BaseApi {
  Future<void> crateApiVaultClose({required Vault that});

  Future<void> crateApiVaultConfirm({
    required Vault that,
    required List<String> answers,
    required BigInt generation,
  });

  Future<void> crateApiVaultConfirmV2({
    required Vault that,
    required List<String> answers,
    required String password,
    required String passwordHint,
    required String recoveryHint,
    required BigInt generation,
  });

  Future<void> crateApiVaultExportRecoveryV2({
    required Vault that,
    required String destination,
    required BigInt generation,
  });

  BigInt crateApiVaultGeneration({required Vault that});

  Future<VaultHintsV2> crateApiVaultHintsV2({required Vault that});

  void crateApiVaultLock({required Vault that});

  Future<Vault> crateApiVaultOpen({required String directory});

  Future<RecoveryChallenge> crateApiVaultPrepareCreation({
    required Vault that,
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallengeV2> crateApiVaultPrepareCreationV2({
    required Vault that,
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallenge> crateApiVaultPrepareRecovery({
    required Vault that,
    required String phrase,
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallengeV2> crateApiVaultPrepareRecoveryV2({
    required Vault that,
    required String phrase,
    required String password,
    required BigInt generation,
  });

  Future<VaultStatus> crateApiVaultStatus({required Vault that});

  Future<void> crateApiVaultUnlock({
    required Vault that,
    required String password,
    required BigInt generation,
  });

  RustArcIncrementStrongCountFnType get rust_arc_increment_strong_count_Vault;

  RustArcDecrementStrongCountFnType get rust_arc_decrement_strong_count_Vault;

  CrossPlatformFinalizerArg get rust_arc_decrement_strong_count_VaultPtr;
}

class VaultRustLibApiImpl extends VaultRustLibApiImplPlatform
    implements VaultRustLibApi {
  VaultRustLibApiImpl({
    required super.handler,
    required super.wire,
    required super.generalizedFrbRustBinding,
    required super.portManager,
  });

  @override
  Future<void> crateApiVaultClose({required Vault that}) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 1,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultCloseConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultCloseConstMeta =>
      const TaskConstMeta(debugName: "Vault_close", argNames: ["that"]);

  @override
  Future<void> crateApiVaultConfirm({
    required Vault that,
    required List<String> answers,
    required BigInt generation,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          sse_encode_list_String(answers, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 2,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultConfirmConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultConfirmConstMeta => const TaskConstMeta(
    debugName: "Vault_confirm",
    argNames: ["that", "answers", "generation"],
  );

  @override
  Future<void> crateApiVaultConfirmV2({
    required Vault that,
    required List<String> answers,
    required String password,
    required String passwordHint,
    required String recoveryHint,
    required BigInt generation,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          sse_encode_list_String(answers, serializer);
          sse_encode_String(password, serializer);
          sse_encode_String(passwordHint, serializer);
          sse_encode_String(recoveryHint, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 3,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultConfirmV2ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultConfirmV2ConstMeta => const TaskConstMeta(
    debugName: "Vault_confirm_v2",
    argNames: [
      "that",
      "answers",
      "password",
      "passwordHint",
      "recoveryHint",
      "generation",
    ],
  );

  @override
  Future<void> crateApiVaultExportRecoveryV2({
    required Vault that,
    required String destination,
    required BigInt generation,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          sse_encode_String(destination, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 4,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultExportRecoveryV2ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultExportRecoveryV2ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_export_recovery_v2",
        argNames: ["that", "destination", "generation"],
      );

  @override
  BigInt crateApiVaultGeneration({required Vault that}) {
    return handler.executeSync(
      SyncTask(
        callFfi: () {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 5)!;
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_u_64,
          decodeErrorData: null,
        ),
        constMeta: kCrateApiVaultGenerationConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultGenerationConstMeta =>
      const TaskConstMeta(debugName: "Vault_generation", argNames: ["that"]);

  @override
  Future<VaultHintsV2> crateApiVaultHintsV2({required Vault that}) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 6,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_vault_hints_v_2,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultHintsV2ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultHintsV2ConstMeta =>
      const TaskConstMeta(debugName: "Vault_hints_v2", argNames: ["that"]);

  @override
  void crateApiVaultLock({required Vault that}) {
    return handler.executeSync(
      SyncTask(
        callFfi: () {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 7)!;
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultLockConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultLockConstMeta =>
      const TaskConstMeta(debugName: "Vault_lock", argNames: ["that"]);

  @override
  Future<Vault> crateApiVaultOpen({required String directory}) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_String(directory, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 8,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData:
              sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultOpenConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultOpenConstMeta =>
      const TaskConstMeta(debugName: "Vault_open", argNames: ["directory"]);

  @override
  Future<RecoveryChallenge> crateApiVaultPrepareCreation({
    required Vault that,
    required String password,
    required BigInt generation,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          sse_encode_String(password, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 9,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_recovery_challenge,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultPrepareCreationConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultPrepareCreationConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_prepare_creation",
        argNames: ["that", "password", "generation"],
      );

  @override
  Future<RecoveryChallengeV2> crateApiVaultPrepareCreationV2({
    required Vault that,
    required String password,
    required BigInt generation,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          sse_encode_String(password, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 10,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_recovery_challenge_v_2,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultPrepareCreationV2ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultPrepareCreationV2ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_prepare_creation_v2",
        argNames: ["that", "password", "generation"],
      );

  @override
  Future<RecoveryChallenge> crateApiVaultPrepareRecovery({
    required Vault that,
    required String phrase,
    required String password,
    required BigInt generation,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          sse_encode_String(phrase, serializer);
          sse_encode_String(password, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 11,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_recovery_challenge,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultPrepareRecoveryConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultPrepareRecoveryConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_prepare_recovery",
        argNames: ["that", "phrase", "password", "generation"],
      );

  @override
  Future<RecoveryChallengeV2> crateApiVaultPrepareRecoveryV2({
    required Vault that,
    required String phrase,
    required String password,
    required BigInt generation,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          sse_encode_String(phrase, serializer);
          sse_encode_String(password, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 12,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_recovery_challenge_v_2,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultPrepareRecoveryV2ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultPrepareRecoveryV2ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_prepare_recovery_v2",
        argNames: ["that", "phrase", "password", "generation"],
      );

  @override
  Future<VaultStatus> crateApiVaultStatus({required Vault that}) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 13,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_vault_status,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultStatusConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultStatusConstMeta =>
      const TaskConstMeta(debugName: "Vault_status", argNames: ["that"]);

  @override
  Future<void> crateApiVaultUnlock({
    required Vault that,
    required String password,
    required BigInt generation,
  }) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
            that,
            serializer,
          );
          sse_encode_String(password, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 14,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultUnlockConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultUnlockConstMeta => const TaskConstMeta(
    debugName: "Vault_unlock",
    argNames: ["that", "password", "generation"],
  );

  RustArcIncrementStrongCountFnType
  get rust_arc_increment_strong_count_Vault => wire
      .rust_arc_increment_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault;

  RustArcDecrementStrongCountFnType
  get rust_arc_decrement_strong_count_Vault => wire
      .rust_arc_decrement_strong_count_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault;

  @protected
  Vault
  dco_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    dynamic raw,
  ) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return VaultImpl.frbInternalDcoDecode(raw as List<dynamic>);
  }

  @protected
  Vault
  dco_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    dynamic raw,
  ) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return VaultImpl.frbInternalDcoDecode(raw as List<dynamic>);
  }

  @protected
  Vault
  dco_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    dynamic raw,
  ) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return VaultImpl.frbInternalDcoDecode(raw as List<dynamic>);
  }

  @protected
  String dco_decode_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as String;
  }

  @protected
  int dco_decode_i_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  List<String> dco_decode_list_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_String).toList();
  }

  @protected
  List<List<String>> dco_decode_list_list_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_list_String).toList();
  }

  @protected
  Uint32List dco_decode_list_prim_u_32_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Uint32List;
  }

  @protected
  Uint8List dco_decode_list_prim_u_8_strict(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as Uint8List;
  }

  @protected
  RecoveryChallenge dco_decode_recovery_challenge(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return RecoveryChallenge(
      words: dco_decode_list_String(arr[0]),
      positions: dco_decode_list_prim_u_32_strict(arr[1]),
    );
  }

  @protected
  RecoveryChallengeV2 dco_decode_recovery_challenge_v_2(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 3)
      throw Exception('unexpected arr length: expect 3 but see ${arr.length}');
    return RecoveryChallengeV2(
      words: dco_decode_list_String(arr[0]),
      positions: dco_decode_list_prim_u_32_strict(arr[1]),
      choices: dco_decode_list_list_String(arr[2]),
    );
  }

  @protected
  int dco_decode_u_32(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  BigInt dco_decode_u_64(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeU64(raw);
  }

  @protected
  int dco_decode_u_8(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as int;
  }

  @protected
  void dco_decode_unit(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return;
  }

  @protected
  BigInt dco_decode_usize(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dcoDecodeU64(raw);
  }

  @protected
  VaultFailure dco_decode_vault_failure(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return VaultFailure.values[raw as int];
  }

  @protected
  VaultHintsV2 dco_decode_vault_hints_v_2(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 2)
      throw Exception('unexpected arr length: expect 2 but see ${arr.length}');
    return VaultHintsV2(
      password: dco_decode_String(arr[0]),
      recovery: dco_decode_String(arr[1]),
    );
  }

  @protected
  VaultStatus dco_decode_vault_status(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return VaultStatus.values[raw as int];
  }

  @protected
  Vault
  sse_decode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return VaultImpl.frbInternalSseDecode(
      sse_decode_usize(deserializer),
      sse_decode_i_32(deserializer),
    );
  }

  @protected
  Vault
  sse_decode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return VaultImpl.frbInternalSseDecode(
      sse_decode_usize(deserializer),
      sse_decode_i_32(deserializer),
    );
  }

  @protected
  Vault
  sse_decode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return VaultImpl.frbInternalSseDecode(
      sse_decode_usize(deserializer),
      sse_decode_i_32(deserializer),
    );
  }

  @protected
  String sse_decode_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_list_prim_u_8_strict(deserializer);
    return utf8.decoder.convert(inner);
  }

  @protected
  int sse_decode_i_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getInt32();
  }

  @protected
  List<String> sse_decode_list_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <String>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_String(deserializer));
    }
    return ans_;
  }

  @protected
  List<List<String>> sse_decode_list_list_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <List<String>>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_list_String(deserializer));
    }
    return ans_;
  }

  @protected
  Uint32List sse_decode_list_prim_u_32_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint32List(len_);
  }

  @protected
  Uint8List sse_decode_list_prim_u_8_strict(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var len_ = sse_decode_i_32(deserializer);
    return deserializer.buffer.getUint8List(len_);
  }

  @protected
  RecoveryChallenge sse_decode_recovery_challenge(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_words = sse_decode_list_String(deserializer);
    var var_positions = sse_decode_list_prim_u_32_strict(deserializer);
    return RecoveryChallenge(words: var_words, positions: var_positions);
  }

  @protected
  RecoveryChallengeV2 sse_decode_recovery_challenge_v_2(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_words = sse_decode_list_String(deserializer);
    var var_positions = sse_decode_list_prim_u_32_strict(deserializer);
    var var_choices = sse_decode_list_list_String(deserializer);
    return RecoveryChallengeV2(
      words: var_words,
      positions: var_positions,
      choices: var_choices,
    );
  }

  @protected
  int sse_decode_u_32(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint32();
  }

  @protected
  BigInt sse_decode_u_64(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getBigUint64();
  }

  @protected
  int sse_decode_u_8(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8();
  }

  @protected
  void sse_decode_unit(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  BigInt sse_decode_usize(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getBigUint64();
  }

  @protected
  VaultFailure sse_decode_vault_failure(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_i_32(deserializer);
    return VaultFailure.values[inner];
  }

  @protected
  VaultHintsV2 sse_decode_vault_hints_v_2(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_password = sse_decode_String(deserializer);
    var var_recovery = sse_decode_String(deserializer);
    return VaultHintsV2(password: var_password, recovery: var_recovery);
  }

  @protected
  VaultStatus sse_decode_vault_status(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var inner = sse_decode_i_32(deserializer);
    return VaultStatus.values[inner];
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  void
  sse_encode_Auto_Owned_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    Vault self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_usize(
      (self as VaultImpl).frbInternalSseEncode(move: true),
      serializer,
    );
  }

  @protected
  void
  sse_encode_Auto_Ref_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    Vault self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_usize(
      (self as VaultImpl).frbInternalSseEncode(move: false),
      serializer,
    );
  }

  @protected
  void
  sse_encode_RustOpaque_flutter_rust_bridgefor_generatedRustAutoOpaqueInnerVault(
    Vault self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_usize(
      (self as VaultImpl).frbInternalSseEncode(move: null),
      serializer,
    );
  }

  @protected
  void sse_encode_String(String self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_prim_u_8_strict(utf8.encoder.convert(self), serializer);
  }

  @protected
  void sse_encode_i_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putInt32(self);
  }

  @protected
  void sse_encode_list_String(List<String> self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_String(item, serializer);
    }
  }

  @protected
  void sse_encode_list_list_String(
    List<List<String>> self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_list_String(item, serializer);
    }
  }

  @protected
  void sse_encode_list_prim_u_32_strict(
    Uint32List self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint32List(self);
  }

  @protected
  void sse_encode_list_prim_u_8_strict(
    Uint8List self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    serializer.buffer.putUint8List(self);
  }

  @protected
  void sse_encode_recovery_challenge(
    RecoveryChallenge self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_String(self.words, serializer);
    sse_encode_list_prim_u_32_strict(self.positions, serializer);
  }

  @protected
  void sse_encode_recovery_challenge_v_2(
    RecoveryChallengeV2 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_String(self.words, serializer);
    sse_encode_list_prim_u_32_strict(self.positions, serializer);
    sse_encode_list_list_String(self.choices, serializer);
  }

  @protected
  void sse_encode_u_32(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint32(self);
  }

  @protected
  void sse_encode_u_64(BigInt self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putBigUint64(self);
  }

  @protected
  void sse_encode_u_8(int self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self);
  }

  @protected
  void sse_encode_unit(void self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
  }

  @protected
  void sse_encode_usize(BigInt self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putBigUint64(self);
  }

  @protected
  void sse_encode_vault_failure(VaultFailure self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.index, serializer);
  }

  @protected
  void sse_encode_vault_hints_v_2(VaultHintsV2 self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.password, serializer);
    sse_encode_String(self.recovery, serializer);
  }

  @protected
  void sse_encode_vault_status(VaultStatus self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.index, serializer);
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self ? 1 : 0);
  }
}

@sealed
class VaultImpl extends RustOpaque implements Vault {
  // Not to be used by end users
  VaultImpl.frbInternalDcoDecode(List<dynamic> wire)
    : super.frbInternalDcoDecode(wire, _kStaticData);

  // Not to be used by end users
  VaultImpl.frbInternalSseDecode(BigInt ptr, int externalSizeOnNative)
    : super.frbInternalSseDecode(ptr, externalSizeOnNative, _kStaticData);

  static final _kStaticData = RustArcStaticData(
    rustArcIncrementStrongCount:
        VaultRustLib.instance.api.rust_arc_increment_strong_count_Vault,
    rustArcDecrementStrongCount:
        VaultRustLib.instance.api.rust_arc_decrement_strong_count_Vault,
    rustArcDecrementStrongCountPtr:
        VaultRustLib.instance.api.rust_arc_decrement_strong_count_VaultPtr,
  );

  Future<void> close() =>
      VaultRustLib.instance.api.crateApiVaultClose(that: this);

  Future<void> confirm({
    required List<String> answers,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultConfirm(
    that: this,
    answers: answers,
    generation: generation,
  );

  Future<void> confirmV2({
    required List<String> answers,
    required String password,
    required String passwordHint,
    required String recoveryHint,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultConfirmV2(
    that: this,
    answers: answers,
    password: password,
    passwordHint: passwordHint,
    recoveryHint: recoveryHint,
    generation: generation,
  );

  Future<void> exportRecoveryV2({
    required String destination,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultExportRecoveryV2(
    that: this,
    destination: destination,
    generation: generation,
  );

  BigInt generation() =>
      VaultRustLib.instance.api.crateApiVaultGeneration(that: this);

  Future<VaultHintsV2> hintsV2() =>
      VaultRustLib.instance.api.crateApiVaultHintsV2(that: this);

  void lock() => VaultRustLib.instance.api.crateApiVaultLock(that: this);

  Future<RecoveryChallenge> prepareCreation({
    required String password,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultPrepareCreation(
    that: this,
    password: password,
    generation: generation,
  );

  Future<RecoveryChallengeV2> prepareCreationV2({
    required String password,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultPrepareCreationV2(
    that: this,
    password: password,
    generation: generation,
  );

  Future<RecoveryChallenge> prepareRecovery({
    required String phrase,
    required String password,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultPrepareRecovery(
    that: this,
    phrase: phrase,
    password: password,
    generation: generation,
  );

  Future<RecoveryChallengeV2> prepareRecoveryV2({
    required String phrase,
    required String password,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultPrepareRecoveryV2(
    that: this,
    phrase: phrase,
    password: password,
    generation: generation,
  );

  Future<VaultStatus> status() =>
      VaultRustLib.instance.api.crateApiVaultStatus(that: this);

  Future<void> unlock({required String password, required BigInt generation}) =>
      VaultRustLib.instance.api.crateApiVaultUnlock(
        that: this,
        password: password,
        generation: generation,
      );
}

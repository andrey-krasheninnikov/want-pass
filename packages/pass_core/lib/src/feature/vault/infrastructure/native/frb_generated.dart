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
  int get rustContentHash => 1824418032;

  static const kDefaultExternalLibraryLoaderConfig =
      ExternalLibraryLoaderConfig(
        stem: 'want_pass_vault',
        ioDirectory: 'rust/target/release/',
        webPrefix: 'pkg/',
        wasmBindgenName: 'wasm_bindgen',
      );
}

abstract class VaultRustLibApi extends BaseApi {
  Future<AccountRecordV1> crateApiVaultAccountV1({
    required Vault that,
    required String id,
    required BigInt generation,
  });

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

  Future<void> crateApiVaultConfirmV3({
    required Vault that,
    required List<String> answers,
    required String password,
    required String passwordHint,
    required String recoveryHint,
    required BigInt revision,
  });

  Future<ContentSnapshotV1> crateApiVaultContentV1({
    required Vault that,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> crateApiVaultDeleteAccountV1({
    required Vault that,
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> crateApiVaultDeleteGroupV1({
    required Vault that,
    required String id,
    required BigInt revision,
    required BigInt generation,
  });

  Future<void> crateApiVaultExportRecoveryV2({
    required Vault that,
    required String destination,
    required BigInt generation,
  });

  Future<void> crateApiVaultExportRecoveryV3({
    required Vault that,
    required String destination,
    required BigInt revision,
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

  Future<RecoveryChallengeV3> crateApiVaultPrepareCreationV3({
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

  Future<RecoveryChallengeV3> crateApiVaultPrepareRecoveryV3({
    required Vault that,
    required String phrase,
    required String password,
    required BigInt generation,
  });

  Future<RecoveryChallengeV3> crateApiVaultRegenerateRecoveryV3({
    required Vault that,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> crateApiVaultSaveAccountV1({
    required Vault that,
    required AccountInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<ContentSnapshotV1> crateApiVaultSaveGroupV1({
    required Vault that,
    required GroupInputV1 input,
    required BigInt revision,
    required BigInt generation,
  });

  Future<VaultStatus> crateApiVaultStatus({required Vault that});

  Future<void> crateApiVaultUnlock({
    required Vault that,
    required String password,
    required BigInt generation,
  });

  Future<void> crateApiVaultUnlockV3({
    required Vault that,
    required String password,
    required BigInt generation,
  });

  Future<void> crateApiVaultValidateRecoveryV3({
    required Vault that,
    required String phrase,
    required BigInt generation,
  });

  Future<void> crateApiVaultWaitForExportsV2({required Vault that});

  Future<bool> crateApiV3ValidatePasswordV3({required String password});

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
  Future<AccountRecordV1> crateApiVaultAccountV1({
    required Vault that,
    required String id,
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
          sse_encode_String(id, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 1,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_account_record_v_1,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultAccountV1ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultAccountV1ConstMeta => const TaskConstMeta(
    debugName: "Vault_account_v1",
    argNames: ["that", "id", "generation"],
  );

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
            funcId: 2,
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
            funcId: 3,
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
            funcId: 4,
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
  Future<void> crateApiVaultConfirmV3({
    required Vault that,
    required List<String> answers,
    required String password,
    required String passwordHint,
    required String recoveryHint,
    required BigInt revision,
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
          sse_encode_u_64(revision, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 5,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultConfirmV3ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultConfirmV3ConstMeta => const TaskConstMeta(
    debugName: "Vault_confirm_v3",
    argNames: [
      "that",
      "answers",
      "password",
      "passwordHint",
      "recoveryHint",
      "revision",
    ],
  );

  @override
  Future<ContentSnapshotV1> crateApiVaultContentV1({
    required Vault that,
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
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 6,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_content_snapshot_v_1,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultContentV1ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultContentV1ConstMeta => const TaskConstMeta(
    debugName: "Vault_content_v1",
    argNames: ["that", "generation"],
  );

  @override
  Future<ContentSnapshotV1> crateApiVaultDeleteAccountV1({
    required Vault that,
    required String id,
    required BigInt revision,
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
          sse_encode_String(id, serializer);
          sse_encode_u_64(revision, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 7,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_content_snapshot_v_1,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultDeleteAccountV1ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultDeleteAccountV1ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_delete_account_v1",
        argNames: ["that", "id", "revision", "generation"],
      );

  @override
  Future<ContentSnapshotV1> crateApiVaultDeleteGroupV1({
    required Vault that,
    required String id,
    required BigInt revision,
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
          sse_encode_String(id, serializer);
          sse_encode_u_64(revision, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 8,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_content_snapshot_v_1,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultDeleteGroupV1ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultDeleteGroupV1ConstMeta => const TaskConstMeta(
    debugName: "Vault_delete_group_v1",
    argNames: ["that", "id", "revision", "generation"],
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
            funcId: 9,
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
  Future<void> crateApiVaultExportRecoveryV3({
    required Vault that,
    required String destination,
    required BigInt revision,
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
          sse_encode_u_64(revision, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 10,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultExportRecoveryV3ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultExportRecoveryV3ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_export_recovery_v3",
        argNames: ["that", "destination", "revision"],
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
          return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 11)!;
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
            funcId: 12,
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
          return pdeCallFfi(generalizedFrbRustBinding, serializer, funcId: 13)!;
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
            funcId: 14,
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
            funcId: 15,
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
            funcId: 16,
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
  Future<RecoveryChallengeV3> crateApiVaultPrepareCreationV3({
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
            funcId: 17,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_recovery_challenge_v_3,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultPrepareCreationV3ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultPrepareCreationV3ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_prepare_creation_v3",
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
            funcId: 18,
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
            funcId: 19,
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
  Future<RecoveryChallengeV3> crateApiVaultPrepareRecoveryV3({
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
            funcId: 20,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_recovery_challenge_v_3,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultPrepareRecoveryV3ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultPrepareRecoveryV3ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_prepare_recovery_v3",
        argNames: ["that", "phrase", "password", "generation"],
      );

  @override
  Future<RecoveryChallengeV3> crateApiVaultRegenerateRecoveryV3({
    required Vault that,
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
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 21,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_recovery_challenge_v_3,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultRegenerateRecoveryV3ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultRegenerateRecoveryV3ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_regenerate_recovery_v3",
        argNames: ["that", "generation"],
      );

  @override
  Future<ContentSnapshotV1> crateApiVaultSaveAccountV1({
    required Vault that,
    required AccountInputV1 input,
    required BigInt revision,
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
          sse_encode_box_autoadd_account_input_v_1(input, serializer);
          sse_encode_u_64(revision, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 22,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_content_snapshot_v_1,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultSaveAccountV1ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultSaveAccountV1ConstMeta => const TaskConstMeta(
    debugName: "Vault_save_account_v1",
    argNames: ["that", "input", "revision", "generation"],
  );

  @override
  Future<ContentSnapshotV1> crateApiVaultSaveGroupV1({
    required Vault that,
    required GroupInputV1 input,
    required BigInt revision,
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
          sse_encode_box_autoadd_group_input_v_1(input, serializer);
          sse_encode_u_64(revision, serializer);
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 23,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_content_snapshot_v_1,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultSaveGroupV1ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultSaveGroupV1ConstMeta => const TaskConstMeta(
    debugName: "Vault_save_group_v1",
    argNames: ["that", "input", "revision", "generation"],
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
            funcId: 24,
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
            funcId: 25,
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

  @override
  Future<void> crateApiVaultUnlockV3({
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
            funcId: 26,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultUnlockV3ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultUnlockV3ConstMeta => const TaskConstMeta(
    debugName: "Vault_unlock_v3",
    argNames: ["that", "password", "generation"],
  );

  @override
  Future<void> crateApiVaultValidateRecoveryV3({
    required Vault that,
    required String phrase,
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
          sse_encode_u_64(generation, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 27,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultValidateRecoveryV3ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultValidateRecoveryV3ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_validate_recovery_v3",
        argNames: ["that", "phrase", "generation"],
      );

  @override
  Future<void> crateApiVaultWaitForExportsV2({required Vault that}) {
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
            funcId: 28,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_unit,
          decodeErrorData: sse_decode_vault_failure,
        ),
        constMeta: kCrateApiVaultWaitForExportsV2ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiVaultWaitForExportsV2ConstMeta =>
      const TaskConstMeta(
        debugName: "Vault_wait_for_exports_v2",
        argNames: ["that"],
      );

  @override
  Future<bool> crateApiV3ValidatePasswordV3({required String password}) {
    return handler.executeNormal(
      NormalTask(
        callFfi: (port_) {
          final serializer = SseSerializer(generalizedFrbRustBinding);
          sse_encode_String(password, serializer);
          pdeCallFfi(
            generalizedFrbRustBinding,
            serializer,
            funcId: 29,
            port: port_,
          );
        },
        codec: SseCodec(
          decodeSuccessData: sse_decode_bool,
          decodeErrorData: null,
        ),
        constMeta: kCrateApiV3ValidatePasswordV3ConstMeta,
        argValues: const [],
        apiImpl: this,
      ),
    );
  }

  TaskConstMeta get kCrateApiV3ValidatePasswordV3ConstMeta =>
      const TaskConstMeta(
        debugName: "validate_password_v3",
        argNames: ["password"],
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
  AccountInputV1 dco_decode_account_input_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 6)
      throw Exception('unexpected arr length: expect 6 but see ${arr.length}');
    return AccountInputV1(
      id: dco_decode_opt_String(arr[0]),
      name: dco_decode_String(arr[1]),
      description: dco_decode_String(arr[2]),
      login: dco_decode_String(arr[3]),
      password: dco_decode_String(arr[4]),
      groupIds: dco_decode_list_String(arr[5]),
    );
  }

  @protected
  AccountRecordV1 dco_decode_account_record_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 6)
      throw Exception('unexpected arr length: expect 6 but see ${arr.length}');
    return AccountRecordV1(
      id: dco_decode_String(arr[0]),
      name: dco_decode_String(arr[1]),
      description: dco_decode_String(arr[2]),
      login: dco_decode_String(arr[3]),
      password: dco_decode_String(arr[4]),
      groupIds: dco_decode_list_String(arr[5]),
    );
  }

  @protected
  AccountSummaryV1 dco_decode_account_summary_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 3)
      throw Exception('unexpected arr length: expect 3 but see ${arr.length}');
    return AccountSummaryV1(
      id: dco_decode_String(arr[0]),
      name: dco_decode_String(arr[1]),
      groupIds: dco_decode_list_String(arr[2]),
    );
  }

  @protected
  bool dco_decode_bool(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw as bool;
  }

  @protected
  AccountInputV1 dco_decode_box_autoadd_account_input_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_account_input_v_1(raw);
  }

  @protected
  GroupInputV1 dco_decode_box_autoadd_group_input_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return dco_decode_group_input_v_1(raw);
  }

  @protected
  ContentSnapshotV1 dco_decode_content_snapshot_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 3)
      throw Exception('unexpected arr length: expect 3 but see ${arr.length}');
    return ContentSnapshotV1(
      revision: dco_decode_u_64(arr[0]),
      groups: dco_decode_list_group_record_v_1(arr[1]),
      accounts: dco_decode_list_account_summary_v_1(arr[2]),
    );
  }

  @protected
  GroupInputV1 dco_decode_group_input_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 5)
      throw Exception('unexpected arr length: expect 5 but see ${arr.length}');
    return GroupInputV1(
      id: dco_decode_opt_String(arr[0]),
      name: dco_decode_String(arr[1]),
      description: dco_decode_String(arr[2]),
      icon: dco_decode_String(arr[3]),
      logo: dco_decode_list_prim_u_8_strict(arr[4]),
    );
  }

  @protected
  GroupRecordV1 dco_decode_group_record_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 5)
      throw Exception('unexpected arr length: expect 5 but see ${arr.length}');
    return GroupRecordV1(
      id: dco_decode_String(arr[0]),
      name: dco_decode_String(arr[1]),
      description: dco_decode_String(arr[2]),
      icon: dco_decode_String(arr[3]),
      logo: dco_decode_list_prim_u_8_strict(arr[4]),
    );
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
  List<AccountSummaryV1> dco_decode_list_account_summary_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_account_summary_v_1).toList();
  }

  @protected
  List<GroupRecordV1> dco_decode_list_group_record_v_1(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return (raw as List<dynamic>).map(dco_decode_group_record_v_1).toList();
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
  String? dco_decode_opt_String(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    return raw == null ? null : dco_decode_String(raw);
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
  RecoveryChallengeV3 dco_decode_recovery_challenge_v_3(dynamic raw) {
    // Codec=Dco (DartCObject based), see doc to use other codecs
    final arr = raw as List<dynamic>;
    if (arr.length != 5)
      throw Exception('unexpected arr length: expect 5 but see ${arr.length}');
    return RecoveryChallengeV3(
      words: dco_decode_list_String(arr[0]),
      positions: dco_decode_list_prim_u_32_strict(arr[1]),
      choices: dco_decode_list_list_String(arr[2]),
      json: dco_decode_String(arr[3]),
      revision: dco_decode_u_64(arr[4]),
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
  AccountInputV1 sse_decode_account_input_v_1(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_opt_String(deserializer);
    var var_name = sse_decode_String(deserializer);
    var var_description = sse_decode_String(deserializer);
    var var_login = sse_decode_String(deserializer);
    var var_password = sse_decode_String(deserializer);
    var var_groupIds = sse_decode_list_String(deserializer);
    return AccountInputV1(
      id: var_id,
      name: var_name,
      description: var_description,
      login: var_login,
      password: var_password,
      groupIds: var_groupIds,
    );
  }

  @protected
  AccountRecordV1 sse_decode_account_record_v_1(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_String(deserializer);
    var var_name = sse_decode_String(deserializer);
    var var_description = sse_decode_String(deserializer);
    var var_login = sse_decode_String(deserializer);
    var var_password = sse_decode_String(deserializer);
    var var_groupIds = sse_decode_list_String(deserializer);
    return AccountRecordV1(
      id: var_id,
      name: var_name,
      description: var_description,
      login: var_login,
      password: var_password,
      groupIds: var_groupIds,
    );
  }

  @protected
  AccountSummaryV1 sse_decode_account_summary_v_1(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_String(deserializer);
    var var_name = sse_decode_String(deserializer);
    var var_groupIds = sse_decode_list_String(deserializer);
    return AccountSummaryV1(id: var_id, name: var_name, groupIds: var_groupIds);
  }

  @protected
  bool sse_decode_bool(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return deserializer.buffer.getUint8() != 0;
  }

  @protected
  AccountInputV1 sse_decode_box_autoadd_account_input_v_1(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_account_input_v_1(deserializer));
  }

  @protected
  GroupInputV1 sse_decode_box_autoadd_group_input_v_1(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    return (sse_decode_group_input_v_1(deserializer));
  }

  @protected
  ContentSnapshotV1 sse_decode_content_snapshot_v_1(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_revision = sse_decode_u_64(deserializer);
    var var_groups = sse_decode_list_group_record_v_1(deserializer);
    var var_accounts = sse_decode_list_account_summary_v_1(deserializer);
    return ContentSnapshotV1(
      revision: var_revision,
      groups: var_groups,
      accounts: var_accounts,
    );
  }

  @protected
  GroupInputV1 sse_decode_group_input_v_1(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_opt_String(deserializer);
    var var_name = sse_decode_String(deserializer);
    var var_description = sse_decode_String(deserializer);
    var var_icon = sse_decode_String(deserializer);
    var var_logo = sse_decode_list_prim_u_8_strict(deserializer);
    return GroupInputV1(
      id: var_id,
      name: var_name,
      description: var_description,
      icon: var_icon,
      logo: var_logo,
    );
  }

  @protected
  GroupRecordV1 sse_decode_group_record_v_1(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_id = sse_decode_String(deserializer);
    var var_name = sse_decode_String(deserializer);
    var var_description = sse_decode_String(deserializer);
    var var_icon = sse_decode_String(deserializer);
    var var_logo = sse_decode_list_prim_u_8_strict(deserializer);
    return GroupRecordV1(
      id: var_id,
      name: var_name,
      description: var_description,
      icon: var_icon,
      logo: var_logo,
    );
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
  List<AccountSummaryV1> sse_decode_list_account_summary_v_1(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <AccountSummaryV1>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_account_summary_v_1(deserializer));
    }
    return ans_;
  }

  @protected
  List<GroupRecordV1> sse_decode_list_group_record_v_1(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    var len_ = sse_decode_i_32(deserializer);
    var ans_ = <GroupRecordV1>[];
    for (var idx_ = 0; idx_ < len_; ++idx_) {
      ans_.add(sse_decode_group_record_v_1(deserializer));
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
  String? sse_decode_opt_String(SseDeserializer deserializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    if (sse_decode_bool(deserializer)) {
      return (sse_decode_String(deserializer));
    } else {
      return null;
    }
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
  RecoveryChallengeV3 sse_decode_recovery_challenge_v_3(
    SseDeserializer deserializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    var var_words = sse_decode_list_String(deserializer);
    var var_positions = sse_decode_list_prim_u_32_strict(deserializer);
    var var_choices = sse_decode_list_list_String(deserializer);
    var var_json = sse_decode_String(deserializer);
    var var_revision = sse_decode_u_64(deserializer);
    return RecoveryChallengeV3(
      words: var_words,
      positions: var_positions,
      choices: var_choices,
      json: var_json,
      revision: var_revision,
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
  void sse_encode_account_input_v_1(
    AccountInputV1 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_opt_String(self.id, serializer);
    sse_encode_String(self.name, serializer);
    sse_encode_String(self.description, serializer);
    sse_encode_String(self.login, serializer);
    sse_encode_String(self.password, serializer);
    sse_encode_list_String(self.groupIds, serializer);
  }

  @protected
  void sse_encode_account_record_v_1(
    AccountRecordV1 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.id, serializer);
    sse_encode_String(self.name, serializer);
    sse_encode_String(self.description, serializer);
    sse_encode_String(self.login, serializer);
    sse_encode_String(self.password, serializer);
    sse_encode_list_String(self.groupIds, serializer);
  }

  @protected
  void sse_encode_account_summary_v_1(
    AccountSummaryV1 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.id, serializer);
    sse_encode_String(self.name, serializer);
    sse_encode_list_String(self.groupIds, serializer);
  }

  @protected
  void sse_encode_bool(bool self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    serializer.buffer.putUint8(self ? 1 : 0);
  }

  @protected
  void sse_encode_box_autoadd_account_input_v_1(
    AccountInputV1 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_account_input_v_1(self, serializer);
  }

  @protected
  void sse_encode_box_autoadd_group_input_v_1(
    GroupInputV1 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_group_input_v_1(self, serializer);
  }

  @protected
  void sse_encode_content_snapshot_v_1(
    ContentSnapshotV1 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_u_64(self.revision, serializer);
    sse_encode_list_group_record_v_1(self.groups, serializer);
    sse_encode_list_account_summary_v_1(self.accounts, serializer);
  }

  @protected
  void sse_encode_group_input_v_1(GroupInputV1 self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_opt_String(self.id, serializer);
    sse_encode_String(self.name, serializer);
    sse_encode_String(self.description, serializer);
    sse_encode_String(self.icon, serializer);
    sse_encode_list_prim_u_8_strict(self.logo, serializer);
  }

  @protected
  void sse_encode_group_record_v_1(
    GroupRecordV1 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_String(self.id, serializer);
    sse_encode_String(self.name, serializer);
    sse_encode_String(self.description, serializer);
    sse_encode_String(self.icon, serializer);
    sse_encode_list_prim_u_8_strict(self.logo, serializer);
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
  void sse_encode_list_account_summary_v_1(
    List<AccountSummaryV1> self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_account_summary_v_1(item, serializer);
    }
  }

  @protected
  void sse_encode_list_group_record_v_1(
    List<GroupRecordV1> self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_i_32(self.length, serializer);
    for (final item in self) {
      sse_encode_group_record_v_1(item, serializer);
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
  void sse_encode_opt_String(String? self, SseSerializer serializer) {
    // Codec=Sse (Serialization based), see doc to use other codecs

    sse_encode_bool(self != null, serializer);
    if (self != null) {
      sse_encode_String(self, serializer);
    }
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
  void sse_encode_recovery_challenge_v_3(
    RecoveryChallengeV3 self,
    SseSerializer serializer,
  ) {
    // Codec=Sse (Serialization based), see doc to use other codecs
    sse_encode_list_String(self.words, serializer);
    sse_encode_list_prim_u_32_strict(self.positions, serializer);
    sse_encode_list_list_String(self.choices, serializer);
    sse_encode_String(self.json, serializer);
    sse_encode_u_64(self.revision, serializer);
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

  Future<AccountRecordV1> accountV1({
    required String id,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultAccountV1(
    that: this,
    id: id,
    generation: generation,
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

  Future<void> confirmV3({
    required List<String> answers,
    required String password,
    required String passwordHint,
    required String recoveryHint,
    required BigInt revision,
  }) => VaultRustLib.instance.api.crateApiVaultConfirmV3(
    that: this,
    answers: answers,
    password: password,
    passwordHint: passwordHint,
    recoveryHint: recoveryHint,
    revision: revision,
  );

  Future<ContentSnapshotV1> contentV1({required BigInt generation}) =>
      VaultRustLib.instance.api.crateApiVaultContentV1(
        that: this,
        generation: generation,
      );

  Future<ContentSnapshotV1> deleteAccountV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultDeleteAccountV1(
    that: this,
    id: id,
    revision: revision,
    generation: generation,
  );

  Future<ContentSnapshotV1> deleteGroupV1({
    required String id,
    required BigInt revision,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultDeleteGroupV1(
    that: this,
    id: id,
    revision: revision,
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

  Future<void> exportRecoveryV3({
    required String destination,
    required BigInt revision,
  }) => VaultRustLib.instance.api.crateApiVaultExportRecoveryV3(
    that: this,
    destination: destination,
    revision: revision,
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

  Future<RecoveryChallengeV3> prepareCreationV3({
    required String password,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultPrepareCreationV3(
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

  Future<RecoveryChallengeV3> prepareRecoveryV3({
    required String phrase,
    required String password,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultPrepareRecoveryV3(
    that: this,
    phrase: phrase,
    password: password,
    generation: generation,
  );

  Future<RecoveryChallengeV3> regenerateRecoveryV3({
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultRegenerateRecoveryV3(
    that: this,
    generation: generation,
  );

  Future<ContentSnapshotV1> saveAccountV1({
    required AccountInputV1 input,
    required BigInt revision,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultSaveAccountV1(
    that: this,
    input: input,
    revision: revision,
    generation: generation,
  );

  Future<ContentSnapshotV1> saveGroupV1({
    required GroupInputV1 input,
    required BigInt revision,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultSaveGroupV1(
    that: this,
    input: input,
    revision: revision,
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

  Future<void> unlockV3({
    required String password,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultUnlockV3(
    that: this,
    password: password,
    generation: generation,
  );

  Future<void> validateRecoveryV3({
    required String phrase,
    required BigInt generation,
  }) => VaultRustLib.instance.api.crateApiVaultValidateRecoveryV3(
    that: this,
    phrase: phrase,
    generation: generation,
  );

  Future<void> waitForExportsV2() =>
      VaultRustLib.instance.api.crateApiVaultWaitForExportsV2(that: this);
}

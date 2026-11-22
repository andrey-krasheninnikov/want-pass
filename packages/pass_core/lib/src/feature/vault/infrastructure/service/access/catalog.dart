part of 'service_impl.dart';

extension _CatalogNative on RustVaultAccessService {
  FutureDomainResult<T> _catalogResult<T>(
    String operation,
    VaultHandleV1 handle,
    Future<T> Function(native.Vault vault, BigInt generation) call,
  ) async {
    final result = await captureResult<T>(() async {
      final vault = (handle as _NativeVaultHandle)._vault;
      return await call(vault, vault.generation());
    }, mapToDomainError: _mapNativeError);
    if (result.isError) {
      reportVaultSafely(
        _reporter,
        layer: VaultDiagnosticLayer.infrastructure,
        operation: 'RustVaultAccessService.$operation():',
        error: result.error is VaultErrorV1
            ? result.error as VaultErrorV1
            : const VaultUnexpectedErrorV1(),
      );
    }
    return result;
  }

  Future<List<ResourceBindingV1>> _bindingsV1(
    native.Vault v,
    BigInt g,
    BigInt r,
    String id,
  ) async => List.unmodifiable(
    (await v.bindingsV1(id: id, revision: r, generation: g)).map(_binding),
  );
  Future<List<CustomValueViewV1>> _customValuesV1(
    native.Vault v,
    BigInt g,
    BigInt r,
    String id,
  ) async {
    await _confirmOperation(v, native.OperationV1.reveal, id, g);
    return List.unmodifiable(
      (await v.customCardValuesV1(
        id: id,
        revision: r,
        generation: g,
      )).map(_customView),
    );
  }

  Future<List<HistorySummaryV1>> _historyV1(
    native.Vault v,
    BigInt g,
    BigInt r,
    String? cardId,
  ) async => List.unmodifiable(
    (await v.historyV1(cardId: cardId, revision: r, generation: g)).map(
      (h) => HistorySummaryV1(
        id: h.id,
        at: DateTime.fromMillisecondsSinceEpoch(
          h.at.toInt() * 1000,
          isUtc: true,
        ),
        cardId: h.cardId,
        name: h.name,
        service: h.service,
      ),
    ),
  );
  Future<HistoricalCardV1> _historicalCardV1(
    native.Vault v,
    BigInt g,
    BigInt r,
    String id,
  ) async {
    await _confirmOperation(v, native.OperationV1.reveal, 'history:$id', g);
    final h = await v.historicalCardV1(id: id, revision: r, generation: g);
    return HistoricalCardV1(
      summary: _cardSummary(h.summary),
      description: h.description,
      fields: h.fields
          .map((f) => CardValueV1(id: _fieldId(f.id), value: f.value))
          .toList(),
      customValues: h.customValues.map(_customView).toList(),
      bindings: h.bindings.map(_binding).toList(),
      attachment: _catalogAttachment(h.attachment),
    );
  }

  Future<ContentSnapshotV2> _catalogEditV1(
    native.Vault v,
    BigInt g,
    BigInt r,
    CatalogEditV1 edit,
  ) async {
    final native.ContentSnapshotV2 result;
    switch (edit) {
      case SaveServiceV1(:final service):
        result = await v.saveServiceV1(
          service: native.ServiceDefinitionV1(
            id: service.id,
            name: service.name,
            description: service.description,
            icon: service.icon,
            logo: Uint8List.fromList(service.logo),
            archived: service.archived,
          ),
          revision: r,
          generation: g,
        );
      case RemoveServiceV1(:final id, :final replacement, :final preserve):
        await _confirmOperation(v, native.OperationV1.delete, 'service:$id', g);
        result = await v.removeServiceV1(
          id: id,
          replacement: replacement,
          preserve: preserve,
          revision: r,
          generation: g,
        );
      case SaveTemplateV1(:final id, :final name, :final fields):
        result = await v.saveTemplateV1(
          id: id,
          name: name,
          fields: fields.map(_nativeTemplateField).toList(),
          revision: r,
          generation: g,
        );
      case SaveBindingsV1(:final cardId, :final bindings):
        result = await v.saveBindingsV1(
          id: cardId,
          bindings: bindings.map(_nativeBinding).toList(),
          revision: r,
          generation: g,
        );
      case SaveCustomCardV1(
        :final card,
        :final templateId,
        :final templateVersion,
        :final acceptUpdate,
        :final values,
      ):
        result = await v.saveCustomCardV1(
          input: native.CustomCardInputV1(
            id: card.id,
            name: card.name,
            description: card.description,
            service: card.service,
            environment: card.environment == null
                ? null
                : _nativeEnvironment(card.environment!),
            groupIds: card.groupIds,
            templateId: templateId,
            templateVersion: templateVersion,
            acceptTemplateUpdate: acceptUpdate,
            values: values
                .map(
                  (f) => native.CustomValueInputV1(
                    fieldId: f.fieldId,
                    value: f.value,
                    file: f.file == null
                        ? null
                        : native.AttachmentInputV1(
                            name: f.file!.name,
                            bytes: Uint8List.fromList(f.file!.bytes),
                          ),
                    keepFile: f.keepFile,
                  ),
                )
                .toList(),
          ),
          revision: r,
          generation: g,
        );
      case RestoreHistoryV1(:final id):
        await _confirmOperation(
          v,
          native.OperationV1.protection,
          'history:$id',
          g,
        );
        result = await v.restoreHistoryV1(id: id, revision: r, generation: g);
      case ClearHistoryV1(:final cardId, :final confirmed):
        await _confirmOperation(
          v,
          native.OperationV1.delete,
          cardId == null ? 'history' : 'history:$cardId',
          g,
        );
        result = await v.clearHistoryV1(
          cardId: cardId,
          confirmed: confirmed,
          revision: r,
          generation: g,
        );
    }
    return _cards(result);
  }
}

ServiceDefinitionV1 _serviceDefinition(native.ServiceDefinitionV1 s) =>
    ServiceDefinitionV1(
      id: s.id,
      name: s.name,
      description: s.description,
      icon: s.icon,
      logo: s.logo,
      archived: s.archived,
    );
TemplateDefinitionV1 _templateDefinition(native.TemplateDefinitionV1 t) =>
    TemplateDefinitionV1(
      id: t.id,
      versions: t.versions
          .map(
            (v) => TemplateVersionV1(
              number: v.number,
              name: v.name,
              fields: v.fields
                  .map(
                    (f) => TemplateFieldV1(
                      id: f.id,
                      label: f.label,
                      kind: CustomFieldKindV1.values.byName(f.kind.name),
                      required: f.required_,
                    ),
                  )
                  .toList(),
            ),
          )
          .toList(),
    );
ResourceBindingV1 _binding(native.ResourceBindingV1 b) => ResourceBindingV1(
  id: b.id,
  kind: ResourceKindV1.values.byName(b.kind.name),
  target: b.target,
  method: BindingMethodV1.values.byName(b.method.name),
  fields: b.fields,
);
AttachmentV1? _catalogAttachment(native.AttachmentSummaryV1? f) =>
    f == null ? null : AttachmentV1(name: f.name, size: f.size);
CustomValueViewV1 _customView(native.CustomValueViewV1 v) => CustomValueViewV1(
  fieldId: v.fieldId,
  value: v.value,
  file: _catalogAttachment(v.file),
);
native.ResourceBindingV1 _nativeBinding(ResourceBindingV1 b) =>
    native.ResourceBindingV1(
      id: b.id,
      kind: native.ResourceKindV1.values.byName(b.kind.name),
      target: b.target,
      method: native.BindingMethodV1.values.byName(b.method.name),
      fields: b.fields,
    );
native.TemplateFieldV1 _nativeTemplateField(TemplateFieldV1 f) =>
    native.TemplateFieldV1(
      id: f.id,
      label: f.label,
      kind: native.CustomFieldKindV1.values.byName(f.kind.name),
      required_: f.required,
    );

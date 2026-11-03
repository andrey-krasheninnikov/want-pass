abstract interface class VaultHandleV1 {
  const VaultHandleV1();
  void invalidateSync();
  Future<void> close();
}

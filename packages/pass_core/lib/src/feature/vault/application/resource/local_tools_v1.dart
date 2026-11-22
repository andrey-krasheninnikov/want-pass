import 'package:domain_error/domain_error.dart';

enum LocalToolCommandV1 {
  dashboard,
  configure,
  disconnect,
  grant,
  revoke,
  request,
  publicKey,
  agentIdentity,
  agentSign,
}

abstract interface class VaultLocalToolsSessionV1 {
  FutureDomainResult<String> localTool(
    LocalToolCommandV1 command,
    String body, {
    Future<bool> Function()? admitted,
  });
}

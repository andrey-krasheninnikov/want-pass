import 'package:want_pass_core/src/feature/vault/domain/_barrel.dart';

enum CardTypeV1 {
  account,
  pat,
  rsa,
  ed25519,
  secretKey,
  passphrase,
  recoveryCodes,
  recoveryUrl,
  secretQa,
  vless,
  wireGuard,
  gpg,
  certificate,
  oauth,
  dsn,
  kubeconfig,
  webhookSecret,
  secureNote,
  file;

  Set<FieldIdV1> get requiredFields => switch (this) {
    account => const {FieldIdV1.login, FieldIdV1.password},
    rsa || ed25519 || gpg => const {FieldIdV1.publicKey, FieldIdV1.privateKey},
    certificate => const {FieldIdV1.certificate, FieldIdV1.privateKey},
    oauth => const {FieldIdV1.clientId, FieldIdV1.clientSecret},
    secretQa => const {FieldIdV1.question, FieldIdV1.answer},
    recoveryCodes => const {FieldIdV1.recoveryCodes},
    file => const {},
    _ => const {FieldIdV1.value},
  };
  Set<FieldIdV1> get optionalFields => switch (this) {
    account => const {
      FieldIdV1.totpSeed,
      FieldIdV1.totpAlgorithm,
      FieldIdV1.totpDigits,
      FieldIdV1.totpPeriod,
      FieldIdV1.recoveryCodes,
      FieldIdV1.reserveLogins,
    },
    oauth => const {FieldIdV1.accessToken, FieldIdV1.refreshToken},
    _ => const {},
  };
}

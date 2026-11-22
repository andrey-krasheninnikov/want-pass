part of 'content.dart';

const _services = <String, (String, bool)>{
  'google': ('Google', true),
  'apple': ('Apple', true),
  'microsoft': ('Microsoft', false),
  'github': ('GitHub', true),
  'gitlab': ('GitLab', true),
  'telegram': ('Telegram', true),
  'aws': ('AWS', false),
  'azure': ('Microsoft Azure', false),
  'gcp': ('Google Cloud', true),
  'cloudflare': ('Cloudflare', true),
  'atlassian': ('Atlassian', true),
  'jira': ('Jira', true),
  'confluence': ('Confluence', true),
  'slack': ('Slack', false),
  'discord': ('Discord', true),
  'notion': ('Notion', true),
  'docker': ('Docker Hub', true),
  'ghcr': ('GitHub Container Registry', false),
  'npm': ('npm', true),
  'pypi': ('PyPI', true),
  'crates-io': ('crates.io', false),
  'firebase': ('Firebase', true),
  'supabase': ('Supabase', true),
  'sentry': ('Sentry', true),
  'vercel': ('Vercel', true),
  'digitalocean': ('DigitalOcean', true),
  'hetzner-cloud': ('Hetzner Cloud', false),
  'ovhcloud': ('OVHcloud', false),
  'oracle-cloud-infrastructure': ('Oracle Cloud Infrastructure', false),
  'akamai-cloud': ('Akamai Cloud (Linode)', false),
  'netlify': ('Netlify', false),
  'render': ('Render', false),
  'railway': ('Railway', false),
  'fly-io': ('Fly.io', false),
  'heroku': ('Heroku', false),
  'bitbucket': ('Bitbucket', false),
  'azure-devops': ('Azure DevOps', false),
  'gitea': ('Gitea', true),
  'circleci': ('CircleCI', false),
  'jenkins': ('Jenkins', false),
  'teamcity': ('TeamCity', false),
  'jetbrains-account': ('JetBrains Account', false),
  'jfrog-artifactory': ('JFrog Artifactory', false),
  'sonatype-nexus-repository': ('Sonatype Nexus Repository', false),
  'hashicorp-vault': ('HashiCorp Vault', false),
  'hcp-terraform': ('HCP Terraform', false),
  'tailscale': ('Tailscale', false),
  'auth0': ('Auth0', false),
  'okta': ('Okta', false),
  'keycloak': ('Keycloak', false),
  '1password': ('1Password', false),
  'bitwarden': ('Bitwarden', true),
  'proton': ('Proton', false),
  'yandex-id': ('Яндекс ID', false),
  'vk-id': ('VK ID', false),
  'dropbox': ('Dropbox', false),
  'nextcloud': ('Nextcloud', true),
  'figma': ('Figma', true),
  'linear': ('Linear', false),
  'zoom': ('Zoom', false),
  'miro': ('Miro', false),
  'amazon': ('Amazon', false),
  'instagram': ('Instagram', false),
  'facebook': ('Facebook', false),
  'reddit': ('Reddit', false),
  'linkedin': ('LinkedIn', false),
  'steam': ('Steam', false),
  'spotify': ('Spotify', false),
  'netflix': ('Netflix', false),
  'app-store-connect': ('App Store Connect', false),
  'google-play-console': ('Google Play Console', false),
  'stripe': ('Stripe', true),
  'paypal': ('PayPal', true),
  'paddle': ('Paddle', false),
  'shopify': ('Shopify', false),
  'twilio': ('Twilio', false),
  'sendgrid': ('SendGrid', false),
  'mailgun': ('Mailgun', false),
  'postmark': ('Postmark', false),
  'resend': ('Resend', false),
  'mailchimp': ('Mailchimp', false),
  'grafana-cloud': ('Grafana Cloud', false),
  'datadog': ('Datadog', false),
  'new-relic': ('New Relic', false),
  'better-stack': ('Better Stack', false),
  'elastic-cloud': ('Elastic Cloud', false),
  'mongodb-atlas': ('MongoDB Atlas', false),
  'neon': ('Neon', false),
  'planetscale': ('PlanetScale', false),
  'upstash': ('Upstash', false),
  'redis-cloud': ('Redis Cloud', false),
  'snowflake': ('Snowflake', false),
  'databricks': ('Databricks', false),
  'backblaze-b2': ('Backblaze B2', false),
  'wasabi': ('Wasabi', false),
  'minio': ('MinIO', false),
  'openai-api': ('OpenAI API', false),
  'anthropic-api': ('Anthropic API', false),
  'hugging-face': ('Hugging Face', false),
  'cloudinary': ('Cloudinary', true),
};

const _types = <CardTypeV1, (String, String, IconData)>{
  CardTypeV1.account: ('Account', 'Учётная запись', Icons.person_outline),
  CardTypeV1.apiKey: ('API key', 'API-ключ', Icons.vpn_key_outlined),
  CardTypeV1.pat: ('PAT', 'PAT', Icons.key),
  CardTypeV1.totp: ('TOTP', 'TOTP', Icons.timer_outlined),
  CardTypeV1.recoveryCodes: (
    'Recovery codes',
    'Коды восстановления',
    Icons.format_list_numbered,
  ),
  CardTypeV1.secureNote: ('Secure note', 'Защищённая заметка', Icons.notes),
  CardTypeV1.ed25519: ('SSH Ed25519 key', 'Ключ SSH Ed25519', Icons.terminal),
  CardTypeV1.rsa: ('SSH RSA key', 'Ключ SSH RSA', Icons.terminal),
  CardTypeV1.oauth: ('OAuth 2.0', 'OAuth 2.0', Icons.sync_alt),
  CardTypeV1.certificate: (
    'Certificate and private key',
    'Сертификат и закрытый ключ',
    Icons.verified_outlined,
  ),
  CardTypeV1.dsn: (
    'Connection string (DSN)',
    'Строка подключения DSN',
    Icons.storage,
  ),
  CardTypeV1.secretKey: (
    'Symmetric key',
    'Симметричный ключ',
    Icons.key_outlined,
  ),
  CardTypeV1.webhookSecret: (
    'Webhook signing secret',
    'Секрет подписи webhook',
    Icons.webhook,
  ),
  CardTypeV1.passphrase: ('Passphrase', 'Парольная фраза', Icons.text_fields),
  CardTypeV1.file: (
    'Secure file',
    'Защищённый файл',
    Icons.insert_drive_file_outlined,
  ),
  CardTypeV1.recoveryUrl: (
    'Recovery link',
    'Ссылка восстановления',
    Icons.restart_alt,
  ),
  CardTypeV1.secretQa: (
    'Secret question and answer',
    'Секретный вопрос и ответ',
    Icons.help_outline,
  ),
  CardTypeV1.awsIam: (
    'AWS IAM access key',
    'Ключ доступа AWS IAM',
    Icons.cloud_outlined,
  ),
  CardTypeV1.googleCloudKey: (
    'Google Cloud service account key',
    'Ключ сервисной учётной записи Google Cloud',
    Icons.cloud_queue,
  ),
  CardTypeV1.azureAppSecret: (
    'Azure application secret',
    'Секрет сервисного приложения Azure',
    Icons.cloud_circle_outlined,
  ),
  CardTypeV1.bearerToken: (
    'Bearer token',
    'Bearer-токен',
    Icons.badge_outlined,
  ),
  CardTypeV1.appPassword: ('App password', 'Пароль приложения', Icons.password),
  CardTypeV1.sshCertificate: (
    'SSH certificate',
    'SSH-сертификат',
    Icons.terminal,
  ),
  CardTypeV1.kubeconfig: ('Kubeconfig', 'Kubeconfig', Icons.settings_ethernet),
  CardTypeV1.kubernetesToken: (
    'Kubernetes service account token',
    'Токен сервисной учётной записи Kubernetes',
    Icons.hub_outlined,
  ),
  CardTypeV1.wireGuard: (
    'WireGuard configuration',
    'Конфигурация WireGuard',
    Icons.vpn_lock_outlined,
  ),
  CardTypeV1.openVpn: (
    'OpenVPN profile',
    'Профиль OpenVPN',
    Icons.shield_outlined,
  ),
  CardTypeV1.ipsec: (
    'IPsec / IKEv2 profile',
    'Профиль IPsec / IKEv2',
    Icons.security,
  ),
  CardTypeV1.vless: ('VLESS URL', 'Ссылка VLESS', Icons.alt_route),
  CardTypeV1.gpg: (
    'GPG key pair',
    'Ключи GPG',
    Icons.enhanced_encryption_outlined,
  ),
  CardTypeV1.keyContainer: (
    'Key container',
    'Контейнер ключей',
    Icons.inventory_2_outlined,
  ),
  CardTypeV1.artifactSigningKey: (
    'Artifact signing key',
    'Ключ подписи артефактов',
    Icons.draw_outlined,
  ),
  CardTypeV1.apnsKey: ('APNs key', 'Ключ APNs', Icons.notifications_none),
  CardTypeV1.appStoreConnectKey: (
    'App Store Connect API key',
    'Ключ API App Store Connect',
    Icons.storefront,
  ),
  CardTypeV1.registryAccess: (
    'Container registry access',
    'Доступ к реестру образов',
    Icons.dns_outlined,
  ),
  CardTypeV1.environmentVariables: (
    'Environment variables',
    'Набор переменных окружения',
    Icons.data_object,
  ),
  CardTypeV1.smtpAccess: ('SMTP access', 'Доступ SMTP', Icons.mail_outline),
  CardTypeV1.presignedUrl: (
    'Presigned URL',
    'Предподписанная ссылка',
    Icons.link,
  ),
  CardTypeV1.sessionCookie: (
    'Session cookie',
    'Cookie сессии',
    Icons.cookie_outlined,
  ),
  CardTypeV1.hotp: ('HOTP', 'HOTP', Icons.pin_outlined),
  CardTypeV1.licenseKey: (
    'License key',
    'Лицензионный ключ',
    Icons.workspace_premium_outlined,
  ),
  CardTypeV1.wifi: ('Wi-Fi password', 'Пароль Wi-Fi', Icons.wifi_password),
  CardTypeV1.devicePin: ('Device PIN', 'PIN устройства', Icons.devices),
  CardTypeV1.simPinPuk: (
    'SIM PIN / PUK',
    'SIM PIN / PUK',
    Icons.sim_card_outlined,
  ),
  CardTypeV1.paymentCard: (
    'Payment card',
    'Платёжная карта',
    Icons.credit_card,
  ),
  CardTypeV1.bankDetails: (
    'Bank details',
    'Банковские реквизиты',
    Icons.account_balance_outlined,
  ),
  CardTypeV1.identityDocument: (
    'Identity document',
    'Документ',
    Icons.assignment_ind_outlined,
  ),
  CardTypeV1.walletMnemonic: (
    'Wallet mnemonic',
    'Мнемоническая фраза кошелька',
    Icons.wallet_outlined,
  ),
  CardTypeV1.walletPrivateKey: (
    'Wallet private key',
    'Приватный ключ кошелька',
    Icons.key_outlined,
  ),
};

String _serviceLabel(BuildContext context, String id) =>
    id == 'other' ? _text(context, 'Other', 'Другое') : _services[id]?.$1 ?? id;

String _typeLabel(BuildContext context, CardTypeV1 type) {
  final (en, ru, _) = _types[type]!;
  return _text(context, en, ru);
}

Icon _typeIcon(CardTypeV1 type, {double size = 20}) =>
    Icon(_types[type]!.$3, size: size);

String _serviceAliases(String id) => switch (id) {
  'gcp' => 'Google Cloud Platform',
  'azure' => 'Azure',
  'docker' => 'Docker',
  'ghcr' => 'GHCR',
  'yandex-id' => 'Yandex',
  'openai-api' => 'OpenAI',
  'anthropic-api' => 'Anthropic',
  _ => '',
};

Widget _serviceIcon(BuildContext context, String service) {
  if (service == 'other') return const Icon(Icons.apps_outlined, size: 20);
  final (label, asset) = _services[service] ?? (service, false);
  final foreground = WantTheme.of(context).color('muted-foreground');
  if (asset) {
    return SvgPicture.asset(
      'assets/services/$service.svg',
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
      excludeFromSemantics: true,
    );
  }
  final words = label.split(RegExp(r'[ .-]+')).where((word) => word.isNotEmpty);
  final monogram = words.length == 1
      ? label.substring(0, label.length.clamp(0, 2))
      : words.take(3).map((word) => word[0]).join();
  return ExcludeSemantics(
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: WantTheme.of(context).color('muted'),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SizedBox(
        width: 24,
        height: 20,
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              monogram.toUpperCase(),
              maxLines: 1,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _catalogLabel(Widget icon, String label) => Row(
  mainAxisSize: MainAxisSize.min,
  spacing: 8,
  children: [
    ExcludeSemantics(child: icon),
    Flexible(child: Text(label)),
  ],
);

Iterable<CardTypeV1> _catalogTypes(CardCatalogV1 catalog) {
  final available = catalog.presets.map((preset) => preset.cardType).toSet();
  return _types.keys.where(available.contains);
}

final class _CatalogSelect<T> extends StatelessWidget {
  final T? value;
  final String label;
  final String? hint;
  final Iterable<T> values;
  final String Function(T value) itemLabel;
  final String Function(T value) searchTerms;
  final Widget Function(T value) itemIcon;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const _CatalogSelect({
    super.key,
    required this.value,
    required this.label,
    this.hint,
    required this.values,
    required this.itemLabel,
    required this.searchTerms,
    required this.itemIcon,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) => FSelect<T>.searchBuilder(
    format: itemLabel,
    searchFieldProperties: FSelectSearchFieldProperties(
      hint: _text(context, 'Search catalog', 'Поиск в каталоге'),
      autofocus: true,
      autocorrect: false,
      enableSuggestions: false,
      enableIMEPersonalizedLearning: false,
    ),
    filter: (query) {
      final needle = query.trim().toLowerCase();
      return values.where(
        (value) =>
            itemLabel(value).toLowerCase().contains(needle) ||
            searchTerms(value).toLowerCase().contains(needle),
      );
    },
    contentBuilder: (context, style, results) => [
      for (final value in results)
        FSelectItem<T>(
          title: Text(itemLabel(value)),
          prefix: ExcludeSemantics(child: itemIcon(value)),
          value: value,
        ),
    ],
    control: FSelectControl.lifted(value: value, onChange: onChanged),
    prefixBuilder: value == null ? null : (_, _, _) => itemIcon(value as T),
    label: Text(label),
    hint: hint,
    enabled: enabled,
  );
}

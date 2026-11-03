.PHONY: bootstrap generate check format format-check run server build-macos native-ui

bootstrap:
	fvm flutter pub get --enforce-lockfile

generate:
	cd packages/pass_core && python3 tool/generate_bridge.py
	cargo fmt --manifest-path packages/pass_core/rust/Cargo.toml
	cd apps/want_pass && fvm dart run build_runner build

format:
	fvm dart format apps/want_pass/lib apps/want_pass/test apps/want_pass/integration_test apps/want_pass/tool packages/pass_core
	cargo fmt --manifest-path server/Cargo.toml
	cargo fmt --manifest-path packages/pass_core/rust/Cargo.toml

format-check:
	fvm dart format --output=none --set-exit-if-changed apps/want_pass/lib apps/want_pass/test apps/want_pass/integration_test apps/want_pass/tool packages/pass_core
	cargo fmt --manifest-path server/Cargo.toml -- --check
	cargo fmt --manifest-path packages/pass_core/rust/Cargo.toml -- --check

check: format-check
	fvm flutter analyze --no-pub
	cd packages/pass_core && fvm dart test
	cd apps/want_pass && fvm flutter test --no-pub
	cargo clippy --manifest-path packages/pass_core/rust/Cargo.toml --all-targets --locked -- -D warnings
	cargo test --manifest-path packages/pass_core/rust/Cargo.toml --locked
	cargo clippy --manifest-path server/Cargo.toml --all-targets --locked -- -D warnings
	cargo test --manifest-path server/Cargo.toml --locked

run:
	cd apps/want_pass && fvm flutter run -d macos

server:
	cargo run --manifest-path server/Cargo.toml --locked

build-macos:
	cd apps/want_pass && fvm flutter build macos --debug --no-pub

VAULT_UI_RUN := local_$(shell date +%Y%m%d_%H%M%S)
native-ui:
	cd apps/want_pass && fvm flutter test integration_test/vault_flow_test.dart -d macos --no-pub --dart-define=VAULT_TEST_RUN=$(VAULT_UI_RUN) --dart-define=VAULT_TEST_PHASE=create
	cd apps/want_pass && fvm flutter test integration_test/vault_flow_test.dart -d macos --no-pub --dart-define=VAULT_TEST_RUN=$(VAULT_UI_RUN) --dart-define=VAULT_TEST_PHASE=reopen

.PHONY: bootstrap check format format-check run server build-macos

bootstrap:
	fvm flutter pub get --enforce-lockfile

format:
	fvm dart format apps/want_pass/lib apps/want_pass/test packages/pass_core
	cargo fmt --manifest-path server/Cargo.toml

format-check:
	fvm dart format --output=none --set-exit-if-changed apps/want_pass/lib apps/want_pass/test packages/pass_core
	cargo fmt --manifest-path server/Cargo.toml -- --check

check: format-check
	fvm flutter analyze --no-pub
	cd packages/pass_core && fvm dart test
	cd apps/want_pass && fvm flutter test --no-pub
	cargo clippy --manifest-path server/Cargo.toml --all-targets --locked -- -D warnings
	cargo test --manifest-path server/Cargo.toml --locked

run:
	cd apps/want_pass && fvm flutter run -d macos

server:
	cargo run --manifest-path server/Cargo.toml --locked

build-macos:
	cd apps/want_pass && fvm flutter build macos --debug --no-pub

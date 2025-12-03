# Repository Guidelines

This guide keeps contributions to the ChopChop Eats Flutter app consistent and predictable.

## Project Structure & Module Organization
The entry point (`lib/main.dart`) wires the layered architecture under `lib/src`. `core/` holds configuration, constants, routing, localization, and shared widgets; `data/` encapsulates Hive/local caches and remote Dio clients behind repositories; `features/` contains user-facing flows (auth, home, order, etc.) with `presentation/pages`, `providers`, and `widgets`. Shared assets live in `assets/images/`, while platform scaffolding stays in `android/` and `ios/`. Tests belong in `test/` and should mirror the `lib/` module they exercise.

## Build, Test & Development Commands
- `flutter pub get` — install dependencies after cloning or editing `pubspec.yaml`.
- `flutter run -d <device>` — launch the app locally; match the device flag (`ios`, `android`, `chrome`) to the target.
- `flutter build apk --release` (or `flutter build ios`) — produce store-ready binaries.
- `flutter pub run build_runner build --delete-conflicting-outputs` — regenerate Hive adapters or other codegen artifacts before committing generated files.

## Coding Style & Naming Conventions
Dart files use two-space indentation, `snake_case` filenames, and `PascalCase` types. Follow Riverpod provider suffixes (e.g., `*_provider.dart`) and keep widgets stateless where possible. Always run `dart format lib test` and `flutter analyze` (configured via `analysis_options.yaml` with `flutter_lints`). Prefer clear module prefixes: `auth_`, `order_`, etc., and place UI strings in the localization classes under `lib/src/core/l10n/`.

## Testing Guidelines
Widget and provider tests live beside their feature counterparts under `test/<feature>/..._test.dart`. Name files after the subject (`home_page_test.dart`) and favor `group()` blocks per state. Run `flutter test` before every PR; add golden or integration tests when changing UI flows that span multiple pages.

## Commit & Pull Request Guidelines
Adopt the existing Conventional Commit style (`feat:`, `fix:`, etc.), e.g., `feat: getDeliveryFee api`. Commits should be scoped to one logical change and include regenerated files if applicable. PRs must reference linked issues or product tickets, summarize behavioral changes, list key commands run (tests/analyze), and attach screenshots or screen recordings for UI updates.

## Security & Configuration Tips
Service endpoints, keys, and environment toggles belong in `lib/src/core/config/` (see `app_environment.dart`); do not hard-code secrets in widgets. Use platform-specific keystores/provisioning profiles for distribution builds, and rotate any test tokens stored in CI before sharing logs.


# AGENTS.md

## Project
- Name: Guarani3W (SIU-Guarani2 web/services). PHP 5.4 app (legacy). Uses Subversion historically (README).
- Main web root: `Sitio/`. Entry points:
  - Web: `Sitio/src/siu/www/index.php` requires `Sitio/src/siu/bootstrap.php` and calls `\siu\bootstrap::cargar()` then `\kernel\nucleo\acceso_web::procesar()`.
  - CLI: `Sitio/bin/guarani` runs `Sitio/src/siu/util/consola/run.php` (uses `\siu\bootstrap::registrar_autoload(true)` + `\siu\util\consola\gadmin`).
- Vendor deps in `Sitio/src/siu/lib/vendor/` (composer-managed). PHPUnit 4.5 is required in `Sitio/src/siu/lib/composer.json`.

## Config
- Runtime config loaded from `Sitio/instalacion/config.php` (template: `Sitio/instalacion/config_template.php`). `\siu\bootstrap` reads global config, validates required keys (`produccion`, `usar_personalizaciones`, `sesion_maxtime`, `sesion_timeout`, etc.) and per-access blocks.
- Additional config files in `Sitio/`: `configApp*.ini`, `configEntorno*.ini`. Environment/service endpoints (WS) are configured in these INI files.
- Personalizations live in `Personalizaciones_SIU/` and `Personalizaciones_Uas/`, `Personalizaciones_UNL/` (PowerBuilder artifacts `.pbl/.pbd`, images, etc.).

## Tests
- Tests live under `Sitio/src/test/` (namespaced like `siu\...`, extend `\PHPUnit_Framework_TestCase`).
- Some tests bootstrap via `require_once .../siu/bootstrap.php; \siu\bootstrap::cargar();` (e.g. `Sitio/src/test/modelo/entidades/personaTest.php`). Others do minimal includes.
- PHPUnit runner present: `Sitio/src/siu/lib/phpunit/phpunit.php` (PHPUnit 3.5-era layout in places, but lib composer says PHPUnit 4.5.*).
- Running tests may require DB/config and seeded test data (see `personaTest` referencing `guarani datos_test` / `\test\modelo\casos_test`).

## Conventions / gotchas
- Encoding: app sets `default_charset` ISO-8859-1 and has encoding-related fixes noted in changelog.
- Timezone: `America/Argentina/Buenos_Aires` set in web entry.
- Kernel/framework is custom/Toba-based under `Sitio/src/siu/lib/kernel/` and `Sitio/src/siu/` (namespaces `siu\`, `kernel\`).
- Versioning/checks via `\siu\version` (conversion/creation/script checks against DB).
- Don't trust top-level files blindly - config lives in `Sitio/instalacion/` and environment INIs in `Sitio/`. Real wiring is in `bootstrap.php` + kernel.

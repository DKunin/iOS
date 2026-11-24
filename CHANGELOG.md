# Changelog

## 2026-11-24

- Добавлена поддержка общей сессии Kunini Auth для авторизации и нативных сетевых запросов macOS-приложения к `home.kunini.ru`.
- Для Kunini Auth debug-сборка использует стабильный OAuth client и callback Companion App, чтобы Home Assistant не отклонял вход с ошибкой `Invalid redirect URI`.
- Перед OAuth-запросом приложение сначала завершает Kunini Auth на URL без query-параметров, чтобы reverse proxy не повреждал OAuth callback при возврате из авторизации.

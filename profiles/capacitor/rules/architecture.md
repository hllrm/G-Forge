## Capacitor + Ionic Architecture Rules

**Layer map:**
- `src/` — web application following the base framework's rules (Angular/React); all UI and business logic
- `src/services/native/` — thin wrappers around Capacitor plugin APIs; feature detection and platform divergence isolated here
- `src/services/` — business logic services; use native bridge services; never import Capacitor plugins directly
- `capacitor.config.ts` — app ID, server config, plugin configuration; no logic
- `ios/` and `android/` — Capacitor-managed native shells; not manually modified except for explicit native plugin setup

**Import direction:** components → services → services/native → Capacitor plugins. Capacitor plugin imports are confined to `src/services/native/`. Platform checks confined to native bridge services.

**Feature detection rule:** All Capacitor plugin calls are guarded with `Capacitor.isPluginAvailable()` or `isNativePlatform()`. Every native feature has a web fallback path. No `navigator.userAgent` parsing.

**Offline-first rule:** Every network call has a catch block and an offline fallback. `@capacitor/network` checked before fetch calls for critical data. Key data cached locally (Preferences, Filesystem, or IndexedDB).

**Native shell rule:** `ios/` and `android/` are Capacitor-managed. Manual edits only for plugin registration that `npx cap sync` cannot handle, documented with a comment.

**Plugin config rule:** All plugin options live in `capacitor.config.ts`, not in service files.

# CHANGELOG

## Changelog Categories
- `BREAKING` for breaking changes.
- `Added` for new features.
- `Changed` for changes in existing functionality.
- `Deprecated` for soon-to-be removed features.
- `Removed` for now removed features.
- `Fixed` for any bug fixes.
- `Security` in case of vulnerabilities.

## v1.7.9
- `Added` `uj_icon` tag now emits a `data-icon="<name>"` attribute on the wrapping `<i>` element, using the resolved icon name. Makes icons targetable via `[data-icon="..."]` selectors without colliding with FontAwesome's own CSS.

## v1.7.8
- `Fixed` iffile tag now correctly falls back to the literal path when the root variable is undefined or nil, while still returning empty when a defined variable resolves to nil.
- `Fixed` Test suite back to 100% passing (534/534) by aligning stale tests with current behavior: readtime word counts use the actual 269 WPM rate, uj_content_format tests exercise inputs with Liquid syntax, uj_jsonify empty-collection expectations match Ruby's JSON.pretty_generate, inject_properties priority test matches `:lowest`.

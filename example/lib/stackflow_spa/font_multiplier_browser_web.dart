import 'dart:js_interop';

// ActivityFontMultiplierLayout.tsx calls location.reload() as a bound method.
// Unlike a local Flutter rebuild this restarts the full browser document,
// including any fontScaling bootstrap that writes the HTML root data attribute.
@JS('window.location')
external _BrowserLocation get _location;

extension type _BrowserLocation(JSObject _) implements JSObject {
  external void reload();
}

@JS('document.documentElement')
external _DocumentRoot get _documentRoot;

extension type _DocumentRoot(JSObject _) implements JSObject {
  external JSString? getAttribute(JSString name);
}

String? readRootFontMultiplier() =>
    _documentRoot.getAttribute('data-seed-font-multiplier'.toJS)?.toDart;

void reloadDocument() => _location.reload();

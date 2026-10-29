import 'dart:js_interop';

// Called only by a Step that this SPA has pushed into browser history.
@JS('window.history')
external _BrowserHistory get _history;

extension type _BrowserHistory(JSObject _) implements JSObject {
  external void back();
}

bool get supportsBrowserBack => true;

void goBack() => _history.back();

import 'dart:js_interop';

// ActivityListItem.tsx uses window.alert, which emits a browser dialog event.
@JS('window.alert')
external void _showWindowAlert(JSString message);

bool get supportsNativeAlert => true;

void showNativeAlert(String message) => _showWindowAlert(message.toJS);

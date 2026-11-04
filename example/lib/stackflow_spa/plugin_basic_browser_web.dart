import 'dart:js_interop';

// Official Stackflow SPA theme.ts: /iphone|ipad|ipod/i.test(navigator.userAgent).
// Read the genuine *Web browser UA* rather than Flutter's engine platform;
// browser emulation may spoof the userAgent independently of navigator.platform.
@JS('window.navigator.userAgent')
external JSString get _userAgent;

String? readBrowserUserAgent() => _userAgent.toDart;

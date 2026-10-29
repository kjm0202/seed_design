/// A browser-native alert is unavailable on Flutter VM and native devices.
bool get supportsNativeAlert => false;

void showNativeAlert(String message) {}

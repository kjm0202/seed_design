import 'package:flutter/widgets.dart';

/// The official SEED breakpoints (`@seed-design/css/breakpoints`), in
/// ascending order. Each one applies from its [minWidth] upwards.
enum SeedBreakpoint {
  /// Every width; the mobile-first default.
  base(0),

  /// 480 logical pixels and wider.
  sm(480),

  /// 768 logical pixels and wider.
  md(768),

  /// 1280 logical pixels and wider.
  lg(1280),

  /// 1440 logical pixels and wider.
  xl(1440);

  const SeedBreakpoint(this.minWidth);

  /// The smallest viewport width, in logical pixels, at which this
  /// breakpoint applies (the official `min-width` media query).
  final double minWidth;

  /// The official `BreakpointThreshold` values: every breakpoint except
  /// [base].
  static const List<SeedBreakpoint> thresholds = [sm, md, lg, xl];

  /// The largest breakpoint that applies at [width].
  static SeedBreakpoint fromWidth(double width) {
    for (final breakpoint in values.reversed) {
      if (width >= breakpoint.minWidth) return breakpoint;
    }
    return base;
  }

  /// The official `useBreakpoint`: the breakpoint of the current viewport.
  ///
  /// It reads the [MediaQuery] width and rebuilds [context] when that width
  /// changes. There is no server rendering in Flutter, so the official
  /// `defaultBreakpoint` option and `BreakpointProvider` have no counterpart.
  static SeedBreakpoint of(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  /// Whether this breakpoint applies at or above [other].
  bool operator >=(SeedBreakpoint other) => index >= other.index;

  /// Whether this breakpoint is narrower than [other].
  bool operator <(SeedBreakpoint other) => index < other.index;
}

/// The official `ResponsiveValue<T>`: a value per breakpoint, mobile first.
///
/// A breakpoint without a value falls back to the nearest smaller one that
/// has a value, as in the official `resolveResponsiveValue`.
///
/// ```dart
/// final columns = const SeedResponsiveValue(base: 1, md: 2, xl: 4).of(context);
/// ```
@immutable
class SeedResponsiveValue<T> {
  /// Creates a responsive value; omitted breakpoints inherit from below.
  const SeedResponsiveValue({this.base, this.sm, this.md, this.lg, this.xl});

  /// Creates a value that is the same at every breakpoint.
  const SeedResponsiveValue.all(T value)
    : base = value,
      sm = null,
      md = null,
      lg = null,
      xl = null;

  /// Value from the matching breakpoint upwards; null inherits from below.
  final T? base, sm, md, lg, xl;

  T? _at(SeedBreakpoint breakpoint) => switch (breakpoint) {
    SeedBreakpoint.base => base,
    SeedBreakpoint.sm => sm,
    SeedBreakpoint.md => md,
    SeedBreakpoint.lg => lg,
    SeedBreakpoint.xl => xl,
  };

  /// The value at [breakpoint], or null when neither it nor any smaller
  /// breakpoint has one.
  T? resolve(SeedBreakpoint breakpoint) {
    for (var i = breakpoint.index; i >= 0; i--) {
      final value = _at(SeedBreakpoint.values[i]);
      if (value != null) return value;
    }
    return null;
  }

  /// The official `useBreakpointValue`: the value for the current viewport.
  /// Rebuilds [context] when the viewport width changes.
  T? of(BuildContext context) => resolve(SeedBreakpoint.of(context));

  @override
  bool operator ==(Object other) =>
      other is SeedResponsiveValue<T> &&
      other.base == base &&
      other.sm == sm &&
      other.md == md &&
      other.lg == lg &&
      other.xl == xl;

  @override
  int get hashCode => Object.hash(base, sm, md, lg, xl);
}

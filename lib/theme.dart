import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff2a638a),
      surfaceTint: Color(0xff2a638a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffcbe6ff),
      onPrimaryContainer: Color(0xff001e30),
      secondary: Color(0xff685f12),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xfff1e58a),
      onSecondaryContainer: Color(0xff1f1c00),
      tertiary: Color(0xff6d538b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffefdbff),
      onTertiaryContainer: Color(0xff270d43),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff181c20),
      onSurfaceVariant: Color(0xff42474d),
      outline: Color(0xff72787e),
      outlineVariant: Color(0xffc1c7ce),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xff97ccf9),
      primaryFixed: Color(0xffcbe6ff),
      onPrimaryFixed: Color(0xff001e30),
      primaryFixedDim: Color(0xff97ccf9),
      onPrimaryFixedVariant: Color(0xff024b71),
      secondaryFixed: Color(0xfff1e58a),
      onSecondaryFixed: Color(0xff1f1c00),
      secondaryFixedDim: Color(0xffd4c871),
      onSecondaryFixedVariant: Color(0xff4f4800),
      tertiaryFixed: Color(0xffefdbff),
      onTertiaryFixed: Color(0xff270d43),
      tertiaryFixedDim: Color(0xffd9bafa),
      onTertiaryFixedVariant: Color(0xff553b71),
      surfaceDim: Color(0xffd7dadf),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f4f9),
      surfaceContainer: Color(0xffebeef3),
      surfaceContainerHigh: Color(0xffe6e8ed),
      surfaceContainerHighest: Color(0xffe0e3e8),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00476c),
      surfaceTint: Color(0xff2a638a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff4379a2),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff4b4400),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff7f7628),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff51376d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff8469a3),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff8c0009),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffda342e),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff181c20),
      onSurfaceVariant: Color(0xff3e4349),
      outline: Color(0xff5a6066),
      outlineVariant: Color(0xff757b82),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xff97ccf9),
      primaryFixed: Color(0xff4379a2),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff276188),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff7f7628),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff655d10),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff8469a3),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff6b5088),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd7dadf),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f4f9),
      surfaceContainer: Color(0xffebeef3),
      surfaceContainerHigh: Color(0xffe6e8ed),
      surfaceContainerHighest: Color(0xffe0e3e8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00253a),
      surfaceTint: Color(0xff2a638a),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff00476c),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff272300),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff4b4400),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff2e154a),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff51376d),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff4e0002),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff8c0009),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff7f9ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff1f252a),
      outline: Color(0xff3e4349),
      outlineVariant: Color(0xff3e4349),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2d3135),
      inversePrimary: Color(0xffdeeeff),
      primaryFixed: Color(0xff00476c),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00304a),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff4b4400),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff322d00),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff51376d),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff392055),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffd7dadf),
      surfaceBright: Color(0xfff7f9ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff1f4f9),
      surfaceContainer: Color(0xffebeef3),
      surfaceContainerHigh: Color(0xffe6e8ed),
      surfaceContainerHighest: Color(0xffe0e3e8),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff97ccf9),
      surfaceTint: Color(0xff97ccf9),
      onPrimary: Color(0xff003450),
      primaryContainer: Color(0xff024b71),
      onPrimaryContainer: Color(0xffcbe6ff),
      secondary: Color(0xffd4c871),
      onSecondary: Color(0xff363100),
      secondaryContainer: Color(0xff4f4800),
      onSecondaryContainer: Color(0xfff1e58a),
      tertiary: Color(0xffd9bafa),
      onTertiary: Color(0xff3d2459),
      tertiaryContainer: Color(0xff553b71),
      onTertiaryContainer: Color(0xffefdbff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff101417),
      onSurface: Color(0xffe0e3e8),
      onSurfaceVariant: Color(0xffc1c7ce),
      outline: Color(0xff8c9198),
      outlineVariant: Color(0xff42474d),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e3e8),
      inversePrimary: Color(0xff2a638a),
      primaryFixed: Color(0xffcbe6ff),
      onPrimaryFixed: Color(0xff001e30),
      primaryFixedDim: Color(0xff97ccf9),
      onPrimaryFixedVariant: Color(0xff024b71),
      secondaryFixed: Color(0xfff1e58a),
      onSecondaryFixed: Color(0xff1f1c00),
      secondaryFixedDim: Color(0xffd4c871),
      onSecondaryFixedVariant: Color(0xff4f4800),
      tertiaryFixed: Color(0xffefdbff),
      onTertiaryFixed: Color(0xff270d43),
      tertiaryFixedDim: Color(0xffd9bafa),
      onTertiaryFixedVariant: Color(0xff553b71),
      surfaceDim: Color(0xff101417),
      surfaceBright: Color(0xff363a3e),
      surfaceContainerLowest: Color(0xff0b0f12),
      surfaceContainerLow: Color(0xff181c20),
      surfaceContainer: Color(0xff1c2024),
      surfaceContainerHigh: Color(0xff262a2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff9cd0fd),
      surfaceTint: Color(0xff97ccf9),
      onPrimary: Color(0xff001829),
      primaryContainer: Color(0xff6196c0),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffd8cd75),
      onSecondary: Color(0xff1a1700),
      secondaryContainer: Color(0xff9c9242),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffdebefe),
      onTertiary: Color(0xff22063d),
      tertiaryContainer: Color(0xffa285c1),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffbab1),
      onError: Color(0xff370001),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff101417),
      onSurface: Color(0xfff9fbff),
      onSurfaceVariant: Color(0xffc6cbd3),
      outline: Color(0xff9ea3aa),
      outlineVariant: Color(0xff7e848a),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e3e8),
      inversePrimary: Color(0xff054c72),
      primaryFixed: Color(0xffcbe6ff),
      onPrimaryFixed: Color(0xff001321),
      primaryFixedDim: Color(0xff97ccf9),
      onPrimaryFixedVariant: Color(0xff003a58),
      secondaryFixed: Color(0xfff1e58a),
      onSecondaryFixed: Color(0xff141100),
      secondaryFixedDim: Color(0xffd4c871),
      onSecondaryFixedVariant: Color(0xff3d3700),
      tertiaryFixed: Color(0xffefdbff),
      onTertiaryFixed: Color(0xff1c0138),
      tertiaryFixedDim: Color(0xffd9bafa),
      onTertiaryFixedVariant: Color(0xff432a5f),
      surfaceDim: Color(0xff101417),
      surfaceBright: Color(0xff363a3e),
      surfaceContainerLowest: Color(0xff0b0f12),
      surfaceContainerLow: Color(0xff181c20),
      surfaceContainer: Color(0xff1c2024),
      surfaceContainerHigh: Color(0xff262a2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff9fbff),
      surfaceTint: Color(0xff97ccf9),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff9cd0fd),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffffaf2),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffd8cd75),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xfffff9fc),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffdebefe),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xfffff9f9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffbab1),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff101417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xfff9fbff),
      outline: Color(0xffc6cbd3),
      outlineVariant: Color(0xffc6cbd3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe0e3e8),
      inversePrimary: Color(0xff002d46),
      primaryFixed: Color(0xffd4e9ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff9cd0fd),
      onPrimaryFixedVariant: Color(0xff001829),
      secondaryFixed: Color(0xfff5e98e),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffd8cd75),
      onSecondaryFixedVariant: Color(0xff1a1700),
      tertiaryFixed: Color(0xfff2e0ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffdebefe),
      onTertiaryFixedVariant: Color(0xff22063d),
      surfaceDim: Color(0xff101417),
      surfaceBright: Color(0xff363a3e),
      surfaceContainerLowest: Color(0xff0b0f12),
      surfaceContainerLow: Color(0xff181c20),
      surfaceContainer: Color(0xff1c2024),
      surfaceContainerHigh: Color(0xff262a2e),
      surfaceContainerHighest: Color(0xff313539),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.background,
        canvasColor: colorScheme.surface,
      );

  /// Success
  static const success = ExtendedColor(
    seed: Color(0xff00a212),
    value: Color(0xff00a212),
    light: ColorFamily(
      color: Color(0xff3f6837),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbff0b1),
      onColorContainer: Color(0xff002201),
    ),
    lightMediumContrast: ColorFamily(
      color: Color(0xff3f6837),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbff0b1),
      onColorContainer: Color(0xff002201),
    ),
    lightHighContrast: ColorFamily(
      color: Color(0xff3f6837),
      onColor: Color(0xffffffff),
      colorContainer: Color(0xffbff0b1),
      onColorContainer: Color(0xff002201),
    ),
    dark: ColorFamily(
      color: Color(0xffa4d396),
      onColor: Color(0xff10380c),
      colorContainer: Color(0xff275021),
      onColorContainer: Color(0xffbff0b1),
    ),
    darkMediumContrast: ColorFamily(
      color: Color(0xffa4d396),
      onColor: Color(0xff10380c),
      colorContainer: Color(0xff275021),
      onColorContainer: Color(0xffbff0b1),
    ),
    darkHighContrast: ColorFamily(
      color: Color(0xffa4d396),
      onColor: Color(0xff10380c),
      colorContainer: Color(0xff275021),
      onColorContainer: Color(0xffbff0b1),
    ),
  );

  List<ExtendedColor> get extendedColors => [
        success,
      ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}

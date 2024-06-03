import 'package:pdf/pdf.dart';

// Define an extension for PdfColor to add additional functionality.
extension ColorExtension on PdfColor {
  /// Tries to parse a color from the string.
  ///
  /// The color must be a valid HEX (with or without '#') or rgba() value,
  /// otherwise it will return null.
  ///
  /// Valid HEX examples:
  /// - "#FFFFFF"
  /// - "FFFFFF"
  /// - "#FFF"
  /// - "FFF"
  ///
  /// Valid RGBA examples:
  /// - "rgba(255, 255, 255, 1)"
  /// - "rgba(255, 255, 255, 0.5)"
  ///
  /// Returns a [PdfColor] object if the string is a valid color representation,
  /// otherwise returns null.
  static PdfColor? tryFromString(String colorString) {
    final colorInRgba = _tryFromRgbaString(colorString);

    if (colorInRgba != null) {
      return colorInRgba;
    }

    final colorInHex = _tryFromHexString(colorString);

    if (colorInHex != null) {
      return colorInHex;
    }

    return null;
  }

  /// Try to parse HEX color from the string.
  static PdfColor? _tryFromHexString(String colorString) {
    final RegExp hexColorRegExp = RegExp(
        r'^#?([0-9A-Fa-f]{3}|[0-9A-Fa-f]{4}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');

    if (!hexColorRegExp.hasMatch(colorString)) {
      return null;
    }

    return PdfColor.fromHex(colorString);
  }

  /// Try to parse the `rgba(red, green, blue, alpha)` from the string.
  static PdfColor? _tryFromRgbaString(String colorString) {
    final reg = RegExp(r'rgba\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)');
    final match = reg.firstMatch(colorString);

    if (match == null) {
      return null; // Return null if the provided string does not match the expected format.
    }

    if (match.groupCount < 4) {
      return null; // Return null if there are not enough color components.
    }

    final redStr = match.group(1);
    final greenStr = match.group(2);
    final blueStr = match.group(3);
    final alphaStr = match.group(4);

    // Attempt to parse color components as integers.
    final red = redStr != null ? int.tryParse(redStr) : null;
    final green = greenStr != null ? int.tryParse(greenStr) : null;
    final blue = blueStr != null ? int.tryParse(blueStr) : null;
    final alpha = alphaStr != null ? int.tryParse(alphaStr) : null;

    // If any component parsing fails, return null.
    if (red == null || green == null || blue == null || alpha == null) {
      return null;
    }

    // Create a PdfColor from the parsed RGBA values.
    return PdfColor.fromInt(
        hexOfRGBA(red, green, blue, opacity: alpha.toDouble()));
  }

  // Convert PdfColor to an RGBA string format.
  String toRgbaString() {
    return 'rgba($red, $green, $blue, $alpha)';
  }
}

// Function to calculate the hex representation of an RGBA color.
int hexOfRGBA(int r, int g, int b, {double opacity = 1}) {
  // Ensure that color values and opacity are within valid ranges.
  r = (r < 0) ? 0 : (r > 255) ? 255 : r;
  g = (g < 0) ? 0 : (g > 255) ? 255 : g;
  b = (b < 0) ? 0 : (b > 255) ? 255 : b;
  opacity = (opacity < 0) ? 0 : (opacity > 1) ? 1 : opacity;
  int a = (opacity * 255).toInt();

  // Calculate and return the hex representation of the color.
  String hex = a.toRadixString(16).padLeft(2, '0') +
               r.toRadixString(16).padLeft(2, '0') +
               g.toRadixString(16).padLeft(2, '0') +
               b.toRadixString(16).padLeft(2, '0');

  return int.parse('0x$hex');
}
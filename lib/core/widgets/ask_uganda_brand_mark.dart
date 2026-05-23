import 'package:flutter/material.dart';

/// Which face of the Ask Uganda brand to render.
enum AskUgandaBrandVariant {
  /// Transparent green speech-bubble mark. Use on light surfaces.
  mark,

  /// Squircle gradient app-icon tile. Use on dark or coloured surfaces
  /// where the transparent mark would not read, and for launcher-style
  /// affordances inside the app.
  squircleIcon,
}

/// The Ask Uganda visual identity. Use this anywhere the assistant should
/// be attributed (chat bubbles, home greeting, about banner, etc.).
class AskUgandaBrandMark extends StatelessWidget {
  const AskUgandaBrandMark({
    super.key,
    this.size = 32,
    this.variant = AskUgandaBrandVariant.mark,
    this.semanticsLabel = 'Ask Uganda mark',
  });

  /// Squared dimension of the mark in logical pixels.
  final double size;
  final AskUgandaBrandVariant variant;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final asset = switch (variant) {
      AskUgandaBrandVariant.mark => 'assets/brand/ask-uganda-mark-256.png',
      AskUgandaBrandVariant.squircleIcon =>
        'assets/brand/ask-uganda-icon-512.png',
    };

    return Semantics(
      label: semanticsLabel,
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: Image(
          image: AssetImage(asset),
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

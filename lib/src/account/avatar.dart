import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../ui/hero_tags.dart';
import '../ui/tokens.dart';

/// Decoded photos, so the image doesn't flicker on rebuilds.
final _imageCache = <String, MemoryImage>{};

MemoryImage _image(String base64) {
  if (_imageCache.length > 20) _imageCache.clear();
  return _imageCache.putIfAbsent(
    base64,
    () => MemoryImage(base64Decode(base64)),
  );
}

String initialsOf(String? name) {
  final parts = (name ?? '').trim().split(RegExp(r'\s+'))
    ..removeWhere((p) => p.isEmpty);
  if (parts.isEmpty) return '?';
  final first = parts.first.characters.first;
  final last = parts.length > 1 ? parts.last.characters.first : '';
  return (first + last).toUpperCase();
}

/// Profile photo, or initials on a neutral circle. With [hero] it flies between
/// the home app bar, the account page and the profile editor.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.size,
    this.photoBase64,
    this.name,
    this.hero = true,
  });

  final double size;
  final String? photoBase64;
  final String? name;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final initials = Text(
      initialsOf(name),
      style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeights.semibold),
    );
    // Forui avatar: the photo, or the initials on a muted circle.
    final avatar = AnimatedSwitcher(
      duration: Motion.slow,
      child: photoBase64 != null
          ? FAvatar(
              key: ValueKey(photoBase64.hashCode),
              image: _image(photoBase64!),
              size: size,
              fallback: initials,
            )
          : FAvatar.raw(
              key: const ValueKey('initials'),
              size: size,
              child: initials,
            ),
    );
    // Scales with the hero flight's size instead of jumping.
    final scaled = SizedBox.square(
      dimension: size,
      child: FittedBox(child: avatar),
    );
    if (!hero) return scaled;
    return Hero(
      tag: HeroTags.avatar,
      child: Material(type: MaterialType.transparency, child: scaled),
    );
  }
}

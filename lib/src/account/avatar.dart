import 'dart:convert';

import 'package:flutter/material.dart';

import '../ui/hero_tags.dart';

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

/// Profile photo, or initials on a gradient. With [hero] it flies between
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
    final colors = Theme.of(context).colorScheme;
    final avatar = SizedBox.square(
      dimension: size,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final side = constraints.biggest.shortestSide;
          return ClipOval(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: photoBase64 != null
                  ? Image(
                      key: ValueKey(photoBase64.hashCode),
                      image: _image(photoBase64!),
                      width: side,
                      height: side,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    )
                  : DecoratedBox(
                      key: const ValueKey('initials'),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.primary, colors.tertiary],
                        ),
                      ),
                      child: SizedBox.square(
                        dimension: side,
                        child: Center(
                          child: Text(
                            initialsOf(name),
                            style: TextStyle(
                              color: colors.onPrimary,
                              fontSize: side * 0.38,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
    if (!hero) return avatar;
    return Hero(
      tag: HeroTags.avatar,
      child: Material(type: MaterialType.transparency, child: avatar),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

ImageProvider? resolveAvatar(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) return null;
  if (avatarUrl.startsWith('http')) return NetworkImage(avatarUrl);
  if (avatarUrl.startsWith('data:')) {
    try {
      final commaIndex = avatarUrl.indexOf(',');
      if (commaIndex == -1) return null;
      final base64Data = avatarUrl.substring(commaIndex + 1);
      final Uint8List bytes = base64Decode(base64Data);
      return MemoryImage(bytes);
    } catch (_) {
      return null;
    }
  }
  return NetworkImage(avatarUrl);
}

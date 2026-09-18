import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppImageView extends StatelessWidget {
  final String imageUri;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const AppImageView({
    super.key,
    required this.imageUri,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final defaultError = errorWidget ??
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.broken_image_outlined, color: Colors.white70, size: 48),
                SizedBox(height: 10),
                Text(
                  'تعذر تحميل صورة الفاتورة',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'قد تكون الجلسة السابقة انتهت، يمكنك تعديل الصنف وإرفاق الصورة مجدداً لحفظها بشكل دائم',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
        );

    // 1. Data URI with base64 (e.g. data:image/png;base64,....)
    if (imageUri.startsWith('data:image') || imageUri.contains(';base64,')) {
      try {
        final commaIndex = imageUri.indexOf(',');
        final base64String = commaIndex != -1 ? imageUri.substring(commaIndex + 1) : imageUri;
        final cleanBase64 = base64String.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (ctx, err, stack) => defaultError,
        );
      } catch (_) {
        return defaultError;
      }
    }

    // 2. Raw base64 string without data: header (long string with no slashes/colons)
    if (!imageUri.startsWith('http') &&
        !imageUri.startsWith('/') &&
        !imageUri.contains('\\') &&
        imageUri.length > 200) {
      try {
        final bytes = base64Decode(imageUri.replaceAll(RegExp(r'\s+'), ''));
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (ctx, err, stack) => defaultError,
        );
      } catch (_) {}
    }

    // 3. Web or HTTP/HTTPS/Blob URL
    if (kIsWeb || imageUri.startsWith('http://') || imageUri.startsWith('https://') || imageUri.startsWith('blob:')) {
      return Image.network(
        imageUri,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (ctx, err, stack) => defaultError,
      );
    }

    // 4. Local File (Android / iOS / Desktop)
    try {
      final file = File(imageUri);
      return Image.file(
        file,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (ctx, err, stack) => defaultError,
      );
    } catch (_) {
      return defaultError;
    }
  }
}

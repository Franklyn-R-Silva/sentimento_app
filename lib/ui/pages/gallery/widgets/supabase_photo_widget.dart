// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

// Project imports:
import 'package:sentimento_app/backend/supabase.dart';
import 'package:sentimento_app/core/theme.dart';

class SupabasePhotoWidget extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const SupabasePhotoWidget({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<SupabasePhotoWidget> createState() => _SupabasePhotoWidgetState();
}

class _SupabasePhotoWidgetState extends State<SupabasePhotoWidget> {
  Future<String>? _signedUrlFuture;

  @override
  void initState() {
    super.initState();
    _loadSignedUrl();
  }

  @override
  void didUpdateWidget(covariant SupabasePhotoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _loadSignedUrl();
    }
  }

  void _loadSignedUrl() {
    // Generate a new signed URL
    _signedUrlFuture = _fetchSignedUrl(widget.imageUrl);
  }

  Future<String> _fetchSignedUrl(String url) async {
    try {
      // 1. Try to extract path from URL if it's a full Supabase URL
      // Pattern: .../storage/v1/object/public/fotos_anuais/path/to/file.jpg
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf('fotos_anuais');

      String path;
      if (bucketIndex != -1 && bucketIndex + 1 < segments.length) {
        path = segments.sublist(bucketIndex + 1).join('/');
      } else {
        // Assume it might be a relative path or raw path
        path = url;
      }

      // 2. Generate signed URL (valid for 1 hour)
      final signedUrl = await SupaFlow.client.storage
          .from('fotos_anuais')
          .createSignedUrl(path, 3600);

      return signedUrl;
    } catch (e) {
      debugPrint('Error generating signed URL: $e');
      return url; // Fallback to original URL
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return FutureBuilder<String>(
      future: _signedUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: widget.width,
            height: widget.height,
            color: theme.alternate.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final url = snapshot.data ?? widget.imageUrl;

        return CachedNetworkImage(
          imageUrl: url,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (context, url) => Container(
            color: theme.alternate.withValues(alpha: 0.3),
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: theme.alternate.withValues(alpha: 0.3),
            child: Icon(Icons.broken_image_rounded, color: theme.secondaryText),
          ),
        );
      },
    );
  }
}

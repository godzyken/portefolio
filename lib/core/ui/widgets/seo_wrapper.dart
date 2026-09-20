import 'package:flutter/material.dart';
import 'package:seo/seo.dart';

/// Un wrapper simple pour injecter des balises SEO (Meta tags) sur une page.
class SeoWrapper extends StatelessWidget {
  final String title;
  final String description;
  final String? url;
  final String? imageUrl;
  final Widget child;

  const SeoWrapper({
    super.key,
    required this.title,
    required this.description,
    this.url,
    this.imageUrl,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Seo.head(
      tags: [
        MetaTag(name: 'title', content: title),
        MetaTag(name: 'description', content: description),
        if (url != null) MetaTag(name: 'og:url', content: url!),
        MetaTag(name: 'og:title', content: title),
        MetaTag(name: 'og:description', content: description),
        if (imageUrl != null) MetaTag(name: 'og:image', content: imageUrl!),
        MetaTag(name: 'twitter:card', content: 'summary_large_image'),
        MetaTag(name: 'twitter:title', content: title),
        MetaTag(name: 'twitter:description', content: description),
      ],
      child: child,
    );
  }
}

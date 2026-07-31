import 'package:flutter/material.dart';

enum ResourceType { pdf, image, video, link, other }

extension ResourceTypeX on ResourceType {
  String get label {
    switch (this) {
      case ResourceType.pdf:
        return 'PDF';
      case ResourceType.image:
        return 'Image';
      case ResourceType.video:
        return 'Video';
      case ResourceType.link:
        return 'Link';
      case ResourceType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ResourceType.pdf:
        return Icons.picture_as_pdf;
      case ResourceType.image:
        return Icons.image;
      case ResourceType.video:
        return Icons.play_circle_filled;
      case ResourceType.link:
        return Icons.link;
      case ResourceType.other:
        return Icons.attach_file;
    }
  }
}

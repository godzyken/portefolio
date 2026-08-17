import 'package:portefolio/core/affichage/tech_maturity_framework.dart';

enum MessageRole { user, avatar, system }

enum MessageType { text, leadForm }

class AvatarMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final TechPillar? relatedPillar;
  final MessageType type;

  AvatarMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.relatedPillar,
    this.type = MessageType.text,
  });

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'content': content,
      };
}

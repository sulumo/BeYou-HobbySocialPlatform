import 'package:cloud_firestore/cloud_firestore.dart';

class HobbyContent {
  final String? id;
  final String title;
  final String description;
  final String type; //content type
  final String hobby;
  final String imageUrl;
  final List<String> tags;
  final String createdBy;
  final Timestamp createdAt;
  final Map<String, dynamic> metadata;
  final int likeCount;
  final int commentCount;

  HobbyContent({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.hobby,
    required this.imageUrl,
    required this.tags,
    required this.createdBy,
    required this.createdAt,
    required this.metadata,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  factory HobbyContent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HobbyContent(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      hobby: data['hobby'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
      metadata: Map<String, dynamic>.from(data['metadata'] ?? {}),
      likeCount: data['likeCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'hobby': hobby,
      'imageUrl': imageUrl,
      'tags': tags,
      'createdBy': createdBy,
      'createdAt': createdAt,
      'metadata': metadata,
      'likeCount': likeCount,
      'commentCount': commentCount,
    };
  }
}

class Comment {
  final String id;
  final String text;
  final String createdBy;
  final Timestamp createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.createdBy,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      text: data['text'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'text': text, 'createdBy': createdBy, 'createdAt': createdAt};
  }
}

class ChallengeParticipant {
  final String userId;
  final Timestamp joinedAt;
  final int progress; // 0 to 100
  final String status; // 'in_progress', 'completed'

  ChallengeParticipant({
    required this.userId,
    required this.joinedAt,
    required this.progress,
    required this.status,
  });

  factory ChallengeParticipant.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeParticipant(
      userId: doc.id,
      joinedAt: data['joinedAt'] ?? Timestamp.now(),
      progress: data['progress'] ?? 0,
      status: data['status'] ?? 'in_progress',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {'joinedAt': joinedAt, 'progress': progress, 'status': status};
  }
}

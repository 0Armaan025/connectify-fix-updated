// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ForumModal {
  final String forumID;
  final String uuid;
  final String description;
  final List<String> upvotes;
  final String mediaUrl;
  final List<String> forumComments;
  final bool isPublic;
  final String createdAt;
  ForumModal({
    required this.forumID,
    required this.uuid,
    required this.description,
    required this.upvotes,
    required this.mediaUrl,
    required this.forumComments,
    required this.isPublic,
    required this.createdAt,
  });

  ForumModal copyWith({
    String? forumID,
    String? uuid,
    String? description,
    List<String>? upvotes,
    String? mediaUrl,
    List<String>? forumComments,
    bool? isPublic,
    String? createdAt,
  }) {
    return ForumModal(
      forumID: forumID ?? this.forumID,
      uuid: uuid ?? this.uuid,
      description: description ?? this.description,
      upvotes: upvotes ?? this.upvotes,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      forumComments: forumComments ?? this.forumComments,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'forumID': forumID,
      'uuid': uuid,
      'description': description,
      'upvotes': upvotes,
      'mediaUrl': mediaUrl,
      'forumComments': forumComments,
      'isPublic': isPublic,
      'createdAt': createdAt,
    };
  }

  factory ForumModal.fromMap(Map<String, dynamic> map) {
    return ForumModal(
      forumID: map['forumID'] as String,
      uuid: map['uuid'] as String,
      description: map['description'] as String,
      upvotes: List<String>.from((map['upvotes'] ?? [])),
      mediaUrl: map['mediaUrl'] as String,
      forumComments: List<String>.from((map['forumComments'] ?? [])),
      isPublic: map['isPublic'] as bool,
      createdAt: map['createdAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ForumModal.fromJson(String source) =>
      ForumModal.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ForumModal(forumID: $forumID, uuid: $uuid, description: $description, upvotes: $upvotes, mediaUrl: $mediaUrl, forumComments: $forumComments, isPublic: $isPublic, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant ForumModal other) {
    if (identical(this, other)) return true;

    return other.forumID == forumID &&
        other.uuid == uuid &&
        other.description == description &&
        listEquals(other.upvotes, upvotes) &&
        other.mediaUrl == mediaUrl &&
        listEquals(other.forumComments, forumComments) &&
        other.isPublic == isPublic &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return forumID.hashCode ^
        uuid.hashCode ^
        description.hashCode ^
        upvotes.hashCode ^
        mediaUrl.hashCode ^
        forumComments.hashCode ^
        isPublic.hashCode ^
        createdAt.hashCode;
  }
}

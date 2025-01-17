// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class ForumCommentModal {
  final String forumCommentID;
  final String uuid;
  final String mediaUrl;
  final String commentContent;
  final List<String> upvotes;

  final String createdAt;
  ForumCommentModal({
    required this.forumCommentID,
    required this.uuid,
    required this.mediaUrl,
    required this.commentContent,
    required this.upvotes,
    required this.createdAt,
  });

  ForumCommentModal copyWith({
    String? forumCommentID,
    String? uuid,
    String? mediaUrl,
    String? commentContent,
    List<String>? upvotes,
    String? createdAt,
  }) {
    return ForumCommentModal(
      forumCommentID: forumCommentID ?? this.forumCommentID,
      uuid: uuid ?? this.uuid,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      commentContent: commentContent ?? this.commentContent,
      upvotes: upvotes ?? this.upvotes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'forumCommentID': forumCommentID,
      'uuid': uuid,
      'mediaUrl': mediaUrl,
      'commentContent': commentContent,
      'upvotes': upvotes,
      'createdAt': createdAt,
    };
  }

  factory ForumCommentModal.fromMap(Map<String, dynamic> map) {
    return ForumCommentModal(
      forumCommentID: map['forumCommentID'] as String,
      uuid: map['uuid'] as String,
      mediaUrl: map['mediaUrl'] as String,
      commentContent: map['commentContent'] as String,
      upvotes: List<String>.from((map['upvotes'] ?? [])),
      createdAt: map['createdAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ForumCommentModal.fromJson(String source) =>
      ForumCommentModal.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ForumCommentModal(forumCommentID: $forumCommentID, uuid: $uuid, mediaUrl: $mediaUrl, commentContent: $commentContent, upvotes: $upvotes, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant ForumCommentModal other) {
    if (identical(this, other)) return true;

    return other.forumCommentID == forumCommentID &&
        other.uuid == uuid &&
        other.mediaUrl == mediaUrl &&
        other.commentContent == commentContent &&
        listEquals(other.upvotes, upvotes) &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return forumCommentID.hashCode ^
        uuid.hashCode ^
        mediaUrl.hashCode ^
        commentContent.hashCode ^
        upvotes.hashCode ^
        createdAt.hashCode;
  }
}

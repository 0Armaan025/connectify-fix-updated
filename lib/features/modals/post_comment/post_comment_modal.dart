// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class PostCommentModal {
  final String username;
  final String profileImageUrl;
  final String createdAt;
  final List<String> likes;
  final String comment;
  PostCommentModal({
    required this.username,
    required this.profileImageUrl,
    required this.createdAt,
    required this.likes,
    required this.comment,
  });

  PostCommentModal copyWith({
    String? username,
    String? profileImageUrl,
    String? createdAt,
    List<String>? likes,
    String? comment,
  }) {
    return PostCommentModal(
      username: username ?? this.username,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comment: comment ?? this.comment,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'username': username,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
      'likes': likes,
      'comment': comment,
    };
  }

  factory PostCommentModal.fromMap(Map<String, dynamic> map) {
    return PostCommentModal(
      username: map['username'] as String,
      profileImageUrl: map['profileImageUrl'] as String,
      createdAt: map['createdAt'] as String,
      likes: List<String>.from((map['likes'] as List<String>)),
      comment: map['comment'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostCommentModal.fromJson(String source) =>
      PostCommentModal.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostCommentModal(username: $username, profileImageUrl: $profileImageUrl, createdAt: $createdAt, likes: $likes, comment: $comment)';
  }

  @override
  bool operator ==(covariant PostCommentModal other) {
    if (identical(this, other)) return true;

    return other.username == username &&
        other.profileImageUrl == profileImageUrl &&
        other.createdAt == createdAt &&
        listEquals(other.likes, likes) &&
        other.comment == comment;
  }

  @override
  int get hashCode {
    return username.hashCode ^
        profileImageUrl.hashCode ^
        createdAt.hashCode ^
        likes.hashCode ^
        comment.hashCode;
  }
}
// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class PostModal {
  final String postID;
  final String uuid;
  final List<String> comments;
  final String location;
  final List<String> likes;
  final String caption;
  final String mediaUrl;
  final String createdAt;
  PostModal({
    required this.postID,
    required this.uuid,
    required this.comments,
    required this.location,
    required this.likes,
    required this.caption,
    required this.mediaUrl,
    required this.createdAt,
  });

  PostModal copyWith({
    String? postID,
    String? uuid,
    List<String>? comments,
    String? location,
    List<String>? likes,
    String? caption,
    String? mediaUrl,
    String? createdAt,
  }) {
    return PostModal(
      postID: postID ?? this.postID,
      uuid: uuid ?? this.uuid,
      comments: comments ?? this.comments,
      location: location ?? this.location,
      likes: likes ?? this.likes,
      caption: caption ?? this.caption,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'postID': postID,
      'uuid': uuid,
      'comments': comments,
      'location': location,
      'likes': likes,
      'caption': caption,
      'mediaUrl': mediaUrl,
      'createdAt': createdAt,
    };
  }

  factory PostModal.fromMap(Map<String, dynamic> map) {
    return PostModal(
      postID: map['postID'] as String,
      uuid: map['uuid'] as String,
      comments: List<String>.from((map['comments'] ?? [])),
      location: map['location'] as String,
      likes: List<String>.from((map['likes'] ?? '')),
      caption: map['caption'] as String,
      mediaUrl: map['mediaUrl'] as String,
      createdAt: map['createdAt'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory PostModal.fromJson(String source) =>
      PostModal.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'PostModal(postID: $postID, uuid: $uuid, comments: $comments, location: $location, likes: $likes, caption: $caption, mediaUrl: $mediaUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant PostModal other) {
    if (identical(this, other)) return true;

    return other.postID == postID &&
        other.uuid == uuid &&
        listEquals(other.comments, comments) &&
        other.location == location &&
        listEquals(other.likes, likes) &&
        other.caption == caption &&
        other.mediaUrl == mediaUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return postID.hashCode ^
        uuid.hashCode ^
        comments.hashCode ^
        location.hashCode ^
        likes.hashCode ^
        caption.hashCode ^
        mediaUrl.hashCode ^
        createdAt.hashCode;
  }
}

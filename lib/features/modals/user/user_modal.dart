// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class UserModal {
  final String uuid;
  final String profileImageUrl;
  final String username;
  final String realName;
  final List<String> followers;
  final List<String> following;
  final String email;
  final int likes;
  final List<String> notifications;
  final bool isVerified;
  final String createdAt;
  final String bio;
  final List<String> blockedUsers;
  final String status;
  UserModal({
    required this.uuid,
    required this.profileImageUrl,
    required this.username,
    required this.realName,
    required this.followers,
    required this.following,
    required this.email,
    required this.likes,
    required this.notifications,
    required this.isVerified,
    required this.createdAt,
    required this.bio,
    required this.blockedUsers,
    required this.status,
  });

  UserModal copyWith({
    String? uuid,
    String? profileImageUrl,
    String? username,
    String? realName,
    List<String>? followers,
    List<String>? following,
    String? email,
    int? likes,
    List<String>? notifications,
    bool? isVerified,
    String? createdAt,
    String? bio,
    List<String>? blockedUsers,
    String? status,
  }) {
    return UserModal(
      uuid: uuid ?? this.uuid,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      username: username ?? this.username,
      realName: realName ?? this.realName,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      email: email ?? this.email,
      likes: likes ?? this.likes,
      notifications: notifications ?? this.notifications,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      bio: bio ?? this.bio,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uuid': uuid,
      'profileImageUrl': profileImageUrl,
      'username': username,
      'realName': realName,
      'followers': followers,
      'following': following,
      'email': email,
      'likes': likes,
      'notifications': notifications,
      'isVerified': isVerified,
      'createdAt': createdAt,
      'bio': bio,
      'blockedUsers': blockedUsers,
      'status': status,
    };
  }

  factory UserModal.fromMap(Map<String, dynamic> map) {
    return UserModal(
      uuid: map['uuid'] as String,
      profileImageUrl: map['profileImageUrl'] as String,
      username: map['username'] as String,
      realName: map['realName'] as String,
      followers: List<String>.from((map['followers'] ?? [])),
      following: List<String>.from((map['following'] ?? [])),
      email: map['email'] as String,
      likes: map['likes'] as int,
      notifications: List<String>.from((map['notifications'] ?? [])),
      isVerified: map['isVerified'] as bool,
      createdAt: map['createdAt'] as String,
      bio: map['bio'] as String,
      blockedUsers: List<String>.from((map['blockedUsers'] ?? [])),
      status: map['status'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModal.fromJson(String source) =>
      UserModal.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModal(uuid: $uuid, profileImageUrl: $profileImageUrl, username: $username, realName: $realName, followers: $followers, following: $following, email: $email, likes: $likes, notifications: $notifications, isVerified: $isVerified, createdAt: $createdAt, bio: $bio, blockedUsers: $blockedUsers, status: $status)';
  }

  @override
  bool operator ==(covariant UserModal other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.profileImageUrl == profileImageUrl &&
        other.username == username &&
        other.realName == realName &&
        listEquals(other.followers, followers) &&
        listEquals(other.following, following) &&
        other.email == email &&
        other.likes == likes &&
        listEquals(other.notifications, notifications) &&
        other.isVerified == isVerified &&
        other.createdAt == createdAt &&
        other.bio == bio &&
        listEquals(other.blockedUsers, blockedUsers) &&
        other.status == status;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        profileImageUrl.hashCode ^
        username.hashCode ^
        realName.hashCode ^
        followers.hashCode ^
        following.hashCode ^
        email.hashCode ^
        likes.hashCode ^
        notifications.hashCode ^
        isVerified.hashCode ^
        createdAt.hashCode ^
        bio.hashCode ^
        blockedUsers.hashCode ^
        status.hashCode;
  }
}

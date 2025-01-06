import 'package:connectify/common/post_widget/post_widget.dart';
import 'package:connectify/features/controllers/database/user_post_database_controller.dart';
import 'package:connectify/features/controllers/database/user_profile_database_controller.dart';
import 'package:flutter/material.dart';

import '../../modals/post/post_modal.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final List<PostModal> _posts = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _page = 1; // Pagination page
  final int _limit = 8; // Posts per page

  @override
  void initState() {
    super.initState();
    _fetchPosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isFetchingMore) {
        _loadMorePosts();
      }
    });
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final posts = await UserPostDatabaseController().getAllPosts(
        context,
      );

      setState(() {
        _posts.addAll(posts as List<PostModal>); // Append new posts to the list
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching posts: $e');
    }
  }

  Future<void> _loadMorePosts() async {
    setState(() {
      _isFetchingMore = true;
    });

    _page++; // Increment the page for pagination
    await _fetchPosts();

    setState(() {
      _isFetchingMore = false;
    });
  }

  Future<Map<String, dynamic>> getUserDataAndCheckMediaType(
      String uuid, String mediaUrl) async {
    try {
      final user =
          await UserProfileDatabaseController().getUserData(context, uuid);

      bool isImage = mediaUrl.toLowerCase().endsWith('.jpg') ||
          mediaUrl.toLowerCase().endsWith('.jpeg') ||
          mediaUrl.toLowerCase().endsWith('.png');

      return {
        'username': user.data['username'] ?? 'Unknown',
        'profileImageUrl': user.data['profileImageUrl'] ?? '',
        'isImage': isImage,
      };
    } catch (e) {
      print('Error fetching user data: $e');
      return {
        'username': 'Unknown',
        'profileImageUrl': '',
        'isImage': false,
      };
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        final post = _posts[index];
                        return FutureBuilder<Map<String, dynamic>>(
                          future: getUserDataAndCheckMediaType(
                              post.uuid, post.mediaUrl),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return const Center(
                                  child: Text('Error loading post'));
                            } else if (snapshot.hasData) {
                              final userData = snapshot.data!;
                              return PostWidget(
                                text: post.caption,
                                comments: [""],
                                createdAt: post.createdAt,
                                likes: post.likes.length - 1,
                                profileImageUrl: userData['profileImageUrl'],
                                username: userData['username'],
                              );
                            } else {
                              return const SizedBox.shrink();
                            }
                          },
                        );
                      },
                    ),
                    if (_isFetchingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

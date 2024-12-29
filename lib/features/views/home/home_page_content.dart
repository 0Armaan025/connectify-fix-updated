import 'package:connectify/common/post_widget/post_widget.dart';
import 'package:flutter/material.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  // Total number of posts
  final int totalPosts = 100;

  // Current count of posts to show
  int postsToShow = 8;

  // List of posts (You can replace this with real data fetching)
  late List<Widget> posts;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    posts = List.generate(
      totalPosts,
      (index) => PostWidget(
        // Replace with real data
        videoUrl:
            'https://www.sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
        text: """
    Exercitation id deserunt tempor ad sit consectetur fugiat. Non laboris qui id voluptate ex cillum reprehenderit sunt. Elit laboris ad laborum tempor dolor adipisicing aliqua reprehenderit nisi id incididunt. Cupidatat quis sunt culpa aliqua duis sit eiusmod dolor ut commodo. Amet do sint ut ad incididunt aute occaecat. Exercitation labore voluptate veniam ex ad qui tempor dolor non ea.
    """,
      ),
    );

    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          // If the user has reached the end of the list, load more posts
          _loadMorePosts();
        }
      });
  }

  // Load more posts as user scrolls
  void _loadMorePosts() {
    if (postsToShow < totalPosts) {
      setState(() {
        postsToShow += 8; // Load 8 more posts
      });
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: SafeArea(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap:
                    true, // To make ListView fit inside SingleChildScrollView
                physics:
                    NeverScrollableScrollPhysics(), // Disable internal scrolling
                itemCount: postsToShow, // Display the number of posts to show
                itemBuilder: (context, index) {
                  return posts[index]; // Display each post
                },
              ),
              if (postsToShow <
                  totalPosts) // Show loading indicator if more posts are being loaded
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

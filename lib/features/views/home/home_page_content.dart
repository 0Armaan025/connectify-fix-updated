import 'package:connectify/common/post_widget/post_widget.dart';
import 'package:flutter/material.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  Future<List<Widget>> _fetchPosts() async {
    List<Widget> posts = List.generate(5, (index) => const PostWidget());

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: FutureBuilder<List<Widget>>(
            future: _fetchPosts(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                return Column(
                  children: snapshot.data ?? [],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

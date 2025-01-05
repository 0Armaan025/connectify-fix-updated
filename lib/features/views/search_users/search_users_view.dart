import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/modals/user/user_modal.dart';
import 'package:connectify/features/views/profile/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../controllers/database/user_profile_database_controller.dart';

class SearchUsersView extends StatefulWidget {
  const SearchUsersView({super.key});

  @override
  _SearchUsersViewState createState() => _SearchUsersViewState();
}

class _SearchUsersViewState extends State<SearchUsersView> {
  final List<UserModal> _allUsers = [];
  List<UserModal> _filteredUsers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers(); // Fetch users when the view initializes.
    _searchController.addListener(_filterUsers);
  }

  /// Fetch all users from the database
  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await UserProfileDatabaseController().getAllUsersData();
      setState(() {
        _allUsers.clear();
        _allUsers.addAll(users.map((e) => UserModal.fromMap(e.data)));
        _filteredUsers = _allUsers; // Initially display all users.
        _isLoading = false;
      });
    } catch (e) {
      showSnackBar(context, 'Error fetching users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filter users based on the search query
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers
          .where((user) => user.username.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Find the people you like :)',
                    textStyle: GoogleFonts.montserrat(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.deepPurpleAccent,
                    ),
                    speed: const Duration(milliseconds: 50),
                  ),
                ],
                repeatForever: true,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Users...',
                  prefixIcon:
                      Icon(Icons.search, color: Colors.deepPurpleAccent),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.deepPurpleAccent),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildUserList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build the user list view
  Widget _buildUserList() {
    if (_filteredUsers.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: GoogleFonts.montserrat(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredUsers.length,
      itemBuilder: (context, index) {
        final user = _filteredUsers[index];
        return UserTile(user: user);
      },
    );
  }
}

class UserTile extends StatelessWidget {
  final UserModal user;

  const UserTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        moveScreen(
          context,
          ProfileView(haveNavbar: true),
          isPushReplacement: true,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30, // Smaller avatar
                backgroundImage: NetworkImage(user.profileImageUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${user.followers.length - 1}',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Followers',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

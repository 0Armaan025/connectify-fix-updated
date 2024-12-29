import 'package:connectify/common/buttons/custom_button.dart';
import 'package:connectify/common/utils/utils.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePostScreen extends StatefulWidget {
  const ImagePostScreen({super.key});

  @override
  State<ImagePostScreen> createState() => _ImagePostScreenState();
}

class _ImagePostScreenState extends State<ImagePostScreen> {
  File? _selectedImage;
  final _descriptionController = TextEditingController();
  List<String> _dummyUsers = [
    'armaan025',
    'alice123',
    'johnDoe',
    'alex007',
    'anna',
    'bobbie'
  ];
  List<String> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    String text = _descriptionController.text;
    // Check if the text includes @ and get users starting with that letter
    if (text.contains('@')) {
      String query = text.split('@').last; // Get the part after '@'
      setState(() {
        _filteredUsers = _dummyUsers
            .where((user) => user.startsWith(query)) // Filter based on query
            .toList();
      });
    } else {
      setState(() {
        _filteredUsers.clear(); // Clear suggestions when @ is not found
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(
                  "What's on your mind today?.... 🤔",
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Image Picker
              DottedBorder(
                color: Colors.grey,
                strokeWidth: 1.5,
                dashPattern: const [6],
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                child: Container(
                  alignment: Alignment.center,
                  child: _selectedImage == null
                      ? IconButton(
                          icon: const Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: Colors.deepPurple,
                          ),
                          onPressed: _pickImage,
                        )
                      : GestureDetector(
                          onTap: _pickImage,
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Caption Input with User Mentioning
              TextField(
                controller: _descriptionController,
                maxLength: 100,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add caption(max 100 words)',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(fontSize: 16, color: Colors.black),
                // Use a TextSpan to style user mentions in blue
                inputFormatters: [
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    if (newValue.text.contains('@')) {
                      return newValue.copyWith(
                        text: newValue.text, // Here, you can apply custom logic
                        selection: TextSelection.collapsed(
                            offset: newValue
                                .text.length), // Keeps the cursor at the end
                      );
                    }
                    return newValue;
                  })
                ],
              ),

              // User Dropdown for Mentions
              if (_filteredUsers.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.only(top: 8),
                  height: 150, // Height for the suggestion dropdown
                  child: ListView.builder(
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        trailing: const Icon(Icons.person),
                        title: Text(
                          '@${_filteredUsers[index]}',
                          style: TextStyle(
                              color: Colors.blue), // Blue color for user names
                        ),
                        onTap: () {
                          setState(() {
                            _descriptionController.text =
                                _descriptionController.text.replaceRange(
                                    _descriptionController.text
                                            .lastIndexOf('@') +
                                        1,
                                    _descriptionController.text.length,
                                    _filteredUsers[index]);
                            _filteredUsers
                                .clear(); // Clear suggestions after selection
                          });
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              // Custom Post Button
              CustomButtonWidget(
                text: "Post! :D",
                onPressed: () {
                  // Handle the post action
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

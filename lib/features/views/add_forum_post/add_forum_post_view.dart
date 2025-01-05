import 'package:connectify/common/buttons/custom_button.dart';
import 'package:connectify/common/utils/normal_utils.dart';
import 'package:connectify/features/controllers/database/user_forum_database_controller.dart';
import 'package:connectify/features/modals/forum/forum_modal.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddForumPostView extends StatefulWidget {
  const AddForumPostView({super.key});

  @override
  State<AddForumPostView> createState() => _AddForumPostViewState();
}

class _AddForumPostViewState extends State<AddForumPostView> {
  File? _selectedImage;
  String selectedOption = 'Public';

  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _pickImage({bool isEdit = false}) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });

      if (isEdit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image replaced successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> createForumPost(BuildContext context) async {
    UserForumDatabaseController controller = UserForumDatabaseController();

    if (_descriptionController.text.isEmpty) {
      showSnackBar(context, "Please add a description/question!");
    } else {
      bool isPublic = selectedOption == 'Public' ? true : false;

      bool isImage = false;
      bool isPdf = false;

      if (_selectedImage != null) {
        String extension = _selectedImage!.path.split('.').last;

        if (extension == 'jpg' || extension == 'jpeg' || extension == 'png') {
          isPdf = false;
          isImage = true;
        } else if (extension == 'pdf') {
          isPdf = true;
          isImage = false;
        } else if (extension == 'mov' || extension == 'mp4') {
          isImage = false;
          isPdf = false;
        }
      }

      ForumModal modal = ForumModal(
          forumID: '',
          uuid: '',
          description: _descriptionController.text,
          upvotes: [""],
          mediaUrl: "",
          forumComments: [""],
          isPublic: isPublic,
          createdAt: "");

      // if(_selectedImage!=null) {
      try {
        controller.createForumPost(
            context, modal, _selectedImage, isImage, isPdf);
        print('Forum post created successfully');
      } catch (e) {
        print('Error creating forum post: $e');
        showSnackBar(context, 'Error: $e');
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: buildAppBar(context),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Center(
                  child: DottedBorder(
                    color: Colors.grey,
                    strokeWidth: 1.5,
                    dashPattern: const [6],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(10),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _selectedImage == null
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: Colors.deepPurple,
                                  ),
                                  onPressed: _pickImage,
                                )
                              : const SizedBox.shrink(),
                          _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  width: double.infinity,
                                  height: size.height * 0.34,
                                  fit: BoxFit.fill,
                                )
                              : const Text(
                                  'No image selected',
                                  style: TextStyle(color: Colors.grey),
                                ),
                          const SizedBox(height: 4),
                          _selectedImage != null
                              ? Container(
                                  width: double.infinity,
                                  alignment: Alignment.centerRight,
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.lightBlue,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                      ),
                                      onPressed: () => _pickImage(isEdit: true),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(left: 12),
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Media is optional, but description/question is not :)\n(-Armaan)",
                  style: GoogleFonts.poppins(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 5, // Makes it textarea-like
                  decoration: InputDecoration(
                    hintText: 'Add description',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Visibility',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  value: 'Public', // Default value
                  items: ['Public', 'Private(only search by forum id)']
                      .map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    // Handle the value change
                    print('Selected: $newValue');
                    setState(() {
                      selectedOption = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomButtonWidget(
                text: "Post...",
                onPressed: () {
                  createForumPost(context);
                },
              ),
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

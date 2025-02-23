import 'package:flutter/material.dart';
import 'post_create_c.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final CreatePostController postController = CreatePostController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Post")),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Post Title"),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description"),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    buildFilterDropdown("Select Area", postController.areas, (value) {
                      setState(() => postController.selectedArea = value);
                    }),
                    buildFilterDropdown("Select Class", postController.grades, (value) {
                      setState(() => postController.selectedGrade = value);
                    }),
                    buildFilterDropdown("Select Subject", postController.subjects, (value) {
                      setState(() => postController.selectedSubject = value);
                    }),
                    buildFilterDropdown("Select Gender", postController.genders, (value) {
                      setState(() => postController.selectedGender = value);
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => postController.createPost(
                titleController.text,
                descriptionController.text,
                context,
              ),
              child: Text("Create Post"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildFilterDropdown(String hint, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration.collapsed(hintText: ''),
        hint: Text(hint),
        items: options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

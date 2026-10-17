// Updated create.dart with black padded input sections
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateContentPage extends StatefulWidget {
  const CreateContentPage({super.key});

  @override
  State<CreateContentPage> createState() => _CreateContentPageState();
}

class _CreateContentPageState extends State<CreateContentPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _metadataController = TextEditingController();
  final _customHobbyController = TextEditingController();
  final _customTypeController = TextEditingController();

  final List<String> hobbyOptions = [
    'Cars',
    'Music',
    'Running',
    'Traveling',
    'Reading',
    'Swimming',
    'Cycling',
    'Writing',
  ];
  final List<String> typeOptions = ['challenge', 'recommendation', 'tip'];

  String? _selectedHobby;
  String? _selectedType;
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Image pick error: $e");
    }
  }

  Future<void> _uploadContent() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final id = const Uuid().v4();

      final ref = FirebaseStorage.instance
          .ref()
          .child('hobby_images')
          .child('$id.jpg');

      await ref.putFile(_selectedImage!);
      final imageUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('hobbyContent').doc(id).set({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': _selectedType == 'Other'
            ? _customTypeController.text.trim()
            : _selectedType,
        'hobby': _selectedHobby == 'Other'
            ? _customHobbyController.text.trim()
            : _selectedHobby,
        'imageUrl': imageUrl,
        'metadata': _metadataController.text.trim().isNotEmpty
            ? {
                'tags': _metadataController.text
                    .trim()
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
              }
            : {},
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'likeCount': 0,
      });

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Upload failed: $e");
    }

    setState(() => _isUploading = false);
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _wrapInput({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Create Hobby Content',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[300],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                      image: _selectedImage != null
                          ? DecorationImage(
                              image: FileImage(_selectedImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _selectedImage == null
                        ? const Center(
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 40,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                _wrapInput(
                  child: DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select Hobby'),
                    items: [...hobbyOptions, 'Other']
                        .map(
                          (hobby) => DropdownMenuItem(
                            value: hobby,
                            child: Text(hobby),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedHobby = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ),
                if (_selectedHobby == 'Other')
                  _wrapInput(
                    child: TextFormField(
                      controller: _customHobbyController,
                      decoration: _inputDecoration("Enter custom hobby name"),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                _wrapInput(
                  child: DropdownButtonFormField<String>(
                    decoration: _inputDecoration('Select Content Type'),
                    items: [...typeOptions, 'Other']
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => _selectedType = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ),
                if (_selectedType == 'Other')
                  _wrapInput(
                    child: TextFormField(
                      controller: _customTypeController,
                      decoration: _inputDecoration("Enter custom content type"),
                      validator: (value) => value!.isEmpty ? 'Required' : null,
                    ),
                  ),
                _wrapInput(
                  child: TextFormField(
                    controller: _titleController,
                    decoration: _inputDecoration("Title"),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
                _wrapInput(
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: _inputDecoration("Description"),
                    maxLines: 4,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                ),
                _wrapInput(
                  child: TextFormField(
                    controller: _metadataController,
                    decoration: _inputDecoration(
                      "Hashtags or metadata (optional)",
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isUploading
                      ? null
                      : (_formKey.currentState?.validate() == true &&
                            _selectedImage != null)
                      ? _uploadContent
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Upload',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

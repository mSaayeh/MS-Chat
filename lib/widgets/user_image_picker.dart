import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPickImage});

  final void Function(File file) onPickImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;

  Future<XFile?> _getImage() async {
    bool? pickFromGallery;
    await showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              pickFromGallery = false;
              Navigator.pop(context);
            },
            child: const Text('Camera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              pickFromGallery = true;
              Navigator.pop(context);
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
    if (pickFromGallery == null) {
      throw Exception();
    }
    return ImagePicker().pickImage(
      source: pickFromGallery! ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 80,
      maxWidth: 300,
      preferredCameraDevice: CameraDevice.front,
    );
  }

  void _pickImage() async {
    try {
      final image = await _getImage();
      if (image == null) {
        return;
      }

      setState(() {
        _pickedImage = File(image.path);
      });
      widget.onPickImage(_pickedImage!);
    } catch (e) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,
            foregroundImage:
                _pickedImage != null ? FileImage(_pickedImage!) : null,
          ),
          if (_pickedImage == null)
            const Icon(
              Icons.image,
              size: 40,
            )
        ],
      ),
    );
  }
}
